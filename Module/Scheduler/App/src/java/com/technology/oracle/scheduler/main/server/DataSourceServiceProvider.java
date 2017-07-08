package com.technology.oracle.scheduler.main.server;

import static com.technology.oracle.scheduler.main.shared.SchedulerConstant.DATA_SOURCE_LIST;

import java.lang.reflect.InvocationTargetException;
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

import com.technology.jep.jepria.server.DaoProvider;
import com.technology.jep.jepria.server.ServerFactory;
import com.technology.jep.jepria.server.dao.JepDataStandard;
import com.technology.jep.jepria.server.service.JepDataServiceServlet;
import com.technology.jep.jepria.shared.exceptions.ApplicationException;
import com.technology.jep.jepria.shared.field.option.JepOption;
import com.technology.jep.jepria.shared.load.FindConfig;
import com.technology.jep.jepria.shared.load.PagingConfig;
import com.technology.jep.jepria.shared.load.PagingResult;
import com.technology.jep.jepria.shared.record.JepRecord;
import com.technology.jep.jepria.shared.record.JepRecordDefinition;
import com.technology.jep.jepria.shared.service.data.JepDataService;

public class DataSourceServiceProvider<S extends JepDataService, D extends JepDataStandard> extends JepDataServiceServlet<JepDataStandard> {

  private Class<? extends JepDataServiceServlet<D>> serviceClass;
  
  private JepDataStandard dao;

  protected DataSourceServiceProvider(JepRecordDefinition recordDefinition, Class<? extends JepDataServiceServlet<D>> serviceClass,
      D dao) {
    super(recordDefinition, null);
    
    this.dao = dao;
    this.serviceClass = serviceClass;
  }

  private static final long serialVersionUID = 1L;

  private Map<String, S> proxyServices = new ConcurrentHashMap<>();
  
  @SuppressWarnings("unchecked")
  public S getService() throws ApplicationException {
    
    String dataSource = getCurrentDataSource();
    
    S proxyService = proxyServices.get(dataSource);
    
    if(proxyService == null) {
      try {
        DaoProvider<?> serverFactory = ServerFactory.class.getConstructor(dao.getClass(), String.class).newInstance(dao, dataSource);
        JepDataServiceServlet<D> proxyServiceImpl = serviceClass.getConstructor(JepRecordDefinition.class, DaoProvider.class).
            newInstance(recordDefinition, serverFactory);
        proxyServiceImpl.init();

        proxyService = (S) proxyServiceImpl;
        
      } catch (InstantiationException | IllegalAccessException | IllegalArgumentException | InvocationTargetException
          | NoSuchMethodException | SecurityException | ServletException e) {
        throw new ApplicationException("Error while initialize service by current data source!", e);
      }

      proxyServices.put(dataSource, proxyService);
    }
    
    return proxyService;
  }

  /**
   * Обрабатывает data sources
   */
  @Override
  public void init() throws ServletException {
    initDataSourceList();
  }

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

  public void setCurrentDataSource(String dataSource) throws ApplicationException {
    if(this.dataSourceNames.contains(dataSource)) {
      HttpSession session = getThreadLocalRequest().getSession();
      session.setAttribute(CURRENT_DATA_SOURCE_ATTRIBUTE, dataSource);
    }
  }
  
  public static final String CURRENT_DATA_SOURCE_ATTRIBUTE = "SCHEDULER_DATA_SOURCE";
  
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
   * Перед вызовом стандартного метода определяется service c подходящим dao под текущий data source. <br/>
   * По аналогии работают другие стандартные методы.
   */
  @Override
  public JepRecord update(FindConfig updateConfig) throws ApplicationException {
    return getService().update(updateConfig);
  }
  
  @Override
  public PagingResult<JepRecord> find(PagingConfig pagingConfig) throws ApplicationException {
    return getService().find(pagingConfig);
  }
  
  @Override
  public JepRecord create(FindConfig createConfig) throws ApplicationException {
    return getService().create(createConfig);
  }
  
  @Override
  public void delete(FindConfig deleteConfig) throws ApplicationException {
    getService().delete(deleteConfig);
  }
}
