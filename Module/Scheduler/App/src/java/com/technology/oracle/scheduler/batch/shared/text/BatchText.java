package com.technology.oracle.scheduler.batch.shared.text;

/**
 * Interface to represent the constants contained in resource bundle:
 * 	'D:/git/Oramake/Module/Scheduler/App/src/java/com/technology/oracle/scheduler/batch/shared/text/BatchText.properties'.
 */
public interface BatchText extends com.google.gwt.i18n.client.Constants {
  
  /**
   * Translated "Остановить батч".
   * 
   * @return translated "Остановить батч"
   */
  @DefaultStringValue("Остановить батч")
  @Key("abortBatch")
  String abortBatch();

  /**
   * Translated "Активировать батч".
   * 
   * @return translated "Активировать батч"
   */
  @DefaultStringValue("Активировать батч")
  @Key("activateBatch")
  String activateBatch();

  /**
   * Translated "ID батча".
   * 
   * @return translated "ID батча"
   */
  @DefaultStringValue("ID батча")
  @Key("batch.detail.batch_id")
  String batch_detail_batch_id();

  /**
   * Translated "Наименование".
   * 
   * @return translated "Наименование"
   */
  @DefaultStringValue("Наименование")
  @Key("batch.detail.batch_name")
  String batch_detail_batch_name();

  /**
   * Translated "Короткое наименование".
   * 
   * @return translated "Короткое наименование"
   */
  @DefaultStringValue("Короткое наименование")
  @Key("batch.detail.batch_short_name")
  String batch_detail_batch_short_name();

  /**
   * Translated "Источник данных".
   * 
   * @return translated "Источник данных"
   */
  @DefaultStringValue("Источник данных")
  @Key("batch.detail.data_source")
  String batch_detail_data_source();

  /**
   * Translated "Дата последнего запуска от".
   * 
   * @return translated "Дата последнего запуска от"
   */
  @DefaultStringValue("Дата последнего запуска от")
  @Key("batch.detail.last_date_from")
  String batch_detail_last_date_from();

  /**
   * Translated "Дата последнего запуска до".
   * 
   * @return translated "Дата последнего запуска до"
   */
  @DefaultStringValue("Дата последнего запуска до")
  @Key("batch.detail.last_date_to")
  String batch_detail_last_date_to();

  /**
   * Translated "Наименование модуля".
   * 
   * @return translated "Наименование модуля"
   */
  @DefaultStringValue("Наименование модуля")
  @Key("batch.detail.module_id")
  String batch_detail_module_id();

  /**
   * Translated "Количество попыток".
   * 
   * @return translated "Количество попыток"
   */
  @DefaultStringValue("Количество попыток")
  @Key("batch.detail.retrial_count")
  String batch_detail_retrial_count();

  /**
   * Translated "Интервал попытки".
   * 
   * @return translated "Интервал попытки"
   */
  @DefaultStringValue("Интервал попытки")
  @Key("batch.detail.retrial_timeout")
  String batch_detail_retrial_timeout();

  /**
   * Translated "Количество записей".
   * 
   * @return translated "Количество записей"
   */
  @DefaultStringValue("Количество записей")
  @Key("batch.detail.row_count")
  String batch_detail_row_count();

  /**
   * Translated "ID".
   * 
   * @return translated "ID"
   */
  @DefaultStringValue("ID")
  @Key("batch.list.batch_id")
  String batch_list_batch_id();

  /**
   * Translated "Наименование".
   * 
   * @return translated "Наименование"
   */
  @DefaultStringValue("Наименование")
  @Key("batch.list.batch_name")
  String batch_list_batch_name();

  /**
   * Translated "Короткое наименование".
   * 
   * @return translated "Короткое наименование"
   */
  @DefaultStringValue("Короткое наименование")
  @Key("batch.list.batch_short_name")
  String batch_list_batch_short_name();

  /**
   * Translated "Создан".
   * 
   * @return translated "Создан"
   */
  @DefaultStringValue("Создан")
  @Key("batch.list.date_ins")
  String batch_list_date_ins();

  /**
   * Translated "Длительность выполнения, с".
   * 
   * @return translated "Длительность выполнения, с"
   */
  @DefaultStringValue("Длительность выполнения, с")
  @Key("batch.list.duration")
  String batch_list_duration();

  /**
   * Translated "Ошибок".
   * 
   * @return translated "Ошибок"
   */
  @DefaultStringValue("Ошибок")
  @Key("batch.list.error_count")
  String batch_list_error_count();

  /**
   * Translated "Job-ов в статусе ошибки".
   * 
   * @return translated "Job-ов в статусе ошибки"
   */
  @DefaultStringValue("Job-ов в статусе ошибки")
  @Key("batch.list.error_job_count")
  String batch_list_error_job_count();

  /**
   * Translated "Число повторных попыток".
   * 
   * @return translated "Число повторных попыток"
   */
  @DefaultStringValue("Число повторных попыток")
  @Key("batch.list.failures")
  String batch_list_failures();

  /**
   * Translated "Oracle Job в статусе ошибки".
   * 
   * @return translated "Oracle Job в статусе ошибки"
   */
  @DefaultStringValue("Oracle Job в статусе ошибки")
  @Key("batch.list.is_job_broken")
  String batch_list_is_job_broken();

  /**
   * Translated "Oracle Job ID (реальный)".
   * 
   * @return translated "Oracle Job ID (реальный)"
   */
  @DefaultStringValue("Oracle Job ID (реальный)")
  @Key("batch.list.job")
  String batch_list_job();

  /**
   * Translated "Дата последнего запуска".
   * 
   * @return translated "Дата последнего запуска"
   */
  @DefaultStringValue("Дата последнего запуска")
  @Key("batch.list.last_date")
  String batch_list_last_date();

  /**
   * Translated "Последняя дата записи в лог".
   * 
   * @return translated "Последняя дата записи в лог"
   */
  @DefaultStringValue("Последняя дата записи в лог")
  @Key("batch.list.last_log_date")
  String batch_list_last_log_date();

  /**
   * Translated "Дата начала записи последнего лога".
   * 
   * @return translated "Дата начала записи последнего лога"
   */
  @DefaultStringValue("Дата начала записи последнего лога")
  @Key("batch.list.last_start_date")
  String batch_list_last_start_date();

  /**
   * Translated "Наименование модуля".
   * 
   * @return translated "Наименование модуля"
   */
  @DefaultStringValue("Наименование модуля")
  @Key("batch.list.module_name")
  String batch_list_module_name();

  /**
   * Translated "Дата следующего запуска".
   * 
   * @return translated "Дата следующего запуска"
   */
  @DefaultStringValue("Дата следующего запуска")
  @Key("batch.list.next_date")
  String batch_list_next_date();

  /**
   * Translated "Оператор".
   * 
   * @return translated "Оператор"
   */
  @DefaultStringValue("Оператор")
  @Key("batch.list.operator_name")
  String batch_list_operator_name();

  /**
   * Translated "Oracle Job ID".
   * 
   * @return translated "Oracle Job ID"
   */
  @DefaultStringValue("Oracle Job ID")
  @Key("batch.list.oracle_job_id")
  String batch_list_oracle_job_id();

  /**
   * Translated "Результат".
   * 
   * @return translated "Результат"
   */
  @DefaultStringValue("Результат")
  @Key("batch.list.result_name")
  String batch_list_result_name();

  /**
   * Translated "Количество попыток".
   * 
   * @return translated "Количество попыток"
   */
  @DefaultStringValue("Количество попыток")
  @Key("batch.list.retrial_count")
  String batch_list_retrial_count();

  /**
   * Translated "Номер текущей попытки".
   * 
   * @return translated "Номер текущей попытки"
   */
  @DefaultStringValue("Номер текущей попытки")
  @Key("batch.list.retrial_number")
  String batch_list_retrial_number();

  /**
   * Translated "Интервал попытки".
   * 
   * @return translated "Интервал попытки"
   */
  @DefaultStringValue("Интервал попытки")
  @Key("batch.list.retrial_timeout")
  String batch_list_retrial_timeout();

  /**
   * Translated "ID корневой записи в лог".
   * 
   * @return translated "ID корневой записи в лог"
   */
  @DefaultStringValue("ID корневой записи в лог")
  @Key("batch.list.root_log_id")
  String batch_list_root_log_id();

  /**
   * Translated "Номер сессии".
   * 
   * @return translated "Номер сессии"
   */
  @DefaultStringValue("Номер сессии")
  @Key("batch.list.serial")
  String batch_list_serial();

  /**
   * Translated "ID сессии".
   * 
   * @return translated "ID сессии"
   */
  @DefaultStringValue("ID сессии")
  @Key("batch.list.sid")
  String batch_list_sid();

  /**
   * Translated "Дата текущего запуска".
   * 
   * @return translated "Дата текущего запуска"
   */
  @DefaultStringValue("Дата текущего запуска")
  @Key("batch.list.this_date")
  String batch_list_this_date();

  /**
   * Translated "Общее время выполнения, с".
   * 
   * @return translated "Общее время выполнения, с"
   */
  @DefaultStringValue("Общее время выполнения, с")
  @Key("batch.list.total_time")
  String batch_list_total_time();

  /**
   * Translated "Предупреждений".
   * 
   * @return translated "Предупреждений"
   */
  @DefaultStringValue("Предупреждений")
  @Key("batch.list.warning_count")
  String batch_list_warning_count();

  /**
   * Translated "Пакетное задание".
   * 
   * @return translated "Пакетное задание"
   */
  @DefaultStringValue("Пакетное задание")
  @Key("batch.title")
  String batch_title();

  /**
   * Translated "Деактивировать батч".
   * 
   * @return translated "Деактивировать батч"
   */
  @DefaultStringValue("Деактивировать батч")
  @Key("deactivateBatch")
  String deactivateBatch();

  /**
   * Translated "Выполнить батч".
   * 
   * @return translated "Выполнить батч"
   */
  @DefaultStringValue("Выполнить батч")
  @Key("executeBatch")
  String executeBatch();
}
