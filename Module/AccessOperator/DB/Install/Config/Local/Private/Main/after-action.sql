-- script: Install/Config/after-action.sql
-- ��������� �������� �������

@oms-run ./oms-activate-batch.sql CopyOperator,AutoBindEmployeeOperator,AutoLockEmployeeOperator,AutoUnlockOperator,LoadLockFromSources,LoadLockUnlockToDest
