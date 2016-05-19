package com.technology.oracle.scheduler.batch.client.ui.form.detail;
 
import static com.technology.jep.jepria.client.ui.WorkstateEnum.EDIT;
import static com.technology.jep.jepria.client.ui.WorkstateEnum.SEARCH;
import static com.technology.jep.jepria.client.ui.WorkstateEnum.VIEW_DETAILS;
import static com.technology.jep.jepria.shared.field.JepFieldNames.MAX_ROW_COUNT;
import static com.technology.oracle.scheduler.batch.client.BatchClientConstant.scopeModuleIds;
import static com.technology.oracle.scheduler.batch.shared.field.BatchFieldNames.BATCH_ID;
import static com.technology.oracle.scheduler.batch.shared.field.BatchFieldNames.BATCH_NAME;
import static com.technology.oracle.scheduler.batch.shared.field.BatchFieldNames.BATCH_SHORT_NAME;
import static com.technology.oracle.scheduler.batch.shared.field.BatchFieldNames.DATA_SOURCE;
import static com.technology.oracle.scheduler.batch.shared.field.BatchFieldNames.LAST_DATE_FROM;
import static com.technology.oracle.scheduler.batch.shared.field.BatchFieldNames.LAST_DATE_TO;
import static com.technology.oracle.scheduler.batch.shared.field.BatchFieldNames.MODULE_ID;
import static com.technology.oracle.scheduler.batch.shared.field.BatchFieldNames.RETRIAL_COUNT;
import static com.technology.oracle.scheduler.batch.shared.field.BatchFieldNames.RETRIAL_TIMEOUT;

import java.util.ArrayList;
import java.util.List;

import com.google.gwt.event.shared.EventBus;
import com.google.gwt.place.shared.Place;
import com.google.gwt.user.client.ui.AcceptsOneWidget;
import com.technology.jep.jepria.client.async.FirstTimeUseAsyncCallback;
import com.technology.jep.jepria.client.async.JepAsyncCallback;
import com.technology.jep.jepria.client.async.TypingTimeoutAsyncCallback;
import com.technology.jep.jepria.client.ui.WorkstateEnum;
import com.technology.jep.jepria.client.ui.eventbus.plain.event.DoGetRecordEvent;
import com.technology.jep.jepria.client.ui.form.detail.DetailFormPresenter;
import com.technology.jep.jepria.client.ui.plain.StandardClientFactory;
import com.technology.jep.jepria.client.widget.event.JepEvent;
import com.technology.jep.jepria.client.widget.event.JepEventType;
import com.technology.jep.jepria.client.widget.event.JepListener;
import com.technology.jep.jepria.client.widget.field.multistate.JepComboBoxField;
import com.technology.jep.jepria.shared.field.option.JepOption;
import com.technology.jep.jepria.shared.load.PagingConfig;
import com.technology.jep.jepria.shared.record.JepRecord;
import com.technology.jep.jepria.shared.util.JepRiaUtil;
import com.technology.oracle.scheduler.batch.client.ui.eventbus.BatchEventBus;
import com.technology.oracle.scheduler.batch.client.ui.eventbus.event.AbortBatchEvent;
import com.technology.oracle.scheduler.batch.client.ui.eventbus.event.ActivateBatchEvent;
import com.technology.oracle.scheduler.batch.client.ui.eventbus.event.DeactivateBatchEvent;
import com.technology.oracle.scheduler.batch.client.ui.eventbus.event.ExecuteBatchEvent;
import com.technology.oracle.scheduler.batch.shared.service.BatchServiceAsync;
import com.technology.oracle.scheduler.main.client.history.scope.SchedulerScope;
 
public class BatchDetailFormPresenter<E extends BatchEventBus, S extends BatchServiceAsync> 
		extends DetailFormPresenter<BatchDetailFormView, E, S, StandardClientFactory<E, S>>  
			implements ActivateBatchEvent.Handler, DeactivateBatchEvent.Handler, ExecuteBatchEvent.Handler, AbortBatchEvent.Handler {

	private S service = clientFactory.getService();
	
	public BatchDetailFormPresenter(Place place, StandardClientFactory<E, S> clientFactory) {
		super(scopeModuleIds, place, clientFactory);
	}
	
	@Override
	public void start(AcceptsOneWidget container, EventBus eventBus) {
		super.start(container, eventBus);
 
		eventBus.addHandler(ActivateBatchEvent.TYPE, this);
		eventBus.addHandler(DeactivateBatchEvent.TYPE, this);
		eventBus.addHandler(ExecuteBatchEvent.TYPE, this);
		eventBus.addHandler(AbortBatchEvent.TYPE, this);
	}
	
	public void onDoGetRecord(DoGetRecordEvent event) {
	
		//для корректной работы табов (ScopeModules)
		final PagingConfig pagingConfig = event.getPagingConfig();
		JepRecord record = pagingConfig.getTemplateRecord();
		record.set(DATA_SOURCE, SchedulerScope.instance.getDataSource());

		super.onDoGetRecord(event);
	}
	
	public void bind() {
		super.bind();
		// Здесь размещается код связывания presenter-а и view 
		fields.addFieldListener(DATA_SOURCE, JepEventType.FIRST_TIME_USE_EVENT, new JepListener() {
			@Override
			public void handleEvent(final JepEvent event) {
				service.getDataSource(new FirstTimeUseAsyncCallback<List<JepOption>>(event) {
					public void onSuccessLoad(List<JepOption> result){
						fields.setFieldOptions(DATA_SOURCE, result);
					}
				});
			}
		});
		
		
		fields.addFieldListener(DATA_SOURCE, JepEventType.CHANGE_SELECTION_EVENT, new JepListener() {

			@Override
			public void handleEvent(JepEvent event) {
				
				SchedulerScope.instance.setDataSource((JepOption) fields.getFieldValue(DATA_SOURCE));
				setDataSourceDependFields();
				changeModules();
			}
			
		});
		
	}
	
 
	private void changeModules(){

		fields.clearField(MODULE_ID);
		
		String dataSource = JepOption.<String>getValue(SchedulerScope.instance.getDataSource());
		final JepComboBoxField moduleComboBoxField = (JepComboBoxField)fields.get(MODULE_ID);
		
		
		if(!JepRiaUtil.isEmpty(dataSource)){
			
			moduleComboBoxField.setLoadingImage(true);
			fields.setFieldEnabled(MODULE_ID, false);
			
			service.getModule(dataSource, new TypingTimeoutAsyncCallback<List<JepOption>>(new JepEvent(moduleComboBoxField)) {
				public void onSuccessLoad(List<JepOption> result){
					
					moduleComboBoxField.setLoadingImage(false);
					fields.setFieldEnabled(MODULE_ID, true);
					fields.setFieldOptions(MODULE_ID, result);
				}
				
				public void onFailure(Throwable caught) {
					
					moduleComboBoxField.setLoadingImage(false);
					fields.setFieldOptions(MODULE_ID, new ArrayList<JepOption>());
					super.onFailure(caught);
				}
			});
			
		}
	}
	
	private void setDataSourceDependFields(){
		
		Boolean enabled = false;
		if(
			!JepRiaUtil.isEmpty(JepOption.<String>getValue(SchedulerScope.instance.getDataSource()))
			){
			enabled = true;
		}
		
		fields.setFieldEnabled(BATCH_ID, enabled);
		fields.setFieldEnabled(BATCH_SHORT_NAME, enabled);
		fields.setFieldEnabled(BATCH_NAME, enabled);
		fields.setFieldEnabled(MODULE_ID, enabled);
		fields.setFieldEnabled(LAST_DATE_FROM, enabled);
		fields.setFieldEnabled(LAST_DATE_TO, enabled);
		fields.setFieldEnabled(RETRIAL_COUNT, enabled);
	}
	
	protected void adjustToWorkstate(WorkstateEnum workstate) {
		
		setDataSourceDependFields();
		
		fields.setFieldVisible(BATCH_ID, SEARCH.equals(workstate) || VIEW_DETAILS.equals(workstate));
		fields.setFieldVisible(BATCH_SHORT_NAME, SEARCH.equals(workstate) || VIEW_DETAILS.equals(workstate));
		fields.setFieldVisible(BATCH_NAME, EDIT.equals(workstate) || SEARCH.equals(workstate) || VIEW_DETAILS.equals(workstate));
		fields.setFieldVisible(MODULE_ID, SEARCH.equals(workstate));
		fields.setFieldVisible(LAST_DATE_FROM, SEARCH.equals(workstate));
		fields.setFieldVisible(LAST_DATE_TO, SEARCH.equals(workstate));
		fields.setFieldVisible(RETRIAL_COUNT, EDIT.equals(workstate) || SEARCH.equals(workstate) || VIEW_DETAILS.equals(workstate));
		fields.setFieldVisible(RETRIAL_TIMEOUT, EDIT.equals(workstate) || VIEW_DETAILS.equals(workstate));
 
		fields.setFieldAllowBlank(BATCH_NAME, !EDIT.equals(workstate));
		fields.setFieldAllowBlank(DATA_SOURCE, !SEARCH.equals(workstate));
		fields.setFieldAllowBlank(RETRIAL_COUNT, !EDIT.equals(workstate));
 
		fields.setFieldEditable(DATA_SOURCE, SEARCH.equals(workstate));
 
		fields.setFieldVisible(MAX_ROW_COUNT, SEARCH.equals(workstate));
		fields.setFieldAllowBlank(MAX_ROW_COUNT, !SEARCH.equals(workstate));
		fields.setFieldValue(MAX_ROW_COUNT, 25);
	}

	public void onActivateBatchEvent(ActivateBatchEvent event) {
		
		if(!VIEW_DETAILS.equals(_workstate))
			return;
		
		service.activateBatch(
				SchedulerScope.instance.getDataSource().getName(), 
				(Integer) currentRecord.get(BATCH_ID),
				new DetailUpdaterCallback()
		);
	}
	public void onDeactivateBatchEvent(DeactivateBatchEvent event) {
		
		if(!VIEW_DETAILS.equals(_workstate))
			return;
		
		service.deactivateBatch(
				SchedulerScope.instance.getDataSource().getName(), 
				(Integer) currentRecord.get(BATCH_ID),
				new DetailUpdaterCallback()
		);
	}
		
	public class DetailUpdaterCallback extends JepAsyncCallback<JepRecord>{

		@Override
		public void onSuccess(JepRecord result) {
			messageBox.alert("Действие успешно выполнено!");
		}
	}
	
	public void onExecuteBatchEvent(ExecuteBatchEvent event) {
		
		if(!VIEW_DETAILS.equals(_workstate))
			return;
		
		service.executeBatch(
				SchedulerScope.instance.getDataSource().getName(), 
				(Integer) currentRecord.get(BATCH_ID),
				new DetailUpdaterCallback()
		);
	}
	public void onAbortBatchEvent(AbortBatchEvent event) {
		
		if(!VIEW_DETAILS.equals(_workstate))
			return;
		
		service.abortBatch(
				SchedulerScope.instance.getDataSource().getName(), 
				(Integer) currentRecord.get(BATCH_ID),
				new DetailUpdaterCallback()
		);
	}
 
}
