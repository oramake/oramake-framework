-- script: Install/Config/after-action.sql
-- Активация пакетных заданий

@oms-run ./oms-activate-batch.sql CopyOperator,AutoBindEmployeeOperator,AutoLockEmployeeOperator,AutoUnlockOperator,LoadLockFromSources,LoadLockUnlockToDest
