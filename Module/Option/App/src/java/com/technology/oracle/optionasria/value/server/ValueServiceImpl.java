package com.technology.oracle.optionasria.value.server;
 
import java.util.List;

import com.technology.jep.jepria.server.ejb.JepDataStandard;
import com.technology.jep.jepria.server.service.JepDataServiceServlet;
import com.technology.jep.jepria.server.util.JepServerUtil;
import com.technology.jep.jepria.shared.exceptions.ApplicationException;
import com.technology.jep.jepria.shared.field.option.JepOption;
import com.technology.oracle.optionasria.main.server.OptionAsRiaServiceImpl;
import com.technology.oracle.optionasria.option.server.ejb.Option;
import com.technology.oracle.optionasria.value.server.ejb.Value;
import com.technology.oracle.optionasria.value.shared.record.ValueRecordDefinition;
import com.technology.oracle.optionasria.value.shared.service.ValueService;

import static com.technology.oracle.optionasria.value.server.ValueServerConstant.BEAN_JNDI_NAME;

import com.google.gwt.user.client.rpc.RemoteServiceRelativePath;
 
@RemoteServiceRelativePath("ValueService")
public class ValueServiceImpl extends OptionAsRiaServiceImpl implements ValueService  {
 
	private static final long serialVersionUID = 1L;
 
	public ValueServiceImpl() {
		super(ValueRecordDefinition.instance, BEAN_JNDI_NAME);
	}
	
	public List<JepOption> getOperator(String dataSource, String operatorName, Integer maxRowCount) throws ApplicationException {
		List<JepOption> result = null;
		try {
			JepDataStandard ejb = (JepDataStandard) JepServerUtil.ejbLookup(ejbName);
			result = ((Value) ejb).getOperator(dataSource, operatorName, maxRowCount);
		} catch (Throwable th) {
			throw new ApplicationException(th.getLocalizedMessage(), th);
		}
		return result;
	}
}
