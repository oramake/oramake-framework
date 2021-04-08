-- script: Install/Schema/Last/set-log-comment.sql
-- Устанавливает комментарии к полям из таблицы lg_log.
--
-- Параметры:
-- tableName                  - Имя таблицы или представления для
--                              комментирования полей
--

define tableName = "&1"



comment on column &tableName..log_id is
  'Id записи лога'
/
comment on column &tableName..sessionid is
  'Идентификатор сессии (значение v$session.audsid)'
/
comment on column &tableName..level_code is
  'Код уровня логирования'
/
comment on column &tableName..message_value is
  'Целочисленное значение, связанное с сообщением'
/
comment on column &tableName..message_label is
  'Строковое значение, связанное с сообщением'
/
comment on column &tableName..message_text is
  'Текст сообщения (первые 4000 символов в случае длинного сообщения)'
/
comment on column &tableName..long_message_text_flag is
  'Флаг длинного (более 4000 символов) сообщения (1 да, иначе null). Для длинного сообщения в поле message_text сохраняются только первые 4000 символов текста собщения, полный текст сообщения сохраняется в поле long_message_text таблицы lg_log_data.'
/
comment on column &tableName..text_data_flag is
  'Флаг наличия текстовых данных, связанных с сообщением (1 да, иначе null). Текстовые данные сохраняются в поле text_data таблицы lg_log_data.'
/
comment on column &tableName..context_level is
  'Контекст выполнения: Уровень вложенного контекста выполнения (null при отсутствии контекста, 0 при отсутствии вложенного и наличии ассоциативного контекста)'
/
comment on column &tableName..context_type_id is
  'Контекст выполнения: Id типа открываемого/закрываемого контекста выполнения (null если контекст не менялся)'
/
comment on column &tableName..context_value_id is
  'Контекст выполнения: Идентификатор, связанный с открываемым/закрываемым контекстом выполнения (null если контекст не менялся)'
/
comment on column &tableName..open_context_log_id is
  'Контекст выполнения: Id записи лога открытия открываемого/закрываемого контекста (null если контекст не менялся, равен log_id при открытии контекста)'
/
comment on column &tableName..open_context_log_time is
  'Контекст выполнения: Время формирования записи лога открытия открываемого/закрываемого контекста (null если контекст не менялся, равен log_time при открытии контекста)'
/
comment on column &tableName..open_context_flag is
  'Контекст выполнения: Флаг открытия контекста выполнения (1 - открытие контекста, 0 - закрытие контекста, -1 - открытие и немедленное закрытие контекста, null - контекст не менялся)'
/
comment on column &tableName..context_type_level is
  'Контекст выполнения: Уровень самовложенности открываемого/закрываемого типа контекста выполнения (начиная с 1, null если контекст не менялся или не является вложенным)'
/
comment on column &tableName..module_name is
  'Имя модуля, добавившего запись'
/
comment on column &tableName..object_name is
  'Имя объекта модуля (пакета, типа, скрипта), добавившего запись'
/
comment on column &tableName..module_id is
  'Id модуля, добавившего запись (если удалось определить)'
/
comment on column &tableName..log_time is
  'Время формирования записи лога'
/
comment on column &tableName..date_ins is
  'Дата добавления записи в таблицу'
/
comment on column &tableName..operator_id is
  'Id оператора (из модуля AccessOperator)'
/
