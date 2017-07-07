package com.technology.oracle.scheduler.batch.client.ui.toolbar.images;
 
import com.google.gwt.resources.client.ClientBundle.Source;
import com.google.gwt.resources.client.ImageResource;
import com.technology.jep.jepria.client.images.JepImages;
 
public interface BatchImages extends JepImages {
  
  @Source("activateBatch.png")
  ImageResource activateBatch();
 
  @Source("deactivateBatch.png")
  ImageResource deactivateBatch();
 
  @Source("executeBatch.png")
  ImageResource executeBatch();
 
  @Source("abortBatch.png")
  ImageResource abortBatch();
 
}
