package com.technology.oracle.scheduler.option.client.history.scope;

import com.technology.jep.jepria.shared.record.JepRecord;

public class OptionScope {

    private Boolean isEditValue = false;
    private JepRecord curruntValueOption;
    
    public static OptionScope instance = new OptionScope();
    
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
    
}