package com.technology.oracle.optionasria.option.server.ejb;
 
import com.technology.jep.jepria.shared.field.option.JepOption;
import com.technology.jep.jepria.shared.exceptions.ApplicationException;
import java.util.List;

import javax.naming.NamingException;

import com.technology.jep.jepria.server.ejb.JepDataStandard;
 
public interface Option extends JepDataStandard {
	List<JepOption> getDataSource() throws ApplicationException, NamingException;
	List<JepOption> getModule(String dataSource) throws ApplicationException;
	List<JepOption> getObjectType(String dataSource) throws ApplicationException;
	List<JepOption> getValueType(String dataSource) throws ApplicationException;
}
