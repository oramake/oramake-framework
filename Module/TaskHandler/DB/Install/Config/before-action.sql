--script: Install/Config/before-action.sql
--�������� ����������� ����� ���������� ���������� ������.
--
--����������� ��������:
--  - ��������� ������� ������� ����� dbms_job � ������� ��������� ����������
--    ������� ( ������� <Install/Config/stop-batches.sql>);
--
--���������:
--  - ��� �������������� ��������� ������ ( INSTALL_VERSION=Last) ������ ��
--    �����������;
--

@@stop-batches.sql "v_th_save_job_queue"
