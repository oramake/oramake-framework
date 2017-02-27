package com.technology.rfi.calendar.day.client.ui.form.detail;
 
import static com.technology.jep.jepria.client.ui.WorkstateEnum.CREATE;
import static com.technology.jep.jepria.client.ui.WorkstateEnum.SEARCH;
import static com.technology.jep.jepria.client.ui.WorkstateEnum.VIEW_DETAILS;
import static com.technology.jep.jepria.shared.field.JepFieldNames.MAX_ROW_COUNT;
import static com.technology.rfi.calendar.day.shared.field.DayFieldNames.DATE_BEGIN;
import static com.technology.rfi.calendar.day.shared.field.DayFieldNames.DATE_END;
import static com.technology.rfi.calendar.day.shared.field.DayFieldNames.DAY;
import static com.technology.rfi.calendar.day.shared.field.DayFieldNames.DAY_TYPE_ID;
import static com.technology.rfi.calendar.day.shared.field.DayFieldNames.DAY_TYPE_NAME;

import java.util.List;

import com.google.gwt.place.shared.Place;
import com.technology.jep.jepria.client.async.FirstTimeUseAsyncCallback;
import com.technology.jep.jepria.client.ui.WorkstateEnum;
import com.technology.jep.jepria.client.ui.eventbus.plain.PlainEventBus;
import com.technology.jep.jepria.client.ui.form.detail.DetailFormPresenter;
import com.technology.jep.jepria.client.ui.form.detail.DetailFormViewImpl;
import com.technology.jep.jepria.client.ui.plain.StandardClientFactory;
import com.technology.jep.jepria.client.widget.event.JepEvent;
import com.technology.jep.jepria.client.widget.event.JepEventType;
import com.technology.jep.jepria.client.widget.event.JepListener;
import com.technology.jep.jepria.shared.field.option.JepOption;
import com.technology.rfi.calendar.day.shared.service.DayServiceAsync;
 
public class DayDetailFormPresenter<E extends PlainEventBus, S extends DayServiceAsync> 
		extends DetailFormPresenter<DetailFormViewImpl, E, S, StandardClientFactory<E, S>> { 
 
	public DayDetailFormPresenter(Place place, StandardClientFactory<E, S> clientFactory) {
		super(place, clientFactory);
	}
 
	public void bind() {
		super.bind();
		fields.addFieldListener(DAY_TYPE_ID, JepEventType.FIRST_TIME_USE_EVENT, new JepListener() {
			@Override
			public void handleEvent(final JepEvent event) {
				service.getDayType(new FirstTimeUseAsyncCallback<List<JepOption>>(event) {
					public void onSuccessLoad(List<JepOption> result){
						fields.setFieldOptions(DAY_TYPE_ID, result);
					}
				});
			}
		});
	}
	
	@Override
	protected void adjustToWorkstate(WorkstateEnum workstate) {
		fields.setFieldVisible(DAY, CREATE.equals(workstate) || VIEW_DETAILS.equals(workstate));
		fields.setFieldVisible(DATE_BEGIN, SEARCH.equals(workstate));
		fields.setFieldVisible(DATE_END, SEARCH.equals(workstate));
		fields.setFieldVisible(DAY_TYPE_NAME, VIEW_DETAILS.equals(workstate));
		fields.setFieldVisible(DAY_TYPE_ID, CREATE.equals(workstate) || SEARCH.equals(workstate));
 
		fields.setFieldAllowBlank(DAY, !CREATE.equals(workstate));
		fields.setFieldAllowBlank(DAY_TYPE_ID, !CREATE.equals(workstate));
 
		fields.setFieldVisible(MAX_ROW_COUNT, SEARCH.equals(workstate));
		fields.setFieldAllowBlank(MAX_ROW_COUNT, !SEARCH.equals(workstate));
		fields.setFieldValue(MAX_ROW_COUNT, 25);
	}
 
}
