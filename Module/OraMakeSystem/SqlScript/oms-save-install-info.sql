-- script: oms-save-install-info.sql
-- Сохраняет в БД информацию об установке модуля ( цель install).
--
-- Параметры:
-- modulePartNumberList       - список номеров частей модулей в виде строки с
--                              разделителем ":"
--
-- Замечания:
--  - скрипт используется внутри OMS;
--  - для выполнения операции используется скрипт
--    <OmsInternal/add-install-result.sql>
--

@&OMS_SCRIPT_DIR/OmsInternal/add-install-result.sql "&1" "" OBJ "" 0 "" "" ""
