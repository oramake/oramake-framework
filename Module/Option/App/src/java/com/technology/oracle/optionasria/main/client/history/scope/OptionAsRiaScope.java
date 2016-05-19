package com.technology.oracle.optionasria.main.client.history.scope;

import com.technology.jep.jepria.shared.field.option.JepOption;
import com.technology.jep.jepria.shared.record.JepRecord;

public class OptionAsRiaScope {

	  private Boolean isEditValue = false;
	  private JepOption dataSource;
	  private JepRecord curruntValueOption;
	  
	  public static OptionAsRiaScope instance = new OptionAsRiaScope();
	  
	  public void setCurruntValueOption(JepRecord curruntValueOption){
		  this.curruntValueOption= curruntValueOption;
	  }
	  
	  public JepRecord getCurruntValueOption(){
		  return curruntValueOption;
	  }
	  
	  public Boolean getIsEditValue() {
	    return isEditValue;
	  }
	  
	  public void setIsEditValue(Boolean isEditValue) {
	    this.isEditValue = isEditValue;
	  }
	  
	  public JepOption getDataSource() {
	    return dataSource;
	  }
	  
	  public void setDataSource(JepOption dataSource) {
	    this.dataSource = dataSource;
	  }
}
