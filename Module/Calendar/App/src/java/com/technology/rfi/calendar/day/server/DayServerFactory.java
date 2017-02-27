package com.technology.rfi.calendar.day.server;

import static com.technology.rfi.calendar.day.server.DayServerConstant.DATA_SOURCE_JNDI_NAME;

import com.technology.jep.jepria.server.ServerFactory;
import com.technology.rfi.calendar.day.server.dao.Day;
import com.technology.rfi.calendar.day.server.dao.DayDao;

public class DayServerFactory extends ServerFactory<Day> {

  private DayServerFactory() {
    super(new DayDao(), DATA_SOURCE_JNDI_NAME);
  }

  public static final DayServerFactory instance = new DayServerFactory();

}
