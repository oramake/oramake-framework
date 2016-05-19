package com.technology.oracle.scheduler.schedule.client.ui.form.list;
 
import static com.technology.jep.jepria.shared.JepRiaConstant.DEFAULT_DATE_FORMAT;
import static com.technology.jep.jepria.shared.JepRiaConstant.DEFAULT_TIME_FORMAT;
import static com.technology.oracle.scheduler.schedule.client.ScheduleClientConstant.scheduleText;
import static com.technology.oracle.scheduler.schedule.shared.field.ScheduleFieldNames.DATE_INS;
import static com.technology.oracle.scheduler.schedule.shared.field.ScheduleFieldNames.OPERATOR_NAME;
import static com.technology.oracle.scheduler.schedule.shared.field.ScheduleFieldNames.SCHEDULE_ID;
import static com.technology.oracle.scheduler.schedule.shared.field.ScheduleFieldNames.SCHEDULE_NAME;

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
 
public class ScheduleListFormViewImpl extends ListFormViewImpl<GridManager> {
 
	public ScheduleListFormViewImpl() {
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
		columnConfigurations.add(new JepColumn(SCHEDULE_ID, scheduleText.schedule_list_schedule_id(), 150, new NumberCell(defaultNumberFormatter)));
		columnConfigurations.add(new JepColumn(SCHEDULE_NAME, scheduleText.schedule_list_schedule_name(), 150));
		columnConfigurations.add(DateColumnConfig(DATE_INS, scheduleText.schedule_list_date_ins(), 150));
		columnConfigurations.add(new JepColumn(OPERATOR_NAME, scheduleText.schedule_list_operator_name(), 150));
		return columnConfigurations;
	}
	
	private static JepColumn DateColumnConfig(String id, String name, int width) {
		return new JepColumn(id, name, width, new DateCell(dateWithTimeFormatter));
	}
	 
	private String getGridId() {
		return this.getClass().toString().replace("class ", "");
	}
}
