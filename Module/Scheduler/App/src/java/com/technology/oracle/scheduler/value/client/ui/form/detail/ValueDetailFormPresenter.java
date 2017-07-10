package com.technology.oracle.scheduler.value.client.ui.form.detail;
 
import static com.technology.jep.jepria.client.ui.WorkstateEnum.CREATE;
import static com.technology.jep.jepria.client.ui.WorkstateEnum.EDIT;
import static com.technology.oracle.scheduler.option.shared.OptionConstant.DATE_VALUE_TYPE_CODE;
import static com.technology.oracle.scheduler.option.shared.OptionConstant.NUMBER_VALUE_TYPE_CODE;
import static com.technology.oracle.scheduler.option.shared.OptionConstant.STRING_VALUE_TYPE_CODE;
import static com.technology.oracle.scheduler.option.shared.field.OptionFieldNames.VALUE_LIST_FLAG;
import static com.technology.oracle.scheduler.option.shared.field.OptionFieldNames.VALUE_TYPE_CODE;
import static com.technology.oracle.scheduler.value.shared.field.ValueFieldNames.BATCH_ID;
import static com.technology.oracle.scheduler.value.shared.field.ValueFieldNames.DATE_VALUE;
import static com.technology.oracle.scheduler.value.shared.field.ValueFieldNames.INSTANCE_NAME;
import static com.technology.oracle.scheduler.value.shared.field.ValueFieldNames.NUMBER_VALUE;
import static com.technology.oracle.scheduler.value.shared.field.ValueFieldNames.PROD_VALUE_FLAG_COMBOBOX;
import static com.technology.oracle.scheduler.value.shared.field.ValueFieldNames.STRING_LIST_SEPARATOR;
import static com.technology.oracle.scheduler.value.shared.field.ValueFieldNames.STRING_VALUE;
import static com.technology.oracle.scheduler.value.shared.field.ValueFieldNames.TIME_VALUE;
import static com.technology.oracle.scheduler.value.shared.field.ValueFieldNames.VALUE_INDEX;

import com.google.gwt.place.shared.Place;
import com.technology.jep.jepria.client.ui.WorkstateEnum;
import com.technology.jep.jepria.client.ui.eventbus.plain.PlainEventBus;
import com.technology.jep.jepria.client.ui.form.detail.DetailFormPresenter;
import com.technology.jep.jepria.client.ui.form.detail.DetailFormView;
import com.technology.jep.jepria.client.ui.plain.StandardClientFactory;
import com.technology.jep.jepria.shared.field.option.JepOption;
import com.technology.jep.jepria.shared.record.JepRecord;
import com.technology.oracle.scheduler.batch.client.history.scope.BatchScope;
import com.technology.oracle.scheduler.option.client.history.scope.OptionScope;
import com.technology.oracle.scheduler.value.shared.service.ValueServiceAsync;
 
public class ValueDetailFormPresenter<E extends PlainEventBus, S extends ValueServiceAsync> 
    extends DetailFormPresenter<DetailFormView, E, S, StandardClientFactory<E, S>> { 
   
  public ValueDetailFormPresenter(Place place, StandardClientFactory<E, S> clientFactory) {
    super(place, clientFactory);
  }
 

  public void bind() {
    super.bind();
  }
  
  /*
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
  */
  
 
  protected void adjustToWorkstate(WorkstateEnum workstate) {
    
    fields.setFieldValue(BATCH_ID, BatchScope.instance.getBatchId());
    fields.setFieldEditable(BATCH_ID, false);
    
    Boolean showStringValue = false, showDateValue = false, showNumberValue = false;
    String valueTypeCode = JepOption.<String>getValue(fields.getFieldValue(VALUE_TYPE_CODE));
    JepRecord valueOption = OptionScope.instance.getCurruntValueOption();
    
    if(valueTypeCode == null) {
      
      fields.setFieldValue(VALUE_TYPE_CODE, valueOption.get(VALUE_TYPE_CODE));
      valueTypeCode  = JepOption.<String> getValue(valueOption.get(VALUE_TYPE_CODE));
    }
    
    if(valueTypeCode == null) {
      
    } else if(valueTypeCode.equals(DATE_VALUE_TYPE_CODE)) {
      showDateValue = true;
    } else if(valueTypeCode.equals(NUMBER_VALUE_TYPE_CODE)) {
      showNumberValue = true;
    } else if(valueTypeCode.equals(STRING_VALUE_TYPE_CODE)) {
      showStringValue = true;
    }
    
    fields.setFieldEditable(VALUE_TYPE_CODE, false);
    fields.setFieldVisible(STRING_VALUE, showStringValue);
    fields.setFieldVisible(DATE_VALUE, showDateValue);
    fields.setFieldVisible(TIME_VALUE, showDateValue);
    fields.setFieldVisible(NUMBER_VALUE, showNumberValue);

    fields.setFieldVisible(PROD_VALUE_FLAG_COMBOBOX, CREATE.equals(workstate));
    fields.setFieldVisible(INSTANCE_NAME, CREATE.equals(workstate));
    fields.setFieldVisible(STRING_LIST_SEPARATOR, CREATE.equals(workstate));
    fields.setFieldVisible(
        VALUE_INDEX, EDIT.equals(workstate) 
        && Boolean.TRUE.equals((Boolean) valueOption.get(VALUE_LIST_FLAG)));
    
    if(Boolean.TRUE.equals((Boolean) valueOption.get(VALUE_LIST_FLAG))) {
      
      fields.setFieldValue(STRING_VALUE, null);
      fields.setFieldValue(DATE_VALUE, null);
      fields.setFieldValue(TIME_VALUE, null);
      fields.setFieldValue(NUMBER_VALUE, null);
    }
 
  }
 
}
