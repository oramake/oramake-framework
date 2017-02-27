package com.technology.rfi.calendar.main.shared.text;

/**
 * Interface to represent the constants contained in resource bundle:
 * 	'D:/work/workspace/Oracle/Module/Calendar/Trunk/App/src/java/com/technology/rfi/calendar/main/shared/text/CalendarText.properties'.
 */
public interface CalendarText extends com.google.gwt.i18n.client.Constants {
  
  /**
   * Translated "Calendar".
   * 
   * @return translated "Calendar"
   */
  @DefaultStringValue("Calendar")
  @Key("module.title")
  String module_title();

  /**
   * Translated "Справочник отклонений рабочих/выходных дней".
   * 
   * @return translated "Справочник отклонений рабочих/выходных дней"
   */
  @DefaultStringValue("Справочник отклонений рабочих/выходных дней")
  @Key("submodule.day.title")
  String submodule_day_title();
}
