package com.technology.oracle.scheduler.main.client.history.scope;

import com.google.gwt.user.client.Window.Location;
import com.technology.jep.jepria.shared.field.option.JepOption;

public class SchedulerScope {
	
	private JepOption dataSource;
	String prevModuleId = null;
	String currentModuleId = null;

	public static SchedulerScope instance = new SchedulerScope();
	
	public JepOption getDataSource() {
		return dataSource;
	}
	
	public void setDataSource(JepOption dataSource) {
		this.dataSource = dataSource;
	}
	
	public String getPrevModuleId() {
		return prevModuleId;
	}
	
	public void setPrevModuleId(String prevModuleId) {
		this.prevModuleId = prevModuleId;
	}

	public String getCurrentModuleId() {
		return currentModuleId;
	}

	public void setCurrentModuleId(String currentModuleId) {
		this.currentModuleId = currentModuleId;
	}
}
