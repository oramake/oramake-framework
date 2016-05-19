package com.technology.oracle.scheduler.moduleroleprivilege.client.ui.form.detail;
 
import static com.technology.jep.jepria.client.ui.WorkstateEnum.CREATE;
import static com.technology.jep.jepria.client.ui.WorkstateEnum.SEARCH;
import static com.technology.jep.jepria.shared.field.JepFieldNames.MAX_ROW_COUNT;
import static com.technology.oracle.scheduler.moduleroleprivilege.shared.field.ModuleRolePrivilegeFieldNames.DATA_SOURCE;
import static com.technology.oracle.scheduler.moduleroleprivilege.shared.field.ModuleRolePrivilegeFieldNames.MODULE_ID;
import static com.technology.oracle.scheduler.moduleroleprivilege.shared.field.ModuleRolePrivilegeFieldNames.MODULE_ROLE_PRIVILEGE_ID;
import static com.technology.oracle.scheduler.moduleroleprivilege.shared.field.ModuleRolePrivilegeFieldNames.PRIVILEGE_CODE;
import static com.technology.oracle.scheduler.moduleroleprivilege.shared.field.ModuleRolePrivilegeFieldNames.ROLE_ID;

import java.util.ArrayList;
import java.util.List;

import com.google.gwt.place.shared.Place;
import com.technology.jep.jepria.client.async.FirstTimeUseAsyncCallback;
import com.technology.jep.jepria.client.async.TypingTimeoutAsyncCallback;
import com.technology.jep.jepria.client.ui.WorkstateEnum;
import com.technology.jep.jepria.client.ui.eventbus.plain.PlainEventBus;
import com.technology.jep.jepria.client.ui.form.detail.DetailFormPresenter;
import com.technology.jep.jepria.client.ui.form.detail.DetailFormView;
import com.technology.jep.jepria.client.ui.plain.StandardClientFactory;
import com.technology.jep.jepria.client.widget.event.JepEvent;
import com.technology.jep.jepria.client.widget.event.JepEventType;
import com.technology.jep.jepria.client.widget.event.JepListener;
import com.technology.jep.jepria.client.widget.field.multistate.JepComboBoxField;
import com.technology.jep.jepria.shared.field.option.JepOption;
import com.technology.jep.jepria.shared.util.JepRiaUtil;
import com.technology.oracle.scheduler.moduleroleprivilege.shared.service.ModuleRolePrivilegeServiceAsync;
 
public class ModuleRolePrivilegeDetailFormPresenter<E extends PlainEventBus, S extends ModuleRolePrivilegeServiceAsync> 
		extends DetailFormPresenter<DetailFormView, E, S, StandardClientFactory<E, S>> { 

	public ModuleRolePrivilegeDetailFormPresenter(Place place, StandardClientFactory<E, S> clientFactory) {
		super(place, clientFactory);
	}
 
	public void bind() {
		super.bind();
		// Здесь размещается код связывания presenter-а и view 
		fields.addFieldListener(DATA_SOURCE, JepEventType.FIRST_TIME_USE_EVENT, new JepListener() {
			@Override
			public void handleEvent(final JepEvent event) {
				service.getDataSource(new FirstTimeUseAsyncCallback<List<JepOption>>(event) {
					public void onSuccessLoad(List<JepOption> result){
						fields.setFieldOptions(DATA_SOURCE, result);
					}
				});
			}
		});
		
		
		fields.addFieldListener(DATA_SOURCE, JepEventType.CHANGE_SELECTION_EVENT, new JepListener() {

			@Override
			public void handleEvent(JepEvent event) {

				setDataSourceDependFields();
				changeModules();
			}			
		});
		
		/*
		fields.addFieldListener(MODULE_ID, JepEventType.FIRST_TIME_USE_EVENT, new JepListener() {
			@Override
			public void handleEvent(final JepEvent event) {
				service.getModule(JepOption.<String>getValue(fields.getFieldValue(DATA_SOURCE)), new JepFirstTimeUseAsyncCallback<List<JepOption>>(event) {
					public void onSuccessLoad(List<JepOption> result){
						fields.setFieldOptions(MODULE_ID, result);
					}
				});
			}
		});
		*/
		
		fields.addFieldListener(PRIVILEGE_CODE, JepEventType.FIRST_TIME_USE_EVENT, new JepListener() {
			@Override
			public void handleEvent(final JepEvent event) {
				service.getPrivilege(JepOption.<String>getValue(fields.getFieldValue(DATA_SOURCE)), new FirstTimeUseAsyncCallback<List<JepOption>>(event) {
					public void onSuccessLoad(List<JepOption> result){
						fields.setFieldOptions(PRIVILEGE_CODE, result);
					}
				});
			}
		});
		
		fields.addFieldListener(ROLE_ID, JepEventType.TYPING_TIMEOUT_EVENT, new JepListener() {
			@Override
			public void handleEvent(final JepEvent event) {
				setRole();
			}
			
		});
	}
	
	private void changeModules(){

		fields.clearField(MODULE_ID);
		
		String dataSource = JepOption.<String>getValue(fields.getFieldValue(DATA_SOURCE));
		final JepComboBoxField moduleComboBoxField = (JepComboBoxField)fields.get(MODULE_ID);
		
		
		if(!JepRiaUtil.isEmpty(dataSource)){
			
			moduleComboBoxField.setLoadingImage(true);
			fields.setFieldEnabled(MODULE_ID, false);
			
			service.getModule(dataSource, new TypingTimeoutAsyncCallback<List<JepOption>>(new JepEvent(moduleComboBoxField)) {
				public void onSuccessLoad(List<JepOption> result){
					
					moduleComboBoxField.setLoadingImage(false);
					fields.setFieldOptions(MODULE_ID, result);
					fields.setFieldEnabled(MODULE_ID, true);
	
				}
				
				public void onFailure(Throwable caught) {
					
					moduleComboBoxField.setLoadingImage(false);
					fields.setFieldOptions(MODULE_ID, new ArrayList<JepOption>());
					super.onFailure(caught);
				}
			});
			
		}
	}

	private void setRole(){
		
		JepComboBoxField roleField = (JepComboBoxField) fields.get(ROLE_ID);
		roleField.setLoadingImage(true);
		String rawValue = roleField.getRawValue();
		service.getRole(JepOption.<String>getValue(fields.getFieldValue(DATA_SOURCE)), rawValue + "%", 
				new TypingTimeoutAsyncCallback<List<JepOption>>(new JepEvent(roleField)
			) {
				@SuppressWarnings("unchecked")
				public void onSuccessLoad(List<JepOption> result){
	
					JepComboBoxField roleField = (JepComboBoxField) fields.get(ROLE_ID);
					roleField.setOptions(result);
					/*
					List<JepOption> roleIdsList = new ArrayList<JepOption>();
					
					if(result.size() >= OPTION_NUMBER){
						
						for(Integer count = 0;!count.equals(OPTION_NUMBER); count++){
							roleIdsList.add(result.get(count));
						}
						
					}else{
						roleIdsList = result;
					}
					
					roleField.setLastOptionText(result.size() >= OPTION_NUMBER ? fraudText.fraud_detail_responsibility_operator_id_lastOptionText() : null);
					roleField.setOptions(roleIdsList);
					*/
				}
				@Override
				public void onFailure(Throwable caught) {
					super.onFailure(caught);
				}
		});
		
	}
	
	private void setDataSourceDependFields(){
		
		Boolean enabled = false;
		if(
			!JepRiaUtil.isEmpty(JepOption.<String>getValue(fields.getFieldValue(DATA_SOURCE)))
			){
			enabled = true;
		}
		
		fields.setFieldEnabled(MODULE_ROLE_PRIVILEGE_ID, enabled);
		fields.setFieldEnabled(MODULE_ID, enabled);
		fields.setFieldEnabled(PRIVILEGE_CODE, enabled);
		fields.setFieldEnabled(ROLE_ID, enabled);
	}
	
 
	protected void adjustToWorkstate(WorkstateEnum workstate) {
		
		setDataSourceDependFields();
		
		fields.setFieldVisible(MODULE_ROLE_PRIVILEGE_ID, SEARCH.equals(workstate));
 
		fields.setFieldAllowBlank(DATA_SOURCE, !(CREATE.equals(workstate) || SEARCH.equals(workstate)));
		fields.setFieldAllowBlank(MODULE_ID, !CREATE.equals(workstate));
		fields.setFieldAllowBlank(PRIVILEGE_CODE, !CREATE.equals(workstate));
		fields.setFieldAllowBlank(ROLE_ID, !CREATE.equals(workstate));
 
		fields.setFieldVisible(MAX_ROW_COUNT, SEARCH.equals(workstate));
		fields.setFieldAllowBlank(MAX_ROW_COUNT, !SEARCH.equals(workstate));
		fields.setFieldValue(MAX_ROW_COUNT, 25);
	}
 
}
