package com.technology.oracle.scheduler.batch.server;
 
import com.technology.jep.jepria.server.JepRiaServerConstant;
 
public class BatchServerConstant extends JepRiaServerConstant {
 
	public static final String BEAN_JNDI_NAME = "BatchBean";
 
	public static final String RESOURCE_BUNDLE_NAME = "com.technology.oracle.scheduler.batch.shared.text.BatchText";
 
	public static final String DATA_SOURCE_JNDI_NAME = "";
	
	/**
	 * Префикс JNDI-имен источников данных модуля.	
	 */
	public static final String PREFIX_DATA_SOURCE_JNDI_NAME = "jdbc/";	
 
}
