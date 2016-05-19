package com.technology.oracle.scheduler.batchrole.client.ui.form.detail;
 
import static com.technology.oracle.scheduler.batch.client.BatchClientConstant.batchText;
import static com.technology.oracle.scheduler.batchrole.client.BatchRoleClientConstant.batchRoleText;
import static com.technology.oracle.scheduler.batchrole.shared.field.BatchRoleFieldNames.PRIVILEGE_CODE;
import static com.technology.oracle.scheduler.batchrole.shared.field.BatchRoleFieldNames.ROLE_ID;
import static com.technology.oracle.scheduler.interval.shared.field.IntervalFieldNames.DATA_SOURCE;

import com.google.gwt.dom.client.Style.Unit;
import com.google.gwt.user.client.ui.ScrollPanel;
import com.google.gwt.user.client.ui.VerticalPanel;
import com.technology.jep.jepria.client.ui.form.detail.DetailFormViewImpl;
import com.technology.jep.jepria.client.widget.field.FieldManager;
import com.technology.jep.jepria.client.widget.field.multistate.JepComboBoxField;
 
public class BatchRoleDetailFormViewImpl extends DetailFormViewImpl {	
 
	public BatchRoleDetailFormViewImpl() {
		super(new FieldManager());

		ScrollPanel scrollPanel = new ScrollPanel();
		scrollPanel.setSize("100%", "100%");
		
		VerticalPanel panel = new VerticalPanel();
		panel.getElement().getStyle().setMarginTop(5, Unit.PX);
		scrollPanel.add(panel);
		
		JepComboBoxField dataSourceComboBoxField = new JepComboBoxField(batchText.batch_detail_data_source());
		JepComboBoxField privilegeCodeComboBoxField = new JepComboBoxField(batchRoleText.batchRole_detail_privilege_code());
		privilegeCodeComboBoxField.setFieldWidth(300);
		
		JepComboBoxField roleIdComboBoxField = new JepComboBoxField(batchRoleText.batchRole_detail_role_id());
		roleIdComboBoxField.setEmptyText(batchRoleText.batchRole_detail_role_id_emptyText());
		roleIdComboBoxField.setFieldWidth(300);
		
		panel.add(dataSourceComboBoxField);
		panel.add(privilegeCodeComboBoxField);
		panel.add(roleIdComboBoxField);
		setWidget(scrollPanel);
 
		fields.put(DATA_SOURCE, dataSourceComboBoxField);
		fields.put(PRIVILEGE_CODE, privilegeCodeComboBoxField);
		fields.put(ROLE_ID, roleIdComboBoxField);
	}
 
}
