package com.technology.oracle.optionasria.option.client.ui.form.detail;
 
import static com.technology.jep.jepria.shared.field.JepFieldNames.MAX_ROW_COUNT;
import static com.technology.oracle.optionasria.option.client.OptionClientConstant.optionText;
import static com.technology.oracle.optionasria.option.shared.field.OptionFieldNames.DATA_SOURCE;
import static com.technology.oracle.optionasria.option.shared.field.OptionFieldNames.DATE_VALUE;
import static com.technology.oracle.optionasria.option.shared.field.OptionFieldNames.ENCRYPTION_FLAG;
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

import com.google.gwt.user.client.ui.DoubleBox;
import com.technology.jep.jepria.client.ui.form.detail.StandardDetailFormViewImpl;
import com.technology.jep.jepria.client.widget.field.multistate.JepCheckBoxField;
import com.technology.jep.jepria.client.widget.field.multistate.JepComboBoxField;
import com.technology.jep.jepria.client.widget.field.multistate.JepDateField;
import com.technology.jep.jepria.client.widget.field.multistate.JepIntegerField;
import com.technology.jep.jepria.client.widget.field.multistate.JepNumberField;
import com.technology.jep.jepria.client.widget.field.multistate.JepTextAreaField;
import com.technology.jep.jepria.client.widget.field.multistate.JepTextField;
import com.technology.jep.jepria.client.widget.field.multistate.JepTimeField;
 
public class OptionDetailFormViewImpl extends StandardDetailFormViewImpl {	
 
	public OptionDetailFormViewImpl() { 
		JepComboBoxField dataSourceComboBoxField = new JepComboBoxField(optionText.option_detail_data_source());
		JepNumberField optionIdNumberField = new JepNumberField(optionText.option_detail_option_id());
		JepComboBoxField moduleIdComboBoxField = new JepComboBoxField(optionText.option_detail_module_id());
		JepTextField objectShortNameTextField = new JepTextField(optionText.option_detail_object_short_name());
		JepComboBoxField objectTypeIdComboBoxField = new JepComboBoxField(optionText.option_detail_object_type_id());
		JepTextField optionShortNameTextField = new JepTextField(optionText.option_detail_option_short_name());
		JepComboBoxField valueTypeCodeComboBoxField = new JepComboBoxField(optionText.option_detail_value_type_code());
		JepCheckBoxField valueListFlagCheckBoxField = new JepCheckBoxField(optionText.option_detail_value_list_flag());
		JepCheckBoxField encryptionFlagCheckBoxField = new JepCheckBoxField(optionText.option_detail_encryption_flag());
		JepCheckBoxField testProdSensitiveFlagCheckBoxField = new JepCheckBoxField(optionText.option_detail_test_prod_sensitive_flag());
		JepTextField optionNameTextField = new JepTextField(optionText.option_detail_option_name());
		optionNameTextField.setFieldWidth(300);
		
		JepTextAreaField optionDescriptionTextField = new JepTextAreaField(optionText.option_detail_option_description());
		optionDescriptionTextField.setFieldWidth(300);
		optionDescriptionTextField.getEditableCard().setStyleName("min-height: 80");
		
		JepTextField stringValueTextField = new JepTextField(optionText.option_detail_string_value());
		JepDateField dateValueDateField = new JepDateField(optionText.option_detail_date_value());
		JepTimeField timeValueTimeField = new JepTimeField(optionText.option_detail_time_value());
		JepNumberField numberValueNumberField = new JepNumberField(optionText.option_detail_number_value()) 
		/*{
			{
				NumberPropertyEditor propertyEditor = new XNumberPropertyEditor(BigDecimal.class) {
					
					@Override
					public String getStringValue(Number value) {
						return value.toString();
					}
				};
				((NumberField)editableCard).setPropertyEditor(propertyEditor);
			}
			
		}*/
		{
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
    }
		;
//		numberValueNumberField.setNumberFormat(NumberFormat.getFormat("000000.000000"));
		
//		JepTextField optionValueTextField = new JepTextField(optionText.option_detail_option_value());
		JepTextField stringListSeparatorTextField = new JepTextField(optionText.option_detail_string_list_separator());
		JepIntegerField maxRowCountField = new JepIntegerField(optionText.option_detail_row_count());
		maxRowCountField.setMaxLength(4);
		maxRowCountField.setFieldWidth(55);
 
		JepTextField valueIndexTextField = new JepTextField(optionText.option_detail_value_index());
		valueIndexTextField.setTitle(optionText.option_detail_value_index_desc());
		//		Label valueIndexDesc = new Label(optionText.option_detail_value_index_desc());
		
		panel.add(dataSourceComboBoxField);
		panel.add(optionIdNumberField);
		panel.add(moduleIdComboBoxField);
		panel.add(objectShortNameTextField);
		panel.add(objectTypeIdComboBoxField);
		panel.add(optionShortNameTextField);
		panel.add(valueTypeCodeComboBoxField);
		panel.add(valueListFlagCheckBoxField);
		panel.add(encryptionFlagCheckBoxField);
		panel.add(testProdSensitiveFlagCheckBoxField);
		panel.add(optionNameTextField);
		panel.add(optionDescriptionTextField);
		panel.add(stringValueTextField);
		panel.add(dateValueDateField);
		panel.add(timeValueTimeField);
		panel.add(numberValueNumberField);
//		container.add(optionValueTextField);
		panel.add(valueIndexTextField);
		panel.add(stringListSeparatorTextField);
		panel.add(maxRowCountField);
  
		fields.put(DATA_SOURCE, dataSourceComboBoxField);
		fields.put(OPTION_ID, optionIdNumberField);
		fields.put(MODULE_ID, moduleIdComboBoxField);
		fields.put(OBJECT_SHORT_NAME, objectShortNameTextField);
		fields.put(OBJECT_TYPE_ID, objectTypeIdComboBoxField);
		fields.put(OPTION_SHORT_NAME, optionShortNameTextField);
		fields.put(VALUE_TYPE_CODE, valueTypeCodeComboBoxField);
		fields.put(VALUE_LIST_FLAG, valueListFlagCheckBoxField);
		fields.put(ENCRYPTION_FLAG, encryptionFlagCheckBoxField);
		fields.put(TEST_PROD_SENSITIVE_FLAG, testProdSensitiveFlagCheckBoxField);
		fields.put(OPTION_NAME, optionNameTextField);
		fields.put(OPTION_DESCRIPTION, optionDescriptionTextField);
		fields.put(STRING_VALUE, stringValueTextField);
		fields.put(DATE_VALUE, dateValueDateField);
		fields.put(TIME_VALUE, timeValueTimeField);
		fields.put(NUMBER_VALUE, numberValueNumberField);
//		fields.put(OPTION_CURRENT_VALUE, optionValueTextField);

		fields.put(VALUE_INDEX, valueIndexTextField);
		fields.put(STRING_LIST_SEPARATOR, stringListSeparatorTextField);
		fields.put(MAX_ROW_COUNT, maxRowCountField);
	}
 
}
