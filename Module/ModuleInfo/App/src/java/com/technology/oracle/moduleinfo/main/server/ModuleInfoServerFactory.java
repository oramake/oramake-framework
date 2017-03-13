package com.technology.oracle.moduleinfo.main.server;

import static com.technology.oracle.moduleinfo.main.server.ModuleInfoServerConstant.DATA_SOURCE_JNDI_NAME;

import com.technology.jep.jepria.server.ServerFactory;
import com.technology.oracle.moduleinfo.main.server.dao.ModuleInfo;
import com.technology.oracle.moduleinfo.main.server.dao.ModuleInfoDao;

public class ModuleInfoServerFactory extends ServerFactory<ModuleInfo> {

  private ModuleInfoServerFactory() {
    super(new ModuleInfoDao(), DATA_SOURCE_JNDI_NAME);
  }

  public static final ModuleInfoServerFactory instance = new ModuleInfoServerFactory();

}
