package com.technology.oracle.scheduler.main.server.ejb;
 
import com.technology.jep.jepria.shared.field.option.JepOption;
import com.technology.jep.jepria.shared.exceptions.ApplicationException;
import java.util.List;

import javax.naming.NamingException;

import com.technology.jep.jepria.server.ejb.JepDataStandard;
 
public interface Scheduler extends JepDataStandard {
	List<JepOption> getDataSource() throws ApplicationException, NamingException;
	
	List<JepOption> getModule(String dataSource) throws ApplicationException;
	List<JepOption> getPrivilege(String dataSource) throws ApplicationException;
	List<JepOption> getRole(String dataSource, String roleName) throws ApplicationException;
}
