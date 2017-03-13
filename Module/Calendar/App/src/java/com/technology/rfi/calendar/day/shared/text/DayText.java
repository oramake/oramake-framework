package com.technology.rfi.calendar.day.shared.text;

/**
 * Interface to represent the constants contained in resource bundle:
 * 	'D:/workspace/srvbl08.Oracle/Calendar/Trunk/App/src/java/com/technology/rfi/calendar/day/shared/text/DayText.properties'.
 */
public interface DayText extends com.google.gwt.i18n.client.Constants {
  
  /**
   * Translated "Дата с".
   * 
   * @return translated "Дата с"
   */
  @DefaultStringValue("Дата с")
  @Key("day.detail.date_begin")
  String day_detail_date_begin();

  /**
   * Translated "Дата по".
   * 
   * @return translated "Дата по"
   */
  @DefaultStringValue("Дата по")
  @Key("day.detail.date_end")
  String day_detail_date_end();

  /**
   * Translated "Дата".
   * 
   * @return translated "Дата"
   */
  @DefaultStringValue("Дата")
  @Key("day.detail.day")
  String day_detail_day();

  /**
   * Translated "Тип дня".
   * 
   * @return translated "Тип дня"
   */
  @DefaultStringValue("Тип дня")
  @Key("day.detail.day_type_id")
  String day_detail_day_type_id();

  /**
   * Translated "Количество записей".
   * 
   * @return translated "Количество записей"
   */
  @DefaultStringValue("Количество записей")
  @Key("day.detail.row_count")
  String day_detail_row_count();

  /**
   * Translated "Дата".
   * 
   * @return translated "Дата"
   */
  @DefaultStringValue("Дата")
  @Key("day.list.day")
  String day_list_day();

  /**
   * Translated "Тип дня".
   * 
   * @return translated "Тип дня"
   */
  @DefaultStringValue("Тип дня")
  @Key("day.list.day_type_name")
  String day_list_day_type_name();

  /**
   * Translated "Справочник отклонений рабочих/выходных дней".
   * 
   * @return translated "Справочник отклонений рабочих/выходных дней"
   */
  @DefaultStringValue("Справочник отклонений рабочих/выходных дней")
  @Key("day.title")
  String day_title();
}
