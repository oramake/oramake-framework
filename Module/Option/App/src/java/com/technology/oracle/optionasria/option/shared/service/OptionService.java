package com.technology.oracle.optionasria.option.shared.service;

import java.util.List;

import com.google.gwt.user.client.rpc.RemoteServiceRelativePath;
import com.technology.jep.jepria.shared.exceptions.ApplicationException;
import com.technology.jep.jepria.shared.field.option.JepOption;
import com.technology.oracle.optionasria.main.shared.service.OptionAsRiaService;

@RemoteServiceRelativePath("OptionService")
public interface OptionService extends OptionAsRiaService {
	List<JepOption> getModule(String currentDataSource) throws ApplicationException;
	List<JepOption> getObjectType(String currentDataSource) throws ApplicationException;
	List<JepOption> getValueType(String currentDataSource) throws ApplicationException;
}
