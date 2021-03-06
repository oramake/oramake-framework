package com.technology.oracle.scheduler.main.client.ui.module;

import static com.technology.oracle.scheduler.main.client.SchedulerClientConstant.BATCHROLE_MODULE_ID;
import static com.technology.oracle.scheduler.main.client.SchedulerClientConstant.BATCH_MODULE_ID;
import static com.technology.oracle.scheduler.main.client.SchedulerClientConstant.DETAILEDLOG_MODULE_ID;
import static com.technology.oracle.scheduler.main.client.SchedulerClientConstant.INTERVAL_MODULE_ID;
import static com.technology.oracle.scheduler.main.client.SchedulerClientConstant.MODULEROLEPRIVILEGE_MODULE_ID;
import static com.technology.oracle.scheduler.main.client.SchedulerClientConstant.OPTION_MODULE_ID;
import static com.technology.oracle.scheduler.main.client.SchedulerClientConstant.ROOTLOG_MODULE_ID;
import static com.technology.oracle.scheduler.main.client.SchedulerClientConstant.SCHEDULE_MODULE_ID;
import static com.technology.oracle.scheduler.main.client.SchedulerClientConstant.VALUE_MODULE_ID;

import java.util.ArrayList;

import com.technology.jep.jepria.client.ui.eventbus.event.EnterModuleEvent;
import com.technology.jep.jepria.client.ui.eventbus.main.MainEventBus;
import com.technology.jep.jepria.client.ui.main.MainClientFactory;
import com.technology.jep.jepria.client.ui.main.MainModulePresenter;
import com.technology.jep.jepria.client.ui.main.MainView;
import com.technology.jep.jepria.shared.service.JepMainServiceAsync;
import com.technology.oracle.scheduler.main.client.history.scope.SchedulerScope;

public class SchedulerMainModulePresenter<E extends MainEventBus, S extends JepMainServiceAsync>
      extends MainModulePresenter<MainView, E, S, MainClientFactory<E, S>> {

  public SchedulerMainModulePresenter(MainClientFactory<E, S> clientFactory) {
    super(clientFactory);
    addModuleProtection(BATCH_MODULE_ID, "SchShowBatch");
    addModuleProtection(SCHEDULE_MODULE_ID, "SchShowSchedule");
    addModuleProtection(INTERVAL_MODULE_ID, "SchShowSchedule");
    addModuleProtection(ROOTLOG_MODULE_ID, "SchShowLog");
    addModuleProtection(DETAILEDLOG_MODULE_ID, "SchShowLog");
    addModuleProtection(BATCHROLE_MODULE_ID, "SchShowBatchRole");
    addModuleProtection(OPTION_MODULE_ID, "SchShowBatchOption");
    addModuleProtection(VALUE_MODULE_ID, "SchShowBatchOption");
    addModuleProtection(MODULEROLEPRIVILEGE_MODULE_ID, "SchShowModuleRolePrivilege");
  }

  @Override
  public void onEnterModule(EnterModuleEvent event) {
    //???????????????????? ???????????????????? ???? ???????????? ???????????? ?????? ?????????????? ?????? ?????????????????????? ???????????????? ???? ???????????????????? ???????? ?? ??????????????
    SchedulerScope.INSTANCE.setPrevModuleId(SchedulerScope.INSTANCE.getCurrentModuleId());
    SchedulerScope.INSTANCE.setCurrentModuleId(event.getModuleId());
    super.onEnterModule(event);
  }
}
