package com.technology.oracle.optionasria.value.client.ui.form.list;

import static com.technology.oracle.optionasria.value.shared.field.ValueFieldNames.DATA_SOURCE;

import java.util.Set;

import com.technology.jep.jepria.client.async.JepAsyncCallback;
import com.technology.jep.jepria.client.history.place.JepEditPlace;
import com.technology.jep.jepria.client.history.place.JepWorkstatePlace;
import com.technology.jep.jepria.client.ui.eventbus.plain.PlainEventBus;
import com.technology.jep.jepria.client.ui.form.list.ListFormPresenter;
import com.technology.jep.jepria.client.ui.plain.StandardClientFactory;
import com.technology.jep.jepria.client.widget.event.JepEvent;
import com.technology.jep.jepria.shared.load.FindConfig;
import com.technology.jep.jepria.shared.record.JepRecord;
import com.technology.oracle.optionasria.main.client.history.scope.OptionAsRiaScope;
import com.technology.oracle.optionasria.value.shared.service.ValueServiceAsync;

public class ValueListFormPresenter<E extends PlainEventBus, S extends ValueServiceAsync>
	extends ListFormPresenter<ValueListFormViewImpl, E, S, StandardClientFactory<E, S>> {

	public ValueListFormPresenter(JepWorkstatePlace place, StandardClientFactory<E, S> clientFactory) {
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

	/**
	 * Обработчик удаления, вызывающий непосредственно сервис удаления.
	 *
	 * @param records записи, которые необходимо удалить
	 */
	@Override
	protected void onDeleteConfirmation(Set<JepRecord> records) {
		for (final JepRecord record : records) {
			record.set(DATA_SOURCE, OptionAsRiaScope.instance.getDataSource());
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
