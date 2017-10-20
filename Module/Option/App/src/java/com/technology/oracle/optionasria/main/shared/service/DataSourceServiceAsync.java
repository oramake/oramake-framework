package com.technology.oracle.optionasria.main.shared.service;

import com.google.gwt.user.client.rpc.AsyncCallback;
import com.technology.jep.jepria.shared.record.JepRecord;
import com.technology.jep.jepria.shared.service.data.JepDataServiceAsync;

public interface DataSourceServiceAsync extends JepDataServiceAsync {
  void getDataSource(AsyncCallback<JepRecord> callback);
  void setCurrentDataSource(String dataSource, AsyncCallback<Void> callback);
}
