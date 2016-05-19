package com.technology.oracle.optionasria.value.client.ui.form.detail;
 
import static com.technology.oracle.optionasria.option.client.OptionClientConstant.optionText;
import static com.technology.oracle.optionasria.value.client.ValueClientConstant.valueText;
import static com.technology.oracle.optionasria.value.shared.field.ValueFieldNames.*;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

import com.technology.jep.jepria.client.widget.field.multistate.JepNumberField;

import static com.technology.jep.jepria.client.JepRiaClientConstant.JepTexts;
import static com.technology.jep.jepria.shared.field.JepFieldNames.MAX_ROW_COUNT;

import com.technology.jep.jepria.client.widget.field.multistate.JepComboBoxField;
import com.technology.jep.jepria.client.widget.field.multistate.JepMoneyField;
import com.technology.jep.jepria.client.widget.field.multistate.JepTextField;
import com.technology.jep.jepria.client.widget.field.multistate.JepDateField;
import com.technology.jep.jepria.client.widget.field.multistate.JepTimeField;
import com.technology.jep.jepria.client.ui.form.detail.JepDetailFormViewImpl;
import com.extjs.gxt.ui.client.widget.LayoutContainer;
import com.extjs.gxt.ui.client.widget.form.NumberField;
import com.extjs.gxt.ui.client.widget.form.NumberPropertyEditor;
import com.extjs.gxt.ui.client.widget.form.XNumberPropertyEditor;
import com.google.gwt.core.client.GWT;
import com.google.gwt.i18n.client.NumberFormat;
import com.technology.jep.jepria.client.widget.field.StandardLayoutContainer;
import com.technology.jep.jepria.client.widget.field.FieldManager;
import com.technology.jep.jepria.shared.field.option.JepOption;
import com.technology.jep.jepria.shared.util.JepRiaUtil;
 
public class ValueDetailFormViewImpl extends JepDetailFormViewImpl {	
 
	public ValueDetailFormViewImpl() {
		super(new FieldManager());
		LayoutContainer container = new StandardLayoutContainer();
 
		JepComboBoxField prodValueFlagJepComboBoxField = new JepComboBoxField(valueText.value_detail_prod_value_flag());
		List<JepOption> options = new ArrayList<JepOption>();
		options.add(new JepOption(JepTexts.yes(), 1));
		options.add(new JepOption(JepTexts.no(), 0));

		prodValueFlagJepComboBoxField.setOptions(options);
		JepTextField instanceNameTextField = new JepTextField(valueText.value_detail_instance_name());
		JepTextField stringListSeparatorTextField = new JepTextField(valueText.value_detail_string_list_separator());
		JepDateField dateValueDateField = new JepDateField(valueText.value_detail_date_value());
		JepTimeField timeValueTimeField = new JepTimeField(valueText.value_detail_time_value());
		JepNumberField numberValueNumberField = new JepNumberField(valueText.value_detail_number_value(), BigDecimal.class){
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
		
		JepTextField stringValueTextField = new JepTextField(valueText.value_detail_string_value());
		JepTextField valueIndexTextField = new JepTextField(valueText.value_detail_value_index());
		valueIndexTextField.setTitle(valueText.value_detail_value_index_desc());
		
		JepNumberField maxRowCountField = new JepNumberField(valueText.value_detail_row_count());
		maxRowCountField.setMaxLength(4);
		maxRowCountField.setFieldWidth(55);
		
		JepComboBoxField valueTypeCodeComboBoxField = new JepComboBoxField(valueText.value_list_value_type_name());
		JepComboBoxField usedOperatorIdComboBoxField = new JepComboBoxField(valueText.value_detail_used_operator_id());
		usedOperatorIdComboBoxField.setEmptyText(valueText.value_detail_used_operator_id_emptyText());
		
		container.add(prodValueFlagJepComboBoxField);
		container.add(instanceNameTextField);
		container.add(usedOperatorIdComboBoxField);
		container.add(valueTypeCodeComboBoxField);
		container.add(dateValueDateField);
		container.add(timeValueTimeField);
		
		container.add(numberValueNumberField);
		container.add(stringValueTextField);
		container.add(valueIndexTextField);
		container.add(stringListSeparatorTextField);
		container.add(maxRowCountField);
		
 
		setBody(container);
 
		fields.put(PROD_VALUE_FLAG_CHECKBOX, prodValueFlagJepComboBoxField);
		fields.put(INSTANCE_NAME, instanceNameTextField);
		fields.put(USED_OPERATOR_ID, usedOperatorIdComboBoxField);
		fields.put(STRING_LIST_SEPARATOR, stringListSeparatorTextField);
		fields.put(VALUE_TYPE_CODE, valueTypeCodeComboBoxField);
		fields.put(DATE_VALUE, dateValueDateField);
		fields.put(TIME_VALUE, timeValueTimeField);
		fields.put(NUMBER_VALUE, numberValueNumberField);
		fields.put(STRING_VALUE, stringValueTextField);
		fields.put(VALUE_INDEX, valueIndexTextField);
		fields.put(MAX_ROW_COUNT, maxRowCountField);
		
		fields.setLabelWidth(250);
	}
 
}
