package com.technology.oracle.scheduler.schedule.shared.text;

/**
 * Interface to represent the constants contained in resource bundle:
 * 	'C:/SVN/Module/Scheduler/Trunk/App/src/java/com/technology/oracle/scheduler/schedule/shared/text/ScheduleText.properties'.
 */
public interface ScheduleText extends com.google.gwt.i18n.client.Constants {
  
  /**
   * Translated "Количество записей".
   * 
   * @return translated "Количество записей"
   */
  @DefaultStringValue("Количество записей")
  @Key("schedule.detail.row_count")
  String schedule_detail_row_count();

  /**
   * Translated "ID".
   * 
   * @return translated "ID"
   */
  @DefaultStringValue("ID")
  @Key("schedule.detail.schedule_id")
  String schedule_detail_schedule_id();

  /**
   * Translated "Наименование".
   * 
   * @return translated "Наименование"
   */
  @DefaultStringValue("Наименование")
  @Key("schedule.detail.schedule_name")
  String schedule_detail_schedule_name();

  /**
   * Translated "Создано".
   * 
   * @return translated "Создано"
   */
  @DefaultStringValue("Создано")
  @Key("schedule.list.date_ins")
  String schedule_list_date_ins();

  /**
   * Translated "Оператор".
   * 
   * @return translated "Оператор"
   */
  @DefaultStringValue("Оператор")
  @Key("schedule.list.operator_name")
  String schedule_list_operator_name();

  /**
   * Translated "ID".
   * 
   * @return translated "ID"
   */
  @DefaultStringValue("ID")
  @Key("schedule.list.schedule_id")
  String schedule_list_schedule_id();

  /**
   * Translated "Наименование".
   * 
   * @return translated "Наименование"
   */
  @DefaultStringValue("Наименование")
  @Key("schedule.list.schedule_name")
  String schedule_list_schedule_name();

  /**
   * Translated "Расписание".
   * 
   * @return translated "Расписание"
   */
  @DefaultStringValue("Расписание")
  @Key("schedule.title")
  String schedule_title();
}
