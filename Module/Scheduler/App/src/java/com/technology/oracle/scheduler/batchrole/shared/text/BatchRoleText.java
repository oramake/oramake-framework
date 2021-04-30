package com.technology.oracle.scheduler.batchrole.shared.text;

/**
 * Interface to represent the constants contained in resource bundle:
 * 	'C:/SVN/Module/Scheduler/Trunk/App/src/java/com/technology/oracle/scheduler/batchrole/shared/text/BatchRoleText.properties'.
 */
public interface BatchRoleText extends com.google.gwt.i18n.client.Constants {
  
  /**
   * Translated "Привилегия".
   * 
   * @return translated "Привилегия"
   */
  @DefaultStringValue("Привилегия")
  @Key("batchRole.detail.privilege_code")
  String batchRole_detail_privilege_code();

  /**
   * Translated "Роль".
   * 
   * @return translated "Роль"
   */
  @DefaultStringValue("Роль")
  @Key("batchRole.detail.role_id")
  String batchRole_detail_role_id();

  /**
   * Translated "Введите первые буквы роли...".
   * 
   * @return translated "Введите первые буквы роли..."
   */
  @DefaultStringValue("Введите первые буквы роли...")
  @Key("batchRole.detail.role_id.emptyText")
  String batchRole_detail_role_id_emptyText();

  /**
   * Translated "Количество записей".
   * 
   * @return translated "Количество записей"
   */
  @DefaultStringValue("Количество записей")
  @Key("batchRole.detail.row_count")
  String batchRole_detail_row_count();

  /**
   * Translated "ID".
   * 
   * @return translated "ID"
   */
  @DefaultStringValue("ID")
  @Key("batchRole.list.batch_role_id")
  String batchRole_list_batch_role_id();

  /**
   * Translated "Создано".
   * 
   * @return translated "Создано"
   */
  @DefaultStringValue("Создано")
  @Key("batchRole.list.date_ins")
  String batchRole_list_date_ins();

  /**
   * Translated "Оператор".
   * 
   * @return translated "Оператор"
   */
  @DefaultStringValue("Оператор")
  @Key("batchRole.list.operator_name")
  String batchRole_list_operator_name();

  /**
   * Translated "Код привилегии".
   * 
   * @return translated "Код привилегии"
   */
  @DefaultStringValue("Код привилегии")
  @Key("batchRole.list.privilege_code")
  String batchRole_list_privilege_code();

  /**
   * Translated "Привилегия".
   * 
   * @return translated "Привилегия"
   */
  @DefaultStringValue("Привилегия")
  @Key("batchRole.list.privilege_name")
  String batchRole_list_privilege_name();

  /**
   * Translated "Роль".
   * 
   * @return translated "Роль"
   */
  @DefaultStringValue("Роль")
  @Key("batchRole.list.role_name")
  String batchRole_list_role_name();

  /**
   * Translated "Краткое наименование роли".
   * 
   * @return translated "Краткое наименование роли"
   */
  @DefaultStringValue("Краткое наименование роли")
  @Key("batchRole.list.role_short_name")
  String batchRole_list_role_short_name();

  /**
   * Translated "Батч-роль".
   * 
   * @return translated "Батч-роль"
   */
  @DefaultStringValue("Батч-роль")
  @Key("batchRole.title")
  String batchRole_title();
}
