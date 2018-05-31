-- script: oms-check-install-version.sql
-- Проверяет возможность установки версии модуля (цель install).
--
-- Параметры:
-- modulePartNumberList       - список номеров частей модулей в виде строки с
--                              разделителем ":"
--
-- Замечания:
--  - скрипт используется внутри OMS;
--  - для выполнения операции используется скрипт
--    <OmsInternal/install-version-operation.sql>
--

@&OMS_SCRIPT_DIR/OmsInternal/install-version-operation.sql "&1" "" OBJ "" 0 "" "" "" 1
