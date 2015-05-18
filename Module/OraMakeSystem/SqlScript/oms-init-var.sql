-- script: oms-init-var.sql
-- ������� �����- � bind-����������, ������������ � SQL-��������, �������� �
-- ������ OMS, �� ���������� �� ���������.
--
-- ����������� ������������� ��� �������� ����� ����� <oms-load> � �������
-- SQL*Plus. � ������ ������������� ���������� SQL-��������, �������� � ������
-- OMS, ��� ������������� <oms-load> ( ��������, � ������������� ������
-- SQL*Plus), �������������� ������ ���� �������� ������ ������ ( ���� ���
-- ����� ������� SQL*Plus, �� ������� ������� ���������� � ��).
--
-- ����������� ���������������:
-- 1 ... 10                   - ��������� ������ �������� ( ��������� ���
--                              <oms-run.sql>)
-- OMS_RESUME_BATCH_SECOND    - �������� ������� <oms-resume-batch.sql>
-- OMS_STOP_BATCH_SECOND      - �������� ������� <oms-stop-batch.sql>
--
-- ����������� bind-����������:
-- oms_*                      - ��������� bind-���������� OMS
--
-- ���������:
--  - ������ ������������ ������ OMS;
--  - �������� ����������� ���������� ������������������� � ������ <oms-load>;
--  - ������ <oms-run.sql> ��� ������ � ������������� ������ SQL*Plus �����
--    �������� ����������� � ����� � ����������� ����������� �������� �
--    bind-���������� oms_run_file_stack ( � ��� ������ ���� ���� � �������
--    �������� ������, � ������� ������������ <oms-run.sql>); ��� ������� ����
--    �������� ����� ��������� ������ �������� ������ � ������� <oms-run.sql>
--    ������ ������������� ����������� ������ "@" ��� "@@".
--  - �.�. ������ �������� �� �������������� ������������ ��������
--    OMS_TEMP_FILE_PREFIX ��� ��������� ������������� ������� SQL*Plus, ��
--    �������� �������� ��� ������������� ���������� ��������; ��� ����������
--    ������� ����� ���������� ������������ �������� ( ��������, � �������
--    ���������� ID �������� ������������ ������� � �.�.).
--  - ��� ������ SQL-��������, �������� � ������ OMS, �� ������������� ������
--    SQL*Plus ��� �������� ����, ����� �������� ���� � �������� �
--    OMS-��������� ( "C:\cygwin\usr\local\share\oms\SqlScript" ���
--    ����������� ��������� Cygwin) � ���������� ��������� SQLPATH;
--

-- ���� � ����������� �������� � ������ ��������� ��-��������� Cygwin � OMS
define OMS_SCRIPT_DIR = "C:/cygwin/usr/local/share/oms/SqlScript"

-- � �������� ���������� �������� ������������ /tmp �� Cygwin, ������ ��
-- ����������� ���������� ��� ������ ������ �������
define OMS_TEMP_FILE_PREFIX = "C:/cygwin/tmp/oms.sqltmp"

-- ���������� � ������� �������� ���������� ������� �������� ( ������������ �
-- oms-run.sql)
define 1 = ""
define 2 = ""
define 3 = ""
define 4 = ""
define 5 = ""
define 6 = ""
define 7 = ""
define 8 = ""
define 9 = ""
define 10 = ""


-- ��������������� � ����������� ���������� ��������
define OMS_RESUME_BATCH_SECOND = ""
define OMS_STOP_BATCH_SECOND = ""


-- ����� ���������
var oms_debug_level number

-- ������ �������� ��������� ������� fileExtensionList � ������������ ���������
-- �������
var oms_file_extension_list varchar2(1000)

var oms_initial_svn_path varchar2(1000)

-- ���� � �������� � ������������ SQL-��������� OMS ( ���������
-- ��������������� OMS_SCRIPT_DIR)
var oms_script_dir varchar2(1000)

var oms_svn_root varchar2(1000)



-- ��������� ���������
var oms_action_goal_list varchar2(1000)
var oms_action_option_list varchar2(4000)
var oms_file_module_initial_svn_pa varchar2(1000)
var oms_file_module_part_number number
var oms_file_module_svn_root varchar2(1000)
var oms_file_object_name varchar2(128)
var oms_file_object_type varchar2(30)
var oms_is_full_module_install number
var oms_is_save_install_info number
var oms_module_initial_svn_path varchar2(1000)
var oms_module_install_version varchar2(50)
var oms_module_svn_root varchar2(1000)
var oms_module_version varchar2(50)
var oms_process_id number
var oms_process_start_time varchar2(50)
var oms_svn_file_path varchar2(255)
var oms_svn_version_info varchar2(50)

-- �������� ���� ��� ��������� ( ���� ������������ �������� DB ���� SqlScript
-- ��� SQL-�������� OMS)
var oms_source_file varchar2(1000)


-- ���������� ������� oms-run.sql
var oms_file_mask varchar2(4000)
var oms_run_file_stack varchar2(4000)
var oms_skip_file_mask varchar2(3999)

