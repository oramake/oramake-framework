-- script: Install/Config/before-action.sql
-- ����������� �������� �������

@oms-run ./oms-deactivate-batch.sql CopyOperator,AutoBindEmployeeOperator,AutoLockEmployeeOperator,AutoUnlockOperator%,LoadLockFromSources,LoadLockUnlockToDest
