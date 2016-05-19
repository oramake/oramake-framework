package com.technology.oracle.optionasria.option.client.ui.form.list;
 
import static com.technology.oracle.optionasria.option.client.OptionClientConstant.optionText;
import static com.technology.oracle.optionasria.option.shared.field.OptionFieldNames.*;

import com.google.gwt.i18n.client.DateTimeFormat;
import com.extjs.gxt.ui.client.Style.HorizontalAlignment;
import static com.technology.jep.jepria.shared.JepRiaConstant.DEFAULT_DATE_FORMAT;
import static com.technology.jep.jepria.shared.JepRiaConstant.DEFAULT_TIME_FORMAT;
import static com.technology.jep.jepria.client.JepRiaClientConstant.JepTexts;
import com.extjs.gxt.ui.client.widget.grid.GridCellRenderer;
import com.extjs.gxt.ui.client.widget.grid.ColumnData;
import com.technology.jep.jepria.shared.util.JepRiaUtil;
import com.extjs.gxt.ui.client.widget.ContentPanel;
import com.extjs.gxt.ui.client.widget.grid.Grid;
import com.extjs.gxt.ui.client.widget.layout.FitLayout;
import com.extjs.gxt.ui.client.widget.grid.ColumnConfig;
import com.extjs.gxt.ui.client.store.ListStore;
import com.extjs.gxt.ui.client.widget.grid.ColumnModel;
import com.technology.jep.jepria.shared.record.JepRecord;
import com.technology.jep.jepria.client.ui.form.list.JepListFormViewImpl;
import java.util.List;
import com.technology.jep.jepria.client.widget.list.JepGrid;
import com.technology.jep.jepria.client.widget.list.PagingManager;
import com.technology.jep.jepria.client.widget.toolbar.JepPagingStandardBar;
import java.util.ArrayList;
 
public class OptionListFormViewImpl extends JepListFormViewImpl<PagingManager> {
 
	public OptionListFormViewImpl() {
		super(new PagingManager());
		ContentPanel container = new ContentPanel();
		container.setHeaderVisible(false);
		container.setLayout(new FitLayout());
 
		Grid<JepRecord> grid = new JepGrid<JepRecord>(new ListStore<JepRecord>(), new ColumnModel(getColumnConfigurations()));
		container.add(grid);
 
		JepPagingStandardBar pagingToolBar = new JepPagingStandardBar(25);
		container.setBottomComponent(pagingToolBar);
 
		setBody(container);
		list.setWidget(grid);
		list.setPagingToolBar(pagingToolBar);
	}
 
	private static DateTimeFormat defaultDateFormatter = DateTimeFormat.getFormat(DEFAULT_DATE_FORMAT);
	private static DateTimeFormat dateWithTimeFormatter = DateTimeFormat.getFormat(DEFAULT_DATE_FORMAT+" "+DEFAULT_TIME_FORMAT);
	
	private static GridCellRenderer<JepRecord> defaultGridCellRenderer = 
		new GridCellRenderer<JepRecord>() {
			@Override
			public Object render(JepRecord model, String property, ColumnData config, int rowIndex, int colIndex, ListStore<JepRecord> store, Grid<JepRecord> grid) {
				Boolean flag = (Boolean)model.get(property);
				return Boolean.TRUE.equals(flag) ? JepTexts.yes() : (JepRiaUtil.isEmpty(flag) ? "" : JepTexts.no());
			}
		};
		

 
	private static List<ColumnConfig> getColumnConfigurations() {
		final List<ColumnConfig> columnConfigurations = new ArrayList<ColumnConfig>();
		columnConfigurations.add(new ColumnConfig(OPTION_ID, optionText.option_list_option_id(), 150));
		columnConfigurations.add(new ColumnConfig(OPTION_NAME, optionText.option_list_option_name(), 150));
		columnConfigurations.add(new ColumnConfig(OPTION_SHORT_NAME, optionText.option_list_option_short_name(), 150));
		columnConfigurations.add(new ColumnConfig(VALUE_TYPE_NAME, optionText.option_list_value_type_name(), 150));
		columnConfigurations.add(new ColumnConfig(STRING_VALUE, optionText.option_list_string_value(), 150));
		columnConfigurations.add(DateColumnConfig(DATE_VALUE, optionText.option_list_date_value(), 150));
		columnConfigurations.add(new ColumnConfig(NUMBER_VALUE, optionText.option_list_number_value(), 150));
		columnConfigurations.add(new ColumnConfig(OBJECT_SHORT_NAME, optionText.option_list_object_short_name(), 150));
		columnConfigurations.add(new ColumnConfig(OBJECT_TYPE_SHORT_NAME, optionText.option_list_object_type_short_name(), 150));
		columnConfigurations.add(new ColumnConfig(MODULE_NAME, optionText.option_list_module_name(), 150));
		columnConfigurations.add(BooleanColumnConfig(VALUE_LIST_FLAG, optionText.option_list_value_list_flag(), 150));
		columnConfigurations.add(new ColumnConfig(LIST_SEPARATOR, optionText.option_list_list_separator(), 150));
		columnConfigurations.add(BooleanColumnConfig(ENCRYPTION_FLAG, optionText.option_list_encryption_flag(), 150));
		columnConfigurations.add(BooleanColumnConfig(TEST_PROD_SENSITIVE_FLAG, optionText.option_list_test_prod_sensitive_flag(), 150));
		columnConfigurations.add(new ColumnConfig(ACCESS_LEVEL_NAME, optionText.option_list_access_level_name(), 150));
		columnConfigurations.add(new ColumnConfig(MODULE_SVN_ROOT, optionText.option_list_module_svn_root(), 150));
		return columnConfigurations;
	}
	private static ColumnConfig DateColumnConfig(String id, String name, int width) {
		ColumnConfig dateCol = new ColumnConfig(id, name, width);
		dateCol.setDateTimeFormat(dateWithTimeFormatter);
		dateCol.setAlignment(HorizontalAlignment.CENTER);
		return dateCol;
	}
 
	private static ColumnConfig BooleanColumnConfig(String id, String name, int width) {
		ColumnConfig booleanCol = new ColumnConfig(id, name, width);
		booleanCol.setRenderer(defaultGridCellRenderer);
		booleanCol.setAlignment(HorizontalAlignment.CENTER);
		return booleanCol;
	}
 
}
