package com.technology.oracle.scheduler.batch.client.ui.toolbar;
 
import static com.technology.jep.jepria.client.ui.toolbar.ToolBarConstant.ADD_BUTTON_ID;
import static com.technology.jep.jepria.client.ui.toolbar.ToolBarConstant.DELETE_BUTTON_ID;
import static com.technology.oracle.scheduler.batch.client.BatchClientConstant.batchText;

import com.google.gwt.core.client.GWT;
import com.technology.jep.jepria.client.ui.toolbar.ToolBarViewImpl;
import com.technology.oracle.scheduler.batch.client.ui.toolbar.images.BatchImages;

public class BatchToolBarViewImpl extends ToolBarViewImpl {
  
  public static final BatchImages batchImages = GWT.create(BatchImages.class);
 
  final static String ACTIVATE_BATCH = "activateBatch"; 
  final static String DEACTIVATE_BATCH = "deactivateBatch"; 
  final static String EXECUTE_BATCH = "executeBatch"; 
  final static String ABORT_BATCH = "abortBatch"; 
  final static String ACTIVATE_BATCH_SEPARATOR_ID = "activateBatchSeparatorId"; 
  final static String EXECUTE_BATCH_SEPARATOR_ID = "executeBatchSeparatorId"; 
 
  public BatchToolBarViewImpl() {
    super();

    removeItem(ADD_BUTTON_ID);
    removeItem(DELETE_BUTTON_ID);
    
    addSeparator(ACTIVATE_BATCH_SEPARATOR_ID);
    addButton(
      ACTIVATE_BATCH, 
      batchImages.activateBatch(),
      batchText.activateBatch());
    addButton(
      DEACTIVATE_BATCH, 
      batchImages.deactivateBatch(),
      batchText.deactivateBatch());
    addSeparator(EXECUTE_BATCH_SEPARATOR_ID);
    addButton(
      EXECUTE_BATCH, 
      batchImages.executeBatch(),
      batchText.executeBatch());
    addButton(
      ABORT_BATCH, 
      batchImages.abortBatch(),
      batchText.abortBatch());
  }
}
