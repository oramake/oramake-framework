-- script: oms-save-uninstall-info.sql
-- Сохраняет в БД информацию об отмене установки версии модуля ( цель
-- uninstall).
--
-- Параметры:
-- modulePartNumberList       - список номеров частей модулей в виде строки с
--                              разделителем ":"
-- uninstallResultVersion     - номер версии модуля, получаемой в БД в
--                              результате отмены установки обновления
--
-- Замечания:
--  - скрипт используется внутри OMS;
--  - для выполнения операции используется скрипт
--    <OmsInternal/add-install-result.sql>
--

@&OMS_SCRIPT_DIR/OmsInternal/add-install-result.sql "&1" "" OBJ "" 1 "&2" "" ""
