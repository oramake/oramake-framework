package com.technology.oracle.optionasria.value.client.ui.form.detail;

import static com.technology.jep.jepria.client.JepRiaClientConstant.JepTexts;
import static com.technology.jep.jepria.shared.field.JepFieldNames.MAX_ROW_COUNT;
import static com.technology.oracle.optionasria.value.client.ValueClientConstant.valueText;
import static com.technology.oracle.optionasria.value.shared.field.ValueFieldNames.DATE_VALUE;
import static com.technology.oracle.optionasria.value.shared.field.ValueFieldNames.INSTANCE_NAME;
import static com.technology.oracle.optionasria.value.shared.field.ValueFieldNames.NUMBER_VALUE;
import static com.technology.oracle.optionasria.value.shared.field.ValueFieldNames.PROD_VALUE_FLAG_CHECKBOX;
import static com.technology.oracle.optionasria.value.shared.field.ValueFieldNames.STRING_LIST_SEPARATOR;
import static com.technology.oracle.optionasria.value.shared.field.ValueFieldNames.STRING_VALUE;
import static com.technology.oracle.optionasria.value.shared.field.ValueFieldNames.TIME_VALUE;
import static com.technology.oracle.optionasria.value.shared.field.ValueFieldNames.USED_OPERATOR_ID;
import static com.technology.oracle.optionasria.value.shared.field.ValueFieldNames.VALUE_INDEX;
import static com.technology.oracle.optionasria.value.shared.field.ValueFieldNames.VALUE_TYPE_CODE;

import java.util.ArrayList;
import java.util.List;

import com.google.gwt.user.client.ui.DoubleBox;
import com.technology.jep.jepria.client.ui.form.detail.StandardDetailFormViewImpl;
import com.technology.jep.jepria.client.widget.field.FieldManager;
import com.technology.jep.jepria.client.widget.field.multistate.JepComboBoxField;
import com.technology.jep.jepria.client.widget.field.multistate.JepDateField;
import com.technology.jep.jepria.client.widget.field.multistate.JepNumberField;
import com.technology.jep.jepria.client.widget.field.multistate.JepTextField;
import com.technology.jep.jepria.client.widget.field.multistate.JepTimeField;
import com.technology.jep.jepria.shared.field.option.JepOption;

public class ValueDetailFormViewImpl extends StandardDetailFormViewImpl {

	public ValueDetailFormViewImpl() {
		super(new FieldManager());

		JepComboBoxField prodValueFlagJepComboBoxField = new JepComboBoxField(valueText.value_detail_prod_value_flag());
		List<JepOption> options = new ArrayList<JepOption>();
		options.add(new JepOption(JepTexts.yes(), 1));
		options.add(new JepOption(JepTexts.no(), 0));

		prodValueFlagJepComboBoxField.setOptions(options);
		JepTextField instanceNameTextField = new JepTextField(valueText.value_detail_instance_name());
		JepTextField stringListSeparatorTextField = new JepTextField(valueText.value_detail_string_list_separator());
		JepDateField dateValueDateField = new JepDateField(valueText.value_detail_date_value());
		JepTimeField timeValueTimeField = new JepTimeField(valueText.value_detail_time_value());
		JepNumberField numberValueNumberField = new JepNumberField(valueText.value_detail_number_value()) {
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
		valueIndexTextField.setTitle(valueText.value_detail_value_index_desc());

		JepNumberField maxRowCountField = new JepNumberField(valueText.value_detail_row_count());
		maxRowCountField.setMaxLength(4);
		maxRowCountField.setFieldWidth(55);

		JepComboBoxField valueTypeCodeComboBoxField = new JepComboBoxField(valueText.value_list_value_type_name());
		JepComboBoxField usedOperatorIdComboBoxField = new JepComboBoxField(valueText.value_detail_used_operator_id());
		usedOperatorIdComboBoxField.setEmptyText(valueText.value_detail_used_operator_id_emptyText());

		panel.add(prodValueFlagJepComboBoxField);
		panel.add(instanceNameTextField);
		panel.add(usedOperatorIdComboBoxField);
		panel.add(valueTypeCodeComboBoxField);
		panel.add(dateValueDateField);
		panel.add(timeValueTimeField);

		panel.add(numberValueNumberField);
		panel.add(stringValueTextField);
		panel.add(valueIndexTextField);
		panel.add(stringListSeparatorTextField);
		panel.add(maxRowCountField);


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
