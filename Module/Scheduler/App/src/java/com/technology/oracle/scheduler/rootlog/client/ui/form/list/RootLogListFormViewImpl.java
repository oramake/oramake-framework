package com.technology.oracle.scheduler.rootlog.client.ui.form.list;
 
import static com.technology.jep.jepria.shared.JepRiaConstant.DEFAULT_DATE_FORMAT;
import static com.technology.jep.jepria.shared.JepRiaConstant.DEFAULT_TIME_FORMAT;
import static com.technology.oracle.scheduler.rootlog.client.RootLogClientConstant.rootLogText;
import static com.technology.oracle.scheduler.rootlog.shared.field.RootLogFieldNames.DATE_INS;
import static com.technology.oracle.scheduler.rootlog.shared.field.RootLogFieldNames.LOG_ID;
import static com.technology.oracle.scheduler.rootlog.shared.field.RootLogFieldNames.MESSAGE_TEXT;
import static com.technology.oracle.scheduler.rootlog.shared.field.RootLogFieldNames.MESSAGE_TYPE_NAME;
import static com.technology.oracle.scheduler.rootlog.shared.field.RootLogFieldNames.OPERATOR_NAME;

import java.util.ArrayList;
import java.util.List;

import com.google.gwt.cell.client.DateCell;
import com.google.gwt.cell.client.NumberCell;
import com.google.gwt.cell.client.TextCell;
import com.google.gwt.i18n.client.DateTimeFormat;
import com.google.gwt.i18n.client.NumberFormat;
import com.google.gwt.user.client.ui.HeaderPanel;
import com.technology.jep.jepria.client.ui.form.list.ListFormViewImpl;
import com.technology.jep.jepria.client.widget.list.GridManager;
import com.technology.jep.jepria.client.widget.list.JepColumn;
import com.technology.jep.jepria.client.widget.list.JepGrid;
import com.technology.jep.jepria.client.widget.toolbar.PagingStandardBar;
import com.technology.jep.jepria.shared.record.JepRecord;
 
public class RootLogListFormViewImpl extends ListFormViewImpl<GridManager> {
 
	public RootLogListFormViewImpl() {
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
		columnConfigurations.add(new JepColumn(LOG_ID, rootLogText.rootLog_list_log_id(), 65, new NumberCell(defaultNumberFormatter)));
		columnConfigurations.add(DateColumnConfig(DATE_INS, rootLogText.rootLog_list_date_ins(), 140));
		
		JepColumn messageText = new JepColumn(MESSAGE_TEXT, rootLogText.rootLog_list_message_text(), 570, new TextCell(), true);
//		messageText.setRenderer(new WrapTextGridCellRenderer());
		columnConfigurations.add(messageText);
		
		columnConfigurations.add(new JepColumn(MESSAGE_TYPE_NAME, rootLogText.rootLog_list_message_type_name(), 160));
		columnConfigurations.add(new JepColumn(OPERATOR_NAME, rootLogText.rootLog_list_operator_name(), 200));
		return columnConfigurations;
	}

	private static JepColumn DateColumnConfig(String id, String name, int width) {
		return new JepColumn(id, name, width, new DateCell(dateWithTimeFormatter));
	}
	 
	private String getGridId() {
		return this.getClass().toString().replace("class ", "");
	}
}
