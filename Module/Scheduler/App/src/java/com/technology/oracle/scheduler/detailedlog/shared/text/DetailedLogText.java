package com.technology.oracle.scheduler.detailedlog.shared.text;

/**
 * Interface to represent the constants contained in resource bundle:
 * 	'D:/svn/Oracle/Module/Scheduler/Trunk/App/src/java/com/technology/oracle/scheduler/detailedlog/shared/text/DetailedLogText.properties'.
 */
public interface DetailedLogText extends com.google.gwt.i18n.client.Constants {
  
  /**
   * Translated "Количество записей".
   * 
   * @return translated "Количество записей"
   */
  @DefaultStringValue("Количество записей")
  @Key("detailedLog.detail.row_count")
  String detailedLog_detail_row_count();

  /**
   * Translated "Дата вставки".
   * 
   * @return translated "Дата вставки"
   */
  @DefaultStringValue("Дата вставки")
  @Key("detailedLog.list.date_ins")
  String detailedLog_list_date_ins();

  /**
   * Translated "ID".
   * 
   * @return translated "ID"
   */
  @DefaultStringValue("ID")
  @Key("detailedLog.list.log_id")
  String detailedLog_list_log_id();

  /**
   * Translated "Текст сообщения".
   * 
   * @return translated "Текст сообщения"
   */
  @DefaultStringValue("Текст сообщения")
  @Key("detailedLog.list.message_text")
  String detailedLog_list_message_text();

  /**
   * Translated "Тип сообщения".
   * 
   * @return translated "Тип сообщения"
   */
  @DefaultStringValue("Тип сообщения")
  @Key("detailedLog.list.message_type_name")
  String detailedLog_list_message_type_name();

  /**
   * Translated "Значение сообщения".
   * 
   * @return translated "Значение сообщения"
   */
  @DefaultStringValue("Значение сообщения")
  @Key("detailedLog.list.message_value")
  String detailedLog_list_message_value();

  /**
   * Translated "Оператор".
   * 
   * @return translated "Оператор"
   */
  @DefaultStringValue("Оператор")
  @Key("detailedLog.list.operator_name")
  String detailedLog_list_operator_name();

  /**
   * Translated "ID корневого лога".
   * 
   * @return translated "ID корневого лога"
   */
  @DefaultStringValue("ID корневого лога")
  @Key("detailedLog.list.parent_log_id")
  String detailedLog_list_parent_log_id();

  /**
   * Translated "Детализация лога".
   * 
   * @return translated "Детализация лога"
   */
  @DefaultStringValue("Детализация лога")
  @Key("detailedLog.title")
  String detailedLog_title();
}
