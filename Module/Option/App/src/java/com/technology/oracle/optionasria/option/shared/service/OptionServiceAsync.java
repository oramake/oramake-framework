package com.technology.oracle.optionasria.option.shared.service;
 
import java.util.List;

import com.google.gwt.user.client.rpc.AsyncCallback;
import com.technology.jep.jepria.shared.field.option.JepOption;
import com.technology.oracle.optionasria.main.shared.service.OptionAsRiaServiceAsync;
 
public interface OptionServiceAsync extends OptionAsRiaServiceAsync {
	//void getDataSource(AsyncCallback<List<JepOption>> callback);
	void getModule(String currentDataSource, AsyncCallback<List<JepOption>> callback);
	void getObjectType(String currentDataSource, AsyncCallback<List<JepOption>> callback);
	void getValueType(String currentDataSource, AsyncCallback<List<JepOption>> callback);
}
