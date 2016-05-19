package com.technology.oracle.optionasria.option.client.ui.form.detail;
 
import static com.technology.oracle.optionasria.option.client.OptionClientConstant.optionText;
import static com.technology.oracle.optionasria.option.shared.field.OptionFieldNames.*;

import java.math.BigDecimal;

import com.technology.jep.jepria.client.widget.field.multistate.JepNumberField;
import static com.technology.jep.jepria.shared.field.JepFieldNames.MAX_ROW_COUNT;
import com.technology.jep.jepria.client.widget.field.multistate.JepComboBoxField;
import com.technology.jep.jepria.client.widget.field.multistate.JepDateField;
import com.technology.jep.jepria.client.widget.field.multistate.JepTextAreaField;
import com.technology.jep.jepria.client.widget.field.multistate.JepTextField;
import com.technology.jep.jepria.client.widget.field.multistate.JepCheckBoxField;
import com.technology.jep.jepria.client.widget.field.multistate.JepTimeField;
import com.technology.jep.jepria.client.widget.field.multistate.large.JepLargeField;
import com.technology.jep.jepria.client.ui.form.detail.JepDetailFormViewImpl;
import com.extjs.gxt.ui.client.widget.Label;
import com.extjs.gxt.ui.client.widget.LayoutContainer;
import com.extjs.gxt.ui.client.widget.form.NumberField;
import com.extjs.gxt.ui.client.widget.form.NumberPropertyEditor;
import com.extjs.gxt.ui.client.widget.form.XNumberPropertyEditor;
import com.google.gwt.i18n.client.NumberFormat;
import com.technology.jep.jepria.client.widget.field.StandardLayoutContainer;
import com.technology.jep.jepria.client.widget.field.FieldManager;
 
public class OptionDetailFormViewImpl extends JepDetailFormViewImpl {	
 
	public OptionDetailFormViewImpl() {
		super(new FieldManager());
		LayoutContainer container = new StandardLayoutContainer();
 
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
		
		JepTextField optionDescriptionTextField = new JepTextAreaField(optionText.option_detail_option_description());
		optionDescriptionTextField.setFieldWidth(300);
		optionDescriptionTextField.getEditableCard().setStyleAttribute("min-height", "80");
		
		JepTextField stringValueTextField = new JepTextField(optionText.option_detail_string_value());
		JepDateField dateValueDateField = new JepDateField(optionText.option_detail_date_value());
		JepTimeField timeValueTimeField = new JepTimeField(optionText.option_detail_time_value());
		JepNumberField numberValueNumberField = new JepNumberField(optionText.option_detail_number_value(), BigDecimal.class) {
			{
				NumberPropertyEditor propertyEditor = new XNumberPropertyEditor(BigDecimal.class) {
					
					@Override
					public String getStringValue(Number value) {
						return value.toString();
					}
				};
				((NumberField)editableCard).setPropertyEditor(propertyEditor);
			}
			
		};
//		numberValueNumberField.setNumberFormat(NumberFormat.getFormat("000000.000000"));
		
//		JepTextField optionValueTextField = new JepTextField(optionText.option_detail_option_value());
		JepTextField stringListSeparatorTextField = new JepTextField(optionText.option_detail_string_list_separator());
		JepNumberField maxRowCountField = new JepNumberField(optionText.option_detail_row_count());
		maxRowCountField.setMaxLength(4);
		maxRowCountField.setFieldWidth(55);
 
		JepTextField valueIndexTextField = new JepTextField(optionText.option_detail_value_index());
		valueIndexTextField.setTitle(optionText.option_detail_value_index_desc());
		//		Label valueIndexDesc = new Label(optionText.option_detail_value_index_desc());
		
		container.add(dataSourceComboBoxField);
		container.add(optionIdNumberField);
		container.add(moduleIdComboBoxField);
		container.add(objectShortNameTextField);
		container.add(objectTypeIdComboBoxField);
		container.add(optionShortNameTextField);
		container.add(valueTypeCodeComboBoxField);
		container.add(valueListFlagCheckBoxField);
		container.add(encryptionFlagCheckBoxField);
		container.add(testProdSensitiveFlagCheckBoxField);
		container.add(optionNameTextField);
		container.add(optionDescriptionTextField);
		container.add(stringValueTextField);
		container.add(dateValueDateField);
		container.add(timeValueTimeField);
		container.add(numberValueNumberField);
//		container.add(optionValueTextField);
		container.add(valueIndexTextField);
		container.add(stringListSeparatorTextField);
		container.add(maxRowCountField);
 
		setBody(container);
 
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
