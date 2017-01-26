-- script: Install/Schema/1.2.1/run.sql
-- Обновление объектов схемы до версии 1.2.1.
--
-- Основные изменения:
--  - исправлен префикс в именах индексов на таблице <mod_install_action>;
--  - из таблицы <mod_install_type> удалено поле operator_id, а также
--    удален триггер mod_install_type_bi_define;
--

@oms-run mod_install_action.sql
@oms-run mod_install_type.sql
