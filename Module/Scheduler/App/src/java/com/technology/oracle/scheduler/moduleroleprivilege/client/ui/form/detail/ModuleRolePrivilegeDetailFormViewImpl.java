package com.technology.oracle.scheduler.moduleroleprivilege.client.ui.form.detail;
 
import static com.technology.jep.jepria.shared.field.JepFieldNames.MAX_ROW_COUNT;
import static com.technology.oracle.scheduler.batchrole.client.BatchRoleClientConstant.batchRoleText;
import static com.technology.oracle.scheduler.moduleroleprivilege.client.ModuleRolePrivilegeClientConstant.moduleRolePrivilegeText;
import static com.technology.oracle.scheduler.moduleroleprivilege.shared.field.ModuleRolePrivilegeFieldNames.DATA_SOURCE;
import static com.technology.oracle.scheduler.moduleroleprivilege.shared.field.ModuleRolePrivilegeFieldNames.MODULE_ID;
import static com.technology.oracle.scheduler.moduleroleprivilege.shared.field.ModuleRolePrivilegeFieldNames.MODULE_ROLE_PRIVILEGE_ID;
import static com.technology.oracle.scheduler.moduleroleprivilege.shared.field.ModuleRolePrivilegeFieldNames.PRIVILEGE_CODE;
import static com.technology.oracle.scheduler.moduleroleprivilege.shared.field.ModuleRolePrivilegeFieldNames.ROLE_ID;

import com.google.gwt.dom.client.Style.Unit;
import com.google.gwt.user.client.ui.ScrollPanel;
import com.google.gwt.user.client.ui.VerticalPanel;
import com.technology.jep.jepria.client.ui.form.detail.DetailFormViewImpl;
import com.technology.jep.jepria.client.widget.field.FieldManager;
import com.technology.jep.jepria.client.widget.field.multistate.JepComboBoxField;
import com.technology.jep.jepria.client.widget.field.multistate.JepIntegerField;
import com.technology.jep.jepria.client.widget.field.multistate.JepNumberField;
 
public class ModuleRolePrivilegeDetailFormViewImpl extends DetailFormViewImpl {	
 
	public ModuleRolePrivilegeDetailFormViewImpl() {
		super(new FieldManager());

		ScrollPanel scrollPanel = new ScrollPanel();
		scrollPanel.setSize("100%", "100%");
		
		VerticalPanel panel = new VerticalPanel();
		panel.getElement().getStyle().setMarginTop(5, Unit.PX);
		scrollPanel.add(panel);
 
		JepComboBoxField dataSourceComboBoxField = new JepComboBoxField(moduleRolePrivilegeText.moduleRolePrivilege_detail_data_source());
		JepNumberField moduleRolePrivilegeIdNumberField = new JepNumberField(moduleRolePrivilegeText.moduleRolePrivilege_detail_module_role_privilege_id());
		JepComboBoxField moduleIdComboBoxField = new JepComboBoxField(moduleRolePrivilegeText.moduleRolePrivilege_detail_module_id());
		JepComboBoxField privilegeCodeComboBoxField = new JepComboBoxField(moduleRolePrivilegeText.moduleRolePrivilege_detail_privilege_code());
		privilegeCodeComboBoxField.setFieldWidth(300);
		
		JepComboBoxField roleIdComboBoxField = new JepComboBoxField(moduleRolePrivilegeText.moduleRolePrivilege_detail_role_id());
		roleIdComboBoxField.setEmptyText(batchRoleText.batchRole_detail_role_id_emptyText());
		roleIdComboBoxField.setFieldWidth(300);
		
		JepIntegerField maxRowCountField = new JepIntegerField(moduleRolePrivilegeText.moduleRolePrivilege_detail_row_count());
		maxRowCountField.setMaxLength(4);
		maxRowCountField.setFieldWidth(55);
 
		panel.add(dataSourceComboBoxField);
		panel.add(moduleRolePrivilegeIdNumberField);
		panel.add(moduleIdComboBoxField);
		panel.add(privilegeCodeComboBoxField);
		panel.add(roleIdComboBoxField);
		panel.add(maxRowCountField);
 
		setWidget(scrollPanel);
 
		fields.put(DATA_SOURCE, dataSourceComboBoxField);
		fields.put(MODULE_ROLE_PRIVILEGE_ID, moduleRolePrivilegeIdNumberField);
		fields.put(MODULE_ID, moduleIdComboBoxField);
		fields.put(PRIVILEGE_CODE, privilegeCodeComboBoxField);
		fields.put(ROLE_ID, roleIdComboBoxField);
		fields.put(MAX_ROW_COUNT, maxRowCountField);
	}
 
}
