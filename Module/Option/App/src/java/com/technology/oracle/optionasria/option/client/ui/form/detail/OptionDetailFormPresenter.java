package com.technology.oracle.optionasria.option.client.ui.form.detail;

import static com.technology.jep.jepria.client.JepRiaClientConstant.JepTexts;
import static com.technology.jep.jepria.client.ui.WorkstateEnum.CREATE;
import static com.technology.jep.jepria.client.ui.WorkstateEnum.EDIT;
import static com.technology.jep.jepria.client.ui.WorkstateEnum.SEARCH;
import static com.technology.jep.jepria.client.ui.WorkstateEnum.VIEW_DETAILS;
import static com.technology.jep.jepria.shared.field.JepFieldNames.MAX_ROW_COUNT;
import static com.technology.oracle.optionasria.main.shared.OptionAsRiaConstant.DATA_SOURCE_LIST;
import static com.technology.oracle.optionasria.option.client.OptionClientConstant.scopeModuleIds;
import static com.technology.oracle.optionasria.option.shared.OptionConstant.dateValueTypeCode;
import static com.technology.oracle.optionasria.option.shared.OptionConstant.numberValueTypeCode;
import static com.technology.oracle.optionasria.option.shared.OptionConstant.stringValueTypeCode;
import static com.technology.oracle.optionasria.option.shared.field.OptionFieldNames.DATE_VALUE;
import static com.technology.oracle.optionasria.option.shared.field.OptionFieldNames.ENCRYPTION_FLAG;
import static com.technology.oracle.optionasria.option.shared.field.OptionFieldNames.IS_EDIT_VALUE;
import static com.technology.oracle.optionasria.option.shared.field.OptionFieldNames.MODULE_ID;
import static com.technology.oracle.optionasria.option.shared.field.OptionFieldNames.NUMBER_VALUE;
import static com.technology.oracle.optionasria.option.shared.field.OptionFieldNames.OBJECT_SHORT_NAME;
import static com.technology.oracle.optionasria.option.shared.field.OptionFieldNames.OBJECT_TYPE_ID;
import static com.technology.oracle.optionasria.option.shared.field.OptionFieldNames.OPTION_DESCRIPTION;
import static com.technology.oracle.optionasria.option.shared.field.OptionFieldNames.OPTION_ID;
import static com.technology.oracle.optionasria.option.shared.field.OptionFieldNames.OPTION_NAME;
import static com.technology.oracle.optionasria.option.shared.field.OptionFieldNames.OPTION_SHORT_NAME;
import static com.technology.oracle.optionasria.option.shared.field.OptionFieldNames.STRING_LIST_SEPARATOR;
import static com.technology.oracle.optionasria.option.shared.field.OptionFieldNames.STRING_VALUE;
import static com.technology.oracle.optionasria.option.shared.field.OptionFieldNames.TEST_PROD_SENSITIVE_FLAG;
import static com.technology.oracle.optionasria.option.shared.field.OptionFieldNames.TIME_VALUE;
import static com.technology.oracle.optionasria.option.shared.field.OptionFieldNames.VALUE_INDEX;
import static com.technology.oracle.optionasria.option.shared.field.OptionFieldNames.VALUE_LIST_FLAG;
import static com.technology.oracle.optionasria.option.shared.field.OptionFieldNames.VALUE_TYPE_CODE;
import static com.technology.oracle.optionasria.value.shared.field.ValueFieldNames.DATA_SOURCE;

import java.util.ArrayList;
import java.util.List;

import com.google.gwt.place.shared.Place;
import com.technology.jep.jepria.client.async.FirstTimeUseAsyncCallback;
import com.technology.jep.jepria.client.async.JepAsyncCallback;
import com.technology.jep.jepria.client.ui.WorkstateEnum;
import com.technology.jep.jepria.client.ui.eventbus.plain.PlainEventBus;
import com.technology.jep.jepria.client.ui.eventbus.plain.event.DoGetRecordEvent;
import com.technology.jep.jepria.client.ui.eventbus.plain.event.SetCurrentRecordEvent;
import com.technology.jep.jepria.client.ui.form.detail.DetailFormPresenter;
import com.technology.jep.jepria.client.ui.plain.StandardClientFactory;
import com.technology.jep.jepria.client.util.JepClientUtil;
import com.technology.jep.jepria.client.widget.event.JepEventType;
import com.technology.jep.jepria.client.widget.field.multistate.JepComboBoxField;
import com.technology.jep.jepria.shared.field.option.JepOption;
import com.technology.jep.jepria.shared.load.PagingConfig;
import com.technology.jep.jepria.shared.record.JepRecord;
import com.technology.jep.jepria.shared.util.JepRiaUtil;
import com.technology.oracle.optionasria.main.client.history.scope.OptionAsRiaScope;
import com.technology.oracle.optionasria.option.shared.service.OptionServiceAsync;

public class OptionDetailFormPresenter<E extends PlainEventBus, S extends OptionServiceAsync>
		extends DetailFormPresenter<OptionDetailFormView, E, S, StandardClientFactory<E, S>> {

	private S service = clientFactory.getService();

	public OptionDetailFormPresenter(Place place, StandardClientFactory<E, S> clientFactory) {
	  super(scopeModuleIds, place, clientFactory);
  }

	@Override
	public void onSetCurrentRecord(SetCurrentRecordEvent event) {
		JepRecord currentRecord = event.getCurrentRecord();
		OptionAsRiaScope.instance.setCurruntValueOption(currentRecord);
		super.onSetCurrentRecord(event);
	}

	/**
	 * Обработчик события получения записи по первичному ключу.<br/>
	 *
	 * Особенности:<br/>
	 * После получения записи происходит инициализация полей формы полученными значениями.
	 *
	 * @param event событие получения записи
	 */
	public void onDoGetRecord(DoGetRecordEvent event) {
		final PagingConfig pagingConfig = event.getPagingConfig();
		JepRecord record = pagingConfig.getTemplateRecord();
		record.set(DATA_SOURCE, OptionAsRiaScope.instance.getDataSource());
		super.onDoGetRecord(event);
	}

	protected boolean beforeSave(JepRecord currentRecord) {
		currentRecord.set(IS_EDIT_VALUE, OptionAsRiaScope.instance.getIsEditValue());
		return super.beforeSave(currentRecord);
	}

	public void bind() {
		super.bind();
		// Здесь размещается код связывания presenter-а и view
		fields.addFieldListener(DATA_SOURCE, JepEventType.FIRST_TIME_USE_EVENT, event -> service.getDataSource(new FirstTimeUseAsyncCallback<JepRecord>(event) {
    	 public void onSuccessLoad(JepRecord result) {
    		fields.setFieldOptions(DATA_SOURCE, result.get(DATA_SOURCE_LIST));
    	}
    }));

		fields.addFieldListener(DATA_SOURCE, JepEventType.CHANGE_SELECTION_EVENT, event -> {
      final String DATA_SOURCE_CHANGE_LAYER_ID = "DATA_SOURCE_CHANGE_LAYER";
      final JepOption dataSource = (JepOption) event.getParameter();
      JepClientUtil.showLoadingPanel(DATA_SOURCE_CHANGE_LAYER_ID, null, JepTexts.loadingPanel_dataLoading());
      service.setCurrentDataSource(JepOption.<String>getValue(dataSource), new JepAsyncCallback<Void>() {
        @Override
        public void onSuccess(Void result) {
          setDataSourceDependFields(dataSource);
          setValueTypeFields();
          changeModules(dataSource);
          objectTypes(dataSource);
          JepClientUtil.hideLoadingPanel(DATA_SOURCE_CHANGE_LAYER_ID);
        }
      });
    });

		/*
		fields.addFieldListener(MODULE_ID, JepEventType.FIRST_TIME_USE_EVENT, new JepListener() {
			@Override
			public void handleEvent(final JepEvent event) {
				service.getModule(JepOption.<String>getValue(fields.getFieldValue(DATA_SOURCE)), new JepFirstTimeUseAsyncCallback<List<JepOption>>(event) {
					public void onSuccessLoad(List<JepOption> result){
						fields.setFieldOptions(MODULE_ID, result);
					}
				});
			}
		});

		fields.addFieldListener(OBJECT_TYPE_ID, JepEventType.FIRST_TIME_USE_EVENT, new JepListener() {
			@Override
			public void handleEvent(final JepEvent event) {
				service.getObjectType(JepOption.<String>getValue(fields.getFieldValue(DATA_SOURCE)), new JepFirstTimeUseAsyncCallback<List<JepOption>>(event) {
					public void onSuccessLoad(List<JepOption> result){
						fields.setFieldOptions(OBJECT_TYPE_ID, result);
					}
				});
			}
		});
		 */
		fields.addFieldListener(VALUE_TYPE_CODE, JepEventType.FIRST_TIME_USE_EVENT, event -> service.getValueType(new FirstTimeUseAsyncCallback<List<JepOption>>(event) {
    	public void onSuccessLoad(List<JepOption> result){
    		fields.setFieldOptions(VALUE_TYPE_CODE, result);
    	}
    }));
		fields.addFieldListener(VALUE_TYPE_CODE, JepEventType.CHANGE_SELECTION_EVENT, event -> setValueTypeFields());
	}

	private void objectTypes(JepOption dataSource){
		fields.clearField(OBJECT_TYPE_ID);
		final JepComboBoxField objectTypeComboBoxField = (JepComboBoxField)fields.get(OBJECT_TYPE_ID);
		if(!JepRiaUtil.isEmpty(dataSource)){
			objectTypeComboBoxField.setLoadingImage(true);
			fields.setFieldEnabled(OBJECT_TYPE_ID, false);
			//service.getObjectType(new TypingTimeoutAsyncCallback<List<JepOption>>(new JepEvent(objectTypeComboBoxField)) {
			service.getObjectType(new JepAsyncCallback<List<JepOption>>() {
				//public void onSuccessLoad(List<JepOption> result){
				public void onSuccess(List<JepOption> result) {
					objectTypeComboBoxField.setLoadingImage(false);
					fields.setFieldEnabled(OBJECT_TYPE_ID, true);
					fields.setFieldOptions(OBJECT_TYPE_ID, result);
				}
				public void onFailure(Throwable caught) {
					objectTypeComboBoxField.setLoadingImage(false);
					fields.setFieldOptions(OBJECT_TYPE_ID, new ArrayList<JepOption>());
					super.onFailure(caught);
				}
			});
		}
	}

	private void changeModules(JepOption dataSource){
		fields.clearField(MODULE_ID);
		final JepComboBoxField moduleComboBoxField = (JepComboBoxField)fields.get(MODULE_ID);
		if(!JepRiaUtil.isEmpty(dataSource)){
			moduleComboBoxField.setLoadingImage(true);
			fields.setFieldEnabled(MODULE_ID, false);
		  //service.getModule(new TypingTimeoutAsyncCallback<List<JepOption>>(new JepEvent(moduleComboBoxField)) {
			service.getModule(new JepAsyncCallback<List<JepOption>>() {
				//public void onSuccessLoad(List<JepOption> result){
			  public void onSuccess(List<JepOption> result) {
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

	private void setDataSourceDependFields(JepOption dataSource){
		Boolean enabled = false;
		if(!JepRiaUtil.isEmpty(dataSource) || _workstate.equals(EDIT)) {
			enabled = true;
		}
		fields.setFieldEnabled(OPTION_ID, enabled);
		fields.setFieldEnabled(MODULE_ID, enabled);
		fields.setFieldEnabled(OBJECT_SHORT_NAME, enabled);
		fields.setFieldEnabled(OBJECT_TYPE_ID, enabled);
		fields.setFieldEnabled(OPTION_SHORT_NAME, enabled);
		fields.setFieldEnabled(OPTION_NAME, enabled);
		fields.setFieldEnabled(OPTION_DESCRIPTION, enabled);
		fields.setFieldEnabled(STRING_VALUE, enabled);
		fields.setFieldEnabled(VALUE_TYPE_CODE, enabled);
	}

	private void setValueTypeFields(){
		Boolean isEditValue = OptionAsRiaScope.instance.getIsEditValue();
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

		if(valueTypeCode == null) {
		} else if(valueTypeCode.equals(dateValueTypeCode)) {
			showDateValue = true;
		} else if(valueTypeCode.equals(numberValueTypeCode)) {
			showNumberValue = true;
		} else if(valueTypeCode.equals(stringValueTypeCode)) {
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
		setDataSourceDependFields(fields.getFieldValue(DATA_SOURCE));
		setValueTypeFields();
		Boolean isEditValue = OptionAsRiaScope.instance.getIsEditValue();

//		fields.setFieldVisible(DATA_SOURCE, VIEW_DETAILS.equals(workstate) || CREATE.equals(workstate) || SEARCH.equals(workstate));
		fields.setFieldVisible(OPTION_ID, SEARCH.equals(workstate) || EDIT.equals(workstate) || VIEW_DETAILS.equals(workstate));
		fields.setFieldVisible(MODULE_ID, CREATE.equals(workstate) || SEARCH.equals(workstate) || (EDIT.equals(workstate) && !isEditValue) || VIEW_DETAILS.equals(workstate));
		fields.setFieldVisible(OBJECT_SHORT_NAME, CREATE.equals(workstate) || SEARCH.equals(workstate) || (EDIT.equals(workstate) && !isEditValue) || VIEW_DETAILS.equals(workstate));
		fields.setFieldVisible(OBJECT_TYPE_ID, CREATE.equals(workstate) || SEARCH.equals(workstate) || (EDIT.equals(workstate) && !isEditValue) || VIEW_DETAILS.equals(workstate));
		fields.setFieldVisible(OPTION_DESCRIPTION, CREATE.equals(workstate) || SEARCH.equals(workstate) || (EDIT.equals(workstate) && !isEditValue) || VIEW_DETAILS.equals(workstate));

		fields.setFieldVisible(VALUE_INDEX, EDIT.equals(workstate) && isEditValue && (Boolean) fields.getFieldValue(VALUE_LIST_FLAG));
		fields.setFieldVisible(VALUE_TYPE_CODE, VIEW_DETAILS.equals(workstate) || CREATE.equals(workstate) || EDIT.equals(workstate));
		fields.setFieldVisible(VALUE_LIST_FLAG, VIEW_DETAILS.equals(workstate) || CREATE.equals(workstate) || (EDIT.equals(workstate) && !isEditValue));
		fields.setFieldVisible(ENCRYPTION_FLAG, VIEW_DETAILS.equals(workstate) || CREATE.equals(workstate) || (EDIT.equals(workstate) && !isEditValue));
		fields.setFieldVisible(TEST_PROD_SENSITIVE_FLAG, VIEW_DETAILS.equals(workstate) || CREATE.equals(workstate) || (EDIT.equals(workstate) && !isEditValue));
		fields.setFieldVisible(STRING_LIST_SEPARATOR, CREATE.equals(workstate));
//		fields.setFieldValue(STRING_LIST_SEPARATOR, ';');

		fields.setFieldAllowBlank(DATA_SOURCE, false);
//		fields.setFieldAllowBlank(OPTION_VALUE, CREATE.equals(workstate) || (EDIT.equals(workstate) && !isEditValue));
		fields.setFieldAllowBlank(OPTION_ID, !EDIT.equals(workstate));
		fields.setFieldAllowBlank(MODULE_ID, !(VIEW_DETAILS.equals(workstate) || CREATE.equals(workstate) || EDIT.equals(workstate)));
		fields.setFieldAllowBlank(OPTION_SHORT_NAME, !(VIEW_DETAILS.equals(workstate) || CREATE.equals(workstate) || EDIT.equals(workstate)));
		fields.setFieldAllowBlank(OPTION_NAME, !(VIEW_DETAILS.equals(workstate) || CREATE.equals(workstate) || EDIT.equals(workstate)));
//		fields.setFieldAllowBlank(OPTION_DESCRIPTION, !EDIT.equals(workstate));
		fields.setFieldAllowBlank(VALUE_TYPE_CODE, !(VIEW_DETAILS.equals(workstate) || CREATE.equals(workstate) || EDIT.equals(workstate)));
//		fields.setFieldAllowBlank(VALUE_LIST_FLAG, !EDIT.equals(workstate));
//		fields.setFieldAllowBlank(ENCRYPTION_FLAG, !EDIT.equals(workstate));
//		fields.setFieldAllowBlank(TEST_PROD_SENSITIVE_FLAG, !EDIT.equals(workstate));

		fields.setFieldEditable(DATA_SOURCE, CREATE.equals(workstate) || SEARCH.equals(workstate));
		fields.setFieldEditable(OPTION_ID, CREATE.equals(workstate) || SEARCH.equals(workstate));
		fields.setFieldEditable(MODULE_ID, CREATE.equals(workstate) || SEARCH.equals(workstate));
		fields.setFieldEditable(OBJECT_SHORT_NAME, CREATE.equals(workstate) || SEARCH.equals(workstate));
		fields.setFieldEditable(OBJECT_TYPE_ID, CREATE.equals(workstate) || SEARCH.equals(workstate));
		fields.setFieldEditable(OPTION_SHORT_NAME, CREATE.equals(workstate) || SEARCH.equals(workstate));
		fields.setFieldEditable(VALUE_TYPE_CODE, CREATE.equals(workstate) || SEARCH.equals(workstate) || (EDIT.equals(workstate) && !isEditValue));

		fields.setFieldVisible(MAX_ROW_COUNT, SEARCH.equals(workstate));
		fields.setFieldAllowBlank(MAX_ROW_COUNT, !SEARCH.equals(workstate));
		fields.setFieldValue(MAX_ROW_COUNT, 25);
	}
}
