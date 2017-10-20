package com.technology.oracle.optionasria.option.client.ui.form.list;
 
import static com.technology.jep.jepria.shared.JepRiaConstant.DEFAULT_DATE_FORMAT;
import static com.technology.jep.jepria.shared.JepRiaConstant.DEFAULT_TIME_FORMAT;
import static com.technology.oracle.optionasria.option.client.OptionClientConstant.optionText;
import static com.technology.oracle.optionasria.option.shared.field.OptionFieldNames.ACCESS_LEVEL_NAME;
import static com.technology.oracle.optionasria.option.shared.field.OptionFieldNames.DATE_VALUE;
import static com.technology.oracle.optionasria.option.shared.field.OptionFieldNames.ENCRYPTION_FLAG;
import static com.technology.oracle.optionasria.option.shared.field.OptionFieldNames.LIST_SEPARATOR;
import static com.technology.oracle.optionasria.option.shared.field.OptionFieldNames.MODULE_NAME;
import static com.technology.oracle.optionasria.option.shared.field.OptionFieldNames.MODULE_SVN_ROOT;
import static com.technology.oracle.optionasria.option.shared.field.OptionFieldNames.NUMBER_VALUE;
import static com.technology.oracle.optionasria.option.shared.field.OptionFieldNames.OBJECT_SHORT_NAME;
import static com.technology.oracle.optionasria.option.shared.field.OptionFieldNames.OBJECT_TYPE_SHORT_NAME;
import static com.technology.oracle.optionasria.option.shared.field.OptionFieldNames.OPTION_ID;
import static com.technology.oracle.optionasria.option.shared.field.OptionFieldNames.OPTION_NAME;
import static com.technology.oracle.optionasria.option.shared.field.OptionFieldNames.OPTION_SHORT_NAME;
import static com.technology.oracle.optionasria.option.shared.field.OptionFieldNames.STRING_VALUE;
import static com.technology.oracle.optionasria.option.shared.field.OptionFieldNames.TEST_PROD_SENSITIVE_FLAG;
import static com.technology.oracle.optionasria.option.shared.field.OptionFieldNames.VALUE_LIST_FLAG;
import static com.technology.oracle.optionasria.option.shared.field.OptionFieldNames.VALUE_TYPE_NAME;

import java.util.ArrayList;
import java.util.List;

import com.google.gwt.cell.client.DateCell;
import com.google.gwt.cell.client.NumberCell;
import com.google.gwt.i18n.client.DateTimeFormat;
import com.google.gwt.i18n.client.NumberFormat;
import com.technology.jep.jepria.client.ui.form.list.StandardListFormViewImpl;
import com.technology.jep.jepria.client.widget.list.JepColumn;
import com.technology.jep.jepria.client.widget.list.cell.BooleanCell;

public class OptionListFormViewImpl extends StandardListFormViewImpl {
 
  public OptionListFormViewImpl() {
    super(OptionListFormViewImpl.class.getCanonicalName());
  }
 
	private static DateTimeFormat defaultDateFormatter = DateTimeFormat.getFormat(DEFAULT_DATE_FORMAT);
	private static DateTimeFormat dateWithTimeFormatter = DateTimeFormat.getFormat(DEFAULT_DATE_FORMAT+" "+DEFAULT_TIME_FORMAT);
	private static NumberFormat defaultNumberFormatter = NumberFormat.getFormat("#");  
		
	protected List<JepColumn> getColumnConfigurations() {
		final List<JepColumn> columnConfigurations = new ArrayList<JepColumn>();
		columnConfigurations.add(new JepColumn(OPTION_ID, optionText.option_list_option_id(), 150, new NumberCell(defaultNumberFormatter)));
		columnConfigurations.add(new JepColumn(OPTION_NAME, optionText.option_list_option_name(), 150));
		columnConfigurations.add(new JepColumn(OPTION_SHORT_NAME, optionText.option_list_option_short_name(), 150));
		columnConfigurations.add(new JepColumn(VALUE_TYPE_NAME, optionText.option_list_value_type_name(), 150));
		columnConfigurations.add(new JepColumn(STRING_VALUE, optionText.option_list_string_value(), 150));
		columnConfigurations.add(new JepColumn(DATE_VALUE, optionText.option_list_date_value(), 150, new DateCell(defaultDateFormatter)));
		columnConfigurations.add(new JepColumn(NUMBER_VALUE, optionText.option_list_number_value(), 150, new NumberCell(defaultNumberFormatter)));
		columnConfigurations.add(new JepColumn(OBJECT_SHORT_NAME, optionText.option_list_object_short_name(), 150));
		columnConfigurations.add(new JepColumn(OBJECT_TYPE_SHORT_NAME, optionText.option_list_object_type_short_name(), 150));
		columnConfigurations.add(new JepColumn(MODULE_NAME, optionText.option_list_module_name(), 150));
		columnConfigurations.add(new JepColumn(VALUE_LIST_FLAG, optionText.option_list_value_list_flag(), 150, new BooleanCell()));
		columnConfigurations.add(new JepColumn(LIST_SEPARATOR, optionText.option_list_list_separator(), 150));
		columnConfigurations.add(new JepColumn(ENCRYPTION_FLAG, optionText.option_list_encryption_flag(), 150, new BooleanCell()));
		columnConfigurations.add(new JepColumn(TEST_PROD_SENSITIVE_FLAG, optionText.option_list_test_prod_sensitive_flag(), 150, new BooleanCell()));
		columnConfigurations.add(new JepColumn(ACCESS_LEVEL_NAME, optionText.option_list_access_level_name(), 150));
		columnConfigurations.add(new JepColumn(MODULE_SVN_ROOT, optionText.option_list_module_svn_root(), 150));
		return columnConfigurations;
	}
 
}
