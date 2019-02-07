package com.technology.oracle.scheduler.main.client;

import static com.technology.oracle.scheduler.main.client.SchedulerClientConstant.*;
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
import com.google.gwt.user.client.ui.IsWidget;
import com.technology.jep.jepria.client.async.LoadAsyncCallback;
import com.technology.jep.jepria.client.async.LoadPlainClientFactory;
import com.technology.jep.jepria.client.ui.eventbus.main.MainEventBus;
import com.technology.jep.jepria.client.ui.eventbus.plain.PlainEventBus;
import com.technology.jep.jepria.client.ui.main.MainClientFactory;
import com.technology.jep.jepria.client.ui.main.MainClientFactoryImpl;
import com.technology.jep.jepria.client.ui.main.MainModulePresenter;
import com.technology.jep.jepria.client.ui.main.MainView;
import com.technology.jep.jepria.client.ui.plain.PlainClientFactory;
import com.technology.jep.jepria.shared.service.JepMainServiceAsync;
import com.technology.jep.jepria.shared.service.data.JepDataServiceAsync;
import com.technology.oracle.scheduler.batch.client.BatchClientFactoryImpl;
import com.technology.oracle.scheduler.batchrole.client.BatchRoleClientFactoryImpl;
import com.technology.oracle.scheduler.detailedlog.client.DetailedLogClientFactoryImpl;
import com.technology.oracle.scheduler.interval.client.IntervalClientFactoryImpl;
import com.technology.oracle.scheduler.main.client.ui.main.SchedulerMainViewImpl;
import com.technology.oracle.scheduler.main.client.ui.module.SchedulerMainModulePresenter;
import com.technology.oracle.scheduler.moduleroleprivilege.client.ModuleRolePrivilegeClientFactoryImpl;
import com.technology.oracle.scheduler.option.client.OptionClientFactoryImpl;
import com.technology.oracle.scheduler.rootlog.client.RootLogClientFactoryImpl;
import com.technology.oracle.scheduler.schedule.client.ScheduleClientFactoryImpl;
import com.technology.oracle.scheduler.value.client.ValueClientFactoryImpl;

public class SchedulerClientFactoryImpl extends MainClientFactoryImpl<MainEventBus, JepMainServiceAsync> {

  private static final IsWidget mainView = new SchedulerMainViewImpl();

  public static MainClientFactory<MainEventBus, JepMainServiceAsync> getInstance() {
    if(instance == null) {
      instance = GWT.create(SchedulerClientFactoryImpl.class);
    }
    return instance;
  }

  private SchedulerClientFactoryImpl() {
    super(
        DETAILEDLOG_MODULE_ID
        , BATCH_MODULE_ID
        , SCHEDULE_MODULE_ID
        , ROOTLOG_MODULE_ID
        , VALUE_MODULE_ID
        , MODULEROLEPRIVILEGE_MODULE_ID
        , BATCHROLE_MODULE_ID
        , OPTION_MODULE_ID
        , INTERVAL_MODULE_ID
    );
  }


  @Override
  public MainModulePresenter<? extends MainView, MainEventBus, JepMainServiceAsync, ? extends MainClientFactory<MainEventBus, JepMainServiceAsync>>
      createMainModulePresenter() {
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

  @Override
  public IsWidget getMainView() {
    return mainView;
  }
}
