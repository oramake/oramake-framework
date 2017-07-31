package com.technology.oracle.scheduler.option.client.ui.form.detail;
 
import static com.technology.oracle.scheduler.batch.client.BatchClientConstant.batchText;
import static com.technology.oracle.scheduler.option.client.OptionClientConstant.optionText;
import static com.technology.oracle.scheduler.option.shared.field.OptionFieldNames.BATCH_ID;
import static com.technology.oracle.scheduler.option.shared.field.OptionFieldNames.DATE_VALUE;
import static com.technology.oracle.scheduler.option.shared.field.OptionFieldNames.ENCRYPTION_FLAG;
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

import com.google.gwt.dom.client.Style.Unit;
import com.google.gwt.user.client.ui.DoubleBox;
import com.google.gwt.user.client.ui.ScrollPanel;
import com.google.gwt.user.client.ui.VerticalPanel;
import com.technology.jep.jepria.client.ui.form.detail.DetailFormViewImpl;
import com.technology.jep.jepria.client.widget.field.FieldManager;
import com.technology.jep.jepria.client.widget.field.multistate.JepCheckBoxField;
import com.technology.jep.jepria.client.widget.field.multistate.JepComboBoxField;
import com.technology.jep.jepria.client.widget.field.multistate.JepDateField;
import com.technology.jep.jepria.client.widget.field.multistate.JepNumberField;
import com.technology.jep.jepria.client.widget.field.multistate.JepTextAreaField;
import com.technology.jep.jepria.client.widget.field.multistate.JepTextField;
import com.technology.jep.jepria.client.widget.field.multistate.JepTimeField;
 
public class OptionDetailFormViewImpl extends DetailFormViewImpl {  
 
  public OptionDetailFormViewImpl() {
    super(new FieldManager());

    ScrollPanel scrollPanel = new ScrollPanel();
    scrollPanel.setSize("100%", "100%");
    
    VerticalPanel panel = new VerticalPanel();
    panel.getElement().getStyle().setMarginTop(5, Unit.PX);
    scrollPanel.add(panel);
 
    JepNumberField batchIdNumberField = new JepNumberField(batchText.batch_detail_batch_id());
    JepNumberField optionIdNumberField = new JepNumberField(optionText.option_detail_option_id());
    JepTextField optionShortNameTextField = new JepTextField(optionText.option_detail_option_short_name());
    JepComboBoxField valueTypeCodeComboBoxField = new JepComboBoxField(optionText.option_detail_value_type_code());
    JepCheckBoxField valueListFlagCheckBoxField = new JepCheckBoxField(optionText.option_detail_value_list_flag());
    JepCheckBoxField encryptionFlagCheckBoxField = new JepCheckBoxField(optionText.option_detail_encryption_flag());
    JepCheckBoxField testProdSensitiveFlagCheckBoxField = new JepCheckBoxField(optionText.option_detail_test_prod_sensitive_flag());
    JepTextField optionNameTextField = new JepTextField(optionText.option_detail_option_name());
    optionNameTextField.setFieldWidth(300);
    
    JepTextAreaField optionDescriptionTextAreaField = new JepTextAreaField(optionText.option_detail_option_description());
    optionDescriptionTextAreaField.setFieldWidth(300);
    optionDescriptionTextAreaField.getElement().getStyle().setProperty("minHeight", "80");
    
    JepTextField stringValueTextField = new JepTextField(optionText.option_detail_string_value());
    JepDateField dateValueDateField = new JepDateField(optionText.option_detail_date_value());
    JepTimeField timeValueTimeField = new JepTimeField(optionText.option_detail_time_value());
    
    JepNumberField numberValueNumberField = new JepNumberField(optionText.option_detail_number_value()) {
      
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
    
    JepTextField stringListSeparatorTextField = new JepTextField(optionText.option_detail_string_list_separator());
    JepTextField valueIndexTextField = new JepTextField(optionText.option_detail_value_index());
    valueIndexTextField.setTitle(optionText.option_detail_value_index_desc());
    
    panel.add(batchIdNumberField);
    panel.add(optionIdNumberField);
    panel.add(optionShortNameTextField);
    panel.add(valueTypeCodeComboBoxField);
    panel.add(valueListFlagCheckBoxField);
    panel.add(encryptionFlagCheckBoxField);
    panel.add(testProdSensitiveFlagCheckBoxField);
    panel.add(optionNameTextField);
    panel.add(optionDescriptionTextAreaField);
    panel.add(stringValueTextField);
    panel.add(dateValueDateField);
    panel.add(timeValueTimeField);
    panel.add(numberValueNumberField);
    panel.add(stringListSeparatorTextField);
    panel.add(valueIndexTextField);
    
    setWidget(scrollPanel);
 
    fields.put(BATCH_ID, batchIdNumberField);
    fields.put(OPTION_ID, optionIdNumberField);
    fields.put(OPTION_SHORT_NAME, optionShortNameTextField);
    fields.put(VALUE_TYPE_CODE, valueTypeCodeComboBoxField);
    fields.put(VALUE_LIST_FLAG, valueListFlagCheckBoxField);
    fields.put(ENCRYPTION_FLAG, encryptionFlagCheckBoxField);
    fields.put(TEST_PROD_SENSITIVE_FLAG, testProdSensitiveFlagCheckBoxField);
    fields.put(OPTION_NAME, optionNameTextField);
    fields.put(OPTION_DESCRIPTION, optionDescriptionTextAreaField);
    fields.put(STRING_VALUE, stringValueTextField);
    fields.put(DATE_VALUE, dateValueDateField);
    fields.put(TIME_VALUE, timeValueTimeField);
    fields.put(NUMBER_VALUE, numberValueNumberField);
    fields.put(STRING_LIST_SEPARATOR, stringListSeparatorTextField);
    fields.put(VALUE_INDEX, valueIndexTextField);
  }
 
}
