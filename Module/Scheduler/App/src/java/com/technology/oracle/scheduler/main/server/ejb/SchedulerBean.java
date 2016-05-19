package com.technology.oracle.scheduler.main.server.ejb;
 
import static com.technology.oracle.scheduler.batch.server.BatchServerConstant.PREFIX_DATA_SOURCE_JNDI_NAME;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;

import javax.ejb.Local;
import javax.ejb.Remote;
import javax.ejb.Stateless;
import javax.naming.InitialContext;
import javax.naming.NameClassPair;
import javax.naming.NamingEnumeration;
import javax.naming.NamingException;

import oracle.j2ee.ejb.StatelessDeployment;

import com.technology.jep.jepria.server.dao.DaoSupport;
import com.technology.jep.jepria.server.dao.ResultSetMapper;
import com.technology.jep.jepria.server.ejb.JepDataBean;
import com.technology.jep.jepria.shared.exceptions.ApplicationException;
import com.technology.jep.jepria.shared.field.option.JepOption;
import com.technology.jep.jepria.shared.record.JepRecord;
import com.technology.jep.jepria.shared.util.Mutable;
import com.technology.oracle.scheduler.main.shared.field.DataSourceOptions;
import com.technology.oracle.scheduler.main.shared.field.ModuleOptions;
import com.technology.oracle.scheduler.main.shared.field.PrivilegeOptions;
import com.technology.oracle.scheduler.main.shared.field.RoleOptions;
 
@Local( { SchedulerLocal.class })
@Remote( { SchedulerRemote.class })
@StatelessDeployment
@Stateless
public class SchedulerBean extends JepDataBean implements Scheduler {
 
	public SchedulerBean(String dataSource, String resource) {
		super(dataSource, resource);
	}
	
	public static Boolean getBoolean(ResultSet rs, String columnName) throws SQLException {
		boolean result = rs.getBoolean(columnName);
		
		if (rs.wasNull()) {
			return null;
		} else {
			return result;
		}
	}
	

	public List<JepOption> getDataSource() throws ApplicationException, NamingException {
		 
		List<JepOption> dataSourceList = new ArrayList<JepOption>();
		
		try{
			InitialContext ic = new InitialContext();		
			NamingEnumeration<NameClassPair> nameEnum = ic.list(DataSourceOptions.DATA_SOURCE);
			
			while (nameEnum.hasMoreElements()) {
				NameClassPair nameClassPair = nameEnum.nextElement();
				dataSourceList.add(new JepOption(nameClassPair.getName(), nameClassPair.getName()));
			}
			
		}
		catch(Throwable e){
			throw new ApplicationException("No one datasource!", e);
		}
		
		Collections.sort(dataSourceList, new Comparator<JepOption>() {
	        @Override
			public int compare(JepOption m1, JepOption m2) {
	        	
	        	return m1.getName().compareTo(m2.getName());
			}
	    });
		
		return dataSourceList;
	}

	@Override
	public List<JepRecord> find(JepRecord templateRecord,
			Mutable<Boolean> autoRefreshFlag, Integer maxRowCount,
			Integer operatorId) throws ApplicationException {
		throw new UnsupportedOperationException();
	}

	@Override
	public Object create(JepRecord record, Integer operatorId)
			throws ApplicationException {

		throw new UnsupportedOperationException();
	}

	@Override
	public void update(JepRecord record, Integer operatorId)
			throws ApplicationException {

		throw new UnsupportedOperationException();		
	}

	@Override
	public void delete(JepRecord record, Integer operatorId)
			throws ApplicationException {

		throw new UnsupportedOperationException();		
	}
 

	public List<JepOption> getPrivilege(String dataSource) throws ApplicationException {
		String sqlQuery = 
			" begin " 
			+ " ? := pkg_Scheduler.getPrivilege;" 
			+ " end;";
 
		return DaoSupport.find(
				sqlQuery,
				sessionContext,
				PREFIX_DATA_SOURCE_JNDI_NAME+dataSource,
				resourceBundleName,
				new ResultSetMapper<JepOption>() {
					public void map(ResultSet rs, JepOption dto) throws SQLException {
						dto.setValue(rs.getString(PrivilegeOptions.PRIVILEGE_CODE));
						dto.setName(rs.getString(PrivilegeOptions.PRIVILEGE_NAME));
					}
				},
				JepOption.class
		); 
		
	}
 
	public List<JepOption> getRole(String dataSource, String roleName) throws ApplicationException {
		String sqlQuery = 
			" begin " 
			+ " ? := pkg_Scheduler.getRole(" 
					+ "searchStr => ? " 
				+");" 
			+ " end;";
 
		return DaoSupport.find(
				sqlQuery,
				sessionContext,
				PREFIX_DATA_SOURCE_JNDI_NAME+dataSource,
				resourceBundleName,
				new ResultSetMapper<JepOption>() {
					public void map(ResultSet rs, JepOption dto) throws SQLException {
						dto.setValue(getInteger(rs, RoleOptions.ROLE_ID));
						dto.setName(rs.getString(RoleOptions.ROLE_NAME));
					}
				},
				JepOption.class
				, roleName
		);
	}
	
	 
	public List<JepOption> getModule(String dataSource) throws ApplicationException {
		String sqlQuery = 
			" begin " 
			+ " ? := pkg_Scheduler.findModule;" 
			+ " end;";
 
		
		return DaoSupport.find(
				sqlQuery,
				sessionContext,
				PREFIX_DATA_SOURCE_JNDI_NAME+dataSource,
				resourceBundleName,
				new ResultSetMapper<JepOption>() {
					public void map(ResultSet rs, JepOption dto) throws SQLException {
						dto.setValue(getInteger(rs, ModuleOptions.MODULE_ID));
						dto.setName(rs.getString(ModuleOptions.MODULE_NAME));
					}
				},
				JepOption.class); 
	}
}
