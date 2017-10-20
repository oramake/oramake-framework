package com.technology.oracle.optionasria.value.client.ui.form.list;

import static com.technology.jep.jepria.shared.JepRiaConstant.DEFAULT_DATE_FORMAT;
import static com.technology.jep.jepria.shared.JepRiaConstant.DEFAULT_TIME_FORMAT;
import static com.technology.oracle.optionasria.value.client.ValueClientConstant.valueText;
import static com.technology.oracle.optionasria.value.shared.field.ValueFieldNames.DATE_VALUE;
import static com.technology.oracle.optionasria.value.shared.field.ValueFieldNames.ENCRYPTION_FLAG;
import static com.technology.oracle.optionasria.value.shared.field.ValueFieldNames.INSTANCE_NAME;
import static com.technology.oracle.optionasria.value.shared.field.ValueFieldNames.LIST_SEPARATOR;
import static com.technology.oracle.optionasria.value.shared.field.ValueFieldNames.NUMBER_VALUE;
import static com.technology.oracle.optionasria.value.shared.field.ValueFieldNames.OPTION_ID;
import static com.technology.oracle.optionasria.value.shared.field.ValueFieldNames.PROD_VALUE_FLAG;
import static com.technology.oracle.optionasria.value.shared.field.ValueFieldNames.STRING_VALUE;
import static com.technology.oracle.optionasria.value.shared.field.ValueFieldNames.USED_OPERATOR_NAME;
import static com.technology.oracle.optionasria.value.shared.field.ValueFieldNames.USED_VALUE_FLAG;
import static com.technology.oracle.optionasria.value.shared.field.ValueFieldNames.VALUE_ID;
import static com.technology.oracle.optionasria.value.shared.field.ValueFieldNames.VALUE_TYPE_NAME;

import java.util.ArrayList;
import java.util.List;

import com.google.gwt.cell.client.DateCell;
import com.google.gwt.cell.client.NumberCell;
import com.google.gwt.i18n.client.DateTimeFormat;
import com.google.gwt.i18n.client.NumberFormat;
import com.technology.jep.jepria.client.ui.form.list.StandardListFormViewImpl;
import com.technology.jep.jepria.client.widget.list.JepColumn;
import com.technology.jep.jepria.client.widget.list.cell.BooleanCell;

public class ValueListFormViewImpl extends StandardListFormViewImpl {

  public ValueListFormViewImpl() {
    super(ValueListFormViewImpl.class.getCanonicalName());
  }

  private static NumberFormat defaultNumberFormatter = NumberFormat.getFormat("#");
	private static DateTimeFormat defaultDateFormatter = DateTimeFormat.getFormat(DEFAULT_DATE_FORMAT);
	private static DateTimeFormat dateWithTimeFormatter = DateTimeFormat.getFormat(DEFAULT_DATE_FORMAT+" "+DEFAULT_TIME_FORMAT);

	protected List<JepColumn> getColumnConfigurations() {
		final List<JepColumn> columnConfigurations = new ArrayList<JepColumn>();
		columnConfigurations.add(new JepColumn(VALUE_ID, valueText.value_list_value_id(), 150, new NumberCell(defaultNumberFormatter)));
		columnConfigurations.add(new JepColumn(OPTION_ID, valueText.value_list_option_id(), 150, new NumberCell(defaultNumberFormatter)));
		columnConfigurations.add(new JepColumn(USED_VALUE_FLAG, valueText.value_list_used_value_flag(), 150, new BooleanCell()));
		columnConfigurations.add(new JepColumn(PROD_VALUE_FLAG, valueText.value_list_prod_value_flag(), 150, new BooleanCell()));
		columnConfigurations.add(new JepColumn(INSTANCE_NAME, valueText.value_list_instance_name(), 150));
//		columnConfigurations.add(new ColumnConfig(VALUE_TYPE_CODE, valueText.value_list_value_type_code(), 150));

		columnConfigurations.add(new JepColumn(VALUE_TYPE_NAME, valueText.value_list_value_type_name(), 150));
		columnConfigurations.add(new JepColumn(STRING_VALUE, valueText.value_list_string_value(), 150));
		columnConfigurations.add(new JepColumn(DATE_VALUE, valueText.value_list_date_value(), 150, new DateCell(defaultDateFormatter)));
		columnConfigurations.add(new JepColumn(NUMBER_VALUE, valueText.value_list_number_value(), 150, new NumberCell(defaultNumberFormatter)));

		columnConfigurations.add(new JepColumn(ENCRYPTION_FLAG, valueText.value_list_encryption_flag(), 150, new BooleanCell()));
		columnConfigurations.add(new JepColumn(LIST_SEPARATOR, valueText.value_list_list_separator(), 150));
		columnConfigurations.add(new JepColumn(USED_OPERATOR_NAME, valueText.value_list_used_operator_name(), 150));
		return columnConfigurations;
	}

}
