package com.technology.oracle.optionasria.value.client.ui.form.detail;

import static com.technology.jep.jepria.client.ui.WorkstateEnum.CREATE;
import static com.technology.jep.jepria.client.ui.WorkstateEnum.EDIT;
import static com.technology.jep.jepria.client.ui.WorkstateEnum.SEARCH;
import static com.technology.jep.jepria.shared.field.JepFieldNames.MAX_ROW_COUNT;
import static com.technology.oracle.optionasria.main.shared.OptionAsRiaConstant.CURRENT_DATA_SOURCE;
import static com.technology.oracle.optionasria.option.shared.OptionConstant.dateValueTypeCode;
import static com.technology.oracle.optionasria.option.shared.OptionConstant.numberValueTypeCode;
import static com.technology.oracle.optionasria.option.shared.OptionConstant.stringValueTypeCode;
import static com.technology.oracle.optionasria.option.shared.field.OptionFieldNames.VALUE_LIST_FLAG;
import static com.technology.oracle.optionasria.option.shared.field.OptionFieldNames.VALUE_TYPE_CODE;
import static com.technology.oracle.optionasria.value.client.ValueClientConstant.valueText;
import static com.technology.oracle.optionasria.value.shared.field.ValueFieldNames.DATA_SOURCE;
import static com.technology.oracle.optionasria.value.shared.field.ValueFieldNames.DATE_VALUE;
import static com.technology.oracle.optionasria.value.shared.field.ValueFieldNames.INSTANCE_NAME;
import static com.technology.oracle.optionasria.value.shared.field.ValueFieldNames.NUMBER_VALUE;
import static com.technology.oracle.optionasria.value.shared.field.ValueFieldNames.OPTION_ID;
import static com.technology.oracle.optionasria.value.shared.field.ValueFieldNames.PROD_VALUE_FLAG_CHECKBOX;
import static com.technology.oracle.optionasria.value.shared.field.ValueFieldNames.STRING_LIST_SEPARATOR;
import static com.technology.oracle.optionasria.value.shared.field.ValueFieldNames.STRING_VALUE;
import static com.technology.oracle.optionasria.value.shared.field.ValueFieldNames.TIME_VALUE;
import static com.technology.oracle.optionasria.value.shared.field.ValueFieldNames.USED_OPERATOR_ID;
import static com.technology.oracle.optionasria.value.shared.field.ValueFieldNames.VALUE_INDEX;

import java.util.ArrayList;
import java.util.List;

import com.google.gwt.place.shared.Place;
import com.google.gwt.storage.client.Storage;
import com.technology.jep.jepria.client.async.JepAsyncCallback;
import com.technology.jep.jepria.client.async.TypingTimeoutAsyncCallback;
import com.technology.jep.jepria.client.ui.WorkstateEnum;
import com.technology.jep.jepria.client.ui.eventbus.plain.PlainEventBus;
import com.technology.jep.jepria.client.ui.eventbus.plain.event.DoDeleteEvent;
import com.technology.jep.jepria.client.ui.eventbus.plain.event.SearchEvent;
import com.technology.jep.jepria.client.ui.form.detail.DetailFormPresenter;
import com.technology.jep.jepria.client.ui.form.detail.DetailFormView;
import com.technology.jep.jepria.client.ui.plain.StandardClientFactory;
import com.technology.jep.jepria.client.widget.event.JepEvent;
import com.technology.jep.jepria.client.widget.event.JepEventType;
import com.technology.jep.jepria.client.widget.field.multistate.JepComboBoxField;
import com.technology.jep.jepria.shared.field.option.JepOption;
import com.technology.jep.jepria.shared.record.JepRecord;
import com.technology.oracle.optionasria.main.client.history.scope.OptionAsRiaScope;
import com.technology.oracle.optionasria.value.shared.service.ValueServiceAsync;

public class ValueDetailFormPresenter<E extends PlainEventBus, S extends ValueServiceAsync>
		extends DetailFormPresenter<DetailFormView, E, S, StandardClientFactory<E, S>> {

	private Storage storage = Storage.getSessionStorageIfSupported();
	private S service = clientFactory.getService();

	public ValueDetailFormPresenter(Place place, StandardClientFactory<E, S> clientFactory) {
    super(place, clientFactory);
  }

	/**
	 * Обработчик удаления, вызывающий непосредственно сервис удаления.
	 *
	 * @param yes вызывать ли сервис удаления: true - вызывать, иначе - не вызывать
	 * @param record запись, которую необходимо удалить
	 */
	protected void onDeleteConfirmation(Boolean yes, final JepRecord record) {
		record.set(DATA_SOURCE, OptionAsRiaScope.instance.getDataSource());
		super.onDeleteConfirmation(yes, record);
	}

	/**
	 * Обработчик события поиска "search".<br/>
	 *
	 * Особенности:<br/>
	 * Сохранение поискового шаблона осуществляется здесь, поскольку переход возможен не только с формы поиска (типовой случай),
	 * но и во время перехода с главной формы на подчиненную.
	 */
	@Override
	public void onSearch(SearchEvent event) {
		// Проинициализируем поисковый шаблон (независимо откуда был осуществлен переход: с формы поиска или с главной формы на подчиненную).
		searchTemplate = event.getPagingConfig().getTemplateRecord();
		searchTemplate.set(DATA_SOURCE, OptionAsRiaScope.instance.getDataSource());
		searchTemplate.set(CURRENT_DATA_SOURCE, storage.getItem(CURRENT_DATA_SOURCE));
		super.onSearch(event);
	}

	protected boolean beforeSave(JepRecord currentRecord) {
		currentRecord.set(DATA_SOURCE, OptionAsRiaScope.instance.getDataSource());
		JepRecord valueOptionRecord = OptionAsRiaScope.instance.getCurruntValueOption();
		currentRecord.set(VALUE_TYPE_CODE, valueOptionRecord.get(VALUE_TYPE_CODE));
		return super.beforeSave(currentRecord);
	}

	/*protected void saveOnCreate(JepRecord currentRecord) {
		currentRecord.set(DATA_SOURCE, OptionAsRiaScope.instance.getDataSource());
		JepRecord valueOptionRecord = OptionAsRiaScope.instance.getCurruntValueOption();
		currentRecord.set(OPTION_ID, valueOptionRecord.get(OPTION_ID));
		currentRecord.set(VALUE_TYPE_CODE, valueOptionRecord.get(VALUE_TYPE_CODE));
		super.saveOnCreate(currentRecord);
	}*/


	public void bind() {
		super.bind();
		// Здесь размещается код связывания presenter-а и view
		fields.addFieldListener(USED_OPERATOR_ID, JepEventType.TYPING_TIMEOUT_EVENT, event -> getOperator());
	}

	private static final Integer OPTION_NUMBER = 10;

	private void getOperator(){
		final JepComboBoxField usedOperatorComboBoxField = (JepComboBoxField) fields.get(USED_OPERATOR_ID);
		usedOperatorComboBoxField.setLoadingImage(true);
		String rawValue = usedOperatorComboBoxField.getRawValue();

		service.getOperator(JepOption.<String>getValue(OptionAsRiaScope.instance.getDataSource()), rawValue + "%", OPTION_NUMBER, new TypingTimeoutAsyncCallback<List<JepOption>>(new JepEvent(null)) {
			@SuppressWarnings("unchecked")
			public void onSuccessLoad(List<JepOption> result){
				JepComboBoxField usedOperatorComboBoxField = (JepComboBoxField) fields.get(USED_OPERATOR_ID);
				List<JepOption> operatorIdsList = new ArrayList<JepOption>();
				if(result.size() >= OPTION_NUMBER){
					for(Integer count = 0;!count.equals(OPTION_NUMBER); count++) {
						operatorIdsList.add(result.get(count));
					}
				} else {
					operatorIdsList = result;
				}
				usedOperatorComboBoxField.setLastOptionText(result.size() >= OPTION_NUMBER ? valueText.value_detail_used_operator_id_lastOptionText() : null);
				usedOperatorComboBoxField.setOptions(operatorIdsList);
				usedOperatorComboBoxField.setLoadingImage(false);
			}
			public void onFailure(Throwable caught) {
				usedOperatorComboBoxField.setLoadingImage(false);
				super.onFailure(caught);
			}
		});

		/*
		service.getResponsibilityOperator(rawValue + "%", OPTION_NUMBER, new JepTypingTimeoutAsyncCallback<List<JepOption>>(new JepEvent(operatorField)) {
			@SuppressWarnings("unchecked")
			public void onSuccessLoad(List<JepOption> result){

				JepComboBoxField operatorField = (JepComboBoxField) fields.get(RESPONSIBILITY_OPERATOR_ID);
				List<JepOption> operatorIdsList = new ArrayList<JepOption>();

				if(result.size() >= OPTION_NUMBER){

					for(Integer count = 0;!count.equals(OPTION_NUMBER); count++){
						operatorIdsList.add(result.get(count));
					}

				}else{
					operatorIdsList = result;
				}

				operatorField.setLastOptionText(result.size() >= OPTION_NUMBER ? fraudText.fraud_detail_responsibility_operator_id_lastOptionText() : null);
				operatorField.setOptions(operatorIdsList);
			}
		});
		 */
	}

	@Override
	protected void saveOnEdit(JepRecord currentRecord) {
		service.setCurrentDataSource(storage.getItem(CURRENT_DATA_SOURCE), new JepAsyncCallback<Void>() {
			@Override
			public void onSuccess(Void result) {
			}
		});
		currentRecord.set(CURRENT_DATA_SOURCE, storage.getItem(CURRENT_DATA_SOURCE));
		super.saveOnEdit(currentRecord);
	}

	@Override
	protected void saveOnCreate(JepRecord currentRecord) {
		service.setCurrentDataSource(storage.getItem(CURRENT_DATA_SOURCE), new JepAsyncCallback<Void>() {
			@Override
			public void onSuccess(Void result) {
				currentRecord.set(DATA_SOURCE, OptionAsRiaScope.instance.getDataSource());
				JepRecord valueOptionRecord = OptionAsRiaScope.instance.getCurruntValueOption();
				currentRecord.set(OPTION_ID, valueOptionRecord.get(OPTION_ID));
				currentRecord.set(VALUE_TYPE_CODE, valueOptionRecord.get(VALUE_TYPE_CODE));
			}
		});
		currentRecord.set(CURRENT_DATA_SOURCE, storage.getItem(CURRENT_DATA_SOURCE));
		super.saveOnCreate(currentRecord);
	}

	public void onDoDelete(DoDeleteEvent event){
		service.setCurrentDataSource(storage.getItem(CURRENT_DATA_SOURCE), new JepAsyncCallback<Void>() {
			@Override
			public void onSuccess(Void result) {
			}
		});
		super.onDoDelete(event);
	}

	protected void adjustToWorkstate(WorkstateEnum workstate) {
		Boolean showStringValue = false, showDateValue = false, showNumberValue = false;
		String valueTypeCode = JepOption.<String>getValue(fields.getFieldValue(VALUE_TYPE_CODE));
		JepRecord valueOption = OptionAsRiaScope.instance.getCurruntValueOption();

		if(valueTypeCode == null) {
			fields.setFieldValue(VALUE_TYPE_CODE, valueOption.get(VALUE_TYPE_CODE));
			valueTypeCode  = JepOption.<String> getValue(valueOption.get(VALUE_TYPE_CODE));
		}

		if(valueTypeCode == null) {
		} else if(valueTypeCode.equals(dateValueTypeCode)){
			showDateValue = true;
		} else if(valueTypeCode.equals(numberValueTypeCode)){
			showNumberValue = true;
		} else if(valueTypeCode.equals(stringValueTypeCode)){
			showStringValue = true;
		}

		fields.setFieldEditable(VALUE_TYPE_CODE, false);
		fields.setFieldEditable(USED_OPERATOR_ID, CREATE.equals(workstate));

		fields.setFieldVisible(STRING_VALUE, showStringValue);
		fields.setFieldVisible(DATE_VALUE, showDateValue);
		fields.setFieldVisible(TIME_VALUE, showDateValue);
		fields.setFieldVisible(NUMBER_VALUE, showNumberValue);

		fields.setFieldVisible(PROD_VALUE_FLAG_CHECKBOX, CREATE.equals(workstate));
		fields.setFieldVisible(INSTANCE_NAME, CREATE.equals(workstate));
		fields.setFieldVisible(STRING_LIST_SEPARATOR, CREATE.equals(workstate));
		fields.setFieldVisible(VALUE_INDEX, EDIT.equals(workstate) && (Boolean) valueOption.get(VALUE_LIST_FLAG));

		fields.setFieldVisible(MAX_ROW_COUNT, SEARCH.equals(workstate));
		fields.setFieldAllowBlank(MAX_ROW_COUNT, !SEARCH.equals(workstate));
		fields.setFieldValue(MAX_ROW_COUNT, 25);

		if((Boolean)valueOption.get(VALUE_LIST_FLAG)){
			fields.setFieldValue(STRING_VALUE, null);
			fields.setFieldValue(DATE_VALUE, null);
			fields.setFieldValue(TIME_VALUE, null);
			fields.setFieldValue(NUMBER_VALUE, null);
		}
	}
}
