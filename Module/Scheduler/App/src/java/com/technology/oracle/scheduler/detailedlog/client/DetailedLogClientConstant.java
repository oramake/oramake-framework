package com.technology.oracle.scheduler.detailedlog.client;
 
import com.google.gwt.core.client.GWT;
import com.technology.oracle.scheduler.detailedlog.shared.DetailedLogConstant;
import com.technology.oracle.scheduler.detailedlog.shared.text.DetailedLogText;
 
public class DetailedLogClientConstant extends DetailedLogConstant {
 
  public static DetailedLogText detailedLogText = (DetailedLogText) GWT.create(DetailedLogText.class);
}
