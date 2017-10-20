package com.technology.oracle.optionasria.option.server.dao;
 
import com.technology.jep.jepria.shared.field.option.JepOption;
import com.technology.jep.jepria.server.dao.JepDataStandard;
import com.technology.jep.jepria.shared.exceptions.ApplicationException;
import java.util.List;

import javax.naming.NamingException;

 
public interface Option extends JepDataStandard {
	List<JepOption> getModule() throws ApplicationException;
	List<JepOption> getObjectType() throws ApplicationException;
	List<JepOption> getValueType() throws ApplicationException;
}
