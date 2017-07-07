package com.technology.oracle.scheduler.interval.client;
 
import com.google.gwt.core.client.GWT;
import com.technology.oracle.scheduler.interval.shared.IntervalConstant;
import com.technology.oracle.scheduler.interval.shared.text.IntervalText;
 
public class IntervalClientConstant extends IntervalConstant {
 
  public static IntervalText intervalText = (IntervalText) GWT.create(IntervalText.class);
}
