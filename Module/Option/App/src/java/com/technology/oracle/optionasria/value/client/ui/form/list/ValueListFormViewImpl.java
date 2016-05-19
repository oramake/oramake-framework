package com.technology.oracle.optionasria.value.client.ui.form.list;
 
import static com.technology.oracle.optionasria.value.client.ValueClientConstant.valueText;
import static com.technology.oracle.optionasria.value.shared.field.ValueFieldNames.*;
import static com.technology.jep.jepria.client.JepRiaClientConstant.JepTexts;
import com.extjs.gxt.ui.client.widget.grid.GridCellRenderer;
import com.extjs.gxt.ui.client.widget.grid.ColumnData;
import com.technology.jep.jepria.shared.util.JepRiaUtil;
import com.extjs.gxt.ui.client.Style.HorizontalAlignment;
import com.google.gwt.i18n.client.DateTimeFormat;
import static com.technology.jep.jepria.shared.JepRiaConstant.DEFAULT_DATE_FORMAT;
import static com.technology.jep.jepria.shared.JepRiaConstant.DEFAULT_TIME_FORMAT;
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
 
public class ValueListFormViewImpl extends JepListFormViewImpl<PagingManager> {
 
	public ValueListFormViewImpl() {
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
 
	private static GridCellRenderer<JepRecord> defaultGridCellRenderer = 
		new GridCellRenderer<JepRecord>() {
			@Override
			public Object render(JepRecord model, String property, ColumnData config, int rowIndex, int colIndex, ListStore<JepRecord> store, Grid<JepRecord> grid) {
				Boolean flag = (Boolean)model.get(property);
				return Boolean.TRUE.equals(flag) ? JepTexts.yes() : (JepRiaUtil.isEmpty(flag) ? "" : JepTexts.no());
			}
		};
	private static DateTimeFormat defaultDateFormatter = DateTimeFormat.getFormat(DEFAULT_DATE_FORMAT);
	private static DateTimeFormat dateWithTimeFormatter = DateTimeFormat.getFormat(DEFAULT_DATE_FORMAT+" "+DEFAULT_TIME_FORMAT);
 
	private static List<ColumnConfig> getColumnConfigurations() {
		final List<ColumnConfig> columnConfigurations = new ArrayList<ColumnConfig>();
		columnConfigurations.add(new ColumnConfig(VALUE_ID, valueText.value_list_value_id(), 150));
		columnConfigurations.add(new ColumnConfig(OPTION_ID, valueText.value_list_option_id(), 150));
		columnConfigurations.add(BooleanColumnConfig(USED_VALUE_FLAG, valueText.value_list_used_value_flag(), 150));
		columnConfigurations.add(BooleanColumnConfig(PROD_VALUE_FLAG, valueText.value_list_prod_value_flag(), 150));
		columnConfigurations.add(new ColumnConfig(INSTANCE_NAME, valueText.value_list_instance_name(), 150));
//		columnConfigurations.add(new ColumnConfig(VALUE_TYPE_CODE, valueText.value_list_value_type_code(), 150));
		columnConfigurations.add(new ColumnConfig(VALUE_TYPE_NAME, valueText.value_list_value_type_name(), 150));
		columnConfigurations.add(new ColumnConfig(STRING_VALUE, valueText.value_list_string_value(), 150));
		columnConfigurations.add(DateColumnConfig(DATE_VALUE, valueText.value_list_date_value(), 150));
		columnConfigurations.add(new ColumnConfig(NUMBER_VALUE, valueText.value_list_number_value(), 150));
		columnConfigurations.add(BooleanColumnConfig(ENCRYPTION_FLAG, valueText.value_list_encryption_flag(), 150));
		columnConfigurations.add(new ColumnConfig(LIST_SEPARATOR, valueText.value_list_list_separator(), 150));
		columnConfigurations.add(new ColumnConfig(USED_OPERATOR_NAME, valueText.value_list_used_operator_name(), 150));
		return columnConfigurations;
	}
	private static ColumnConfig BooleanColumnConfig(String id, String name, int width) {
		ColumnConfig booleanCol = new ColumnConfig(id, name, width);
		booleanCol.setRenderer(defaultGridCellRenderer);
		booleanCol.setAlignment(HorizontalAlignment.CENTER);
		return booleanCol;
	}
 
	private static ColumnConfig DateColumnConfig(String id, String name, int width) {
		ColumnConfig dateCol = new ColumnConfig(id, name, width);
		dateCol.setDateTimeFormat(dateWithTimeFormatter);
		dateCol.setAlignment(HorizontalAlignment.CENTER);
		return dateCol;
	}
 
}
