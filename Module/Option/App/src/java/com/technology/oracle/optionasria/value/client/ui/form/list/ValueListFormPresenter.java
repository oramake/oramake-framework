package com.technology.oracle.optionasria.value.client.ui.form.list;
 
import static com.technology.oracle.optionasria.value.shared.field.ValueFieldNames.*;

import java.util.List;
 
import com.extjs.gxt.ui.client.event.Events;
import com.extjs.gxt.ui.client.widget.grid.Grid;
import com.technology.jep.jepria.client.widget.event.JepEvent;
import com.technology.jep.jepria.client.widget.event.JepListener;
import com.technology.jep.jepria.client.widget.event.JepEventType;
import com.technology.jep.jepria.client.ui.eventbus.plain.JepEventBus;
import com.technology.jep.jepria.client.async.JepAsyncCallback;
import com.technology.jep.jepria.client.history.place.JepEditPlace;
import com.technology.jep.jepria.client.history.place.JepViewDetailPlace;
import com.technology.jep.jepria.client.history.place.JepWorkstatePlace;
import com.technology.jep.jepria.client.ui.module.JepClientFactory;
import com.technology.oracle.optionasria.main.client.history.scope.OptionAsRiaScope;
import com.technology.oracle.optionasria.value.shared.service.ValueServiceAsync;
import com.technology.jep.jepria.client.ui.form.list.JepListFormPresenter; 
import com.technology.jep.jepria.shared.load.FindConfig;
import com.technology.jep.jepria.shared.record.JepRecord;
public class ValueListFormPresenter<E extends JepEventBus, S extends ValueServiceAsync> 
	extends JepListFormPresenter<E, ValueListFormViewImpl, S, JepClientFactory<E, S>> { 
 
	public ValueListFormPresenter(JepWorkstatePlace place, JepClientFactory<E, S> clientFactory) {
		super(place, clientFactory);
	}
 
	public void bind() {
	    super.bind();

	    //удаляем внутреннего слушателя
	    list.removeListener(JepEventType.ROW_DOUBLE_CLICK_EVENT, (JepListener) list.getListeners(JepEventType.ROW_DOUBLE_CLICK_EVENT).get(0));

	    //а также нативный листенер
	    Grid grid = (Grid) list.getWidget();
	    grid.removeListener(Events.RowDoubleClick, grid.getListeners(Events.RowDoubleClick).get(0));

	    //определяем новую бизнес-логику
	    list.addListener(JepEventType.ROW_DOUBLE_CLICK_EVENT, new JepListener() {

			@Override
			public void handleEvent(JepEvent event) {
				placeController.goTo(new JepEditPlace());
			}
	    }); 
	 }
	
	/**
	 * Обработчик удаления, вызывающий непосредственно сервис удаления.
	 *
	 * @param records записи, которые необходимо удалить
	 */
	@Override
	protected void onDeleteConfirmation(List<JepRecord> records) {
		for (final JepRecord record : records) {
			record.set(DATA_SOURCE, OptionAsRiaScope.instance.getDataSource());
			FindConfig deleteConfig = new FindConfig(record);
			deleteConfig.setListUID(getListUID());
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
