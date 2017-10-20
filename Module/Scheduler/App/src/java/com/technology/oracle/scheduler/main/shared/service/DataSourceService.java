package com.technology.oracle.scheduler.main.shared.service;
 
import com.technology.jep.jepria.shared.exceptions.ApplicationException;
import com.technology.jep.jepria.shared.record.JepRecord;
import com.technology.jep.jepria.shared.service.data.JepDataService;
 
public interface DataSourceService extends JepDataService {
  JepRecord getDataSource() throws ApplicationException;
  void setCurrentDataSource(String dataSource) throws ApplicationException;
}
