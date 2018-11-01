-- script: Install/Schema/Last/lg_log.comment.sql
-- Устанавливает комментарии для таблицы <lg_log>.
--

comment on table lg_log is
  'Лог работы программных модулей [ SVN root: Oracle/Module/Logging]'
/
comment on column lg_log.log_id is
  'Id записи лога'
/
comment on column lg_log.sessionid is
  'Идентификатор сессии (значение v$session.audsid либо уникальное отрицательное значение если v$session.audsid равно 0)'
/
comment on column lg_log.level_code is
  'Код уровня логирования'
/
comment on column lg_log.message_value is
  'Целочисленное значение, связанное с сообщением'
/
comment on column lg_log.message_label is
  'Строковое значение, связанное с сообщением'
/
comment on column lg_log.message_text is
  'Текст сообщения'
/
comment on column lg_log.context_level is
  'Контекст выполнения: Уровень вложенного контекста выполнения (null при отсутствии контекста, 0 при отсутствии вложенного и наличии ассоциативного контекста)'
/
comment on column lg_log.context_type_id is
  'Контекст выполнения: Id типа открываемого/закрываемого контекста выполнения (null если контекст не менялся)'
/
comment on column lg_log.context_value_id is
  'Контекст выполнения: Идентификатор, связанный с открываемым/закрываемым контекстом выполнения (null если контекст не менялся)'
/
comment on column lg_log.open_context_log_id is
  'Контекст выполнения: Id записи лога открытия открываемого/закрываемого контекста (null если контекст не менялся, равен log_id при открытии контекста)'
/
comment on column lg_log.open_context_log_time is
  'Контекст выполнения: Время формирования записи лога открытия открываемого/закрываемого контекста (null если контекст не менялся, равен log_time при открытии контекста)'
/
comment on column lg_log.open_context_flag is
  'Контекст выполнения: Флаг открытия контекста выполнения (1 - открытие контекста, 0 - закрытие контекста, -1 - открытие и немедленное закрытие контекста, null - контекст не менялся)'
/
comment on column lg_log.context_type_level is
  'Контекст выполнения: Уровень самовложенности открываемого/закрываемого типа контекста выполнения (начиная с 1, null если контекст не менялся или не является вложенным)'
/
comment on column lg_log.module_name is
  'Имя модуля, добавившего запись'
/
comment on column lg_log.object_name is
  'Имя объекта модуля (пакета, типа, скрипта), добавившего запись'
/
comment on column lg_log.module_id is
  'Id модуля, добавившего запись (если удалось определить)'
/
comment on column lg_log.log_time is
  'Время формирования записи лога'
/
comment on column lg_log.date_ins is
  'Дата добавления записи в таблицу'
/
comment on column lg_log.operator_id is
  'Id оператора ( из модуля AccessOperator)'
/
comment on column lg_log.parent_log_id is
  'Устаревшее поле: Id родительской записи лога'
/
comment on column lg_log.message_type_code is
  'Устаревшее поле: Код типа сообщения'
/
