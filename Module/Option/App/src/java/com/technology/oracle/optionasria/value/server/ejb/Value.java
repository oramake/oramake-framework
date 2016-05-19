package com.technology.oracle.optionasria.value.server.ejb;
 
import java.util.List;

import com.technology.jep.jepria.server.ejb.JepDataStandard;
import com.technology.jep.jepria.shared.exceptions.ApplicationException;
import com.technology.jep.jepria.shared.field.option.JepOption;
 
public interface Value extends JepDataStandard {

	List<JepOption> getOperator(String dataSource, String operatorName, Integer maxRowCount) throws ApplicationException;
}
