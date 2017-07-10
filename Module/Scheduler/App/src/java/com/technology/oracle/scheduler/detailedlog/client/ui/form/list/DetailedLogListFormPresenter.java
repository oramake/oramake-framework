package com.technology.oracle.scheduler.detailedlog.client.ui.form.list;
 
import static com.technology.jep.jepria.client.JepRiaClientConstant.JepTexts;
import static com.technology.oracle.scheduler.detailedlog.shared.field.DetailedLogFieldNames.DATA_SOURCE;

import com.google.gwt.place.shared.Place;
import com.technology.jep.jepria.client.async.JepAsyncCallback;
import com.technology.jep.jepria.client.history.place.JepViewListPlace;
import com.technology.jep.jepria.client.ui.eventbus.plain.PlainEventBus;
import com.technology.jep.jepria.client.ui.eventbus.plain.event.PagingEvent;
import com.technology.jep.jepria.client.ui.eventbus.plain.event.RefreshEvent;
import com.technology.jep.jepria.client.ui.eventbus.plain.event.SearchEvent;
import com.technology.jep.jepria.client.ui.eventbus.plain.event.SortEvent;
import com.technology.jep.jepria.client.ui.form.list.ListFormPresenter;
import com.technology.jep.jepria.client.ui.form.list.ListFormView;
import com.technology.jep.jepria.client.ui.plain.StandardClientFactory;
import com.technology.jep.jepria.client.widget.event.JepEvent;
import com.technology.jep.jepria.shared.load.PagingConfig;
import com.technology.jep.jepria.shared.load.PagingResult;
import com.technology.jep.jepria.shared.record.JepRecord;
import com.technology.oracle.scheduler.detailedlog.shared.service.DetailedLogServiceAsync;
import com.technology.oracle.scheduler.main.client.history.scope.SchedulerScope;

public class DetailedLogListFormPresenter<V extends ListFormView, E extends PlainEventBus, S extends DetailedLogServiceAsync, F extends StandardClientFactory<E, S>> 
    extends ListFormPresenter<V, E, S, F> { 
 
  public DetailedLogListFormPresenter(Place place, F clientFactory) {
    super(place, clientFactory);
  }

  @Override
  public void onRowDoubleClick(JepEvent event) {}
 
  @Override
  public void onSearch(SearchEvent event) {
    //TODO: для чего этот код?
    searchTemplate = event.getPagingConfig(); // Запомним поисковый шаблон.
    pagingConfig = null;
    super.onSearch(event);
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
  public void onRefresh(RefreshEvent event) {
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
      
      if(pagingConfig != null) {
        
        clientFactory.getService().paging(pagingConfig, callback);
      } else {
        
        clientFactory.getService().find(searchTemplate, callback);
      }
    }
  }
}
