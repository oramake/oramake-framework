package com.technology.oracle.optionasria.value.shared.service;
 
import java.util.List;

import com.google.gwt.user.client.rpc.RemoteServiceRelativePath;
import com.technology.jep.jepria.shared.exceptions.ApplicationException;
import com.technology.jep.jepria.shared.field.option.JepOption;
import com.technology.oracle.optionasria.main.shared.service.OptionAsRiaService;
 
@RemoteServiceRelativePath("ValueService")
public interface ValueService extends OptionAsRiaService {
	List<JepOption> getOperator(String dataSource, String operatorName, Integer maxRowCount) throws ApplicationException;
}
