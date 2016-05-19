package com.technology.oracle.optionasria.option.shared.service;
 
import com.technology.jep.jepria.shared.field.option.JepOption;
import com.google.gwt.user.client.rpc.AsyncCallback;
import java.util.List;
import com.technology.jep.jepria.shared.service.data.JepDataServiceAsync;
 
public interface OptionServiceAsync extends JepDataServiceAsync {
	void getDataSource(AsyncCallback<List<JepOption>> callback);
	void getModule(String dataSource, AsyncCallback<List<JepOption>> callback);
	void getObjectType(String dataSource, AsyncCallback<List<JepOption>> callback);
	void getValueType(String dataSource, AsyncCallback<List<JepOption>> callback);
}
