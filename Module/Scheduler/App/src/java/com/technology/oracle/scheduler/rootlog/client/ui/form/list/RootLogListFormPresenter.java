package com.technology.oracle.scheduler.rootlog.client.ui.form.list;

import static com.technology.jep.jepria.client.JepRiaClientConstant.JepTexts;
import static com.technology.oracle.scheduler.main.client.SchedulerClientConstant.DETAILEDLOG_MODULE_ID;
import static com.technology.oracle.scheduler.main.client.SchedulerClientConstant.ROOTLOG_MODULE_ID;

import com.google.gwt.place.shared.Place;
import com.google.gwt.user.client.Window;
import com.technology.jep.jepria.client.async.JepAsyncCallback;
import com.technology.jep.jepria.client.history.place.JepViewListPlace;
import com.technology.jep.jepria.client.history.scope.JepScope;
import com.technology.jep.jepria.client.history.scope.JepScopeStack;
import com.technology.jep.jepria.client.ui.WorkstateEnum;
import com.technology.jep.jepria.client.ui.eventbus.event.UpdateScopeEvent;
import com.technology.jep.jepria.client.ui.eventbus.plain.PlainEventBus;
import com.technology.jep.jepria.client.ui.eventbus.plain.event.PagingEvent;
import com.technology.jep.jepria.client.ui.eventbus.plain.event.RefreshListEvent;
import com.technology.jep.jepria.client.ui.eventbus.plain.event.SortEvent;
import com.technology.jep.jepria.client.ui.form.list.ListFormPresenter;
import com.technology.jep.jepria.client.ui.form.list.ListFormView;
import com.technology.jep.jepria.client.ui.plain.StandardClientFactory;
import com.technology.jep.jepria.client.widget.event.JepEvent;
import com.technology.jep.jepria.shared.load.PagingConfig;
import com.technology.jep.jepria.shared.load.PagingResult;
import com.technology.jep.jepria.shared.record.JepRecord;
import com.technology.oracle.scheduler.main.client.history.scope.SchedulerScope;
import com.technology.oracle.scheduler.rootlog.shared.record.RootLogRecordDefinition;
import com.technology.oracle.scheduler.rootlog.shared.service.RootLogServiceAsync;

import java.awt.*;

public class RootLogListFormPresenter<V extends ListFormView, E extends PlainEventBus, S extends RootLogServiceAsync, F extends StandardClientFactory<E, S>>
  extends ListFormPresenter<V, E, S, F> {

  public RootLogListFormPresenter(Place place, F clientFactory) {
    super(place, clientFactory);
  }

  @Override
  public void onRowDoubleClick(JepEvent event) {

    String[] scopes = {DETAILEDLOG_MODULE_ID};
    WorkstateEnum newWorkstate = WorkstateEnum.VIEW_LIST;


    JepScope newScope = new JepScope(scopes){
      //костыль begin
            @Override
            public boolean isMainActive() {
                  return true;
            }
            @Override
            public boolean isMain(String moduleId) {
                  return false;
            }
            //костыль end
        };


    newScope.setActiveModuleId(ROOTLOG_MODULE_ID);

    newScope.getModuleStates()[0] = newWorkstate;
        newScope.setPrimaryKey(RootLogRecordDefinition.instance.buildPrimaryKeyMap(currentRecord));

        JepScopeStack.instance.push(newScope);
        eventBus.setCurrentRecord(currentRecord); // Выставим значение первичного ключа
        eventBus.updateScope(new UpdateScopeEvent(JepScopeStack.instance.peek()));

    clientFactory.getMainClientFactory().getEventBus().enterModule(DETAILEDLOG_MODULE_ID);

  };

  private PagingConfig pagingConfig = null;

  @Override
  public void onSort(SortEvent event) {
    pagingConfig = null;
    super.onSort(event);
  }

  @Override
  public void onPaging(PagingEvent event) {
    pagingConfig = event.getPagingConfig();
    super.onPaging(event);
  }

  /**
   * Обработчик события обновления списка.
   *
   * @param event событие обновления списка
   */
  @Override
  public void onRefreshList(RefreshListEvent event) {
    // Важно при обновлении списка менять рабочее состояние на VIEW_LIST.
    placeController.goTo(new JepViewListPlace());
    // Если существует сохраненный шаблон, по которому нужно обновлять список, то ...
    if(searchTemplate != null) {
      list.clear(); // Очистим список от предыдущего содержимого (чтобы не вводить в заблуждение пользователя).
      list.mask(JepTexts.loadingPanel_dataLoading()); // Выставим индикатор "Загрузка данных...".
      searchTemplate.setListUID(listUID); // Выставим идентификатор получаемого списка данных.
      searchTemplate.setPageSize(list.getPageSize()); // Выставим размер получаемой страницы набора данных.
      JepAsyncCallback<PagingResult<JepRecord>> callback = new JepAsyncCallback<PagingResult<JepRecord>>() {

        @Override
        public void onSuccess(final PagingResult<JepRecord> pagingResult) {
          list.set(pagingResult); // Установим в список полученные от сервиса данные.
          list.unmask(); // Скроем индикатор "Загрузка данных...".
        }

        @Override
        public void onFailure(Throwable caught) {
          list.unmask(); // Скроем индикатор "Загрузка данных...".
          super.onFailure(caught);
        }

      };

      if(pagingConfig != null &&
          DETAILEDLOG_MODULE_ID.equals(SchedulerScope.INSTANCE.getPrevModuleId())) {
        clientFactory.getService().paging(pagingConfig, callback);
      } else {
        clientFactory.getService().find(searchTemplate, callback);
        pagingConfig = null;
      }
    }
  }
}
