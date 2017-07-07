package com.technology.oracle.scheduler.value.client.ui.form.detail;
 
import static com.technology.jep.jepria.client.JepRiaClientConstant.JepTexts;
import static com.technology.oracle.scheduler.batch.client.BatchClientConstant.batchText;
import static com.technology.oracle.scheduler.option.client.OptionClientConstant.optionText;
import static com.technology.oracle.scheduler.option.shared.field.OptionFieldNames.DATA_SOURCE;
import static com.technology.oracle.scheduler.value.client.ValueClientConstant.valueText;
import static com.technology.oracle.scheduler.value.shared.field.ValueFieldNames.BATCH_ID;
import static com.technology.oracle.scheduler.value.shared.field.ValueFieldNames.DATE_VALUE;
import static com.technology.oracle.scheduler.value.shared.field.ValueFieldNames.INSTANCE_NAME;
import static com.technology.oracle.scheduler.value.shared.field.ValueFieldNames.NUMBER_VALUE;
import static com.technology.oracle.scheduler.value.shared.field.ValueFieldNames.PROD_VALUE_FLAG_COMBOBOX;
import static com.technology.oracle.scheduler.value.shared.field.ValueFieldNames.STRING_LIST_SEPARATOR;
import static com.technology.oracle.scheduler.value.shared.field.ValueFieldNames.STRING_VALUE;
import static com.technology.oracle.scheduler.value.shared.field.ValueFieldNames.TIME_VALUE;
import static com.technology.oracle.scheduler.value.shared.field.ValueFieldNames.VALUE_INDEX;
import static com.technology.oracle.scheduler.value.shared.field.ValueFieldNames.VALUE_TYPE_CODE;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

import com.google.gwt.dom.client.Style.Unit;
import com.google.gwt.user.client.ui.DoubleBox;
import com.google.gwt.user.client.ui.ScrollPanel;
import com.google.gwt.user.client.ui.VerticalPanel;
import com.technology.jep.jepria.client.ui.form.detail.DetailFormViewImpl;
import com.technology.jep.jepria.client.widget.field.FieldManager;
import com.technology.jep.jepria.client.widget.field.multistate.JepComboBoxField;
import com.technology.jep.jepria.client.widget.field.multistate.JepDateField;
import com.technology.jep.jepria.client.widget.field.multistate.JepNumberField;
import com.technology.jep.jepria.client.widget.field.multistate.JepTextField;
import com.technology.jep.jepria.client.widget.field.multistate.JepTimeField;
import com.technology.jep.jepria.shared.field.option.JepOption;
 
public class ValueDetailFormViewImpl extends DetailFormViewImpl {  
 
  public ValueDetailFormViewImpl() {
    super(new FieldManager());
    
    ScrollPanel scrollPanel = new ScrollPanel();
    scrollPanel.setSize("100%", "100%");
    VerticalPanel panel = new VerticalPanel();
    panel.getElement().getStyle().setMarginTop(5, Unit.PX);
    scrollPanel.add(panel);
 
 
    JepNumberField batchIdNumberField = new JepNumberField(batchText.batch_detail_batch_id());
    JepComboBoxField dataSourceComboBoxField = new JepComboBoxField(optionText.option_detail_data_source());
    JepComboBoxField prodValueFlagJepComboBoxField = new JepComboBoxField(valueText.value_detail_prod_value_flag());
    List<JepOption> options = new ArrayList<JepOption>();
    options.add(new JepOption(JepTexts.yes(), 1));
    options.add(new JepOption(JepTexts.no(), 0));
    
    prodValueFlagJepComboBoxField.setOptions(options);
    
    JepTextField instanceNameTextField = new JepTextField(valueText.value_detail_instance_name());
    JepTextField stringListSeparatorTextField = new JepTextField(valueText.value_detail_string_list_separator());
    JepDateField dateValueDateField = new JepDateField(valueText.value_detail_date_value());
    JepTimeField timeValueTimeField = new JepTimeField(optionText.option_detail_time_value());
    
    JepNumberField numberValueNumberField = new JepNumberField(valueText.value_detail_number_value()){
      
      @Override
      protected void addEditableCard() {
        editableCard = new DoubleBox(){
          @Override
          public void setValue(Double value) {
            super.setText(value == null ? "" : value.toString());
          }
        };
        editablePanel.add(editableCard);
        
        // Добавляем обработчик события "нажатия клавиши" для проверки ввода символов.
        initKeyPressHandler();
      }
    };    
    JepTextField stringValueTextField = new JepTextField(valueText.value_detail_string_value());
    JepTextField valueIndexTextField = new JepTextField(valueText.value_detail_value_index());
    valueIndexTextField.setTitle(optionText.option_detail_value_index_desc());
    
    JepComboBoxField valueTypeCodeComboBoxField = new JepComboBoxField(valueText.value_list_value_type_name());
    
    panel.add(dataSourceComboBoxField);
    panel.add(batchIdNumberField);
    panel.add(prodValueFlagJepComboBoxField);
    panel.add(instanceNameTextField);
    panel.add(valueTypeCodeComboBoxField);
    
    panel.add(dateValueDateField);
    panel.add(timeValueTimeField);
    panel.add(numberValueNumberField);
    panel.add(stringValueTextField);
    panel.add(valueIndexTextField);
    panel.add(stringListSeparatorTextField);
    
    setWidget(scrollPanel);
 
    fields.put(DATA_SOURCE, dataSourceComboBoxField);
    fields.put(BATCH_ID, batchIdNumberField);
    fields.put(PROD_VALUE_FLAG_COMBOBOX, prodValueFlagJepComboBoxField);
    fields.put(VALUE_TYPE_CODE, valueTypeCodeComboBoxField);
    fields.put(INSTANCE_NAME, instanceNameTextField);
    fields.put(STRING_LIST_SEPARATOR, stringListSeparatorTextField);
    fields.put(DATE_VALUE, dateValueDateField);
    fields.put(TIME_VALUE, timeValueTimeField);
    fields.put(NUMBER_VALUE, numberValueNumberField);
    fields.put(STRING_VALUE, stringValueTextField);
    fields.put(VALUE_INDEX, valueIndexTextField);
  }
 
}
