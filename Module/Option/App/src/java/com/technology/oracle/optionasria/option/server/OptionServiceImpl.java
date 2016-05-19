package com.technology.oracle.optionasria.option.server;
 
import com.technology.jep.jepria.server.service.JepDataServiceServlet;
import com.technology.jep.jepria.server.util.JepServerUtil;
import com.technology.jep.jepria.shared.field.option.JepOption;
import com.technology.jep.jepria.shared.exceptions.ApplicationException;
import com.technology.jep.jepria.server.ejb.JepDataStandard;
import java.util.List;

import com.technology.oracle.optionasria.option.server.ejb.Option;
import com.technology.oracle.optionasria.option.shared.record.OptionRecordDefinition;
import com.technology.oracle.optionasria.option.shared.service.OptionService;

import static com.technology.oracle.optionasria.option.server.OptionServerConstant.BEAN_JNDI_NAME;

import com.google.gwt.user.client.rpc.RemoteServiceRelativePath;
 
@RemoteServiceRelativePath("OptionService")
public class OptionServiceImpl extends com.technology.oracle.optionasria.main.server.OptionAsRiaServiceImpl implements OptionService  {
 
	private static final long serialVersionUID = 1L;
 
	public OptionServiceImpl() {
		super(OptionRecordDefinition.instance, BEAN_JNDI_NAME);
	}
 
	public List<JepOption> getDataSource() throws ApplicationException {
		List<JepOption> result = null;
		try {
			JepDataStandard ejb = (JepDataStandard) JepServerUtil.ejbLookup(ejbName);
			result = ((Option) ejb).getDataSource();
		} catch (Throwable th) {
			throw new ApplicationException(th.getLocalizedMessage(), th);
		}
		return result;
	}
 
	public List<JepOption> getModule(String dataSource) throws ApplicationException {
		List<JepOption> result = null;
		try {
			JepDataStandard ejb = (JepDataStandard) JepServerUtil.ejbLookup(ejbName);
			result = ((Option) ejb).getModule(dataSource);
		} catch (Throwable th) {
			throw new ApplicationException(th.getLocalizedMessage(), th);
		}
		return result;
	}
 
	public List<JepOption> getObjectType(String dataSource) throws ApplicationException {
		List<JepOption> result = null;
		try {
			JepDataStandard ejb = (JepDataStandard) JepServerUtil.ejbLookup(ejbName);
			result = ((Option) ejb).getObjectType(dataSource);
		} catch (Throwable th) {
			throw new ApplicationException(th.getLocalizedMessage(), th);
		}
		return result;
	}
 
	public List<JepOption> getValueType(String dataSource) throws ApplicationException {
		List<JepOption> result = null;
		try {
			JepDataStandard ejb = (JepDataStandard) JepServerUtil.ejbLookup(ejbName);
			result = ((Option) ejb).getValueType(dataSource);
		} catch (Throwable th) {
			throw new ApplicationException(th.getLocalizedMessage(), th);
		}
		return result;
	}
}
