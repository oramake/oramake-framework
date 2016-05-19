package com.technology.oracle.optionasria.value.client;
 
import static com.technology.oracle.optionasria.main.client.OptionAsRiaClientConstant.VALUE_MODULE_ID;

import com.google.gwt.activity.shared.Activity;
import com.google.gwt.core.client.GWT;
import com.google.gwt.place.shared.Place;
import com.google.gwt.user.client.ui.IsWidget;
import com.technology.jep.jepria.client.ui.form.list.JepListFormPresenter;
import com.technology.jep.jepria.client.ui.eventbus.plain.JepEventBus;
import com.technology.jep.jepria.shared.service.data.JepDataServiceAsync;
import com.technology.jep.jepria.client.ui.form.list.JepListFormView;
import com.technology.jep.jepria.client.ui.module.JepClientFactory;
import com.technology.jep.jepria.client.ui.module.JepClientFactoryImpl;
import com.technology.jep.jepria.client.ui.module.JepModulePresenter;
import com.technology.jep.jepria.client.history.place.JepWorkstatePlace;
import com.technology.jep.jepria.client.ui.toolbar.ToolBarView;
import com.technology.jep.jepria.client.ui.toolbar.ToolBarViewImpl;
import com.technology.oracle.optionasria.value.client.ui.form.detail.ValueDetailFormPresenter;
import com.technology.oracle.optionasria.value.client.ui.form.detail.ValueDetailFormViewImpl;
import com.technology.oracle.optionasria.value.client.ui.form.list.ValueListFormPresenter;
import com.technology.oracle.optionasria.value.client.ui.form.list.ValueListFormViewImpl;
import com.technology.oracle.optionasria.value.client.ui.toolbar.ValueToolBarPresenter;
import com.technology.oracle.optionasria.value.client.ui.toolbar.ValueToolBarViewImpl;
import com.technology.oracle.optionasria.value.shared.record.ValueRecordDefinition;
import com.technology.oracle.optionasria.value.shared.service.ValueService;
import com.technology.oracle.optionasria.value.shared.service.ValueServiceAsync;
 
public class ValueClientFactoryImpl<E extends JepEventBus, S extends ValueServiceAsync>
		extends JepClientFactoryImpl<E, S> {
 
	private static final IsWidget valueDetailFormView = new ValueDetailFormViewImpl();
	private static final ToolBarView valueToolBarView = new ValueToolBarViewImpl();
	private static final IsWidget valueListFormView = new ValueListFormViewImpl();
 
	public ValueClientFactoryImpl() {
		super(ValueRecordDefinition.instance);
		dataService = GWT.create(ValueService.class);
		initActivityMappers(this);
	}
 
	private JepModulePresenter valueModulePresenter = null;
	@Override
	public JepModulePresenter getAbstractModulePresenter(Place place) {
		if(valueModulePresenter == null) {
			valueModulePresenter = new JepModulePresenter(VALUE_MODULE_ID, place, clientFactory);
		} else {
			valueModulePresenter.setPlace(place);
		}
		return valueModulePresenter;
	}
 
	private ValueToolBarPresenter<E, S> valueToolBarPresenter = null;
	@Override
	public Activity getToolBarActivity(JepWorkstatePlace place) {
		if(valueToolBarPresenter == null) {
			valueToolBarPresenter = new ValueToolBarPresenter<E, S> (place, this);
		} else {
			valueToolBarPresenter.setPlace(place);
		}
		return valueToolBarPresenter;
	}
 
	private ValueListFormPresenter<E, S> valueListFormPresenter = null;
	@Override
	public Activity getListFormActivity(JepWorkstatePlace place) {
		if(valueListFormPresenter == null) {
			valueListFormPresenter = new ValueListFormPresenter<E, S>(place, this);
		} else {
			valueListFormPresenter.setPlace(place);
		}
		return valueListFormPresenter;
	}
 
	private ValueDetailFormPresenter<E, S> valueDetailFormPresenter = null;
	@Override
	public Activity getDetailFormActivity(JepWorkstatePlace place) {
		if(valueDetailFormPresenter == null) {
			valueDetailFormPresenter = new ValueDetailFormPresenter<E, S>(place, this);
		} else {
			valueDetailFormPresenter.setPlace(place);
		}
		return valueDetailFormPresenter;
	}
 
	@Override
	public ToolBarView getToolBarView() {
		return valueToolBarView;
	}
 
	@Override
	public IsWidget getDetailFormView() {
		return valueDetailFormView;
	}
 
	@Override
	public IsWidget getListFormView() {
		return valueListFormView;
	}
 
	private static JepClientFactory<JepEventBus, JepDataServiceAsync> clientFactory = null;
 
	public static JepClientFactory<JepEventBus, JepDataServiceAsync> getInstance() {
		if(clientFactory == null) {
			clientFactory = GWT.create(ValueClientFactoryImpl.class);
		}
		return clientFactory;
	}
}
