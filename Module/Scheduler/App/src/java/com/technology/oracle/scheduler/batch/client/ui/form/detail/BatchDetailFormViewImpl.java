package com.technology.oracle.scheduler.batch.client.ui.form.detail;
 
import static com.technology.jep.jepria.shared.field.JepFieldNames.MAX_ROW_COUNT;
import static com.technology.oracle.scheduler.batch.client.BatchClientConstant.batchText;
import static com.technology.oracle.scheduler.batch.shared.field.BatchFieldNames.BATCH_ID;
import static com.technology.oracle.scheduler.batch.shared.field.BatchFieldNames.BATCH_NAME;
import static com.technology.oracle.scheduler.batch.shared.field.BatchFieldNames.BATCH_SHORT_NAME;
import static com.technology.oracle.scheduler.batch.shared.field.BatchFieldNames.DATA_SOURCE;
import static com.technology.oracle.scheduler.batch.shared.field.BatchFieldNames.LAST_DATE_FROM;
import static com.technology.oracle.scheduler.batch.shared.field.BatchFieldNames.LAST_DATE_TO;
import static com.technology.oracle.scheduler.batch.shared.field.BatchFieldNames.MODULE_ID;
import static com.technology.oracle.scheduler.batch.shared.field.BatchFieldNames.RETRIAL_COUNT;
import static com.technology.oracle.scheduler.batch.shared.field.BatchFieldNames.RETRIAL_TIMEOUT;

import com.google.gwt.dom.client.Style.Unit;
import com.google.gwt.user.client.ui.ScrollPanel;
import com.google.gwt.user.client.ui.VerticalPanel;
import com.technology.jep.jepria.client.ui.form.detail.DetailFormViewImpl;
import com.technology.jep.jepria.client.widget.field.FieldManager;
import com.technology.jep.jepria.client.widget.field.multistate.JepComboBoxField;
import com.technology.jep.jepria.client.widget.field.multistate.JepDateField;
import com.technology.jep.jepria.client.widget.field.multistate.JepIntegerField;
import com.technology.jep.jepria.client.widget.field.multistate.JepNumberField;
import com.technology.jep.jepria.client.widget.field.multistate.JepTextField;
 
public class BatchDetailFormViewImpl 
	extends DetailFormViewImpl 
		implements BatchDetailFormView {	
 
	public BatchDetailFormViewImpl() {
		super(new FieldManager());

		ScrollPanel scrollPanel = new ScrollPanel();
		scrollPanel.setSize("100%", "100%");
		
		VerticalPanel panel = new VerticalPanel();
		panel.getElement().getStyle().setMarginTop(5, Unit.PX);
		scrollPanel.add(panel);
 
		JepComboBoxField dataSourceComboBoxField = new JepComboBoxField(batchText.batch_detail_data_source());
		JepNumberField batchIdNumberField = new JepNumberField(batchText.batch_detail_batch_id());
		JepTextField batchShortNameTextField = new JepTextField(batchText.batch_detail_batch_short_name());
		JepTextField batchNameTextField = new JepTextField(batchText.batch_detail_batch_name());
		JepComboBoxField moduleIdComboBoxField = new JepComboBoxField(batchText.batch_detail_module_id());
		JepDateField lastDateFromDateField = new JepDateField(batchText.batch_detail_last_date_from());
		JepDateField lastDateToDateField = new JepDateField(batchText.batch_detail_last_date_to());
		JepNumberField retrialCountNumberField = new JepNumberField(batchText.batch_detail_retrial_count());
		JepTextField retrialTimeoutTextField = new JepTextField(batchText.batch_detail_retrial_timeout());
		JepIntegerField maxRowCountField = new JepIntegerField(batchText.batch_detail_row_count());
		maxRowCountField.setMaxLength(4);
		maxRowCountField.setFieldWidth(55);
 
		panel.add(dataSourceComboBoxField);
		panel.add(batchIdNumberField);
		panel.add(batchShortNameTextField);
		panel.add(batchNameTextField);
		panel.add(moduleIdComboBoxField);
		panel.add(lastDateFromDateField);
		panel.add(lastDateToDateField);
		panel.add(retrialCountNumberField);
		panel.add(retrialTimeoutTextField);
		panel.add(maxRowCountField);
 
		setWidget(scrollPanel);
 
		fields.put(DATA_SOURCE, dataSourceComboBoxField);
		fields.put(BATCH_ID, batchIdNumberField);
		fields.put(BATCH_SHORT_NAME, batchShortNameTextField);
		fields.put(BATCH_NAME, batchNameTextField);
		fields.put(MODULE_ID, moduleIdComboBoxField);
		fields.put(LAST_DATE_FROM, lastDateFromDateField);
		fields.put(LAST_DATE_TO, lastDateToDateField);
		fields.put(RETRIAL_COUNT, retrialCountNumberField);
		fields.put(RETRIAL_TIMEOUT, retrialTimeoutTextField);
		fields.put(MAX_ROW_COUNT, maxRowCountField);
	}
 
}
