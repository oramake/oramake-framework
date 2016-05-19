package com.technology.oracle.optionasria.value.shared.service;
 
import java.util.List;

import com.google.gwt.user.client.rpc.RemoteServiceRelativePath;
import com.technology.jep.jepria.shared.exceptions.ApplicationException;
import com.technology.jep.jepria.shared.field.option.JepOption;
import com.technology.jep.jepria.shared.service.data.JepDataService;
 
@RemoteServiceRelativePath("ValueService")
public interface ValueService extends JepDataService {
	List<JepOption> getOperator(String dataSource, String operatorName, Integer maxRowCount) throws ApplicationException;
}
