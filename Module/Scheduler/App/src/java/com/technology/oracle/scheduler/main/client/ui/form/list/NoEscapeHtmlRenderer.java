package com.technology.oracle.scheduler.main.client.ui.form.list;

import com.google.gwt.safehtml.shared.SafeHtml;
import com.google.gwt.safehtml.shared.SafeHtmlBuilder;
import com.google.gwt.safehtml.shared.SafeHtmlUtils;
import com.google.gwt.text.shared.SafeHtmlRenderer;

public class NoEscapeHtmlRenderer implements SafeHtmlRenderer<String> {

	private static NoEscapeHtmlRenderer instance;

	public static NoEscapeHtmlRenderer getInstance() {
		if (instance == null) {
			instance = new NoEscapeHtmlRenderer();
		}
		return instance;
	}

	private NoEscapeHtmlRenderer() {}

	public SafeHtml render(String object) {
		return (object == null) ? SafeHtmlUtils.EMPTY_SAFE_HTML : SafeHtmlUtils.fromSafeConstant(object);
	}

	public void render(String object, SafeHtmlBuilder appendable) {
		appendable.append(SafeHtmlUtils.fromSafeConstant(object));
	}
}
