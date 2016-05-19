package com.technology.oracle.optionasria.option.client;
 
import static com.technology.oracle.optionasria.main.client.OptionAsRiaClientConstant.OPTION_MODULE_ID;

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
import com.technology.oracle.optionasria.option.client.ui.eventbus.OptionEventBus;
import com.technology.oracle.optionasria.option.client.ui.form.detail.OptionDetailFormPresenter;
import com.technology.oracle.optionasria.option.client.ui.form.detail.OptionDetailFormViewImpl;
import com.technology.oracle.optionasria.option.client.ui.form.list.OptionListFormPresenter;
import com.technology.oracle.optionasria.option.client.ui.form.list.OptionListFormViewImpl;
import com.technology.oracle.optionasria.option.client.ui.toolbar.OptionToolBarPresenter;
import com.technology.oracle.optionasria.option.client.ui.toolbar.OptionToolBarViewImpl;
import com.technology.oracle.optionasria.option.shared.record.OptionRecordDefinition;
import com.technology.oracle.optionasria.option.shared.service.OptionService;
import com.technology.oracle.optionasria.option.shared.service.OptionServiceAsync;
 
public class OptionClientFactoryImpl<E extends OptionEventBus, S extends OptionServiceAsync>
		extends JepClientFactoryImpl<E, S> {
 
	private static final IsWidget optionDetailFormView = new OptionDetailFormViewImpl();
	private static final ToolBarView optionToolBarView = new OptionToolBarViewImpl();
	private static final IsWidget optionListFormView = new OptionListFormViewImpl();
 
	public OptionClientFactoryImpl() {
		super(OptionRecordDefinition.instance);
		dataService = GWT.create(OptionService.class);
		initActivityMappers(this);
	}
 
	private JepModulePresenter optionModulePresenter = null;
	@Override
	public JepModulePresenter getAbstractModulePresenter(Place place) {
		if(optionModulePresenter == null) {
			optionModulePresenter = new JepModulePresenter(OPTION_MODULE_ID, place, clientFactory);
		} else {
			optionModulePresenter.setPlace(place);
		}
		return optionModulePresenter;
	}
 
	private OptionToolBarPresenter<E, S> optionToolBarPresenter = null;
	@Override
	public Activity getToolBarActivity(JepWorkstatePlace place) {
		if(optionToolBarPresenter == null) {
			optionToolBarPresenter = new OptionToolBarPresenter<E, S> (place, this);
		} else {
			optionToolBarPresenter.setPlace(place);
		}
		return optionToolBarPresenter;
	}
 
	private OptionListFormPresenter<E, S> optionListFormPresenter = null;
	@Override
	public Activity getListFormActivity(JepWorkstatePlace place) {
		if(optionListFormPresenter == null) {
			optionListFormPresenter = new OptionListFormPresenter<E, S>(place, this);
		} else {
			optionListFormPresenter.setPlace(place);
		}
		return optionListFormPresenter;
	}
 
	private OptionDetailFormPresenter<E, S> optionDetailFormPresenter = null;
	@Override
	public Activity getDetailFormActivity(JepWorkstatePlace place) {
		if(optionDetailFormPresenter == null) {
			optionDetailFormPresenter = new OptionDetailFormPresenter<E, S>(place, this);
		} else {
			optionDetailFormPresenter.setPlace(place);
		}
		return optionDetailFormPresenter;
	}
 
	@Override
	public ToolBarView getToolBarView() {
		return optionToolBarView;
	}
 
	@Override
	public IsWidget getDetailFormView() {
		return optionDetailFormView;
	}
 
	@Override
	public IsWidget getListFormView() {
		return optionListFormView;
	}
 
	private static JepClientFactory<JepEventBus, JepDataServiceAsync> clientFactory = null;
 
	public static JepClientFactory<JepEventBus, JepDataServiceAsync> getInstance() {
		if(clientFactory == null) {
			clientFactory = GWT.create(OptionClientFactoryImpl.class);
		}
		return clientFactory;
	}
}
