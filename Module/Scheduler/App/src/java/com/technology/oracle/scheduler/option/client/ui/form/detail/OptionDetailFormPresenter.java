package com.technology.oracle.scheduler.option.client.ui.form.detail;
 
import static com.technology.jep.jepria.client.ui.WorkstateEnum.CREATE;
import static com.technology.jep.jepria.client.ui.WorkstateEnum.EDIT;
import static com.technology.jep.jepria.client.ui.WorkstateEnum.SEARCH;
import static com.technology.jep.jepria.client.ui.WorkstateEnum.VIEW_DETAILS;
import static com.technology.oracle.scheduler.option.client.OptionClientConstant.scopeModuleIds;
import static com.technology.oracle.scheduler.option.shared.OptionConstant.DATE_VALUE_TYPE_CODE;
import static com.technology.oracle.scheduler.option.shared.OptionConstant.NUMBER_VALUE_TYPE_CODE;
import static com.technology.oracle.scheduler.option.shared.OptionConstant.STRING_VALUE_TYPE_CODE;
import static com.technology.oracle.scheduler.option.shared.field.OptionFieldNames.BATCH_ID;
import static com.technology.oracle.scheduler.option.shared.field.OptionFieldNames.DATA_SOURCE;
import static com.technology.oracle.scheduler.option.shared.field.OptionFieldNames.DATE_VALUE;
import static com.technology.oracle.scheduler.option.shared.field.OptionFieldNames.ENCRYPTION_FLAG;
import static com.technology.oracle.scheduler.option.shared.field.OptionFieldNames.IS_EDIT_VALUE;
import static com.technology.oracle.scheduler.option.shared.field.OptionFieldNames.NUMBER_VALUE;
import static com.technology.oracle.scheduler.option.shared.field.OptionFieldNames.OPTION_DESCRIPTION;
import static com.technology.oracle.scheduler.option.shared.field.OptionFieldNames.OPTION_ID;
import static com.technology.oracle.scheduler.option.shared.field.OptionFieldNames.OPTION_NAME;
import static com.technology.oracle.scheduler.option.shared.field.OptionFieldNames.OPTION_SHORT_NAME;
import static com.technology.oracle.scheduler.option.shared.field.OptionFieldNames.STRING_LIST_SEPARATOR;
import static com.technology.oracle.scheduler.option.shared.field.OptionFieldNames.STRING_VALUE;
import static com.technology.oracle.scheduler.option.shared.field.OptionFieldNames.TEST_PROD_SENSITIVE_FLAG;
import static com.technology.oracle.scheduler.option.shared.field.OptionFieldNames.TIME_VALUE;
import static com.technology.oracle.scheduler.option.shared.field.OptionFieldNames.VALUE_INDEX;
import static com.technology.oracle.scheduler.option.shared.field.OptionFieldNames.VALUE_LIST_FLAG;
import static com.technology.oracle.scheduler.option.shared.field.OptionFieldNames.VALUE_TYPE_CODE;

import java.util.List;

import com.google.gwt.place.shared.Place;
import com.technology.jep.jepria.client.async.FirstTimeUseAsyncCallback;
import com.technology.jep.jepria.client.ui.WorkstateEnum;
import com.technology.jep.jepria.client.ui.eventbus.plain.PlainEventBus;
import com.technology.jep.jepria.client.ui.eventbus.plain.event.DoGetRecordEvent;
import com.technology.jep.jepria.client.ui.form.detail.DetailFormPresenter;
import com.technology.jep.jepria.client.ui.form.detail.DetailFormView;
import com.technology.jep.jepria.client.ui.plain.StandardClientFactory;
import com.technology.jep.jepria.client.widget.event.JepEvent;
import com.technology.jep.jepria.client.widget.event.JepEventType;
import com.technology.jep.jepria.client.widget.event.JepListener;
import com.technology.jep.jepria.shared.field.option.JepOption;
import com.technology.jep.jepria.shared.load.PagingConfig;
import com.technology.jep.jepria.shared.record.JepRecord;
import com.technology.jep.jepria.shared.util.JepRiaUtil;
import com.technology.oracle.scheduler.batch.client.history.scope.BatchScope;
import com.technology.oracle.scheduler.main.client.history.scope.SchedulerScope;
import com.technology.oracle.scheduler.option.client.history.scope.OptionScope;
import com.technology.oracle.scheduler.option.shared.service.OptionServiceAsync;
 
public class OptionDetailFormPresenter<E extends PlainEventBus, S extends OptionServiceAsync> 
		extends DetailFormPresenter<DetailFormView, E, S, StandardClientFactory<E, S>> { 
 
	public OptionDetailFormPresenter(Place place, StandardClientFactory<E, S> clientFactory) {
		super(scopeModuleIds, place, clientFactory);
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
		fields.addFieldListener(VALUE_TYPE_CODE, JepEventType.FIRST_TIME_USE_EVENT, new JepListener() {
			@Override
			public void handleEvent(final JepEvent event) {
				service.getValueType(SchedulerScope.instance.getDataSource().getName(), new FirstTimeUseAsyncCallback<List<JepOption>>(event) {
					public void onSuccessLoad(List<JepOption> result){
						fields.setFieldOptions(VALUE_TYPE_CODE, result);
					}
				});
			}
		});
		
		fields.addFieldListener(VALUE_TYPE_CODE, JepEventType.CHANGE_SELECTION_EVENT, new JepListener() {

			@Override
			public void handleEvent(JepEvent event) {
				setValueTypeFields();
			}
		});
	}
	
	public void onDoGetRecord(DoGetRecordEvent event) {
		
		//для корректной работы табов (ScopeModules)
		final PagingConfig pagingConfig = event.getPagingConfig();
		JepRecord record = pagingConfig.getTemplateRecord();
		record.set(DATA_SOURCE, SchedulerScope.instance.getDataSource());
		record.set(BATCH_ID, BatchScope.instance.getBatchId());
		
		fields.setFieldEditable(DATA_SOURCE, false);
		fields.setFieldValue(DATA_SOURCE, SchedulerScope.instance.getDataSource());
		fields.setFieldValue(BATCH_ID, BatchScope.instance.getBatchId());

		super.onDoGetRecord(event);
	}
	
	@Override
	protected boolean beforeSave(JepRecord currentRecord) {
		
		currentRecord.set(IS_EDIT_VALUE, OptionScope.instance.getIsEditValue());
		return super.beforeSave(currentRecord);
	}
	

	private void setValueTypeFields(){
		
		Boolean isEditValue = OptionScope.instance.getIsEditValue();
		Boolean showStringValue = false, showDateValue = false, showNumberValue = false;
		Boolean enabled = true;
		
		String valueTypeCode = JepOption.<String>getValue(fields.getFieldValue((VALUE_TYPE_CODE)));

		if(JepRiaUtil.isEmpty(valueTypeCode)){
			showStringValue = true;
			enabled = false;
		}
		
		fields.setFieldEditable(OPTION_NAME, CREATE.equals(_workstate) || SEARCH.equals(_workstate) || (EDIT.equals(_workstate) && !isEditValue));
		fields.setFieldEnabled(STRING_VALUE, enabled);
		fields.setFieldEnabled(DATE_VALUE, enabled);
		fields.setFieldEnabled(TIME_VALUE, enabled);
		fields.setFieldEnabled(NUMBER_VALUE, enabled);
		
		if(valueTypeCode == null){

		}else if(valueTypeCode.equals(DATE_VALUE_TYPE_CODE)){
			showDateValue = true;
		}else if(valueTypeCode.equals(NUMBER_VALUE_TYPE_CODE)){
			showNumberValue = true;
		}else if(valueTypeCode.equals(STRING_VALUE_TYPE_CODE)){
			showStringValue = true;
		}
		
		fields.setFieldVisible(STRING_VALUE, SEARCH.equals(_workstate) || (CREATE.equals(_workstate) || (EDIT.equals(_workstate) && isEditValue)) && showStringValue);
		fields.setFieldVisible(DATE_VALUE, (CREATE.equals(_workstate) || (EDIT.equals(_workstate) && isEditValue)) && showDateValue);
		fields.setFieldVisible(TIME_VALUE, (CREATE.equals(_workstate) || (EDIT.equals(_workstate) && isEditValue)) && showDateValue);
		fields.setFieldVisible(NUMBER_VALUE, (CREATE.equals(_workstate) || (EDIT.equals(_workstate) && isEditValue)) && showNumberValue);

		if((Boolean)fields.getFieldValue(VALUE_LIST_FLAG)){
			
			fields.setFieldValue(STRING_VALUE, null);
			fields.setFieldValue(DATE_VALUE, null);
			fields.setFieldValue(TIME_VALUE, null);
			fields.setFieldValue(NUMBER_VALUE, null);
		}
	}
	
 
	protected void adjustToWorkstate(WorkstateEnum workstate) {
		
		setValueTypeFields();
		Boolean isEditValue = OptionScope.instance.getIsEditValue();
		
		fields.setFieldValue(BATCH_ID, BatchScope.instance.getBatchId());
		fields.setFieldEditable(BATCH_ID, false);
		
		fields.setFieldVisible(OPTION_ID, EDIT.equals(workstate) || VIEW_DETAILS.equals(workstate));
		fields.setFieldVisible(OPTION_SHORT_NAME, VIEW_DETAILS.equals(workstate) || CREATE.equals(workstate) || SEARCH.equals(workstate));
		fields.setFieldVisible(STRING_LIST_SEPARATOR, CREATE.equals(workstate));
		fields.setFieldVisible(VALUE_INDEX, EDIT.equals(workstate) && isEditValue && (Boolean) fields.getFieldValue(VALUE_LIST_FLAG));
		fields.setFieldVisible(OPTION_DESCRIPTION, CREATE.equals(workstate) || SEARCH.equals(workstate) || (EDIT.equals(workstate) && !isEditValue) || VIEW_DETAILS.equals(workstate));
		fields.setFieldVisible(VALUE_LIST_FLAG, VIEW_DETAILS.equals(workstate) || CREATE.equals(workstate) || (EDIT.equals(workstate) && !isEditValue));
		fields.setFieldVisible(ENCRYPTION_FLAG, VIEW_DETAILS.equals(workstate) || CREATE.equals(workstate) || (EDIT.equals(workstate) && !isEditValue));
		fields.setFieldVisible(TEST_PROD_SENSITIVE_FLAG, VIEW_DETAILS.equals(workstate) || CREATE.equals(workstate) || (EDIT.equals(workstate) && !isEditValue));
 
		fields.setFieldValue(DATA_SOURCE, SchedulerScope.instance.getDataSource());
		
		fields.setFieldAllowBlank(OPTION_SHORT_NAME, !CREATE.equals(workstate));
		fields.setFieldAllowBlank(OPTION_NAME, !(VIEW_DETAILS.equals(workstate) || CREATE.equals(workstate) || (EDIT.equals(workstate) && !isEditValue)));
		fields.setFieldAllowBlank(VALUE_TYPE_CODE, !(VIEW_DETAILS.equals(workstate) || CREATE.equals(workstate) || (EDIT.equals(workstate) && !isEditValue)));
 
		fields.setFieldEditable(DATA_SOURCE, false);
		fields.setFieldEditable(OPTION_ID, false);
		fields.setFieldEditable(VALUE_TYPE_CODE, CREATE.equals(workstate) || SEARCH.equals(workstate) || (EDIT.equals(workstate) && !isEditValue));
 
	}
 
}
