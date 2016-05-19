package com.technology.oracle.scheduler.rootlog.client.ui.form.detail;
 
import static com.technology.oracle.scheduler.rootlog.shared.field.RootLogFieldNames.*;
import static com.technology.oracle.scheduler.rootlog.client.RootLogClientConstant.rootLogText;
 
import com.technology.jep.jepria.client.ui.form.detail.DetailFormViewImpl;
import com.google.gwt.dom.client.Style.Unit;
import com.google.gwt.user.client.ui.ScrollPanel;
import com.google.gwt.user.client.ui.VerticalPanel;
 
import com.technology.jep.jepria.client.widget.field.FieldManager;
 
public class RootLogDetailFormViewImpl
	extends DetailFormViewImpl 
	implements RootLogDetailFormView {	
 
	public RootLogDetailFormViewImpl() {
		super(new FieldManager());
 
		ScrollPanel scrollPanel = new ScrollPanel();
		scrollPanel.setSize("100%", "100%");
		VerticalPanel panel = new VerticalPanel();
		panel.getElement().getStyle().setMarginTop(5, Unit.PX);
		scrollPanel.add(panel);
 
		setWidget(scrollPanel);
 
	}
 
}
