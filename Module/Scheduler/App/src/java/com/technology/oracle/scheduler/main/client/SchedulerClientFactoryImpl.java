package com.technology.oracle.scheduler.main.client;
 
import static com.technology.oracle.scheduler.main.client.SchedulerClientConstant.BATCHROLE_MODULE_ID;
import static com.technology.oracle.scheduler.main.client.SchedulerClientConstant.BATCH_MODULE_ID;
import static com.technology.oracle.scheduler.main.client.SchedulerClientConstant.DETAILEDLOG_MODULE_ID;
import static com.technology.oracle.scheduler.main.client.SchedulerClientConstant.INTERVAL_MODULE_ID;
import static com.technology.oracle.scheduler.main.client.SchedulerClientConstant.MODULEROLEPRIVILEGE_MODULE_ID;
import static com.technology.oracle.scheduler.main.client.SchedulerClientConstant.OPTION_MODULE_ID;
import static com.technology.oracle.scheduler.main.client.SchedulerClientConstant.ROOTLOG_MODULE_ID;
import static com.technology.oracle.scheduler.main.client.SchedulerClientConstant.SCHEDULE_MODULE_ID;
import static com.technology.oracle.scheduler.main.client.SchedulerClientConstant.VALUE_MODULE_ID;
import static com.technology.oracle.scheduler.main.client.SchedulerClientConstant.schedulerText;

import com.google.gwt.activity.shared.Activity;
import com.google.gwt.core.client.GWT;
import com.technology.jep.jepria.client.ModuleItem;
import com.technology.jep.jepria.client.async.LoadAsyncCallback;
import com.technology.jep.jepria.client.async.LoadPlainClientFactory;
import com.technology.jep.jepria.client.ui.eventbus.main.MainEventBus;
import com.technology.jep.jepria.client.ui.eventbus.plain.PlainEventBus;
import com.technology.jep.jepria.client.ui.main.MainClientFactory;
import com.technology.jep.jepria.client.ui.main.MainClientFactoryImpl;
import com.technology.jep.jepria.client.ui.plain.PlainClientFactory;
import com.technology.jep.jepria.shared.service.JepMainServiceAsync;
import com.technology.jep.jepria.shared.service.data.JepDataServiceAsync;
import com.technology.oracle.scheduler.batch.client.BatchClientFactoryImpl;
import com.technology.oracle.scheduler.batchrole.client.BatchRoleClientFactoryImpl;
import com.technology.oracle.scheduler.detailedlog.client.DetailedLogClientFactoryImpl;
import com.technology.oracle.scheduler.interval.client.IntervalClientFactoryImpl;
import com.technology.oracle.scheduler.main.client.ui.module.SchedulerMainModulePresenter;
import com.technology.oracle.scheduler.moduleroleprivilege.client.ModuleRolePrivilegeClientFactoryImpl;
import com.technology.oracle.scheduler.option.client.OptionClientFactoryImpl;
import com.technology.oracle.scheduler.rootlog.client.RootLogClientFactoryImpl;
import com.technology.oracle.scheduler.schedule.client.ScheduleClientFactoryImpl;
import com.technology.oracle.scheduler.value.client.ValueClientFactoryImpl;

@SuppressWarnings("unchecked")
public class SchedulerClientFactoryImpl<E extends MainEventBus, S extends JepMainServiceAsync>
  extends MainClientFactoryImpl<E, S>
    implements MainClientFactory<E, S> {
  
  public static MainClientFactory<MainEventBus, JepMainServiceAsync> getInstance() {
    if(instance == null) {
      instance = GWT.create(SchedulerClientFactoryImpl.class);
    }
    return instance;
  }
 
  private SchedulerClientFactoryImpl() {
    super(
        new ModuleItem(BATCH_MODULE_ID, schedulerText.submodule_batch_title())
        , new ModuleItem(SCHEDULE_MODULE_ID, schedulerText.submodule_schedule_title())
        , new ModuleItem(INTERVAL_MODULE_ID, schedulerText.submodule_interval_title())
        , new ModuleItem(ROOTLOG_MODULE_ID, schedulerText.submodule_rootlog_title())
        , new ModuleItem(DETAILEDLOG_MODULE_ID, schedulerText.submodule_detailedlog_title())
        , new ModuleItem(BATCHROLE_MODULE_ID, schedulerText.submodule_batchrole_title())
        , new ModuleItem(OPTION_MODULE_ID, schedulerText.submodule_option_title())
        , new ModuleItem(VALUE_MODULE_ID, schedulerText.submodule_value_title())
        , new ModuleItem(MODULEROLEPRIVILEGE_MODULE_ID, schedulerText.submodule_moduleroleprivilege_title())
    );
 
    initActivityMappers(this);
  }
  
   
  @SuppressWarnings({"rawtypes" })
  @Override
  public Activity createMainModulePresenter() {
    return new SchedulerMainModulePresenter(this);
  }
 
  public void getPlainClientFactory(String moduleId, final LoadAsyncCallback<PlainClientFactory<PlainEventBus, JepDataServiceAsync>> callback) {
    if(BATCH_MODULE_ID.equals(moduleId)) {
      GWT.runAsync(new LoadPlainClientFactory(callback) {
        public PlainClientFactory<PlainEventBus, JepDataServiceAsync> getPlainClientFactory() {
          return BatchClientFactoryImpl.getInstance();
        }
      });
    }
    else if(SCHEDULE_MODULE_ID.equals(moduleId)) {
      GWT.runAsync(new LoadPlainClientFactory(callback) {
        public PlainClientFactory<PlainEventBus, JepDataServiceAsync> getPlainClientFactory() {
          return ScheduleClientFactoryImpl.getInstance();
        }
      });
    }
    else if(INTERVAL_MODULE_ID.equals(moduleId)) {
      GWT.runAsync(new LoadPlainClientFactory(callback) {
        public PlainClientFactory<PlainEventBus, JepDataServiceAsync> getPlainClientFactory() {
          return IntervalClientFactoryImpl.getInstance();
        }
      });
    }
    else if(ROOTLOG_MODULE_ID.equals(moduleId)) {
      GWT.runAsync(new LoadPlainClientFactory(callback) {
        public PlainClientFactory<PlainEventBus, JepDataServiceAsync> getPlainClientFactory() {
          return RootLogClientFactoryImpl.getInstance();
        }
      });
    }
    else if(DETAILEDLOG_MODULE_ID.equals(moduleId)) {
      GWT.runAsync(new LoadPlainClientFactory(callback) {
        public PlainClientFactory<PlainEventBus, JepDataServiceAsync> getPlainClientFactory() {
          return DetailedLogClientFactoryImpl.getInstance();
        }
      });
    }
    else if(BATCHROLE_MODULE_ID.equals(moduleId)) {
      GWT.runAsync(new LoadPlainClientFactory(callback) {
        public PlainClientFactory<PlainEventBus, JepDataServiceAsync> getPlainClientFactory() {
          return BatchRoleClientFactoryImpl.getInstance();
        }
      });
    }
    else if(OPTION_MODULE_ID.equals(moduleId)) {
      GWT.runAsync(new LoadPlainClientFactory(callback) {
        public PlainClientFactory<PlainEventBus, JepDataServiceAsync> getPlainClientFactory() {
          return OptionClientFactoryImpl.getInstance();
        }
      });
    }
    else if(VALUE_MODULE_ID.equals(moduleId)) {
      GWT.runAsync(new LoadPlainClientFactory(callback) {
        public PlainClientFactory<PlainEventBus, JepDataServiceAsync> getPlainClientFactory() {
          return ValueClientFactoryImpl.getInstance();
        }
      });
    }
    else if(MODULEROLEPRIVILEGE_MODULE_ID.equals(moduleId)) {
      GWT.runAsync(new LoadPlainClientFactory(callback) {
        public PlainClientFactory<PlainEventBus, JepDataServiceAsync> getPlainClientFactory() {
          return ModuleRolePrivilegeClientFactoryImpl.getInstance();
        }
      });
    }
  }
}
