package com.technology.oracle.scheduler.interval.client.ui.form.list;
 
import static com.technology.jep.jepria.shared.JepRiaConstant.DEFAULT_DATE_FORMAT;
import static com.technology.jep.jepria.shared.JepRiaConstant.DEFAULT_TIME_FORMAT;
import static com.technology.oracle.scheduler.interval.client.IntervalClientConstant.intervalText;
import static com.technology.oracle.scheduler.interval.shared.field.IntervalFieldNames.DATE_INS;
import static com.technology.oracle.scheduler.interval.shared.field.IntervalFieldNames.INTERVAL_ID;
import static com.technology.oracle.scheduler.interval.shared.field.IntervalFieldNames.INTERVAL_TYPE_NAME;
import static com.technology.oracle.scheduler.interval.shared.field.IntervalFieldNames.MAX_VALUE;
import static com.technology.oracle.scheduler.interval.shared.field.IntervalFieldNames.MIN_VALUE;
import static com.technology.oracle.scheduler.interval.shared.field.IntervalFieldNames.OPERATOR_NAME;
import static com.technology.oracle.scheduler.interval.shared.field.IntervalFieldNames.STEP;

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
 
public class IntervalListFormViewImpl extends ListFormViewImpl<GridManager> {
 
  public IntervalListFormViewImpl() {
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
  private static NumberFormat defaultNumberFormatter = NumberFormat.getFormat("#");
 
  private static List<JepColumn> getColumnConfigurations() {
    final List<JepColumn> columnConfigurations = new ArrayList<JepColumn>();
    columnConfigurations.add(new JepColumn(INTERVAL_ID, intervalText.interval_list_interval_id(), 45, new NumberCell(defaultNumberFormatter)));
    columnConfigurations.add(new JepColumn(MIN_VALUE, intervalText.interval_list_min_value(), 70, new NumberCell(defaultNumberFormatter)));
    columnConfigurations.add(new JepColumn(MAX_VALUE, intervalText.interval_list_max_value(), 70, new NumberCell(defaultNumberFormatter)));
    columnConfigurations.add(new JepColumn(STEP, intervalText.interval_list_step(), 110, new NumberCell(defaultNumberFormatter)));
    columnConfigurations.add(new JepColumn(INTERVAL_TYPE_NAME, intervalText.interval_list_interval_type_name(), 110));
    columnConfigurations.add(DateColumnConfig(DATE_INS, intervalText.interval_list_date_ins(), 140));
    columnConfigurations.add(new JepColumn(OPERATOR_NAME, intervalText.interval_list_operator_name(), 310));
    return columnConfigurations;
  }
  
  private static JepColumn DateColumnConfig(String id, String name, int width) {
    return new JepColumn(id, name, width, new DateCell(dateWithTimeFormatter));
  }
   
  private String getGridId() {
    return this.getClass().toString().replace("class ", "");
  }
 
}
