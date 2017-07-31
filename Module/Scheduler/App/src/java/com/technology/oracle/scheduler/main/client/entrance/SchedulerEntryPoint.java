package com.technology.oracle.scheduler.main.client.entrance;
 
import com.technology.jep.jepria.client.entrance.JepEntryPoint;
import com.technology.oracle.scheduler.main.client.SchedulerClientFactoryImpl;
 
public class SchedulerEntryPoint extends JepEntryPoint {
 
  SchedulerEntryPoint() {
    super(SchedulerClientFactoryImpl.getInstance());
  }
}
