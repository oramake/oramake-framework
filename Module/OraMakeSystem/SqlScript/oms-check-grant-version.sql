-- script: oms-check-grant-version.sql
-- Проверяет возможность выдачи прав согласно указанной версии модуля (цель
-- grant).
--
-- Параметры:
-- modulePartNumberList       - список номеров частей модулей в виде строки с
--                              разделителем ":"
-- installVersion             - устанавливаемая версия модуля ( по умолчанию из
--                              oms_module_install_version)
-- isFullInstall              - флаг полной установки ( 1 при полной установке,
--                              0 при установке обновления) ( по умолчанию из
--                              oms_is_full_module_install)
-- grantScript                - скрипт выдачи прав
-- toUserName                 - пользователь, которому выдаются права
--
-- Замечания:
--  - скрипт используется внутри OMS;
--  - для выполнения операции используется скрипт
--    <OmsInternal/install-version-operation.sql>
--

@&OMS_SCRIPT_DIR/OmsInternal/install-version-operation.sql "&1" "&2" PRI "&3" 0 "" "&4" "&5" 1
