-- script: replace-file-module
-- ������ ��������� pkg_File �� pkg_FileHandler

@Install/Config/stop-batches.sql "v_flh_save_job_queue"

prompt * creating synonym pkg_File for pkg_FileHandler 

create or replace synonym pkg_File for pkg_FileHandler
/

@Install/Config/resume-batches.sql "v_flh_save_job_queue"
