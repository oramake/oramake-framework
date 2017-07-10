package com.technology.oracle.scheduler.option.client.ui.form.list;
 
import static com.technology.jep.jepria.shared.JepRiaConstant.DEFAULT_DATE_FORMAT;
import static com.technology.jep.jepria.shared.JepRiaConstant.DEFAULT_TIME_FORMAT;
import static com.technology.oracle.scheduler.option.client.OptionClientConstant.optionText;
import static com.technology.oracle.scheduler.option.shared.field.OptionFieldNames.ACCESS_LEVEL_NAME;
import static com.technology.oracle.scheduler.option.shared.field.OptionFieldNames.DATE_VALUE;
import static com.technology.oracle.scheduler.option.shared.field.OptionFieldNames.ENCRYPTION_FLAG;
import static com.technology.oracle.scheduler.option.shared.field.OptionFieldNames.LIST_SEPARATOR;
import static com.technology.oracle.scheduler.option.shared.field.OptionFieldNames.NUMBER_VALUE_LIST;
import static com.technology.oracle.scheduler.option.shared.field.OptionFieldNames.OPTION_ID;
import static com.technology.oracle.scheduler.option.shared.field.OptionFieldNames.OPTION_NAME;
import static com.technology.oracle.scheduler.option.shared.field.OptionFieldNames.OPTION_SHORT_NAME;
import static com.technology.oracle.scheduler.option.shared.field.OptionFieldNames.STRING_VALUE;
import static com.technology.oracle.scheduler.option.shared.field.OptionFieldNames.TEST_PROD_SENSITIVE_FLAG;
import static com.technology.oracle.scheduler.option.shared.field.OptionFieldNames.VALUE_LIST_FLAG;
import static com.technology.oracle.scheduler.option.shared.field.OptionFieldNames.VALUE_TYPE_NAME;

import java.util.ArrayList;
import java.util.List;

import com.google.gwt.cell.client.DateCell;
import com.google.gwt.cell.client.NumberCell;
import com.google.gwt.i18n.client.DateTimeFormat;
import com.google.gwt.i18n.client.NumberFormat;
import com.google.gwt.user.client.ui.HeaderPanel;
import com.technology.jep.jepria.client.ui.form.list.ListFormViewImpl;
import com.technology.jep.jepria.client.widget.list.GridManager;
import com.technology.jep.jepria.client.widget.list.JepColumn;
import com.technology.jep.jepria.client.widget.list.JepGrid;
import com.technology.jep.jepria.client.widget.toolbar.PagingStandardBar;
import com.technology.jep.jepria.shared.record.JepRecord;
import com.technology.oracle.scheduler.main.client.widget.list.cell.BooleanCell;
 
public class OptionListFormViewImpl extends ListFormViewImpl<GridManager> {
 
  public OptionListFormViewImpl() {
    super(new GridManager());
     
    HeaderPanel gridPanel = new HeaderPanel();
    setWidget(gridPanel);
 
    gridPanel.setHeight("100%");
    gridPanel.setWidth("100%");
 
    JepGrid<JepRecord> grid = new JepGrid<JepRecord>(getGridId(), null, getColumnConfigurations(), true);
    PagingStandardBar pagingBar = new PagingStandardBar(25);
 
    gridPanel.setContentWidget(grid);
    gridPanel.setFooterWidget(pagingBar);
 
    list.setWidget(grid);
    list.setPagingToolBar(pagingBar);
  }
 
  private static DateTimeFormat defaultDateFormatter = DateTimeFormat.getFormat(DEFAULT_DATE_FORMAT);
  private static DateTimeFormat dateWithTimeFormatter = DateTimeFormat.getFormat(DEFAULT_DATE_FORMAT+" "+DEFAULT_TIME_FORMAT);
  private static NumberFormat defaultNumberFormatter = NumberFormat.getFormat("#.#");

  private static List<JepColumn> getColumnConfigurations() {
    final List<JepColumn> columnConfigurations = new ArrayList<JepColumn>();
    columnConfigurations.add(new JepColumn(OPTION_ID, optionText.option_list_option_id(), 150, new NumberCell(defaultNumberFormatter)));
    columnConfigurations.add(new JepColumn(OPTION_NAME, optionText.option_list_option_name(), 150));
    columnConfigurations.add(new JepColumn(OPTION_SHORT_NAME, optionText.option_list_option_short_name(), 150));
    columnConfigurations.add(new JepColumn(VALUE_TYPE_NAME, optionText.option_list_value_type_name(), 150));
    columnConfigurations.add(new JepColumn(STRING_VALUE, optionText.option_list_string_value(), 150));
    columnConfigurations.add(DateColumnConfig(DATE_VALUE, optionText.option_list_date_value(), 150));
//    columnConfigurations.add(new JepColumn(NUMBER_VALUE, optionText.option_list_number_value(), 150, new NumberCell(NumberFormat.getFormat("#.##"))));
    columnConfigurations.add(new JepColumn(NUMBER_VALUE_LIST, optionText.option_list_number_value(), 150));
    columnConfigurations.add(BooleanColumnConfig(VALUE_LIST_FLAG, optionText.option_list_value_list_flag(), 150));
    columnConfigurations.add(new JepColumn(LIST_SEPARATOR, optionText.option_list_list_separator(), 150));
    columnConfigurations.add(BooleanColumnConfig(ENCRYPTION_FLAG, optionText.option_list_encryption_flag(), 150));
    columnConfigurations.add(BooleanColumnConfig(TEST_PROD_SENSITIVE_FLAG, optionText.option_list_test_prod_sensitive_flag(), 150));
    columnConfigurations.add(new JepColumn(ACCESS_LEVEL_NAME, optionText.option_list_access_level_name(), 150));
    return columnConfigurations;
  }
  
  private static JepColumn DateColumnConfig(String id, String name, int width) {
    return new JepColumn(id, name, width, new DateCell(dateWithTimeFormatter));
  }
   
  private String getGridId() {
    return this.getClass().toString().replace("class ", "");
  }
  
  private static JepColumn BooleanColumnConfig(String id, String name, int width) {
    return new JepColumn(id, name, width, new BooleanCell());
  }
 
}
