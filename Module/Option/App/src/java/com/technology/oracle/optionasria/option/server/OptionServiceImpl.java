package com.technology.oracle.optionasria.option.server;
 
import java.util.List;

import com.google.gwt.user.client.rpc.RemoteServiceRelativePath;
import com.technology.jep.jepria.shared.exceptions.ApplicationException;
import com.technology.jep.jepria.shared.field.option.JepOption;
import com.technology.oracle.optionasria.option.server.dao.Option;
import com.technology.oracle.optionasria.option.server.dao.OptionDao;
import com.technology.oracle.optionasria.option.shared.record.OptionRecordDefinition;
import com.technology.oracle.optionasria.option.shared.service.OptionService;
import com.technology.oracle.optionasria.main.server.OptionAsRiaServiceImpl;
 
@RemoteServiceRelativePath("OptionService")
public class OptionServiceImpl extends OptionAsRiaServiceImpl<Option> implements OptionService  {
 
	private static final long serialVersionUID = 1L;
 
	public OptionServiceImpl() {
		super(OptionRecordDefinition.instance, new OptionDao());
	}
 
	public List<JepOption> getModule() throws ApplicationException {
		List<JepOption> result = null;
		try {
			result = getProxyDao().getModule();
		} catch (Throwable th) {
			throw new ApplicationException(th.getLocalizedMessage(), th);
		}
		return result;
	}
 
	public List<JepOption> getObjectType() throws ApplicationException {
		List<JepOption> result = null;
		try {
			result = getProxyDao().getObjectType();
		} catch (Throwable th) {
			throw new ApplicationException(th.getLocalizedMessage(), th);
		}
		return result;
	}
 
	public List<JepOption> getValueType() throws ApplicationException {
		List<JepOption> result = null;
		try {
			result = getProxyDao().getValueType();
		} catch (Throwable th) {
			throw new ApplicationException(th.getLocalizedMessage(), th);
		}
		return result;
	}
}
