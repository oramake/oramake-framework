package com.technology.oracle.optionasria.value.server;
 
import java.util.List;

import com.google.gwt.user.client.rpc.RemoteServiceRelativePath;
import com.technology.jep.jepria.shared.exceptions.ApplicationException;
import com.technology.jep.jepria.shared.field.option.JepOption;
import com.technology.oracle.optionasria.main.server.OptionAsRiaServiceImpl;
import com.technology.oracle.optionasria.value.server.dao.Value;
import com.technology.oracle.optionasria.value.server.dao.ValueDao;
import com.technology.oracle.optionasria.value.shared.record.ValueRecordDefinition;
import com.technology.oracle.optionasria.value.shared.service.ValueService;
 
@RemoteServiceRelativePath("ValueService")
public class ValueServiceImpl extends OptionAsRiaServiceImpl<Value> implements ValueService  {
 
	private static final long serialVersionUID = 1L;
 
	public ValueServiceImpl() {
		super(ValueRecordDefinition.instance, new ValueDao());
	}
	
	public List<JepOption> getOperator(String dataSource, String operatorName, Integer maxRowCount) throws ApplicationException {
		List<JepOption> result = null;
		try {
			result = getProxyDao(dataSource).getOperator(dataSource, operatorName, maxRowCount);
		} catch (Throwable th) {
			throw new ApplicationException(th.getLocalizedMessage(), th);
		}
		return result;
	}
}
