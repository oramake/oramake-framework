package com.technology.oracle.optionasria.value.shared.service;
 
import java.util.List;

import com.google.gwt.user.client.rpc.AsyncCallback;
import com.technology.jep.jepria.shared.field.option.JepOption;
import com.technology.jep.jepria.shared.service.data.JepDataServiceAsync;
 
public interface ValueServiceAsync extends JepDataServiceAsync {

	void getOperator(String dataSource, String operatorName, Integer maxRowCount, AsyncCallback<List<JepOption>> callback);
}
