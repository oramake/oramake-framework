-- script: Install/Config/before-action.sql
-- Деактивация пакетных заданий

@oms-run ./oms-deactivate-batch.sql CopyOperator,AutoBindEmployeeOperator,AutoLockEmployeeOperator,AutoUnlockOperator%,LoadLockFromSources,LoadLockUnlockToDest
