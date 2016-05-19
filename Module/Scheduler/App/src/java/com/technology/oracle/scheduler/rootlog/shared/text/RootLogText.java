package com.technology.oracle.scheduler.rootlog.shared.text;

/**
 * Interface to represent the constants contained in resource bundle:
 * 	'D:/svn/Oracle/Module/Scheduler/Branch/Scheduler/App/src/java/com/technology/oracle/scheduler/rootlog/shared/text/RootLogText.properties'.
 */
public interface RootLogText extends com.google.gwt.i18n.client.Constants {
  
  /**
   * Translated "Количество записей".
   * 
   * @return translated "Количество записей"
   */
  @DefaultStringValue("Количество записей")
  @Key("rootLog.detail.row_count")
  String rootLog_detail_row_count();

  /**
   * Translated "Создан".
   * 
   * @return translated "Создан"
   */
  @DefaultStringValue("Создан")
  @Key("rootLog.list.date_ins")
  String rootLog_list_date_ins();

  /**
   * Translated "ID".
   * 
   * @return translated "ID"
   */
  @DefaultStringValue("ID")
  @Key("rootLog.list.log_id")
  String rootLog_list_log_id();

  /**
   * Translated "Текст сообщения".
   * 
   * @return translated "Текст сообщения"
   */
  @DefaultStringValue("Текст сообщения")
  @Key("rootLog.list.message_text")
  String rootLog_list_message_text();

  /**
   * Translated "Тип сообщения".
   * 
   * @return translated "Тип сообщения"
   */
  @DefaultStringValue("Тип сообщения")
  @Key("rootLog.list.message_type_name")
  String rootLog_list_message_type_name();

  /**
   * Translated "Оператор".
   * 
   * @return translated "Оператор"
   */
  @DefaultStringValue("Оператор")
  @Key("rootLog.list.operator_name")
  String rootLog_list_operator_name();

  /**
   * Translated "Лог".
   * 
   * @return translated "Лог"
   */
  @DefaultStringValue("Лог")
  @Key("rootLog.title")
  String rootLog_title();
}
