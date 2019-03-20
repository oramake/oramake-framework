package com.technology.oracle.scheduler.main.client.ui.main;

import static com.technology.oracle.scheduler.main.client.SchedulerClientConstant.*;

import java.util.ArrayList;
import java.util.List;

import com.technology.jep.jepria.client.ui.main.MainViewImpl;
import com.technology.jep.jepria.client.ui.main.ModuleConfiguration;

public class SchedulerMainViewImpl extends MainViewImpl {

  @Override
  protected List<ModuleConfiguration> getModuleConfigurations() {
    List<ModuleConfiguration> ret = new ArrayList<>();
    ret.add(new ModuleConfiguration(DETAILEDLOG_MODULE_ID, schedulerText.submodule_detailedlog_title()));
    ret.add(new ModuleConfiguration(BATCH_MODULE_ID, schedulerText.submodule_batch_title()));
    ret.add(new ModuleConfiguration(SCHEDULE_MODULE_ID, schedulerText.submodule_schedule_title()));
    ret.add(new ModuleConfiguration(ROOTLOG_MODULE_ID, schedulerText.submodule_rootlog_title()));
    ret.add(new ModuleConfiguration(VALUE_MODULE_ID, schedulerText.submodule_value_title()));
    ret.add(new ModuleConfiguration(MODULEROLEPRIVILEGE_MODULE_ID, schedulerText.submodule_moduleroleprivilege_title()));
    ret.add(new ModuleConfiguration(BATCHROLE_MODULE_ID, schedulerText.submodule_batchrole_title()));
    ret.add(new ModuleConfiguration(OPTION_MODULE_ID, schedulerText.submodule_option_title()));
    ret.add(new ModuleConfiguration(INTERVAL_MODULE_ID, schedulerText.submodule_interval_title()));
    return ret;
  }
}
