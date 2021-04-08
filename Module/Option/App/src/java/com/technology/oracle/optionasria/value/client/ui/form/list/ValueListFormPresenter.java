package com.technology.oracle.optionasria.value.client.ui.form.list;

import static com.technology.oracle.optionasria.main.shared.OptionAsRiaConstant.CURRENT_DATA_SOURCE;
import static com.technology.oracle.optionasria.value.shared.field.ValueFieldNames.DATA_SOURCE;

import java.awt.*;
import java.util.Set;

import com.google.gwt.place.shared.Place;
import com.google.gwt.storage.client.Storage;
import com.google.gwt.user.client.Window;
import com.technology.jep.jepria.client.async.JepAsyncCallback;
import com.technology.jep.jepria.client.history.place.JepEditPlace;
import com.technology.jep.jepria.client.history.place.JepWorkstatePlace;
import com.technology.jep.jepria.client.ui.eventbus.plain.PlainEventBus;
import com.technology.jep.jepria.client.ui.eventbus.plain.event.SearchEvent;
import com.technology.jep.jepria.client.ui.form.list.ListFormPresenter;
import com.technology.jep.jepria.client.ui.form.list.ListFormView;
import com.technology.jep.jepria.client.ui.plain.StandardClientFactory;
import com.technology.jep.jepria.client.widget.event.JepEvent;
import com.technology.jep.jepria.shared.load.FindConfig;
import com.technology.jep.jepria.shared.record.JepRecord;
import com.technology.oracle.optionasria.main.client.history.scope.OptionAsRiaScope;
import com.technology.oracle.optionasria.value.shared.service.ValueServiceAsync;

public class ValueListFormPresenter<V extends ListFormView, E extends PlainEventBus, S extends ValueServiceAsync, F extends StandardClientFactory<E, S>>
	extends ListFormPresenter<V, E, S, F> {

	public ValueListFormPresenter(Place place, F clientFactory) {
		super(place, clientFactory);
	}

	public void bind() {
	    super.bind();
	    /*
	    //удаляем внутреннего слушателя
	    list.removeListener(JepEventType.ROW_DOUBLE_CLICK_EVENT, (JepListener) list.getListeners(JepEventType.ROW_DOUBLE_CLICK_EVENT).get(0));

	    //а также нативный листенер
	    JepGrid grid = (JepGrid) list.getWidget();

	    grid.removeListener(Events.RowDoubleClick, grid.getListeners(Events.RowDoubleClick).get(0));

	    //определяем новую бизнес-логику
	    list.addListener(JepEventType.ROW_DOUBLE_CLICK_EVENT, new JepListener() {

			@Override
			public void handleEvent(JepEvent event) {
				placeController.goTo(new JepEditPlace());
			}
	    }); */
	 }
	/*
	public void onRowDoubleClick(JepEvent event) {
	  placeController.goTo(new JepEditPlace());
	}*/

	@Override
	public void onSearch(SearchEvent event) {
		Storage storage = Storage.getSessionStorageIfSupported();
		event.getPagingConfig().getTemplateRecord().set(CURRENT_DATA_SOURCE, storage.getItem(CURRENT_DATA_SOURCE));
		super.onSearch(event);
	}

	/**
	 * Обработчик удаления, вызывающий непосредственно сервис удаления.
	 *
	 * @param records записи, которые необходимо удалить
	 */
	@Override
	protected void onDeleteConfirmation(Set<JepRecord> records) {
		for (final JepRecord record : records) {
			record.set(DATA_SOURCE, OptionAsRiaScope.instance.getDataSource());
			record.set(CURRENT_DATA_SOURCE, Storage.getSessionStorageIfSupported().getItem(CURRENT_DATA_SOURCE));
			FindConfig deleteConfig = new FindConfig(record);
			deleteConfig.setListUID(listUID);
			clientFactory.getService().delete(deleteConfig, new JepAsyncCallback<Void>() {
				public void onFailure(final Throwable th) {
					clientFactory.getExceptionManager().handleException(th, "Delete error");
				}
				public void onSuccess(final Void result) {
					eventBus.delete(record);
				}
			});
		}
	}
}
