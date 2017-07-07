package com.technology.oracle.scheduler.value.client.ui.form.list;
 
import static com.technology.jep.jepria.shared.JepRiaConstant.DEFAULT_DATE_FORMAT;
import static com.technology.jep.jepria.shared.JepRiaConstant.DEFAULT_TIME_FORMAT;
import static com.technology.oracle.scheduler.value.client.ValueClientConstant.valueText;
import static com.technology.oracle.scheduler.value.shared.field.ValueFieldNames.DATE_VALUE;
import static com.technology.oracle.scheduler.value.shared.field.ValueFieldNames.ENCRYPTION_FLAG;
import static com.technology.oracle.scheduler.value.shared.field.ValueFieldNames.INSTANCE_NAME;
import static com.technology.oracle.scheduler.value.shared.field.ValueFieldNames.LIST_SEPARATOR;
import static com.technology.oracle.scheduler.value.shared.field.ValueFieldNames.NUMBER_VALUE_LIST;
import static com.technology.oracle.scheduler.value.shared.field.ValueFieldNames.OPTION_ID;
import static com.technology.oracle.scheduler.value.shared.field.ValueFieldNames.PROD_VALUE_FLAG;
import static com.technology.oracle.scheduler.value.shared.field.ValueFieldNames.STRING_VALUE;
import static com.technology.oracle.scheduler.value.shared.field.ValueFieldNames.USED_VALUE_FLAG;
import static com.technology.oracle.scheduler.value.shared.field.ValueFieldNames.VALUE_ID;
import static com.technology.oracle.scheduler.value.shared.field.ValueFieldNames.VALUE_TYPE_CODE_LIST;
import static com.technology.oracle.scheduler.value.shared.field.ValueFieldNames.VALUE_TYPE_NAME;

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
 
public class ValueListFormViewImpl extends ListFormViewImpl<GridManager> {
 
  public ValueListFormViewImpl() {
    super(new GridManager());
     
    HeaderPanel gridPanel = new HeaderPanel();
    setWidget(gridPanel);
 
    gridPanel.setHeight("100%");
    gridPanel.setWidth("100%");
 
    JepGrid<JepRecord> grid = new JepGrid<JepRecord>(getGridId(), getColumnConfigurations(), true);
    PagingStandardBar pagingBar = new PagingStandardBar(25);
 
    gridPanel.setContentWidget(grid);
    gridPanel.setFooterWidget(pagingBar);
 
    list.setWidget(grid);
    list.setPagingToolBar(pagingBar);
  }

  private static DateTimeFormat defaultDateFormatter = DateTimeFormat.getFormat(DEFAULT_DATE_FORMAT);
  private static DateTimeFormat dateWithTimeFormatter = DateTimeFormat.getFormat(DEFAULT_DATE_FORMAT+" "+DEFAULT_TIME_FORMAT);
  private static NumberFormat defaultNumberFormatter = NumberFormat.getFormat("#");
 
  private static List<JepColumn> getColumnConfigurations() {
    final List<JepColumn> columnConfigurations = new ArrayList<JepColumn>();
    columnConfigurations.add(new JepColumn(VALUE_ID, valueText.value_list_value_id(), 150, new NumberCell(defaultNumberFormatter)));
    columnConfigurations.add(new JepColumn(OPTION_ID, valueText.value_list_option_id(), 150, new NumberCell(defaultNumberFormatter)));
    columnConfigurations.add(BooleanColumnConfig(USED_VALUE_FLAG, valueText.value_list_used_value_flag(), 150));
    columnConfigurations.add(BooleanColumnConfig(PROD_VALUE_FLAG, valueText.value_list_prod_value_flag(), 150));
    columnConfigurations.add(new JepColumn(INSTANCE_NAME, valueText.value_list_instance_name(), 150));
    columnConfigurations.add(new JepColumn(VALUE_TYPE_CODE_LIST, valueText.value_list_value_type_code(), 150));
    columnConfigurations.add(new JepColumn(VALUE_TYPE_NAME, valueText.value_list_value_type_name(), 150));
    columnConfigurations.add(new JepColumn(STRING_VALUE, valueText.value_list_string_value(), 150));
    columnConfigurations.add(DateColumnConfig(DATE_VALUE, valueText.value_list_date_value(), 150));
//    columnConfigurations.add(new JepColumn(NUMBER_VALUE, valueText.value_list_number_value(), 150));
    columnConfigurations.add(new JepColumn(NUMBER_VALUE_LIST, valueText.value_list_number_value(), 150));
    columnConfigurations.add(BooleanColumnConfig(ENCRYPTION_FLAG, valueText.value_list_encryption_flag(), 150));
    columnConfigurations.add(new JepColumn(LIST_SEPARATOR, valueText.value_list_list_separator(), 150));
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

