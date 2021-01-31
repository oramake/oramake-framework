-- script: Install/Schema/3.5.0/run.sql
-- Обновление объектов схемы до версии 3.5.0.
--
-- Основные изменения:
--  - увеличена максимальная длина поля option_description таблиц
--    <opt_option> и <opt_option_history>;
--  - персоздается тип <opt_option_value_t>;
--

@oms-run opt_option.sql
@oms-run opt_option_history.sql
@oms-run Install/Schema/Last/opt_option_value_t.typ
