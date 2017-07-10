package com.technology.oracle.scheduler.detailedlog.client.ui.form.list;
 
import static com.technology.jep.jepria.shared.JepRiaConstant.DEFAULT_DATE_FORMAT;
import static com.technology.jep.jepria.shared.JepRiaConstant.DEFAULT_TIME_FORMAT;
import static com.technology.oracle.scheduler.detailedlog.client.DetailedLogClientConstant.detailedLogText;
import static com.technology.oracle.scheduler.detailedlog.shared.field.DetailedLogFieldNames.DATE_INS;
import static com.technology.oracle.scheduler.detailedlog.shared.field.DetailedLogFieldNames.LOG_ID;
import static com.technology.oracle.scheduler.detailedlog.shared.field.DetailedLogFieldNames.MESSAGE_TEXT;
import static com.technology.oracle.scheduler.detailedlog.shared.field.DetailedLogFieldNames.MESSAGE_TYPE_NAME;
import static com.technology.oracle.scheduler.detailedlog.shared.field.DetailedLogFieldNames.MESSAGE_VALUE;
import static com.technology.oracle.scheduler.detailedlog.shared.field.DetailedLogFieldNames.OPERATOR_NAME;
import static com.technology.oracle.scheduler.detailedlog.shared.field.DetailedLogFieldNames.PARENT_LOG_ID;

import java.util.ArrayList;
import java.util.List;

import com.google.gwt.cell.client.DateCell;
import com.google.gwt.cell.client.NumberCell;
import com.google.gwt.cell.client.TextCell;
import com.google.gwt.i18n.client.DateTimeFormat;
import com.google.gwt.i18n.client.NumberFormat;
import com.google.gwt.text.shared.ToStringRenderer;
import com.google.gwt.user.client.ui.HeaderPanel;
import com.technology.jep.jepria.client.ui.form.list.ListFormViewImpl;
import com.technology.jep.jepria.client.widget.list.GridManager;
import com.technology.jep.jepria.client.widget.list.JepColumn;
import com.technology.jep.jepria.client.widget.list.JepGrid;
import com.technology.jep.jepria.client.widget.toolbar.PagingStandardBar;
import com.technology.jep.jepria.shared.record.JepRecord;
import com.technology.oracle.scheduler.main.client.ui.form.list.NoEscapeHtmlRenderer;
 
public class DetailedLogListFormViewImpl extends ListFormViewImpl<GridManager> {
 
  public DetailedLogListFormViewImpl() {
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
    columnConfigurations.add(new JepColumn(LOG_ID, detailedLogText.detailedLog_list_log_id(), 70, new NumberCell(defaultNumberFormatter)));
    columnConfigurations.add(new JepColumn(PARENT_LOG_ID, detailedLogText.detailedLog_list_parent_log_id(), 90, new NumberCell(defaultNumberFormatter)));
    columnConfigurations.add(DateColumnConfig(DATE_INS, detailedLogText.detailedLog_list_date_ins(), 140));
    
    JepColumn messageTextColumnConfig = new JepColumn(MESSAGE_TEXT, detailedLogText.detailedLog_list_message_text(), 600, new TextCell(NoEscapeHtmlRenderer.getInstance()), true);
//    messageTextColumnConfig.setRenderer(new WrapTextGridCellRenderer());
    columnConfigurations.add(messageTextColumnConfig);
    
    columnConfigurations.add(new JepColumn(MESSAGE_VALUE, detailedLogText.detailedLog_list_message_value(), 90));
    columnConfigurations.add(new JepColumn(MESSAGE_TYPE_NAME, detailedLogText.detailedLog_list_message_type_name(), 160));
    columnConfigurations.add(new JepColumn(OPERATOR_NAME, detailedLogText.detailedLog_list_operator_name(), 200));
    return columnConfigurations;
  }
  
  private static JepColumn DateColumnConfig(String id, String name, int width) {
    return new JepColumn(id, name, width, new DateCell(dateWithTimeFormatter));
  }
   
  private String getGridId() {
    return this.getClass().toString().replace("class ", "");
  }
}
