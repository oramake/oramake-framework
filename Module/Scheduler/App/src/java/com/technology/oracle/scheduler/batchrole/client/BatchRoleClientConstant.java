package com.technology.oracle.scheduler.batchrole.client;
 
import com.google.gwt.core.client.GWT;
import com.technology.oracle.scheduler.batchrole.shared.BatchRoleConstant;
import com.technology.oracle.scheduler.batchrole.shared.text.BatchRoleText;
 
public class BatchRoleClientConstant extends BatchRoleConstant {
 
	public static BatchRoleText batchRoleText = (BatchRoleText) GWT.create(BatchRoleText.class);
}
