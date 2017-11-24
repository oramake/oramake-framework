-- script: oms-init-var.sql
-- Создает макро- и bind-переменные, используемые в SQL-скриптах, входящих в
-- состав OMS, со значениями по умолчанию.
--
-- Выполняется автоматически при загрузке файла через <oms-load> с помощью
-- SQL*Plus. В случае необходимости выполнения SQL-скриптов, входящих в состав
-- OMS, без использования <oms-load> ( например, в интерактивной сессии
-- SQL*Plus), предварительно должен быть выполнен данный скрипт ( один раз
-- после запуска SQL*Plus, не требует наличия соединения с БД).
--
-- Создаваемые макропеременные:
-- 1 ... 10                   - параметры вызова скриптов ( требуется для
--                              <oms-run.sql>)
-- OMS_RESUME_BATCH_SECOND    - параметр скрипта <oms-resume-batch.sql>
-- OMS_STOP_BATCH_SECOND      - параметр скрипта <oms-stop-batch.sql>
--
-- Создаваемые bind-переменные:
-- oms_*                      - различные bind-переменные OMS
--
-- Замечания:
--  - скрипт используется внутри OMS;
--  - значения большинства переменных переустанавливается в скрите <oms-load>;
--  - скрипт <oms-run.sql> при вызове в интерактивной сессии SQL*Plus может
--    работать некорректно в связи с отсутствием правильного значения у
--    bind-переменной oms_run_file_stack ( в ней должен быть путь к скрипту
--    верхнего уровня, в котором используется <oms-run.sql>); Для решения этой
--    проблемы нужно запускать скрипт верхнего уровня с помощью <oms-run.sql>
--    вместо использования стандартных команд "@" или "@@".
--  - т.к. данным скриптом не обеспечивается уникальность значения
--    OMS_TEMP_FILE_PREFIX для различных интерактивных сессиях SQL*Plus, то
--    возможны проблемы при одновременном выполнении скриптов; Для исключения
--    проблем нужно обеспечить уникальность значений ( например, с помощью
--    добавления ID процесса операционной системы и т.д.).
--  - для вызова SQL-скриптов, входящих в состав OMS, из интерактивной сессии
--    SQL*Plus без указания пути, нужно добавить путь к каталогу с
--    OMS-скриптами ( "C:\cygwin\usr\local\share\oms\SqlScript" при
--    стандартной установке Cygwin) в переменную окружения SQLPATH;
--

-- Path to OMS scripts in the case of the default installation of Cygwin and
-- OMS
define OMS_SCRIPT_DIR = "C:/cygwin/usr/local/share/oms/SqlScript"

-- /tmp from Cygwin is used as the temporary directory, but the element unique
-- for each session is not added
define OMS_TEMP_FILE_PREFIX = "C:/cygwin/tmp/oms.sqltmp"

-- Define and clear the values of arguments for starting scripts (used in
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


-- Macro variables with application script parameters
define OMS_RESUME_BATCH_SECOND = ""
define OMS_STOP_BATCH_SECOND = ""


-- Common parameters
var oms_debug_level number

-- List of values of the elements of the array fileExtensionList with a comma
-- delimiter
var oms_file_extension_list varchar2(1000)

var oms_initial_svn_path varchar2(1000)

-- Path to OMS scripts (identical to the macro variable OMS_SCRIPT_DIR)
var oms_script_dir varchar2(1000)

var oms_svn_root varchar2(1000)



-- Installation parameters
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

-- The source file for installation (path relative to the DB directory or
-- SqlScript for OMS SQL scripts)
var oms_source_file varchar2(1000)


-- oms-run.sql script variables
var oms_file_mask varchar2(4000)
var oms_run_file_stack varchar2(4000)
var oms_skip_file_mask varchar2(3999)

