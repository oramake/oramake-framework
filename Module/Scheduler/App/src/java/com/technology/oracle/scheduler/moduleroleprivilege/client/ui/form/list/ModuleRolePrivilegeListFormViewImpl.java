package com.technology.oracle.scheduler.moduleroleprivilege.client.ui.form.list;
 
import static com.technology.jep.jepria.shared.JepRiaConstant.DEFAULT_DATE_FORMAT;
import static com.technology.jep.jepria.shared.JepRiaConstant.DEFAULT_TIME_FORMAT;
import static com.technology.oracle.scheduler.moduleroleprivilege.client.ModuleRolePrivilegeClientConstant.moduleRolePrivilegeText;
import static com.technology.oracle.scheduler.moduleroleprivilege.shared.field.ModuleRolePrivilegeFieldNames.DATE_INS;
import static com.technology.oracle.scheduler.moduleroleprivilege.shared.field.ModuleRolePrivilegeFieldNames.MODULE_NAME;
import static com.technology.oracle.scheduler.moduleroleprivilege.shared.field.ModuleRolePrivilegeFieldNames.MODULE_ROLE_PRIVILEGE_ID;
import static com.technology.oracle.scheduler.moduleroleprivilege.shared.field.ModuleRolePrivilegeFieldNames.OPERATOR_NAME;
import static com.technology.oracle.scheduler.moduleroleprivilege.shared.field.ModuleRolePrivilegeFieldNames.PRIVILEGE_CODE_STR;
import static com.technology.oracle.scheduler.moduleroleprivilege.shared.field.ModuleRolePrivilegeFieldNames.PRIVILEGE_NAME;
import static com.technology.oracle.scheduler.moduleroleprivilege.shared.field.ModuleRolePrivilegeFieldNames.ROLE_NAME;
import static com.technology.oracle.scheduler.moduleroleprivilege.shared.field.ModuleRolePrivilegeFieldNames.ROLE_SHORT_NAME;

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
 
public class ModuleRolePrivilegeListFormViewImpl extends ListFormViewImpl<GridManager> {
 
	public ModuleRolePrivilegeListFormViewImpl() {
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
		columnConfigurations.add(new JepColumn(MODULE_ROLE_PRIVILEGE_ID, moduleRolePrivilegeText.moduleRolePrivilege_list_module_role_privilege_id(), 50, new NumberCell(defaultNumberFormatter)));
		columnConfigurations.add(new JepColumn(MODULE_NAME, moduleRolePrivilegeText.moduleRolePrivilege_list_module_name(), 220));
		columnConfigurations.add(new JepColumn(PRIVILEGE_CODE_STR, moduleRolePrivilegeText.moduleRolePrivilege_list_privilege_code(), 110));
		columnConfigurations.add(new JepColumn(ROLE_SHORT_NAME, moduleRolePrivilegeText.moduleRolePrivilege_list_role_short_name(), 200));
		columnConfigurations.add(new JepColumn(PRIVILEGE_NAME, moduleRolePrivilegeText.moduleRolePrivilege_list_privilege_name(), 220));
		columnConfigurations.add(new JepColumn(ROLE_NAME, moduleRolePrivilegeText.moduleRolePrivilege_list_role_name(), 400));
		columnConfigurations.add(DateColumnConfig(DATE_INS, moduleRolePrivilegeText.moduleRolePrivilege_list_date_ins(), 90));
		columnConfigurations.add(new JepColumn(OPERATOR_NAME, moduleRolePrivilegeText.moduleRolePrivilege_list_operator_name(), 200));
		return columnConfigurations;
	}
	
	private static JepColumn DateColumnConfig(String id, String name, int width) {
		return new JepColumn(id, name, width, new DateCell(dateWithTimeFormatter));
	}
	 
	private String getGridId() {
		return this.getClass().toString().replace("class ", "");
	}
 
}
