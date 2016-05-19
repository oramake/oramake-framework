package com.technology.oracle.optionasria.option.shared.service;
 
import com.google.gwt.user.client.rpc.RemoteServiceRelativePath;
import com.technology.jep.jepria.shared.field.option.JepOption;
import com.technology.jep.jepria.shared.exceptions.ApplicationException;
import java.util.List;
import com.technology.jep.jepria.shared.service.data.JepDataService;
 
@RemoteServiceRelativePath("OptionService")
public interface OptionService extends JepDataService {
	List<JepOption> getDataSource() throws ApplicationException;
	List<JepOption> getModule(String dataSource) throws ApplicationException;
	List<JepOption> getObjectType(String dataSource) throws ApplicationException;
	List<JepOption> getValueType(String dataSource) throws ApplicationException;
}
