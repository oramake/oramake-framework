package com.technology.oracle.scheduler.batch.client.ui.form.list;
 
import static com.technology.jep.jepria.shared.JepRiaConstant.DEFAULT_DATE_FORMAT;
import static com.technology.jep.jepria.shared.JepRiaConstant.DEFAULT_TIME_FORMAT;
import static com.technology.oracle.scheduler.batch.client.BatchClientConstant.batchText;
import static com.technology.oracle.scheduler.batch.shared.field.BatchFieldNames.BATCH_ID;
import static com.technology.oracle.scheduler.batch.shared.field.BatchFieldNames.BATCH_NAME;
import static com.technology.oracle.scheduler.batch.shared.field.BatchFieldNames.BATCH_SHORT_NAME;
import static com.technology.oracle.scheduler.batch.shared.field.BatchFieldNames.DATE_INS;
import static com.technology.oracle.scheduler.batch.shared.field.BatchFieldNames.DURATION_SECOND;
import static com.technology.oracle.scheduler.batch.shared.field.BatchFieldNames.ERROR_COUNT;
import static com.technology.oracle.scheduler.batch.shared.field.BatchFieldNames.ERROR_JOB_COUNT;
import static com.technology.oracle.scheduler.batch.shared.field.BatchFieldNames.FAILURES;
import static com.technology.oracle.scheduler.batch.shared.field.BatchFieldNames.IS_JOB_BROKEN;
import static com.technology.oracle.scheduler.batch.shared.field.BatchFieldNames.JOB;
import static com.technology.oracle.scheduler.batch.shared.field.BatchFieldNames.LAST_DATE;
import static com.technology.oracle.scheduler.batch.shared.field.BatchFieldNames.LAST_LOG_DATE;
import static com.technology.oracle.scheduler.batch.shared.field.BatchFieldNames.LAST_START_DATE;
import static com.technology.oracle.scheduler.batch.shared.field.BatchFieldNames.MODULE_NAME;
import static com.technology.oracle.scheduler.batch.shared.field.BatchFieldNames.NEXT_DATE;
import static com.technology.oracle.scheduler.batch.shared.field.BatchFieldNames.OPERATOR_NAME;
import static com.technology.oracle.scheduler.batch.shared.field.BatchFieldNames.ORACLE_JOB_ID;
import static com.technology.oracle.scheduler.batch.shared.field.BatchFieldNames.RESULT_NAME;
import static com.technology.oracle.scheduler.batch.shared.field.BatchFieldNames.RETRIAL_COUNT;
import static com.technology.oracle.scheduler.batch.shared.field.BatchFieldNames.RETRIAL_NUMBER;
import static com.technology.oracle.scheduler.batch.shared.field.BatchFieldNames.RETRIAL_TIMEOUT;
import static com.technology.oracle.scheduler.batch.shared.field.BatchFieldNames.ROOT_LOG_ID;
import static com.technology.oracle.scheduler.batch.shared.field.BatchFieldNames.SERIAL;
import static com.technology.oracle.scheduler.batch.shared.field.BatchFieldNames.SID;
import static com.technology.oracle.scheduler.batch.shared.field.BatchFieldNames.THIS_DATE;
import static com.technology.oracle.scheduler.batch.shared.field.BatchFieldNames.TOTAL_TIME;
import static com.technology.oracle.scheduler.batch.shared.field.BatchFieldNames.WARNING_COUNT;

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
 
public class BatchListFormViewImpl extends ListFormViewImpl<GridManager> {
 
  public BatchListFormViewImpl() {
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
 
  private List<JepColumn> getColumnConfigurations() {
    final List<JepColumn> columnConfigurations = new ArrayList<JepColumn>();
    columnConfigurations.add(new JepColumn(BATCH_ID, batchText.batch_list_batch_id(), 40, new NumberCell(defaultNumberFormatter)));
    columnConfigurations.add(new JepColumn(BATCH_NAME, batchText.batch_list_batch_name(), 200));
    columnConfigurations.add(new JepColumn(BATCH_SHORT_NAME, batchText.batch_list_batch_short_name(), 180));
    columnConfigurations.add(new JepColumn(MODULE_NAME, batchText.batch_list_module_name(), 160));
    columnConfigurations.add(new JepColumn(RETRIAL_COUNT, batchText.batch_list_retrial_count(), 120, new NumberCell(defaultNumberFormatter)));
    columnConfigurations.add(new JepColumn(RETRIAL_TIMEOUT, batchText.batch_list_retrial_timeout(), 140));
    columnConfigurations.add(new JepColumn(ORACLE_JOB_ID, batchText.batch_list_oracle_job_id(), 110, new NumberCell(defaultNumberFormatter)));
    columnConfigurations.add(new JepColumn(RETRIAL_NUMBER, batchText.batch_list_retrial_number(), 140, new NumberCell(defaultNumberFormatter)));
    columnConfigurations.add(DateColumnConfig(DATE_INS, batchText.batch_list_date_ins(), 90));
    columnConfigurations.add(new JepColumn(OPERATOR_NAME, batchText.batch_list_operator_name(), 210));
    columnConfigurations.add(new JepColumn(JOB, batchText.batch_list_job(), 120, new NumberCell(defaultNumberFormatter)));
    columnConfigurations.add(DateColumnConfig(LAST_DATE, batchText.batch_list_last_date(), 140));
    columnConfigurations.add(DateColumnConfig(THIS_DATE, batchText.batch_list_this_date(), 140));
    columnConfigurations.add(DateColumnConfig(NEXT_DATE, batchText.batch_list_next_date(), 140));
    columnConfigurations.add(new JepColumn(TOTAL_TIME, batchText.batch_list_total_time(), 120, new NumberCell(defaultNumberFormatter)));
    columnConfigurations.add(new JepColumn(FAILURES, batchText.batch_list_failures(), 160, new NumberCell(defaultNumberFormatter)));
    columnConfigurations.add(new JepColumn(IS_JOB_BROKEN, batchText.batch_list_is_job_broken(), 110, new NumberCell(defaultNumberFormatter)));
    columnConfigurations.add(new JepColumn(SID, batchText.batch_list_sid(), 110, new NumberCell(defaultNumberFormatter)));
    columnConfigurations.add(new JepColumn(SERIAL, batchText.batch_list_serial(), 110, new NumberCell(defaultNumberFormatter)));
    columnConfigurations.add(new JepColumn(ROOT_LOG_ID, batchText.batch_list_root_log_id(), 110, new NumberCell(defaultNumberFormatter)));
    columnConfigurations.add(DateColumnConfig(LAST_START_DATE, batchText.batch_list_last_start_date(), 160));
    columnConfigurations.add(DateColumnConfig(LAST_LOG_DATE, batchText.batch_list_last_log_date(), 140));
    columnConfigurations.add(new JepColumn(RESULT_NAME, batchText.batch_list_result_name(), 180));
    columnConfigurations.add(new JepColumn(ERROR_JOB_COUNT, batchText.batch_list_error_job_count(), 120, new NumberCell(defaultNumberFormatter)));
    columnConfigurations.add(new JepColumn(ERROR_COUNT, batchText.batch_list_error_count(), 90, new NumberCell(defaultNumberFormatter)));
    columnConfigurations.add(new JepColumn(WARNING_COUNT, batchText.batch_list_warning_count(), 120, new NumberCell(defaultNumberFormatter)));
    columnConfigurations.add(new JepColumn(DURATION_SECOND, batchText.batch_list_duration(), 180, new NumberCell(defaultNumberFormatter)));
    return columnConfigurations;
  }
  
  private static JepColumn DateColumnConfig(String id, String name, int width) {
    return new JepColumn(id, name, width, new DateCell(dateWithTimeFormatter));
  }
   
  private String getGridId() {
    return this.getClass().toString().replace("class ", "");
  }

}
