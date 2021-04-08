package com.technology.oracle.optionasria.main.server;

import static com.technology.oracle.optionasria.main.shared.OptionAsRiaConstant.CURRENT_DATA_SOURCE;
import static com.technology.oracle.optionasria.main.shared.OptionAsRiaConstant.DATA_SOURCE_LIST;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

import javax.naming.InitialContext;
import javax.naming.NameClassPair;
import javax.naming.NamingEnumeration;
import javax.naming.NamingException;
import javax.servlet.ServletException;
import javax.servlet.http.HttpSession;

import com.technology.jep.jepria.server.dao.JepDataStandard;
import com.technology.jep.jepria.server.dao.transaction.TransactionFactory;
import com.technology.jep.jepria.server.service.JepDataServiceServlet;
import com.technology.jep.jepria.server.util.JepServerUtil;
import com.technology.jep.jepria.shared.exceptions.ApplicationException;
import com.technology.jep.jepria.shared.field.option.JepOption;
import com.technology.jep.jepria.shared.load.FindConfig;
import com.technology.jep.jepria.shared.load.PagingConfig;
import com.technology.jep.jepria.shared.load.PagingResult;
import com.technology.jep.jepria.shared.record.JepRecord;
import com.technology.jep.jepria.shared.record.JepRecordDefinition;
import com.technology.oracle.optionasria.main.shared.service.DataSourceService;

public class DataSourceServiceImpl<D extends JepDataStandard> extends JepDataServiceServlet<D> implements DataSourceService {
  
  private static final long serialVersionUID = 1L;
  
  private Map<String, D> proxiesDao = new ConcurrentHashMap<>();
  
  protected D getProxyDao(String currentDataSource) throws ApplicationException {

//    String dataSource = getCurrentDataSource();
    
    D proxyDao = proxiesDao.get(currentDataSource);
    
    if(proxyDao == null) {
      proxyDao = TransactionFactory.createProxy(dao, currentDataSource, moduleName);
      proxiesDao.put(currentDataSource, proxyDao);
    }
    
    return proxyDao;
  }
  
  /**
   * Имя текущего модуля.
   */
  private D dao;
  
  /**
   * Имя текущего модуля.
   */
  private String moduleName;
  
  /**
   * Список DataSource. <br/>
   * Инициализируется один раз в init()
   */
  private List<JepOption> dataSourceList = new ArrayList<JepOption>();
  
  /**
   * Список имен (для быстрого поиска)
   */
  private List<String> dataSourceNames = new ArrayList<String>();

  /**
   * Получает текущий DataSource из сессии
   * @return Текущий DataSource
   * @throws ApplicationException если текущий DataSource null
   */
  protected String getCurrentDataSource() throws ApplicationException {
    String currentDataSource = _getCurrentDataSource();
    if(currentDataSource == null) {
      throw new ApplicationException("DataSource not set!", null);
    }
    return currentDataSource;
  }

  /**
   * Получает текущий DataSource из сессии
   * @return Текущий DataSource
   */
  protected String _getCurrentDataSource() {
    HttpSession session = getThreadLocalRequest().getSession();
    String currentDataSource = (String) session.getAttribute(CURRENT_DATA_SOURCE_ATTRIBUTE);
    return currentDataSource;
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public void init() throws ServletException {
    moduleName = JepServerUtil.getModuleName(getServletConfig());
    initDataSourceList();
  }
  
  /**
   * Механизм работы с DAO переопределен, поэтому вместо DaoProvider передается null.
   * @param recordDefinition
   */
  protected DataSourceServiceImpl(JepRecordDefinition recordDefinition, D dao) {
    super(recordDefinition, null);
    this.dao = dao;
  }

  public JepRecord getDataSource() throws ApplicationException {
    JepRecord result = new JepRecord();
    result.set(DATA_SOURCE_LIST, dataSourceList);
//    TODO: возвращать значение по умолчанию (из сессии). Аккуратно обработать переходы между client-server (String и JepOption)
//    Вызвать нужные события на клиенте
//    result.set(DATA_SOURCE_DEFAULT, _getCurrentDataSource());
    return result;
  }
  
  private void initDataSourceList() throws ServletException {

    String dataSourceSuffix = "jdbc/";
    
    try {
      InitialContext ic = new InitialContext();
      NamingEnumeration<NameClassPair> nameEnum = ic.list("java:/comp/env/" + dataSourceSuffix);
      
      while (nameEnum.hasMoreElements()) {
        NameClassPair nameClassPair = nameEnum.nextElement();
        String dataSource = dataSourceSuffix + nameClassPair.getName();
        dataSourceList.add(new JepOption(nameClassPair.getName(), dataSource));
        dataSourceNames.add(dataSource);
      }
    } catch (NamingException e) {
      throw new ServletException("No one datasource!", e);
    }    
    
    Collections.<JepOption>sort(dataSourceList, new Comparator<JepOption>() {
      @Override
      public int compare(JepOption o1, JepOption o2) {
        return o1.getName().compareTo(o2.getName());
      }
    });
  }
  
  /**
   * Перед вызовом стандартного методо подменяем dao. <br/>
   * По аналогии работают другие стандартные методы.
   */
  @Override
  public synchronized JepRecord update(FindConfig updateConfig) throws ApplicationException {
    if(JepOption.<String>getValue(updateConfig.getTemplateRecord().get(CURRENT_DATA_SOURCE)) == null){
      throw new ApplicationException("Не установлен DataSource!", new ApplicationException());
    }else {
      super.dao = getProxyDao(JepOption.<String>getValue(updateConfig.getTemplateRecord().get(CURRENT_DATA_SOURCE)));
      return super.update(updateConfig);
    }
  }

  @Override
  public synchronized PagingResult<JepRecord> find(PagingConfig pagingConfig) throws ApplicationException {
    HttpSession session = getThreadLocalRequest().getSession();
    if(JepOption.<String>getValue(pagingConfig.getTemplateRecord().get(CURRENT_DATA_SOURCE)) != null){
      super.dao = getProxyDao(JepOption.<String>getValue(pagingConfig.getTemplateRecord().get(CURRENT_DATA_SOURCE)));
      return super.find(pagingConfig);
    } else if ((String)session.getAttribute(CURRENT_DATA_SOURCE_ATTRIBUTE) != null){
      super.dao = getProxyDao((String)session.getAttribute(CURRENT_DATA_SOURCE_ATTRIBUTE));
      session.removeAttribute(CURRENT_DATA_SOURCE_ATTRIBUTE);
      return super.find(pagingConfig);
    } else {
      throw new ApplicationException("Не установлен DataSource!", new ApplicationException());
    }
  }

  @Override
  public synchronized JepRecord create(FindConfig createConfig) throws ApplicationException {
    if(JepOption.<String>getValue(createConfig.getTemplateRecord().get(CURRENT_DATA_SOURCE)) == null){
      throw new ApplicationException("Не установлен DataSource!", new ApplicationException());
    }else {
      super.dao = getProxyDao(JepOption.<String>getValue(createConfig.getTemplateRecord().get(CURRENT_DATA_SOURCE)));
//    super.dao = getProxyDao();
      return super.create(createConfig);
    }
  }

  @Override
  public synchronized void delete(FindConfig deleteConfig) throws ApplicationException {
    HttpSession session = getThreadLocalRequest().getSession();
    if(JepOption.<String>getValue(deleteConfig.getTemplateRecord().get(CURRENT_DATA_SOURCE)) != null){
      super.dao = getProxyDao(JepOption.<String>getValue(deleteConfig.getTemplateRecord().get(CURRENT_DATA_SOURCE)));
      super.delete(deleteConfig);
    } else if ((String)session.getAttribute(CURRENT_DATA_SOURCE_ATTRIBUTE) != null){
      super.dao = getProxyDao((String)session.getAttribute(CURRENT_DATA_SOURCE_ATTRIBUTE));
      session.removeAttribute(CURRENT_DATA_SOURCE_ATTRIBUTE);
      super.delete(deleteConfig);
    } else {
      throw new ApplicationException("Не установлен DataSource!", new ApplicationException());
    }

  }

  @Override
  public void setCurrentDataSource(String dataSource) throws ApplicationException {
    if(this.dataSourceNames.contains(dataSource)) {
      HttpSession session = getThreadLocalRequest().getSession();
      session.setAttribute(CURRENT_DATA_SOURCE_ATTRIBUTE, dataSource);
    }
  }
  
  public static final String CURRENT_DATA_SOURCE_ATTRIBUTE = "SCHEDULER_DATA_SOURCE";
}

