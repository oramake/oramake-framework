package com.technology.oracle.scheduler.batchrole.client.ui.form.list;
 
import static com.technology.jep.jepria.shared.JepRiaConstant.DEFAULT_DATE_FORMAT;
import static com.technology.jep.jepria.shared.JepRiaConstant.DEFAULT_TIME_FORMAT;
import static com.technology.oracle.scheduler.batchrole.client.BatchRoleClientConstant.batchRoleText;
import static com.technology.oracle.scheduler.batchrole.shared.field.BatchRoleFieldNames.BATCH_ROLE_ID;
import static com.technology.oracle.scheduler.batchrole.shared.field.BatchRoleFieldNames.DATE_INS;
import static com.technology.oracle.scheduler.batchrole.shared.field.BatchRoleFieldNames.OPERATOR_NAME;
import static com.technology.oracle.scheduler.batchrole.shared.field.BatchRoleFieldNames.PRIVILEGE_CODE_STR;
import static com.technology.oracle.scheduler.batchrole.shared.field.BatchRoleFieldNames.PRIVILEGE_NAME;
import static com.technology.oracle.scheduler.batchrole.shared.field.BatchRoleFieldNames.ROLE_NAME;
import static com.technology.oracle.scheduler.batchrole.shared.field.BatchRoleFieldNames.ROLE_SHORT_NAME;

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
 
public class BatchRoleListFormViewImpl extends ListFormViewImpl<GridManager> {
   
    public BatchRoleListFormViewImpl() {
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
    
  private static NumberFormat defaultNumberFormatter = NumberFormat.getFormat("#");    
  private static DateTimeFormat defaultDateFormatter = DateTimeFormat.getFormat(DEFAULT_DATE_FORMAT);
  private static DateTimeFormat dateWithTimeFormatter = DateTimeFormat.getFormat(DEFAULT_DATE_FORMAT+" "+DEFAULT_TIME_FORMAT);
 
  private static List<JepColumn> getColumnConfigurations() {
    final List<JepColumn> columnConfigurations = new ArrayList<JepColumn>();
    columnConfigurations.add(new JepColumn(BATCH_ROLE_ID, batchRoleText.batchRole_list_batch_role_id(), 30, new NumberCell(defaultNumberFormatter)));
    columnConfigurations.add(new JepColumn(PRIVILEGE_CODE_STR, batchRoleText.batchRole_list_privilege_code(), 110));
    columnConfigurations.add(new JepColumn(ROLE_SHORT_NAME, batchRoleText.batchRole_list_role_short_name(), 195));
    columnConfigurations.add(new JepColumn(PRIVILEGE_NAME, batchRoleText.batchRole_list_privilege_name(), 220));
    columnConfigurations.add(new JepColumn(ROLE_NAME, batchRoleText.batchRole_list_role_name(), 400));
    columnConfigurations.add(DateColumnConfig(DATE_INS, batchRoleText.batchRole_list_date_ins(), 140));
    columnConfigurations.add(new JepColumn(OPERATOR_NAME, batchRoleText.batchRole_list_operator_name(), 4700));
    return columnConfigurations;
  }
  
  private static JepColumn DateColumnConfig(String id, String name, int width) {
    return new JepColumn(id, name, width, new DateCell(dateWithTimeFormatter));
  }
  
  private String getGridId() {
    return this.getClass().toString().replace("class ", "");
  } 
}
