create or replace package body pkg_SchedulerLoad is
/* package body: pkg_SchedulerLoad::body */



/* group: ��������� */


/* iconst: Blank_Characters
  ����������� �������, ���������� � ��������� �������.
*/
Blank_Characters constant varchar2(10) :=
   ' ' || chr(10) || chr(13) || chr(9)
;



/* group: �������� ���� ��������� */

/* iconst: Date_OptionType
  �������� option/@type, ��������������� ��������� ���� ����.
*/
Date_OptionType constant varchar2(30) := 'date';

/* iconst: Number_OptionType
  �������� option/@type, ��������������� ��������� ���� �����.
*/
Number_OptionType constant varchar2(30) := 'number';

/* iconst: String_OptionType
  �������� option/@type, ��������������� ��������� ���� ������.
*/
String_OptionType constant varchar2(30) := 'string';



/* group: �������� ������ ������� � ��������� */

/* iconst: Full_OptionAccessLevel
  �������� option/@access_level, ��������������� ������� �������.
*/
Full_OptionAccessLevel constant varchar2(30) := 'full';

/* iconst: Read_OptionAccessLevel
  �������� option/@access_level, ��������������� ������� ������ �� ������.
*/
Read_OptionAccessLevel constant varchar2(30) := 'read';

/* iconst: Value_OptionAccessLevel
  �������� option/@access_level, ��������������� ������� � ��������� ��������.
*/
Value_OptionAccessLevel constant varchar2(30) := 'value';



/* group: ���������� */

/* ivar: logger
  ����� ������.
*/
logger lg_logger_t := lg_logger_t.getLogger(
  moduleName    => pkg_Scheduler.Module_Name
  , objectName  => 'pkg_SchedulerLoad'
);



/* group: ������� */



/* group: ������� */

/* ifunc: getDataText
  ��������� ������ �� ������ ����� � ���� ������.

  ���������:
  fileText                    - �������� ����� �����
*/
function getDataText(
  fileText clob
)
return clob
is
-- getDataText
begin
  return
    rtrim( ltrim(
      to_char( fileText)
      , Blank_Characters
    )
      , Blank_Characters
    );
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��������� ������ �� ������ � ���� ������'
      )
    , true
  );
end getDataText;

/* iproc: getStringInternal
  ��������� ������ �� ���� xml ( ��� �������� ����� ��������� text()).

  ���������:
  xml                       - ������ xml
  xPath                     - ���� XPath � ����
  raiseExceptionFlag        - ������������ �� ����������, ���� ��� �� ������
  translateReferenceFlag    - ������������� �� ������ ( ��������, &quot;,
                              ��-��������� �������������)
*/
function getStringInternal(
  xml xmltype
  , xPath varchar2
  , raiseExceptionFlag boolean := null
  , translateReferenceFlag boolean := null
)
return varchar2
is
  -- ������ ����
  textData xmltype;

  -- �������� ������
  stringValue varchar2(32767);

begin
  if ( xml.existsNode( xPath) = 1) then
    if coalesce( translateReferenceFlag, true) = true then
      select
        extractvalue( xml, '/' || xPath)
      into
        stringValue
      from
        dual
      ;
    else
      textData := xml.extract( xPath);
      stringValue := textData.getStringVal();
    end if;
  elsif coalesce( raiseExceptionFlag, true) then
    raise_application_error(
      pkg_Error.IllegalArgument
      , '��� �� ������'
    );
  end if;
  return stringValue;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��������� ������ �� ���� xml ('
        || ' xPath="' || xPath || '"'
        || ')'
      )
    , true
  );
end getStringInternal;

/* iproc: getString
  ��������� ������ �� ���� xml.

  ���������:
  xml                       - ������ xml
  xPath                     - ���� XPath � ����
  raiseExceptionFlag        - ������������ �� ����������, ���� ��� �� ������
  translateReferenceFlag    - ������������� �� ������ ( ��������, &quot;,
                              ��-��������� �������������)
*/
function getString(
  xml xmltype
  , xPath varchar2
  , raiseExceptionFlag boolean := null
  , translateReferenceFlag boolean := null
)
return varchar2
is
begin
  return
    getStringInternal(
      xml => xml
      , xPath => xPath || '/text()'
      , raiseExceptionFlag => raiseExceptionFlag
      , translateReferenceFlag => translateReferenceFlag
    );
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��������� ������ �� ���� xml ('
        || ' xPath="' || xPath || '"'
        || ')'
      )
    , true
  );
end getString;

/* iproc: getInteger
  ������ �������� ������ ����� �� �����.

  ���������:
  xml                       - ������ xml
  xPath                     - ���� XPath � ����
  raiseExceptionFlag        - ������������ �� ����������, ���� ��� �� ������
*/
function getInteger(
  xml xmltype
  , xPath varchar2
  , raiseExceptionFlag boolean := null
)
return integer
is
begin
  return
    to_number(
      getString(
        xml => xml
        , xPath => xPath
        , translateReferenceFlag => false
        , raiseExceptionFlag => raiseExceptionFlag
      )
      ,  '99999999999999999999'
    );
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��������� ������ ����� �� ���� xml ('
        || ' xPath="' || xPath || '"'
        || ')'
      )
    , true
  );
end getInteger;

/* ifunc: getNumber
  ������ �������� ����� �� �����.

  ���������:
  xml                       - ������ xml
  xPath                     - ���� XPath � ����
  raiseExceptionFlag        - ������������ �� ����������, ���� ��� �� ������
*/
function getNumber(
  xml xmltype
  , xPath varchar2
  , raiseExceptionFlag boolean := null
)
return number
is
-- getNumber
begin
  return
    to_number(
      getString(
        xml => xml
        , xPath => xPath
        , translateReferenceFlag => false
        , raiseExceptionFlag => raiseExceptionFlag
      )
      , 'FM99999999999999999999D99999'
      , 'NLS_NUMERIC_CHARACTERS=''. '''
    );
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��������� ������ �� ������ � ���� ������ ('
        || ' xPath="' || xPath || '"'
        || ').'
      )
    , true
  );
end getNumber;

/* func: getAttributeString
  ��������� �������� �������� ������.

  ���������:
  xml                       - ������ xml
  xPath                     - ���� XPath � ����
  raiseExceptionFlag        - ������������ �� ����������, ���� ��� �� ������
*/
function getAttributeString(
  xml xmltype
  , xPath varchar2
  , attributeName varchar2
  , raiseExceptionFlag boolean := null
)
return varchar2
is
-- getAttributeString
begin
  return
    getStringInternal(
      xml => xml
      , xPath => xPath || '/@' || attributeName
      , raiseExceptionFlag => raiseExceptionFlag
      , translateReferenceFlag => true
    );
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��������� �������� ('
        || ' xPath="' || xPath || '"'
        || ', attributeName="' || attributeName || '"'
        || ').'
      )
    , true
  );
end getAttributeString;

/* func: getBatchTypeId
  ��������� id ���� �����.

  ���������:
  moduleId                    - id ������
*/
function getBatchTypeId(
  moduleId integer
)
return integer
is

  -- id ���� �����
  batchTypeId integer;
  -- ��� ������
  moduleName v_mod_module.module_name%type;

-- getBatchTypeId
begin
  select
    module_name
  into
    moduleName
  from
    v_mod_module
  where
    module_id = moduleId
  ;
  select
    max( batch_type_id)
  into
    batchTypeId
  from
    sch_batch_type
  where
    batch_type_name_eng = moduleName
  ;
  if batchTypeId is null then
    insert into sch_batch_type(
      batch_type_name_rus
      , batch_type_name_eng
    )
    values (
      moduleName
      , moduleName
    )
    returning
      batch_type_id
    into
      batchTypeId
    ;
  end if;
  return
    batchTypeId
  ;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��������� id ���� ����� ('
        || ' moduleId=' || to_char( moduleId)
        || ').'
      )
    , true
  );
end getBatchTypeId;

/* iproc: outputInfo
  ����� ��������������� ��������� ����� dbms_output.

  ���������:
  messageText                 - ����� ���������
*/
procedure outputInfo(
  messageText varchar2
)
is
begin
  if logger.isInfoEnabled() then
    pkg_Common.outputMessage( messageText);
  end if;
end outputInfo;

/* ifunc: getFilePath
  ���������� ���� � �����, �������������� �� ���� ���������� ������.

  ���������:
  parent                      - ��������� ����� ����
  child                       - �������� ����� ����
*/
function getFilePath(
  parent varchar2
  , child varchar2
)
return varchar2
is
  -- �������������� ����
  path varchar2(32767);
-- getFilePath
begin
  execute immediate
  '
  begin
    :path := pkg_File.getFilePath( :parent, :child);
  end;
  '
  using
    out path
    , in parent
    , in child
  ;
  return
    path
  ;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��������� ���� � �����'
      )
    , true
  );
end getFilePath;

/* iproc: unloadClobToFile
  �������� clob � ���� � ��������������� Unix-����� ������ � Windows-�����
  ������.

  ���������:
  fileText                    - ����� �����
  filePath                    - ���� � �����
*/
procedure unloadClobToFile(
  fileText clob
  , filePath varchar2
)
is
-- unloadClobToFile
begin
  execute immediate
  '
begin
  pkg_File.unloadClobToFile(
    fileText =>
      replace(
        -- ������ �������� � ���� Unix
        replace( :fileText, chr(13) || chr(10), chr(10))
        , chr(10), chr(13) || chr(10)
      )
    , toPath => :filePath
    , writeMode => pkg_File.Mode_Rewrite
  );
end;'
  using
    fileText
    , filePath
  ;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ �������� clob � ���� ('
        || ' filePath="' || filePath || '"'
        || ')'
      )
    , true
  );
end unloadClobToFile;

/* iproc: checkDirectory
  �������� ���������� ���� � ���.
*/
procedure checkDirectory(
  dirPath varchar2
)
is
begin
  execute immediate '
begin
  pkg_File.makeDirectory(
    dirPath => :dirPath
    , raiseExceptionFlag => false
  );
end;'
  using
    dirPath
  ;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ �������� ���������� ('
        || 'dirPath="' || dirPath || '"'
        || ')'
      )
    , true
  );
end checkDirectory;

/* func: getXmlString
  ��������� ������ ��� �������� xml.

  ���������:
  sourceString                - �������� ������
*/
function getXmlString(
  sourceString varchar2
)
return varchar2
is
-- getXmlString
begin
  return
    replace(
    replace(
    replace(
    replace(
    replace(
    replace(
      sourceString
      , '&'
      , '&amp;'
      )
      , '"'
      , '&quot;'
      )
      , ''''
      , '&apos;'
      )
      , ''''
      , '&apos;'
      )
      , '<'
      , '&lt;'
      )
      , '>'
      , '&gt;'
      )
  ;
end getXmlString;

/* proc: setLoggingLevel
  ������������� ������� ����������� ������ ( <logger>).

  ���������:
  levelCode               - ������� �����������
*/
procedure setLoggingLevel(
  levelCode varchar2
)
is
-- setLoggingLevel
begin
  logger.setLevel( levelCode);
end setLoggingLevel;

/* func: normalizeText
  ����������� �����. ������� ������������ ������� � "." � ����� � � ������
  ������. ������� ���������� ������� � ����� �����. ����������� Windows-�����
  ����� � ��� Unix.

  ���������:
  sourceText                  - �������� ����

  �������:
  - ��������������� �����;
*/
function normalizeText(
  sourceText varchar2
)
return varchar2
is
-- normalizeText
begin
  return
    regexp_replace(
      replace(
        ltrim(
          rtrim( sourceText, Blank_Characters || '.')
          , Blank_Characters
        )
        , chr(13)
        , ''
      )
      , '( |' || chr(9) || ')+' || chr(10)
      , chr(10)
    );
end normalizeText;



/* group: �������� ������ � �� */

/* proc: loadJob(moduleId)
  �������� ������� (job) � ��.

  ���������:
  moduleId                    - id ������
  jobShortName                - �������� ������������ �������
  jobName                     - ������������ ������� ( �� �������)
  description                 - �������� �������
  jobWhat                     - plsql-��� �������
  publicFlag                  - ���� ������������� ������� ( 1 - ������� �����
                                ���� ������������ � ������ �������, 0 - �������
                                ����� ���� ������������ ������ � ������ ������,
                                ��-��������� 0)
  batchShortName              - �������� ������������ ��������� ������� ( �����),
                                ���� ������� ����� ���� ������������ ������
                                � ������ �������� ������� ( �����)
  skipCheckJob                - ���� �������� �������� ������������
                                ( ����������) PL/SQL-������ ������� ( "1" ��
                                ���������, �� ��������� ���������)
*/
procedure loadJob(
  moduleId integer
  , jobShortName varchar2
  , jobName varchar2
  , description varchar2
  , jobWhat varchar2
  , publicFlag number := null
  , batchShortName varchar2 := null
  , skipCheckJob number := null
)
is

  -- Id ��������������� job
  destJobId integer;

  -- ���� ������������� ������� ( ����� ��������)
  newPublicFlag sch_job.public_flag%type;



  /*
    �������� ������������ ( ����������) PL/SQL-����� �������.
  */
  procedure checkJobWhat
  is
  begin
    execute immediate
      'declare'
      ||  ' batchShortName sch_batch.batch_short_name%type;'
      ||  ' jobResultID sch_result.result_id%type;'
      ||  ' jobResultMessage varchar2(4000);'
      ||  ' restartBatchFlag integer;'
      ||  ' retryBatchFlag integer;'
      ||' begin '
      ||  ' return; '
      ||    jobWhat
      ||' end;'
    ;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ �������� ������������ ( ����������) PL/SQL-�����'
        )
      , true
    );
  end checkJobWhat;



-- loadJob
begin
  newPublicFlag := coalesce( publicFlag, 0);
  if ( coalesce( skipCheckJob, 0) = 0) then
    checkJobWhat();
  end if;
  select
    max( j.job_id)
  into
    destJobId
  from
    sch_job j
  where
    j.job_short_name = jobShortName
    and j.module_id = moduleId
    and (
      j.batch_short_name = batchShortName
      or batchShortName is null
        and j.batch_short_name is null
    )
  ;
  if destJobId is null then
    insert into sch_job(
      job_id
      , job_short_name
      , public_flag
      , module_id
      , batch_short_name
      , job_name
      , job_what
      , description
      , operator_id
    )
    values(
      sch_job_seq.nextval
      , jobShortName
      , newPublicFlag
      , moduleId
      , batchShortName
      , jobName
      , jobWhat
      , loadJob.description
      , pkg_Operator.getCurrentUserId()
    );
    outputInfo( 'sch_job: + ' || to_char( sql%rowcount) || ' row');
  else
    update
      sch_job j
    set
      j.public_flag = newPublicFlag
      , j.job_name = jobName
      , j.job_what = jobWhat
      , j.description = loadJob.description
    where
      job_id = destJobId
      and not (
        j.public_flag = newPublicFlag
        and j.job_name = jobName
        and j.job_what = jobWhat
        and nullif( j.description, loadJob.description) is null
        and nullif( loadJob.description, j.description) is null
      )
    ;
    if sql%rowcount !=0 then
      outputInfo( 'sch_job: * ' || to_char( sql%rowcount) || ' row');
    end if;
  end if;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ �������� ������� ( job) � �� ('
        || ' moduleId=' || to_char( moduleId)
        || ', jobShortName="' || jobShortName || '"'
        || ', jobName="' || jobName || '"'
        || ', description="' || description || '"'
        || ', jobWhat="' || jobWhat || '"'
        || ', publicFlag=' || to_char( publicFlag)
        || ', batchShortName="' || batchShortName || '"'
        || ', skipCheckJob=' || to_char( skipCheckJob)
        || ').'
      )
    , true
  );
end loadJob;

/* proc: loadJob(jobName)
  �������� ������� (job) � ��.

  ���������:
  moduleName                  - �������� ������ ( �������� "ModuleInfo")
  moduleSvnRoot               - ���� � ��������� �������� ����������������
                                ������ � Subversion ( ������� � �����
                                �����������, ��������
                                "Oracle/Module/ModuleInfo")
  moduleInitialSvnPath        - �������������� ���� � ��������� ��������
                                ���������������� ������ � Subversion ( �������
                                � ����� ����������� � ������ ����� ������, �
                                ������� �� ��� ������, ��������
                                "Oracle/Module/ModuleInfo@711")
  jobShortName                - �������� ������������ �������
  jobName                     - ������������ ������� ( �� �������)
  jobWhat                     - PL/SQL-��� �������
  publicFlag                  - ���� ������������� ������� ( 1 - ������� �����
                                ���� ������������ � ������ �������, 0 - �������
                                ����� ���� ������������ ������ � ������ ������,
                                ��-��������� 0)
  batchShortName              - �������� ������������ ��������� ������� ( �����),
                                ���� ������� ����� ���� ������������ ������
                                � ������ �������� ������� ( �����)
  skipCheckJob                - ���� �������� �������� ������������
                                ( ����������) PL/SQL-������ ������� ( "1" ��
                                ���������, �� ��������� ���������)

  ����������:
  - ������ ���� ����� ���� �� ���� �� ��� ���������� moduleName,
    moduleSvnRoot, moduleInitialSvnPath;
*/
procedure loadJob(
  moduleName varchar2 := null
  , moduleSvnRoot varchar2 := null
  , moduleInitialSvnPath varchar2 := null
  , jobShortName varchar2
  , jobName varchar2
  , jobWhat varchar2
  , description varchar2
  , publicFlag number := null
  , batchShortName varchar2 := null
  , skipCheckJob number := null
)
is
  -- id ������
  moduleId integer;
-- loadJob
begin
  moduleId := pkg_ModuleInfo.getModuleId(
    moduleName => moduleName
    , svnRoot => moduleSvnRoot
    , initialSvnPath => moduleInitialSvnPath
  );
  loadJob(
    moduleId => moduleId
    , jobShortName => jobShortName
    , jobName => jobName
    , description => description
    , jobWhat => jobWhat
    , publicFlag => publicFlag
    , batchShortName => batchShortName
    , skipCheckJob => skipCheckJob
  );
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ �������� ������� (job) � �� ('
        || ' moduleName="' || moduleName || '"'
        || ', jobShortName="' || jobShortName || '"'
        || ', jobName="' || jobName || '"'
        || ', jobWhat="' || jobWhat || '"'
        || ', publicFlag=' || to_char( publicFlag)
        || ', batchShortName="' || batchShortName || '"'
        || ').'
      )
    , true
  );
end loadJob;

/* proc: loadJob(fileText)
  �������� ������� (job) � ��.

  ���������:
  moduleName                  - �������� ������ ( �������� "ModuleInfo")
  moduleSvnRoot               - ���� � ��������� �������� ����������������
                                ������ � Subversion ( ������� � �����
                                �����������, ��������
                                "Oracle/Module/ModuleInfo")
  moduleInitialSvnPath        - �������������� ���� � ��������� ��������
                                ���������������� ������ � Subversion ( �������
                                � ����� ����������� � ������ ����� ������, �
                                ������� �� ��� ������, ��������
                                "Oracle/Module/ModuleInfo@711")
  jobShortName                - �������� ������������ �������
  fileText                    - ����� ��������� ����� ��� ��������
  publicFlag                  - ���� ������������� ������� ( 1 - ������� �����
                                ���� ������������ � ������ �������, 0 - �������
                                ����� ���� ������������ ������ � ������ ������,
                                ��-��������� 0)
  batchShortName              - �������� ������������ ��������� ������� ( �����),
                                ���� ������� ����� ���� ������������ ������
                                � ������ �������� ������� ( �����)
  skipCheckJob                - ���� �������� �������� ������������
                                ( ����������) PL/SQL-������ ������� ( "1" ��
                                ���������, �� ��������� ���������)

  ����������:
  - ������ ���� ����� ���� �� ���� �� ��� ���������� moduleName,
    moduleSvnRoot, moduleInitialSvnPath;
*/
procedure loadJob(
  moduleName varchar2 := null
  , moduleSvnRoot varchar2 := null
  , moduleInitialSvnPath varchar2 := null
  , jobShortName varchar2
  , fileText clob
  , publicFlag number := null
  , batchShortName varchar2 := null
  , skipCheckJob number := null
)
is
  -- id ������
  moduleId integer;
  -- ��� �������
  jobName sch_job.job_name%type;
  -- PL/SQL-��� �������
  jobWhat varchar2(32767);
  -- �������� �������
  description sch_job.description%type;
  -- ����� ������
  lineText varchar2(32767);

  -- ������� ��������� ������
  nextLinePosition integer;

-- loadJob
begin
  moduleId := pkg_ModuleInfo.getModuleId(
    moduleName => moduleName
    , initialSvnPath => moduleInitialSvnPath
    , svnRoot => moduleSvnRoot
  );
  jobWhat := to_char( getDataText( fileText => fileText));
  if ( jobWhat not like '--%') then
    raise_application_error(
      pkg_Error.IllegalArgument
      , '���� ������ ������� ������ ���������� � ����������� ( "-- "), � ������� �'
        || '������ ������ ������� ��� �������'
    );
  end if;
  while jobWhat like '--%' loop
    nextLinePosition := instr( jobWhat, chr(10));
    if ( nextLinePosition = 0) then
      raise_application_error(
        pkg_Error.IllegalArgument
        , 'PL/SQL-��� ������� �� ������'
      );
    end if;
    nextLinePosition := nextLinePosition + 1;
    if jobName is null then
      jobName :=
        rtrim(
          ltrim(
            substr( jobWhat, 4, nextLinePosition - 4)
            , Blank_Characters
          )
          , Blank_Characters
        )
      ;
      if jobName is null then
        raise_application_error(
          pkg_Error.IllegalArgument
          , '��� ������� �����'
        );
      end if;
    else
      description :=
        description || substr( jobWhat, 4, nextLinePosition - 5) || chr(10)
      ;
      logger.trace( 'job description + "' || substr( jobWhat, 4, nextLinePosition - 5) || '"');
    end if;
    jobWhat := substr( jobWhat, nextLinePosition);
  end loop;
  loadJob(
    moduleId => moduleId
    , jobShortName => jobShortName
    , jobName => normalizeText( jobName)
    , description => normalizeText( description)
    , jobWhat => normalizeText( jobWhat)
    , publicFlag => publicFlag
    , batchShortName => batchShortName
    , skipCheckJob => skipCheckJob
  );
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ �������� ������� ( job) � �� ('
        || ' moduleSvnRoot="' || moduleSvnRoot || '"'
        || ', moduleInitialSvnPath="' || moduleInitialSvnPath || '"'
        || ', jobShortName="' || jobShortName || '"'
        || ', publicFlag=' || to_char( publicFlag)
        || ', batchShortName="' || batchShortName || '"'
        || ').'
      )
    , true
  );
end loadJob;

/* iproc: moveOption
  ��������� ������������ ��������� ��������� ������� � ������ ��������� ������
  ��� ��������� ������������ ��������� �������.
  ������� ����������� ��������� ������ ������������ ��������� �� ������
  ������ ������������� � ��������� ������������� ���������.

  ���������:
  batchShortName              - �������� ��� ��������� �������
  moduleId                    - Id ������, � �������� ��������� ������������
                                ���������
  newBatchShortName           - �������� ������������ ��������� �������, �
                                �������� ������ ���������� ���������
                                ( null ���� �� ���������� ( �� ���������))
  newModuleId                 - Id ������, � �������� ������ ����������
                                ���������
                                ( null ���� �� ���������� ( �� ���������))
*/
procedure moveOption(
  batchShortName varchar2
  , moduleId integer
  , newBatchShortName varchar2 := null
  , newModuleId integer := null
)
is

  nMove pls_integer := 0;

  -- ������ ������������ ����������
  opt sch_batch_option_t;

  -- ������ ��� ����� ����������
  opt2 sch_batch_option_t;

begin
  logger.trace( 'moveOption: ...');
  opt := sch_batch_option_t(
    batchShortName      => batchShortName
    , moduleId          => moduleId
  );
  opt2 := sch_batch_option_t(
    batchShortName      => coalesce( newBatchShortName, batchShortName)
    , moduleId          => coalesce( newModuleId, moduleId)
  );
  for opr in
        (
        select
          t.*
        from
          table(
            -- ����� ���������� ���� ��������� ��� ������������� � Oracle 10.2
            cast( opt.getOptionValue() as opt_option_value_table_t)
          ) t
        )
      loop
    opt2.createOption(
      optionShortName         => opr.option_short_name
      , valueTypeCode         => opr.value_type_code
      , optionName            => opr.option_name
      , valueListFlag         => opr.value_list_flag
      , encryptionFlag        => opr.encryption_flag
      , testProdSensitiveFlag => opr.test_prod_sensitive_flag
      , accessLevelCode       => opr.access_level_code
      , optionDescription     => opr.option_description
    );
    for vlr in
          (
          select
            t.*
          from
            table(
              -- ����� ���������� ���� ��������� ��� ������������� � Oracle 10.2
              cast( opt.getValue( opr.option_short_name) as opt_value_table_t)
            ) t
          )
        loop
      opt2.setValue(
        optionShortName       => opr.option_short_name
        , prodValueFlag       => vlr.prod_value_flag
        , instanceName        => vlr.instance_name
        , valueTypeCode       => vlr.value_type_code
        , dateValue           => vlr.date_value
        , numberValue         => vlr.number_value
        , stringValue         => vlr.string_value
        , setValueListFlag    => vlr.value_list_flag
        , listSeparator       => vlr.list_separator
      );
    end loop;
    opt.deleteOption(
      optionShortName => opr.option_short_name
    );
    nMove := nMove + 1;
  end loop;
  if nMove > 0 then
    outputInfo(
      'option moved ('
      || ltrim(
          case when newBatchShortName != batchShortName then
              ', batch_short_name'
            end
          || case when newModuleId != moduleId then
              ', module_id'
            end
          , ','
        )
      || '): ' || nMove || ' row'
    );
  end if;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� ��������� ������ ��� ���������� ��������� ������� ('
        || ' batchShortName="' || batchShortName || '"'
        || ', moduleId=' || moduleId
        || ', newBatchShortName="' || newBatchShortName || '"'
        || ', newModuleId=' || newModuleId
        || ').'
      )
    , true
  );
end moveOption;

/* iproc: updateBatch
  ���������� ������ �����.

  ���������:
  newBatchRecord              - ������ ����� � ������ �����������
  dbBatchRecord               - ������ �����, ��������� �� ��
  updateMainAttributeFlag     - ��������� �� �������� ��������
  updateConfigFlag            - ��������� �� �������� ������������
  updateScheduleFlag          - ��������� �� ����������
*/
procedure updateBatch(
  newBatchRecord sch_batch%rowtype
  , dbBatchRecord in out nocopy sch_batch%rowtype
  , updateMainAttributeFlag integer
  , updateConfigFlag integer
  , updateScheduleFlag number
)
is

  -- ����� �� �������������� ������
  modifyRowFlag boolean := false;

begin
  logger.trace( 'updateBatch: updateMainAttributeFlag=' || to_char( updateMainAttributeFlag));
  if updateMainAttributeFlag = 1 then
    if not (
      dbBatchRecord.batch_name_rus = newBatchRecord.batch_name_rus
      and dbBatchRecord.batch_name_eng = newBatchRecord.batch_name_eng
      and dbBatchRecord.batch_type_id = newBatchRecord.batch_type_id
      and dbBatchRecord.module_id = newBatchRecord.module_id
    )
    then
      if dbBatchRecord.module_id != newBatchRecord.module_id then
        moveOption(
          batchShortName  => newBatchRecord.batch_short_name
          , moduleId      => dbBatchRecord.module_id
          , newModuleId   => newBatchRecord.module_id
        );
      end if;
      logger.trace( 'updateBatch: main field change');
      dbBatchRecord.batch_name_rus := newBatchRecord.batch_name_rus;
      dbBatchRecord.batch_name_eng := newBatchRecord.batch_name_eng;
      dbBatchRecord.batch_type_id := newBatchRecord.batch_type_id;
      dbBatchRecord.module_id := newBatchRecord.module_id;
      modifyRowFlag := true;
    end if;
  end if;
  if updateConfigFlag = 1 then
    if updateScheduleFlag = 1 and not (
      nullif( dbBatchRecord.retrial_timeout, newBatchRecord.retrial_timeout) is null
      and nullif( newBatchRecord.retrial_timeout, dbBatchRecord.retrial_timeout) is null
      and nullif( dbBatchRecord.retrial_count, newBatchRecord.retrial_count) is null
      and nullif( newBatchRecord.retrial_count, dbBatchRecord.retrial_count ) is null
    )
    then
      logger.trace( 'updateBatch: retrial change');
      dbBatchRecord.retrial_timeout := newBatchRecord.retrial_timeout;
      dbBatchRecord.retrial_count := newBatchRecord.retrial_count;
      modifyRowFlag := true;
    end if;
    if not (
      nullif( dbBatchRecord.nls_language, newBatchRecord.nls_language) is null
      and nullif( newBatchRecord.nls_language, dbBatchRecord.nls_language ) is null
      and nullif( dbBatchRecord.nls_territory, newBatchRecord.nls_territory) is null
      and nullif( newBatchRecord.nls_territory, dbBatchRecord.nls_territory) is null
      )
    then
      logger.trace( 'updateBatch: nls');
      dbBatchRecord.nls_language := newBatchRecord.nls_language;
      dbBatchRecord.nls_territory := newBatchRecord.nls_territory;
      modifyRowFlag := true;
    end if;
  end if;
  if modifyRowFlag then
    update
      sch_batch
    set
      batch_name_eng          = dbBatchRecord.batch_name_eng
      , batch_name_rus        = dbBatchRecord.batch_name_rus
      , batch_type_id         = dbBatchRecord.batch_type_id
      , module_id             = dbBatchRecord.module_id
      , retrial_count         = dbBatchRecord.retrial_count
      , retrial_timeout       = dbBatchRecord.retrial_timeout
      , nls_language          = dbBatchRecord.nls_language
      , nls_territory         = dbBatchRecord.nls_territory
    where
      batch_id = dbBatchRecord.batch_id
    ;
    outputInfo( 'sch_batch: * ' || to_char( sql%rowcount) || ' row');
  end if;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ '
      )
    , true
  );
end updateBatch;

/* proc: loadBatchConfig(batchShortName)
  �������� �������� ��������� ������� ( ������) � �� �� XML.

  ���������:
  moduleId                    - id ������
  batchConfigXml              - xml � ������� ��������
  batchShortName              - �������� ������������ �����
                                ���� ������, �� �������������� �������� ������������
                                � ��������� short_name. ���� �� �����, ��
                                ����������� ������� ������� ������������ ����� ��
                                �������� short_name;
  batchNewFlag                - ��������� �� ���� ����� ( ��� �����������
                                ������������� �������� ����������)
  updateScheduleFlag          - ��������� �� ���������� ������������� �����
                                ( ��-��������� ����������� ���������� ������
                                  ������ �����)
  skipLoadOption              - ���� ���������� �������� ���������� ��������
                                ������� ( "1" �� ���������, �� ���������
                                ��������� ��������� �������������� ��������
                                �������)
  updateOptionValue           - ��������� �� �������� ������������ ����������
*/
procedure loadBatchConfig(
  moduleId integer
  , batchConfigXml xmltype
  , batchShortName varchar2
  , batchNewFlag number
  , updateScheduleFlag number
  , skipLoadOption number
  , updateOptionValue number
)
is

  -- ������ �����
  batch sch_batch%rowtype;

  -- ������� "����� �� ����"
  usedBatchNewFlag boolean;

  /*
    ��������� ������ �����.
  */
  procedure getBatch
  is
    -- ������������ �������� ������������ �����
    usedBatchShortName sch_batch.batch_short_name%type;
  begin
    usedBatchShortName :=
      getAttributeString( batchConfigXml, 'batch_config', 'short_name', raiseExceptionFlag => false);
    if batchShortName is not null then
      if usedBatchShortName is null then
        usedBatchShortName := batchShortName;
      elsif ( usedBatchShortName <> batchShortName) then
        raise_application_error(
          pkg_Error.IllegalArgument
          , '�������������� ��������� ������������ ����� ( '
            || 'usedBatchShortName="' || usedBatchShortName || '"'
            || ', batchShortName="' || batchShortName || '"'
            || ')'
        );
      end if;
    end if;
    if usedBatchShortName is null then
      raise_application_error(
        pkg_Error.IllegalArgument
        , '�� ������ �������� ������������ �����'
      );
    else
      logger.trace( 'loadBatchConfig: usedBatchShortName="' || usedBatchShortName || '"');
    end if;
    select
      *
    into
      batch
    from
      sch_batch
    where
      batch_short_name = usedBatchShortName
    ;
    logger.trace( 'batch.retrial_count=' || to_char( batch.retrial_count));
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ ��������� id �����'
        )
      , true
    );
  end getBatch;

  /*
    �������� ��������� �����, ����������� � ����������.
  */
  procedure loadBatchAttribute
  is
    -- �������� �����
    newBatchRecord sch_batch%rowtype;
  begin
    newBatchRecord.retrial_count :=
      getInteger( batchConfigXml, 'batch_config/retry_count', raiseExceptionFlag => false);
    logger.trace( 'newBatchRecord.retrial_count=' || to_char( newBatchRecord.retrial_count));
    newBatchRecord.retrial_timeout :=
      numToDsInterval(
        getNumber( batchConfigXml, 'batch_config/retry_interval', raiseExceptionFlag => false)
        , 'MINUTE'
      );
    newBatchRecord.nls_territory :=
      getString( batchConfigXml, 'batch_config/nls_territory', raiseExceptionFlag => false);
    newBatchRecord.nls_language :=
      getString( batchConfigXml, 'batch_config/nls_language', raiseExceptionFlag => false);
    logger.trace( 'batch.retrial_count=' || to_char( batch.retrial_count));
    updateBatch(
      newBatchRecord => newBatchRecord
      , dbBatchRecord => batch
      , updateMainAttributeFlag => 0
      , updateConfigFlag => 1
      , updateScheduleFlag => updateScheduleFlag
    );
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ �������� ��������� �����'
        )
      , true
    );
  end loadBatchAttribute;

  /*
    ���������� ���������� �� �����.
  */
  procedure readSchedule
  is
    -- ����� ����������
    loadScheduleNumber integer := 1;

    -- ������ �������� ����������
    loadSchedule sch_load_schedule_tmp%rowtype;

    -- ������ �������� ���������
    loadInterval sch_load_interval_tmp%rowtype;

    -- ��������, ��������� ��� ���������
    intervalValue integer;

    -- XML ����������
    scheduleXml xmltype;

    -- XML ���������
    intervalXml xmltype;

    -- ������ ���������
    intervalIndex integer;

    /*
      ��������� ���� ���������.
    */
    function getIntervalCode( sourceCode varchar2)
    return varchar2
    is
    begin
      return
        case
          lower( sourceCode)
        when
          'mi'
        then
          'MI'
        when
          'hh24'
        then
          'HH'
        when
          'd'
        then
          'DW'
        else
          upper( sourceCode)
        end
      ;
    exception when others then
      raise_application_error(
        pkg_Error.ErrorStackInfo
        , logger.errorStack(
            '������ ��������� ���� ��������� ('
            || ' sourceCode="' || sourceCode || '"'
            || ').'
          )
        , true
      );
    end getIntervalCode;

  begin
    delete from
      sch_load_schedule_tmp
    ;
    delete from
      sch_load_interval_tmp
    ;
    while (
      batchConfigXml.existsNode( 'batch_config/schedule[' || to_char( loadScheduleNumber) || ']') = 1
    ) loop
      scheduleXml := batchConfigXml.extract( 'batch_config/schedule[' || to_char( loadScheduleNumber) || ']');
      loadSchedule.load_schedule_number := loadScheduleNumber;
      loadSchedule.schedule_name_rus := getString( scheduleXml, 'schedule/name', raiseExceptionFlag => true);
      loadSchedule.schedule_name_eng :=
        coalesce( getString( scheduleXml, 'schedule/name_eng', raiseExceptionFlag => false), 'NA');
      insert into
        sch_load_schedule_tmp
      values
        loadSchedule
      ;
      intervalIndex := 1;
      while
        ( scheduleXml.existsNode( 'schedule/interval[' || to_char( intervalIndex) || ']') = 1)
      loop
        intervalXml := scheduleXml.extract( 'schedule/interval[' || to_char( intervalIndex) || ']');
        loadInterval.load_schedule_number := loadScheduleNumber;
        loadInterval.interval_type_code :=
          getIntervalCode(
            getAttributeString( intervalXml, 'interval', 'type', raiseExceptionFlag => true)
          );
        loadInterval.min_value :=
          getInteger( intervalXml, 'interval/min_value', raiseExceptionFlag => false);
        loadInterval.max_value :=
          getInteger( intervalXml, 'interval/max_value', raiseExceptionFlag => false);
        loadInterval.step :=
          getInteger( intervalXml, 'interval/step', raiseExceptionFlag => false);
        intervalValue := getInteger( intervalXml, 'interval/value', raiseExceptionFlag => false);
        if ( intervalValue is not null ) then
          if loadInterval.min_value is not null or loadInterval.max_value is not null then
            raise_application_error(
              pkg_Error.IllegalArgument
              , '��� ��������� ������ ���� ����� ���� ��� value ���� min_value � max_value'
            );
          end if;
          if loadInterval.step is not null then
            raise_application_error(
              pkg_Error.IllegalArgument
              , '��� ��������� ��� ������� value �� ����� ���� ����� step'
            );
          end if;
          loadInterval.min_value := intervalValue;
          loadInterval.max_value := intervalValue;
          loadInterval.step := 1;
        else
          loadInterval.step := coalesce( loadInterval.step, 1);
        end if;
        insert into
          sch_load_interval_tmp
        values
          loadInterval
        ;
        intervalIndex := intervalIndex + 1;
      end loop;
      loadScheduleNumber := loadScheduleNumber + 1;
    end loop;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ ���������� ������ ����������'
        )
      , true
    );
  end readSchedule;

    /*
    ���������� ���������� � ��.
  */
  procedure saveInterval(
    scheduleId integer
    , loadScheduleNumber integer
  )
  is

    -- ������ ��� �������� ������ ����������
    cursor srcIntervalCur is
      select
        interval_type_code
        , min_value
        , max_value
        , step
      from
        sch_load_interval_tmp
      where
        load_schedule_number = loadScheduleNumber
      order by
        interval_type_code
        , min_value
        , step
    ;

    -- ������ ��� ������������ ������ ����������
    cursor destIntervalCur is
      select
        interval_type_code
        , min_value
        , max_value
        , step
      from
        sch_interval
      where
        schedule_id = scheduleId
      order by
        interval_type_code
        , min_value
        , step
      for update
    ;

    -- ������ ������������� ���������
    destInterval destIntervalCur%rowtype;

    -- �������� ���������� �������
    nInsert pls_integer := 0;
    nUpdate pls_integer := 0;
    nDel    pls_integer := 0;

    /*
      �������� ������ ���������.
    */
    procedure deleteRow
    is
    begin
      delete from
        sch_interval
      where current of destIntervalCur
      ;
      nDel := nDel + 1;
      fetch destIntervalCur into destInterval;
    end deleteRow;

  begin
    open destIntervalCur;
    fetch destIntervalCur into destInterval;
    for srcInterval in srcIntervalCur loop
      while destIntervalCur%found and
        (
          destInterval.interval_type_code < srcInterval.interval_type_code
          or (
            destInterval.interval_type_code = srcInterval.interval_type_code
            and destInterval.min_value < srcInterval.min_value
          )
          or (
            destInterval.interval_type_code = srcInterval.interval_type_code
            and destInterval.min_value = srcInterval.min_value
            and destInterval.step < srcInterval.step
          )
        )
      loop
        logger.trace( 'saveInterval: deleteRow');
        deleteRow();
      end loop;
      if destIntervalCur%found and
        destInterval.interval_type_code = srcInterval.interval_type_code
        and destInterval.min_value = srcInterval.min_value
        and destInterval.step = srcInterval.step
      then
        if not (
          -- ��� ���� ���������
          nullif( destInterval.max_value, srcInterval.max_value) is null
          and nullif( srcInterval.max_value, destInterval.max_value) is null
        )
        then
          logger.trace( 'saveInterval: updateRow');
          update
            sch_interval
          set
            max_value = srcInterval.max_value
          where current of destIntervalCur;
          nUpdate := nUpdate + 1;
        end if;
        fetch destIntervalCur into destInterval;
      else
        logger.trace( 'saveInterval: insertRow');
        insert into sch_interval
        (
          schedule_id
          , interval_type_code
          , min_value
          , max_value
          , step
        )
        values
        (
          scheduleId
          , srcInterval.interval_type_code
          , srcInterval.min_value
          , srcInterval.max_value
          , srcInterval.step
        )
        ;
        nInsert := nInsert + 1;
      end if;
    end loop;
    while destIntervalCur%found loop
      deleteRow();
    end loop;
    close destIntervalCur;
    if nInsert > 0 then
      outputInfo( 'sch_interval: + ' || nInsert || ' row');
    end if;
    if nUpdate > 0 then
      outputInfo( 'sch_interval: * ' || nUpdate || ' row');
    end if;
    if nDel > 0 then
      outputInfo( 'sch_interval: - ' || nDel || ' row');
    end if;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ ���������� ���������� � �� ('
          || ' scheduleId=' || to_char( scheduleId)
          || ', loadScheduleNumber=' || to_char( loadScheduleNumber)
          || ').'
        )
      , true
    );
  end saveInterval;

  /*
    ���������� ���������� � ��.
  */
  procedure saveSchedule
  is


    -- ������ ��� ��������� ���������� �� ��������� ������
    cursor srcScheduleCur is
      select
        load_schedule_number
        , schedule_name_rus
        , schedule_name_eng
      from
        sch_load_schedule_tmp
      order by
        schedule_name_rus
    ;

    -- ������ ��� ��������� ������������� ����������
    cursor destScheduleCur is
      select
        schedule_id
        , schedule_name_rus
        , schedule_name_eng
      from
        sch_schedule
      where
        batch_id = batch.batch_id
      order by
        schedule_name_rus
      for update
    ;
    -- ������ ��������������� ����������
    destSchedule destScheduleCur%rowtype;

    nDel pls_integer    := 0;
    nInsert pls_integer := 0;
    nUpdate pls_integer := 0;

    -- id ������ ������������ ��� ������������ ����������
    scheduleId integer;

    /*
      �������� ������ ����������.
    */
    procedure deleteRow
    is
    begin
      delete from
        sch_interval
      where
        schedule_id = destSchedule.schedule_id
      ;
      delete from
        sch_schedule
      where current of destScheduleCur;
      nDel := nDel + 1;
      fetch destScheduleCur into destSchedule;
    end deleteRow;

  begin
    open destScheduleCur;
    fetch destScheduleCur into destSchedule;
    for srcSchedule in srcScheduleCur loop
      while destScheduleCur%found
        and destSchedule.schedule_name_rus < srcSchedule.schedule_name_rus
      loop
        deleteRow();
      end loop;
    if destScheduleCur%notfound
      or destSchedule.schedule_name_rus != srcSchedule.schedule_name_rus
    then
      insert into sch_schedule(
        batch_id
        , schedule_name_rus
        , schedule_name_eng
      )
      values
      (
        batch.batch_id
        , srcSchedule.schedule_name_rus
        , srcSchedule.schedule_name_eng
      )
      returning schedule_id into scheduleId;
      nInsert := nInsert + 1;
    else
      if destSchedule.schedule_name_eng <> srcSchedule.schedule_name_eng then
        update
          sch_schedule t
        set
          t.schedule_name_eng = srcSchedule.schedule_name_eng
        where
          t.schedule_id = destSchedule.schedule_id
        ;
      end if;
      scheduleId := destSchedule.schedule_id;
      fetch destScheduleCur into destSchedule;
    end if;
    saveInterval(
      scheduleId => scheduleId
      , loadScheduleNumber => srcSchedule.load_schedule_number
    );
    end loop;
    while destScheduleCur%found loop
      deleteRow();
    end loop;
    if nInsert > 0 then
      outputInfo( 'sch_schedule: + ' || to_char( nInsert) || ' row');
    end if;
    if nDel > 0 then
      outputInfo( 'sch_schedule: - ' || to_char( nDel) || ' row');
    end if;
    if nUpdate > 0 then
      outputInfo( 'sch_schedule: * ' || to_char( nUpdate) || ' row');
    end if;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ �������� ����������'
        )
      , true
    );
  end saveSchedule;

  /*
    �������� ���������� �����.
  */
  procedure loadOption
  is

    -- �������� �������
    nLoadOption pls_integer := 0;
    nInsert pls_integer := 0;
    nUpdate pls_integer := 0;
    nDelete pls_integer := 0;
    nValueChange pls_integer := 0;

    -- ��������� ��������� �������
    opt sch_batch_option_t;



    /*
      ������������ �������� ���������.
    */
    procedure processValue(
      optionShortName varchar2
      , optionXml xmltype
      , valueTypeCode varchar2
      , testProdSensitiveFlag integer
      , valueListFlag integer
      , firstValueElementName varchar2
      , newOptionFlag pls_integer
    )
    is

      cursor valueCur is
        select
          d.*
          , coalesce(
              d.separator
              , case when d.value_list_flag = 1 then ';' end
            )
            as list_separator
        from
          (
          select
            a.*
            , case
                when a.value_element_name in (
                      'prod_value'
                      , 'production_value'
                      , 'prod_value_list'
                      , 'production_value_list'
                    )
                  then 1
                when a.value_element_name in (
                      'test_value'
                      , 'test_value_list'
                    )
                  then 0
                when a.value_element_name in (
                      'value'
                      , 'value_list'
                    )
                  then null
                -- ����������� �������
                else -1
              end
              as prod_value_flag
            , case when
                  a.value_element_name like '%value\_list' escape '\'
                then 1
                else 0
              end
              as value_list_flag
            , lag( a.value_order_number, 1)
              over(
                partition by a.value_element_name, upper( a.instance_name)
                order by a.value_order_number
              )
              as prev_value_order_number
          from
            (
            select
              b.*
              , b.value_xml.getRootElement() as value_element_name
            from
              xmltable(
                '/option/*'
                passing optionXml
                columns
                  value_order_number for ordinality
                  , instance_name varchar2(100) path '@instance'
                  , separator varchar2(100) path '@separator'
                  , value_text varchar2(4000) path 'text()'
                  , value_xml xmltype path 'self::node()'
              ) b
            ) a
          ) d
        order by
          d.value_order_number
      ;

      -- ���� ��������� ��������
      valueChangeFlag integer;

      -- ������ Id ������������ ��������
      type IdListT is table of boolean index by varchar2(50);
      usedValueIdList IdListT;



      /*
        ��������� ������������ ������ ���������.
      */
      procedure checkValue(
        rec valueCur%rowtype
      )
      is
      begin

        -- �������� ������������ ��������� XML
        if rec.prod_value_flag = -1 then
          raise_application_error(
            pkg_Error.IllegalArgument
            , '����������� ����������� ������� "'
              || rec.value_element_name || '"'
              || ' ��� ������� �������� ���������.'
          );
        elsif rec.value_list_flag != valueListFlag
              or testProdSensitiveFlag = 0
                and rec.prod_value_flag is not null
              or testProdSensitiveFlag = 1
                and rec.prod_value_flag is null
            then
          raise_application_error(
            pkg_Error.IllegalArgument
            , '��� ������� �������� ��������� ����������� ������������'
              || ' ������������ �������� "' || firstValueElementName
              || '" � "' || rec.value_element_name || '".'
          );
        end if;

        -- �������� ������������ �������� ���������
        if rec.value_list_flag = 0 and rec.separator is not null then
          raise_application_error(
            pkg_Error.IllegalArgument
            , '������������ ������������� �������� "separator" ��� ��������'
              || ' "' || rec.value_element_name || '".'
          );
        elsif length( rec.separator) > 1 then
          raise_application_error(
            pkg_Error.IllegalArgument
            , '�������� �������� "separator" ������ ���� �������������� ('
              || ' separator="' || rec.separator || '"'
              || ').'
          );
        end if;

        -- ������������ ��������
        if rec.prev_value_order_number is not null then
          raise_application_error(
            pkg_Error.IllegalArgument
            , '��������� ������� �������� ('
              || ' element_name="' || rec.value_element_name || '"'
              || ' instance="' || rec.instance_name || '"'
              || ', ����� ������ � �������� #' || rec.prev_value_order_number
              || ').'
          );
        end if;
      end checkValue;



      /*
        ���������� ������ � ���������� ������ ��������.
      */
      function getValueList(
        valueXml xmltype
        , listSeparator varchar2
      )
      return varchar2
      is

        cursor itemCur is
          select
            b.*
            , b.item_xml.getRootElement() as item_element_name
          from
            xmltable(
              '/*/*'
              passing valueXml
              columns
                item_order_number for ordinality
                , item_text varchar2(4000) path 'text()'
                , item_xml xmltype path 'self::node()'
            ) b
        ;

        stringValue varchar2(4000);

      begin
        for rec in itemCur loop
          begin
            if rec.item_element_name != 'item' then
              raise_application_error(
                pkg_Error.IllegalArgument
                , '����������� ����������� ������� "'
                  || rec.item_element_name || '"'
                  || ' ��� ������� �������� �� ������ ��������.'
              );
            elsif instr( rec.item_text, listSeparator) > 0 then
              raise_application_error(
                pkg_Error.IllegalArgument
                , '������-����������� ����������� � �������� ��������'
                  || ' ������ ('
                  || ' listSeparator="' || listSeparator || '"'
                  || ', item_text="' || rec.item_text || '"'
                  || ').'
              );
            end if;
            stringValue :=
              stringValue
              || case when rec.item_order_number > 1 then listSeparator end
              || rec.item_text
            ;
          exception when others then
            raise_application_error(
              pkg_Error.ErrorStackInfo
              , logger.errorStack(
                  '������ ��� ��������� �������� �� ������ ('
                  || ' item_order_number=' || rec.item_order_number
                  || ').'
                )
              , true
            );
          end;
        end loop;
        return stringValue;
      exception when others then
        raise_application_error(
          pkg_Error.ErrorStackInfo
          , logger.errorStack(
              '������ ��� ������������ ������ �� ������� ��������.'
            )
          , true
        );
      end getValueList;



      /*
        ������� ������ ��������.
      */
      procedure deleteExcessValue
      is

        cursor dataCur is
          select
            t.value_id
          from
            table(
              -- ����� ���������� ���� ��������� ��� ������������� � Oracle 10.2
              cast( opt.getValue( optionShortName) as opt_value_table_t)
            ) t
          order by
            1
        ;

      begin
        for rec in dataCur loop
          if not usedValueIdList.exists( to_char( rec.value_id)) then
            sch_batch_option_t.deleteValue(
              valueId => rec.value_id
            );
            nValueChange := nValueChange + 1;
            outputInfo(
              'option value delete: ' || optionShortName
              || ', value_id=' || rec.value_id
            );
          end if;
        end loop;
      exception when others then
        raise_application_error(
          pkg_Error.ErrorStackInfo
          , logger.errorStack(
              '������ ��� �������� ������ ��������.'
            )
          , true
        );
      end deleteExcessValue;



      /*
        ����������� ������ � ����.
      */
      function toDate(
        valueString varchar2
        , formatString varchar2
      )
      return date
      is
      begin
        return
          to_date( valueString, formatString)
        ;
      exception when others then
        raise_application_error(
          pkg_Error.ErrorStackInfo
          , logger.errorStack(
              '������ ��� �������������� ������ � ���� ('
              || ' valueString="' || valueString || '"'
              || ', formatString="' || formatString || '"'
              || ').'
            )
          , true
        );

      end toDate;



      /*
        ������������ ������ � ������ � �����.

        ���������:
        valueString                 - ������ � ������
        decimalChar                 - ���������� �����������, ������������ �
                                      ������ ( �� ��������� ".")

        ���������:
        - ������������ to_number � ��������� ����������� ����������� � �������
          NLS_NUMERIC_CHARACTERS �� ����������, �.�. ���������, ����� ������
          ��������� �� 2-� ���������, ����� �������������� �������� �����������
          ������������;
      */
      function toNumber(
        valueString varchar2
        , decimalChar varchar2 := null
      )
      return number
      is

        -- ������������ � ������ ���������� �����������
        oldDecimalChar varchar2(1);

        -- ���������� ����������� ��� to_number ( null ���� ��������� �
        -- ������������)
        newDecimalChar varchar2(1);

      -- toNumber
      begin

        -- ���������� ������������� ��������� �����������
        oldDecimalChar := coalesce( decimalChar, '.');
        newDecimalChar := nullif(
          substr( to_char( 0.1, 'tm9'), 1, 1)
          , oldDecimalChar
        );

        if newDecimalChar is not null
            and instr( valueString, newDecimalChar) > 0
            then
          raise_application_error(
            pkg_Error.IllegalArgument
            , '� ������ �� �� ���������� ������������ ������, ����������'
              || ' ���������� ������������ � ������ ('
              || ' session decimal char="' || newDecimalChar || '"'
              || ' string decimal char="' || oldDecimalChar || '"'
              || ').'
          );
        end if;

        return
          to_number(
            case when newDecimalChar is null then
              valueString
            else
              replace( valueString, oldDecimalChar, newDecimalChar)
            end
          )
        ;
      exception when others then
        raise_application_error(
          pkg_Error.ErrorStackInfo
          , logger.errorStack(
              '������ ��� �������������� ������ � ����� ('
              || ' valueString="' || valueString || '"'
              || ', decimalChar="' || decimalChar || '"'
              || ').'
            )
          , true
        );
      end toNumber;



    -- processValue
    begin
      for rec in valueCur loop
        begin
          checkValue( rec);
          valueChangeFlag := opt.setValue(
            optionShortName       => optionShortName
            , prodValueFlag       => rec.prod_value_flag
            , instanceName        => rec.instance_name
            , dateValue           =>
                case when
                  rec.value_text is not null
                  and valueTypeCode
                    = sch_batch_option_t.getDateValueTypeCode()
                then
                  toDate( rec.value_text, 'dd.mm.yyyy hh24:mi:ss')
                end
            , numberValue         =>
                case when
                  rec.value_text is not null
                  and valueTypeCode
                    = sch_batch_option_t.getNumberValueTypeCode()
                then
                  toNumber( rec.value_text, '.')
                end
            , stringValue         =>
                case
                  when rec.value_list_flag = 1 then
                    getValueList( rec.value_xml, rec.list_separator)
                  when valueTypeCode
                        = sch_batch_option_t.getStringValueTypeCode()
                      then
                    rec.value_text
                end
            , setValueListFlag    => rec.value_list_flag
            , listSeparator       => rec.list_separator
            , valueFormat         =>
                case when
                  rec.value_list_flag = 1
                  and valueTypeCode
                    = sch_batch_option_t.getDateValueTypeCode()
                then
                  'dd.mm.yyyy hh24:mi:ss'
                end
            , decimalChar         =>
                case when
                  rec.value_list_flag = 1
                  and valueTypeCode
                    = sch_batch_option_t.getNumberValueTypeCode()
                then
                  '.'
                end
            , skipIfNoChangeFlag  => 1
          );
          if newOptionFlag = 0 then
            if valueChangeFlag = 1 then
              nValueChange := nValueChange + 1;
            end if;
            usedValueIdList(
              to_char(
                opt.getValueId(
                  optionShortName => optionShortName
                  , prodValueFlag => rec.prod_value_flag
                  , instanceName  => rec.instance_name
                )
              )
            ) := true;
          end if;
        exception when others then
          raise_application_error(
            pkg_Error.ErrorStackInfo
            , logger.errorStack(
                '������ ��� ��������� �������� ('
                || ' optionShortName="' || optionShortName || '"'
                || ', valueTypeCode="' || valueTypeCode || '"'
                || ', value_order_number=' || rec.value_order_number
                || ', value_element_name="' || rec.value_element_name || '"'
                || ', instance_name="' || rec.instance_name || '"'
                || ').'
              )
            , true
          );
        end;
      end loop;
      if newOptionFlag = 0 then
        deleteExcessValue();
      end if;
    exception when others then
      raise_application_error(
        pkg_Error.ErrorStackInfo
        , logger.errorStack(
            '������ ��� ��������� �������� ��������� ('
            || ' newOptionFlag=' || newOptionFlag
            || ').'
          )
        , true
      );
    end processValue;



    /*
      ������� ������ ���������.
    */
    procedure deleteExcessOption
    is

      cursor dataCur is
        select
          d.option_short_name
        from
          table(
            -- ����� ���������� ���� ��������� ��� ������������� � Oracle 10.2
            cast( opt.getOptionValue() as opt_option_value_table_t)
          ) d
        where
          batchConfigXml.existsNode(
            'batch_config/option[@short_name="' || d.option_short_name || '"]'
          ) = 0
        order by
          1
      ;

    begin
      for rec in dataCur loop
        opt.deleteOption(
          optionShortName => rec.option_short_name
        );
        outputInfo( 'option delete: ' || rec.option_short_name);
        nDelete := nDelete + 1;
      end loop;
    exception when others then
      raise_application_error(
        pkg_Error.ErrorStackInfo
        , logger.errorStack(
            '������ ��� �������� ������ ����������.'
          )
        , true
      );
    end deleteExcessOption;



    /*
      ������������ ��������� ��� ��������.
    */
    procedure processOption
    is

      cursor optionCur is
        select
          a.*
          , case a.option_type
              when Date_OptionType then
                sch_batch_option_t.getDateValueTypeCode()
              when Number_OptionType then
                sch_batch_option_t.getNumberValueTypeCode()
              when String_OptionType then
                sch_batch_option_t.getStringValueTypeCode()
            end
            as value_type_code
          , case coalesce( a.encryption, '0')
              when '0' then 0
              when '1' then 1
            end
            as encryption_flag
          , case coalesce( a.access_level, Full_OptionAccessLevel)
              when Full_OptionAccessLevel then
                sch_batch_option_t.getFullAccessLevelCode()
              when Read_OptionAccessLevel then
                sch_batch_option_t.getReadAccessLevelCode()
              when Value_OptionAccessLevel then
                sch_batch_option_t.getValueAccessLevelCode()
            end
            as access_level_code
          , case when a.first_child_name like '%value\_list' escape '\' then
              1
            else
              0
            end
            as value_list_flag
          , case when
              a.first_child_name like 'test\_value%' escape '\'
              or a.first_child_name like 'prod\_value%' escape '\'
              or a.first_child_name like 'production\_value%' escape '\'
            then
              1
            else
              0
            end
            as test_prod_sensitive_flag
        from
          (
          select
            b.*
            , b.option_xml.extract( '/option/*[1]').getRootElement()
              as first_child_name
            , lag( b.option_order_number, 1)
              over(
                partition by b.option_short_name
                order by b.option_order_number
              )
              as prev_name_order_number
          from
            xmltable(
              '/batch_config/option'
              passing batchConfigXml
              columns
                -- ����������� ����� ��������� � XML
                option_order_number for ordinality
                , option_short_name varchar2(100) path '@short_name'
                , option_type varchar2(100) path '@type'
                , option_name varchar2(250) path '@name'
                  -- �� ���������� �������� ���, ����� ��������� ������ �
                  -- ������� � ������ ������������� ��������
                , encryption varchar2(100) path '@encryption'
                , access_level varchar2(100) path '@access_level'
                , option_description varchar2(1000) path '@description'
                , option_xml xmltype path 'self::node()'
            ) b
          ) a
        order by
          a.option_order_number
      ;

      -- ���� �������� ������ ���������
      newOptionFlag pls_integer;



      /*
        ��������� ������������ ������ ���������.
      */
      procedure checkOption(
        rec optionCur%rowtype
      )
      is

        -- ��� �������� � ��������� ���������
        attrName varchar2(30);

      begin

        -- �������� ������� ��������
        attrName :=
          case
            when rec.option_short_name is null then 'short_name'
            when rec.option_type is null then 'type'
            when rec.option_name is null then 'name'
          end
        ;
        if attrName is not null then
          raise_application_error(
            pkg_Error.IllegalArgument
            , '�� ������� �������� ������������� �������� "'
              || attrName || '" �������� "option".'
          );
        end if;

        -- �������� ������������ �������� ���������
        if rec.value_type_code is null then
          raise_application_error(
            pkg_Error.IllegalArgument
            , '������������ �������� �������� "type" �������� "option" ('
              || ' type="' || rec.option_type || '"'
              || ').'
          );
        elsif rec.encryption_flag is null then
          raise_application_error(
            pkg_Error.IllegalArgument
            , '������������ �������� �������� "encryption" ��������'
              || ' "option" ('
              || ' encryption="' || rec.encryption || '"'
              || ').'
          );
        elsif rec.access_level_code is null then
          raise_application_error(
            pkg_Error.IllegalArgument
            , '������������ �������� �������� "access_level" ��������'
              || ' "option" ('
              || ' access_level="' || rec.access_level || '"'
              || ').'
          );
        end if;

        -- ������������ �� option_short_name
        if rec.prev_name_order_number is not null then
          raise_application_error(
            pkg_Error.IllegalArgument
            , '�������� ��� ��������� � �������� "short_name" ��'
              || ' �������� ���������� ('
              || ' short_name="' || rec.option_short_name || '"'
              || ', ������������ � ����� #' || rec.prev_name_order_number
              || ').'
          );
        end if;
      end checkOption;



    -- processOption
    begin
      for rec in optionCur loop
        begin
          checkOption( rec);
          newOptionFlag := 1 - opt.existsOption( rec.option_short_name);
          if newOptionFlag = 1 then
            opt.createOption(
              optionShortName           => rec.option_short_name
              , valueTypeCode           => rec.value_type_code
              , optionName              => rec.option_name
              , valueListFlag           => rec.value_list_flag
              , encryptionFlag          => rec.encryption_flag
              , testProdSensitiveFlag   => rec.test_prod_sensitive_flag
              , accessLevelCode         => rec.access_level_code
              , optionDescription       => rec.option_description
            );
            nInsert := nInsert + 1;
          else
            nUpdate := nUpdate + opt.updateOption(
              optionShortName           => rec.option_short_name
              , valueTypeCode           => rec.value_type_code
              , optionName              => rec.option_name
              , valueListFlag           => rec.value_list_flag
              , encryptionFlag          => rec.encryption_flag
              , testProdSensitiveFlag   => rec.test_prod_sensitive_flag
              , accessLevelCode         => rec.access_level_code
              , optionDescription       => rec.option_description
              , forceOptionDescriptionFlag  => 1
              , moveProdSensitiveValueFlag  => 1
              , deleteBadValueFlag          => 1
              , skipIfNoChangeFlag          => 1
            );
          end if;
          if newOptionFlag = 1 or updateOptionValue = 1 or usedBatchNewFlag
              then
            processValue(
              optionShortName         => rec.option_short_name
              , optionXml             => rec.option_xml
              , valueTypeCode         => rec.value_type_code
              , testProdSensitiveFlag => rec.test_prod_sensitive_flag
              , valueListFlag         => rec.value_list_flag
              , firstValueElementName => rec.first_child_name
              , newOptionFlag         => newOptionFlag
            );
          end if;
          nLoadOption := nLoadOption + 1;
        exception when others then
          raise_application_error(
            pkg_Error.ErrorStackInfo
            , logger.errorStack(
                '������ ��� ��������� ��������� ('
                || ' option_order_number=' || rec.option_order_number
                || ', option_short_name="' || rec.option_short_name || '"'
                || ').'
              )
            , true
          );
        end;
      end loop;
      deleteExcessOption();
    exception when others then
      raise_application_error(
        pkg_Error.ErrorStackInfo
        , logger.errorStack(
            '������ ��� ��������� ���������� ��� ��������.'
          )
        , true
      );
    end processOption;



  -- loadOption
  begin
    logger.trace(
      'loadOption: batch_short_name="' || batch.batch_short_name || '"'
    );
    opt := sch_batch_option_t(
      batchShortName  => batch.batch_short_name
      , moduleId      => batch.module_id
    );
    processOption();
    if nLoadOption > 0 then
      outputInfo( 'options for load: ' || nLoadOption);
    end if;
    if nInsert > 0 then
      outputInfo( 'option: + ' || nInsert || ' row');
    end if;
    if nUpdate > 0 then
      outputInfo( 'option: * ' || nUpdate || ' row');
    end if;
    if nDelete > 0 then
      outputInfo( 'option: - ' || nDelete || ' row');
    end if;
    if nValueChange > 0 then
      outputInfo( 'option: * ' || nValueChange || ' values');
    end if;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ �������� ���������� �����.'
        )
      , true
    );
  end loadOption;



-- loadBatchConfig
begin
  getBatch();
  logger.trace( 'batch.retrial_count=' || to_char( batch.retrial_count)); logger.trace( 'loadBatchConfig: batchDateIns={' || to_char(  batch.date_ins, 'dd.mm.yyyy hh24:mi:ss') || '}');
  usedBatchNewFlag := coalesce( batchNewFlag, 0) = 1 or batch.date_ins > sysdate - 1;
  if ( updateScheduleFlag = 1) or usedBatchNewFlag then
    logger.trace( 'updateSchedule');
    -- ���� ���� �� ��� ���� ������ ��� ������
    if batchShortName is null then
      loadBatchAttribute();
    end if;
    readSchedule();
    saveSchedule();
  end if;
  if coalesce( skipLoadOption, 0) = 0 then
    loadOption();
  end if;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ �������� �������� ��������� ������� � �� �� XML ('
        || ' moduleId=' || to_char( moduleId)
        || ', batchShortName="' || batchShortName || '"'
        || ').'
      )
    , true
  );
end loadBatchConfig;

/* proc: loadBatchConfig
  �������� �������� �������� ������� ( ������) � �� �� XML.

  ���������:
  moduleName                  - �������� ������ ( �������� "ModuleInfo")
  moduleSvnRoot               - ���� � ��������� �������� ����������������
                                ������ � Subversion ( ������� � �����
                                �����������, ��������
                                "Oracle/Module/ModuleInfo")
  moduleInitialSvnPath        - �������������� ���� � ��������� ��������
                                ���������������� ������ � Subversion ( �������
                                � ����� ����������� � ������ ����� ������, �
                                ������� �� ��� ������, ��������
                                "Oracle/Module/ModuleInfo@711")
  xmlText                     - ����� xml � ������� ��������
  updateScheduleFlag          - ��������� �� ���������� ������������� �����
                                ( ��-��������� ����������� ���������� ������
                                  ������ �����)
  skipLoadOption              - ���� ���������� �������� ���������� ��������
                                ������� ( "1" �� ���������, �� ���������
                                ��������� ��������� �������������� ��������
                                �������)
  updateOptionValue           - ��������� �� �������� ������������ ����������
*/
procedure loadBatchConfig(
  moduleName varchar2 := null
  , moduleSvnRoot varchar2 := null
  , moduleInitialSvnPath varchar2 := null
  , xmlText clob
  , updateScheduleFlag number := null
  , skipLoadOption number := null
  , updateOptionValue number := null
)
is
  -- xml � ������� ��������� ������
  listXml xmltype;
  -- xml � ������� ��������
  batchConfigXml xmltype;
  -- id ������
  moduleId integer;

  -- ����� xml �������� �����
  configNumber integer := 1;

  -- ���� � xml �������� �����
  configPath varchar2(100);

-- loadBatchConfig
begin
  moduleId := pkg_ModuleInfo.getModuleId(
    moduleName => moduleName
    , svnRoot => moduleSvnRoot
    , initialSvnPath => moduleInitialSvnPath
  );
  listXml := xmltype( getDataText( xmlText));
  loop
    configPath := '/batch_config[' || to_char( configNumber) || ']';
    exit when ( listXml.existsnode( configPath) = 0);
    batchConfigXml := listXml.extract( configPath);
    loadBatchConfig(
      moduleId => moduleId
      , batchConfigXml => batchConfigXml
      , batchShortName => null
      , batchNewFlag => null
      , updateScheduleFlag => updateScheduleFlag
      , skipLoadOption => skipLoadOption
      , updateOptionValue => updateOptionValue
    );
    configNumber := configNumber + 1;
  end loop;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ �������� �������� ������ ('
        || ' moduleName="' || moduleName || '"'
        || ', moduleSvnRoot="' || moduleSvnRoot || '"'
        || ', moduleInitialSvnPath="' || moduleInitialSvnPath || '"'
        || ').'
      )
    , true
  );
end loadBatchConfig;

/* proc: loadBatch(moduleId)
  �������� ��������� ������� ( �����) � �� �� XML.

  ���������:
  moduleId                    - id ������
  batchShortName              - �������� ������������ ��������� ������� ( �����)
                                ( ������ ��������������� ������ XML)
  xmlText                     - ���������� ��������� ������� � ���� xml
  updateScheduleFlag          - ��������� �� ���������� ������������� �����
                                ( ��-��������� ����������� ���������� ������
                                  ������ �����)
  skipLoadOption              - ���� ���������� �������� ���������� ��������
                                ������� ( "1" �� ���������, �� ���������
                                ��������� ��������� ��������������� ��������
                                �������)
  updateOptionValue           - ��������� �� �������� ������������ ����������
*/
procedure loadBatch(
  moduleId integer
  , batchShortName varchar2
  , xmlText clob
  , updateScheduleFlag number := null
  , skipLoadOption number := null
  , updateOptionValue number := null
)
is
  -- XML �����
  batchXml xmltype;
  -- XML ��������� �����
  batchConfigXml xmltype;

  -- ������ ����� �� XML
  batch sch_batch%rowtype;

  -- �������� �� ����� ���� ��� ���������� ������������
  batchNewFlag number;

  /*
    �������� ������ �����.
  */
  procedure loadBatch
  is
    -- ������������ ������ � ��
    dbBatchRecord sch_batch%rowtype;

    -- ������ ��� ������ ������ � ��
    cursor batchCur( batchShortName varchar2) is
      select
        *
      from
        sch_batch
      where
        batch_short_name = batchShortName
    ;

  begin
    batch.batch_short_name := getAttributeString( batchXml, 'batch' , 'short_name');
    logger.trace( 'batch.batch_short_name="' || batch.batch_short_name || '"');
    if (
      batch.batch_short_name <> batchShortName
      or batchShortName is null
      or batch.batch_short_name is null
    ) then
      raise_application_error(
        pkg_Error.IllegalArgument
        , '������������ �������� ������������ ����� ('
          || ' batch.batch_short_name="' || batch.batch_short_name || '"'
          || ')'
      );
    end if;
    batch.batch_name_rus := getString( batchXml, 'batch/name');
    batch.batch_name_eng := coalesce(
      getString(
        batchXml, 'batch/name_eng', raiseExceptionFlag => false
      )
      , 'NA'
    );
    batch.batch_type_id := getBatchTypeId( moduleId => moduleId);
    batch.retrial_count :=
      getInteger( batchXml, 'batch/batch_config/retry_count', raiseExceptionFlag => false);
    batch.retrial_timeout :=
      numToDsInterval(
        getNumber( batchXml, 'batch/batch_config/retry_interval', raiseExceptionFlag => false)
        , 'MINUTE'
      );
    batch.nls_territory :=
      getString( batchXml, 'batch/batch_config/nls_territory', raiseExceptionFlag => false);
    batch.nls_language :=
      getString( batchXml, 'batch/batch_config/nls_language', raiseExceptionFlag => false);
    batch.module_id := moduleId;
    open
      batchCur( batchShortName => batch.batch_short_name)
    ;
    fetch
      batchCur
    into
      dbBatchRecord
    ;
    if batchCur%notfound then
      insert into sch_batch(
        batch_short_name
        , batch_name_rus
        , batch_name_eng
        , batch_type_id
        , retrial_count
        , retrial_timeout
        , nls_language
        , nls_territory
        , module_id
      )
      values(
        batch.batch_short_name
        , batch.batch_name_rus
        , batch.batch_name_eng
        , batch.batch_type_id
        , batch.retrial_count
        , batch.retrial_timeout
        , batch.nls_language
        , batch.nls_territory
        , batch.module_id
      )
      returning
        batch_id
      into
        batch.batch_id
      ;
      outputInfo( 'sch_batch: + ' || to_char( sql%rowcount) || ' row');
      batchNewFlag := 1;
    else
      updateBatch(
        newBatchRecord => batch
        , dbBatchRecord => dbBatchRecord
        , updateMainAttributeFlag => 1
        , updateConfigFlag => batchXml.existsnode( 'batch/batch_config')
        , updateScheduleFlag => updateScheduleFlag
      );
      batch.batch_id := dbBatchRecord.batch_id;
      batchNewFlag := 0;
    end if;
    close batchCur;
  exception when others then
    if batchCur%isopen then
      close batchCur;
    end if;
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ �������� ������ �����'
        )
      , true
    );
  end loadBatch;

  /*
    �������� ����������� �����.
  */
  procedure loadBatchContent
  is

    -- ��� ������� ������� ��������� ����������� �����
    type ContentColT is table of integer;

    -- ������� ������� ��������� ����������� �����
    contentCol ContentColT := ContentColT();

    /*
      ��������� ���������� ����� � ��������� �������.
    */
    procedure parseBatchContent
    is
      -- ��� �������������� �������� ����������� �����
      subtype BatchContentIdT is varchar2(100);

      -- ��� ��������������� ������ ������� ��������� �� ���������������
      -- �����������
      type BatchContentIndexById is table of integer index by BatchContentIdT;

      -- ��������������� ������ ������� ��������� �� ���������������
      -- �����������
      batchConfigIndexById BatchContentIndexById;

      -- ������ �������� �����������
      contentIndex integer := 1;

      -- ������ ������� ����������
      conditionIndex integer;

      -- xml �������� �����������
      contentXml xmltype;

      -- Id �������� �������� �����������
      contentId BatchContentIdT;

      -- xml ������� ����������
      conditionXml xmltype;

      -- Id �������� ����������� �� �������
      conditionContentId BatchContentIdT;

      -- ������ ������� ������������ �������
      checkContentIndex integer;

      -- ��������� ������� ��� �������
      resultId integer;

      /*
        ����� �������.
      */
      function getJobId(
        jobShortName varchar2
      )
      return integer
      is

        -- ������ ��� ������ ������
        moduleString varchar2(32767);

        -- Id ������
        externalModuleId integer;

        -- Id �������
        jobId integer;
      begin
        logger.trace( 'getJobId: jobShortName="' || jobShortName || '"');
        moduleString := getAttributeString( contentXml, 'content', 'module', raiseExceptionFlag => false);
        logger.trace( 'getJobId: moduleString="' || moduleString || '"');
        if moduleString is not null then
          -- ��������� ������� ���������
          externalModuleId := pkg_ModuleInfo.getModuleId( moduleString);
          select
            max( job_id)
          into
            jobId
          from
            sch_job
          where
            job_short_name = jobShortName
            and module_id = externalModuleId
            and public_flag = 1
          ;
        else
          -- ������� ��������� �����
          select
            max( job_id)
          into
            jobId
          from
            sch_job
          where
            job_short_name = jobShortName
            and module_id = moduleId
            and batch_short_name = batch.batch_short_name
          ;
          if jobId is null then
            -- ������� ��������� ������
            select
              max( job_id)
            into
              jobId
            from
              sch_job
            where
              job_short_name = jobShortName
              and module_id = moduleId
              and public_flag = 0
              and batch_short_name is null
            ;
          end if;
        end if;
        if jobId is null then
          raise_application_error(
            pkg_Error.IllegalArgument
            , '������� �� ������� ( jobShortName="' || jobShortName || '")'
          );
        end if;
        return
          jobId
        ;
      exception when others then
        raise_application_error(
          pkg_Error.ErrorStackInfo
          , logger.errorStack(
              '������ ������ ������� ( '
              || ' jobShortName="' || jobShortName || '"'
              || ')'
            )
          , true
        );
      end getJobId;

      /*
        ��������� id ���������� ����������.
      */
      function getResultId( resultCode varchar2)
      return integer
      is
      begin
        return
          case
            lower( resultCode)
          when
            'true'
          then
            pkg_Scheduler.True_ResultId
          when
            'false'
          then
            pkg_Scheduler.False_ResultId
          when
            'error'
          then
            pkg_Scheduler.Error_ResultId
          when
            'run_error'
          then
            pkg_Scheduler.RunError_ResultId
          when
            'skip'
          then
            pkg_Scheduler.Skip_ResultId
          when
            'retry'
          then
            pkg_Scheduler.RetryAttempt_ResultId
          end
        ;
      exception when others then
        raise_application_error(
          pkg_Error.ErrorStackInfo
          , logger.errorStack(
              '������ ��������� id ���������� ('
              || 'resultCode="' || resultCode || '"'
              || ')'
            )
          , true
        );
      end getResultId;

    begin
      delete from
        sch_load_condition_tmp
      ;
      while ( batchXml.existsNode( 'batch/content[' || to_char( contentIndex) || ']') = 1) loop
        contentXml := batchXml.extract( 'batch/content[' || to_char( contentIndex) || ']');
        contentId := getAttributeString( contentXml, 'content', 'id');
        logger.trace( 'contentId="' || contentId || '"');
        contentCol.extend(1);
        contentCol( contentIndex) := getJobId( getAttributeString( contentXml, 'content', 'job'));
        conditionIndex := 1;
        while
          ( contentXml.existsNode( 'content/condition[' || to_char( conditionIndex) || ']') = 1)
        loop
          conditionXml := contentXml.extract( 'content/condition[' || to_char( conditionIndex) || ']');
          conditionContentId := getAttributeString( conditionXml, 'condition', 'id');
          if not batchConfigIndexById.exists( conditionContentId) then
            raise_application_error(
              pkg_Error.IllegalArgument
              , '������� ����������� ����� �� ������ ( id="' || conditionContentId || '")'
            );
          else
            -- ���������� ���������� �� "id"
            checkContentIndex := batchConfigIndexById( conditionContentId);
            resultId := getResultId( getString( conditionXml, 'condition'));
          end if;
          insert into
            sch_load_condition_tmp
          (
            order_by
            , check_order_by
            , result_id
          )
          values(
            contentIndex
            , checkContentIndex
            , resultId
          );
          conditionIndex := conditionIndex + 1;
        end loop;
        -- ��������� ���������� �� "id"
        batchConfigIndexById( contentId) := contentIndex;
        logger.trace( 'batchConfigIndexById( "' || contentId || '") := ' || to_char( contentIndex));
        contentIndex := contentIndex + 1;
      end loop;
    exception when others then
      raise_application_error(
        pkg_Error.ErrorStackInfo
        , logger.errorStack(
            '������ ������� ����������� �������'
          )
        , true
      );
    end parseBatchContent;

    /*
      ���������� ����������� ����� �� �������� � ��.
    */
    procedure saveBatchContent
    is
      -- ������ �� ��������������� ����������� �����
      cursor destBatchContentCur is
        select
          bc.batch_content_id
          , bc.order_by
          , bc.job_id
        from
          sch_batch_content bc
        where
          bc.batch_id = batch.batch_id
        order by
          bc.order_by
      for update
      ;

      -- ������ ��������������� ����������� �����
      destBatchContent destBatchContentCur%rowtype;

      -- id �������
      jobId integer;
      -- �������� �������
      nDel pls_integer    := 0;
      nInsert pls_integer := 0;
      nUpdate pls_integer := 0;

      /*
        �������� �������� ����������� �����.
      */
      procedure deleteRow
      is
      begin
        delete from
          sch_condition
        where
          batch_content_id = destBatchContent.batch_content_id
          or check_batch_content_id = destBatchContent.batch_content_id
        ;
        if sql%rowcount > 0 then
          outputInfo( 'sch_condition: - ' || to_char( sql%rowcount) || ' row');
        end if;
        delete from sch_batch_content where current of destBatchContentCur;
        nDel := nDel + 1;
        fetch destBatchContentCur into destBatchContent;
      exception when others then
        raise_application_error(
          pkg_Error.ErrorStackInfo
          , logger.errorStack(
              '������ �������� �������� ����������� �����'
            )
          , true
        );
      end deleteRow;

    begin
      open destBatchContentCur;
      fetch destBatchContentCur into destBatchContent;
      for contentIndex in contentCol.first .. contentCol.last loop
        jobId := contentCol( contentIndex);
        while destBatchContentCur%found
          and destBatchContent.order_by < contentIndex
        loop
          deleteRow();
        end loop;
        if destBatchContentCur%found
          and destBatchContent.order_by = contentIndex
        then
          if destBatchContent.job_id <> jobId then
            update
              sch_batch_content
            set
              job_id = jobId
            where current of destBatchContentCur;
            nUpdate := nUpdate + 1;
          end if;
          fetch destBatchContentCur into destBatchContent;
        else
          insert into sch_batch_content
          (
            batch_id
            , job_id
            , order_by
          )
          values
          (
            batch.batch_id
            , jobId
            , contentIndex
          );
        end if;
      end loop;
      while destBatchContentCur%found loop
        deleteRow();
      end loop;
      close destBatchContentCur;
      if nInsert > 0 then
        outputInfo( 'sch_batch_content: + ' || to_char( nInsert) || ' row');
      end if;
      if nUpdate > 0 then
        outputInfo( 'sch_batch_content: * ' || to_char( nUpdate) || ' row');
      end if;
      if nDel > 0 then
        outputInfo( 'sch_batch_content: - ' || to_char( nDel) || ' row');
      end if;
    exception when others then
      raise_application_error(
        pkg_Error.ErrorStackInfo
        , logger.errorStack(
            '������ ���������� ����������� ����� � ��'
          )
        , true
      );
    end saveBatchContent;

    /*
      ���������� ������� ���������� �������.
    */
    procedure saveCondition
    is

      -- ������ �� �������� �������� ���������� �������
      cursor srcConditionCur is
        select
          order_by
          , check_order_by
          , result_id
        from
          sch_load_condition_tmp
        order by
          1, 2, 3
        ;

      -- ������ �� ������������ �������� ���������� �������
      cursor destConditionCur is
        select
          bc.order_by
          , bc_2.order_by as check_order_by
          , cn.result_id
        from
          sch_condition cn
        inner join
          sch_batch_content bc
        on
          bc.batch_content_id = cn.batch_content_id
        inner join
          sch_batch_content bc_2
        on
          bc_2.batch_content_id = cn.check_batch_content_id
        where
          bc.batch_id = batch.batch_id
        order by
          1, 2, 3
        for update of cn.check_batch_content_id, cn.result_id
        ;

      -- ������ ������� ���������� �������
      destCondition destConditionCur%rowtype;

      -- �������� ���������� �������
      nDel pls_integer    := 0;
      nInsert pls_integer := 0;

       /*
         �������� ������ ������� ���������� �������.
       */
       procedure deleteRow
       is
       begin
         delete from
           sch_condition
         where current of
           destConditionCur
         ;
         nDel := nDel + 1;
         fetch destConditionCur into destCondition;
       end deleteRow;

    begin
      open destConditionCur;
      fetch destConditionCur into destCondition;
      for srcCondition in srcConditionCur loop
        while
          destConditionCur%found
          and (
            destCondition.order_by < srcCondition.order_by
            or (
              destCondition.order_by = srcCondition.order_by
              and destCondition.check_order_by < srcCondition.check_order_by
            )
            or (
              destCondition.order_by = srcCondition.order_by
              and destCondition.check_order_by = srcCondition.check_order_by
              and destCondition.result_id < srcCondition.result_id
            )
          )
        loop
          deleteRow();
        end loop;
        if
          destConditionCur%found
          and destCondition.order_by = srcCondition.order_by
          and destCondition.check_order_by = srcCondition.check_order_by
          and destCondition.result_id = srcCondition.result_id
        then
          fetch destConditionCur into destCondition;
        else
          insert into sch_condition
          (
            batch_content_id
            , check_batch_content_id
            , result_id
          )
          select
            (
            select
              batch_content_id
            from
              sch_batch_content
            where
              batch_id = batch.batch_id
              and order_by = srcCondition.order_by
            ) as batch_content_id
            ,
            (
            select
              batch_content_id
            from
              sch_batch_content
            where
              batch_id = batch.batch_id
              and order_by =  srcCondition.check_order_by
            ) as check_batch_content_id
            , srcCondition.result_id
          from
            dual
          ;
          nInsert := nInsert + 1;
        end if;
      end loop;
      while destConditionCur%found loop
        deleteRow();
      end loop;
      if nInsert > 0 then
        outputInfo( 'sch_condition: + ' || to_char( nInsert) || ' row');
      end if;
      if nDel > 0 then
        outputInfo( 'sch_condition: - ' || to_char( nDel) || ' row');
      end if;
    exception when others then
      raise_application_error(
        pkg_Error.ErrorStackInfo
        , logger.errorStack(
            '������ ���������� ������� ���������� �������'
          )
        , true
      );
    end saveCondition;

  begin
    parseBatchContent();
    saveBatchContent();
    saveCondition();
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ �������� ����������� �����'
        )
      , true
    );
  end loadBatchContent;

-- loadJob
begin
  batchXml := xmltype( getDataText( xmlText));
  loadBatch();
  loadBatchContent();
  if ( batchXml.existsnode( 'batch/batch_config') = 1) then
    batchConfigXml := batchXml.extract( 'batch/batch_config');
    loadBatchConfig(
      moduleId => moduleId
      , batchConfigXml => batchConfigXml
      , batchShortName => batchShortName
      , batchNewFlag => batchNewFlag
      , updateScheduleFlag => updateScheduleFlag
      , skipLoadOption => skipLoadOption
      , updateOptionValue => updateOptionValue
    );
  end if;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ �������� ����� ('
        || ' moduleId=' || to_char( moduleId)
        || ', batchShortName="' || batchShortName || '"'
        || ').'
      )
    , true
  );
end loadBatch;

/* proc: loadBatch
  �������� ��������� ������� ( �����) � �� �� XML.

  ���������:
  moduleName                  - �������� ������ ( �������� "ModuleInfo")
  moduleSvnRoot               - ���� � ��������� �������� ����������������
                                ������ � Subversion ( ������� � �����
                                �����������, ��������
                                "Oracle/Module/ModuleInfo")
  moduleInitialSvnPath        - �������������� ���� � ��������� ��������
                                ���������������� ������ � Subversion ( �������
                                � ����� ����������� � ������ ����� ������, �
                                ������� �� ��� ������, ��������
                                "Oracle/Module/ModuleInfo@711")
  batchShortName              - �������� ������������ ��������� ������� ( �����)
                                ( ������ ��������������� ������ XML)
  xmlText                     - ���������� ��������� ������� � ���� xml
  updateScheduleFlag          - ��������� �� ���������� ������������� �����
                                ( ��-��������� ����������� ���������� ������
                                  ������ �����)
  skipLoadOption              - ���� ���������� �������� ���������� ��������
                                ������� ( "1" �� ���������, �� ���������
                                ��������� ��������� ��������������� ��������
                                �������)
  updateOptionValue           - ��������� �� �������� ������������ ����������
*/
procedure loadBatch(
  moduleName varchar2 := null
  , moduleSvnRoot varchar2 := null
  , moduleInitialSvnPath varchar2 := null
  , batchShortName varchar2
  , xmlText clob
  , updateScheduleFlag number := null
  , skipLoadOption number := null
  , updateOptionValue number := null
)
is
  -- id ������
  moduleId integer;
-- loadJob
begin
  moduleId := pkg_ModuleInfo.getModuleId(
    moduleName => moduleName
    , svnRoot => moduleSvnRoot
    , initialSvnPath => moduleInitialSvnPath
  );
  loadBatch(
    moduleId => moduleId
    , batchShortName => batchShortName
    , xmlText => xmlText
    , updateScheduleFlag => updateScheduleFlag
    , skipLoadOption => skipLoadOption
    , updateOptionValue => updateOptionValue
  );
end loadBatch;

/* proc: renameBatch( INTERNAL)
  ��������������� �������� �������.

  ���������:
  batchRec                    - ������ ��������� �������
  newBatchShortName           - ����� �������� ������������ ��������� �������
*/
procedure renameBatch(
  batchRec sch_batch%rowtype
  , newBatchShortName varchar2
)
is
begin
  update
    sch_batch b
  set
    b.batch_short_name = newBatchShortName
  where
    b.batch_id = batchRec.batch_id
  ;
  if sql%rowcount = 0 then
    raise_application_error(
      pkg_Error.BatchNotFound
      , '�������� ������� �� ������� ('
        || ' batch_id=' || batchRec.batch_id
        || ').'
    );
  end if;
  moveOption(
    batchShortName        => batchRec.batch_short_name
    , moduleId            => batchRec.module_id
    , newBatchShortName   => newBatchShortName
  );
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� ���������������� ��������� ������� ('
        || ' batch_id=' || batchRec.batch_id
        || ', batch_short_name="' || batchRec.batch_short_name || '"'
        || ', newBatchShortName="' || newBatchShortName || '"'
        || ').'
      )
    , true
  );
end renameBatch;

/* proc: renameBatch( batchId)
  ��������������� �������� �������.

  ���������:
  batchId                     - Id ��������� �������
  newBatchShortName           - ����� �������� ������������ ��������� �������
*/
procedure renameBatch(
  batchId integer
  , newBatchShortName varchar2
)
is

  -- ������ ��������� �������
  btr sch_batch%rowtype;

begin
  pkg_SchedulerMain.getBatch( btr, batchId => batchId);
  renameBatch(
    batchRec            => btr
    , newBatchShortName => newBatchShortName
  );
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� ���������������� ��������� ������� ('
        || ' batchId=' || batchId
        || ', newBatchShortName="' || newBatchShortName || '"'
        || ').'
      )
    , true
  );
end renameBatch;

/* proc: renameBatch
  ��������������� �������� �������.

  ���������:
  batchShortName              - �������� ������������ ��������� �������
  newBatchShortName           - ����� �������� ������������ ��������� �������
*/
procedure renameBatch(
  batchShortName varchar2
  , newBatchShortName varchar2
)
is

  -- ������ ��������� �������
  btr sch_batch%rowtype;

begin
  pkg_SchedulerMain.getBatch( btr, batchShortName => batchShortName);
  renameBatch(
    batchRec            => btr
    , newBatchShortName => newBatchShortName
  );
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� ���������������� ��������� ������� ('
        || ' batchShortName="' || batchShortName || '"'
        || ', newBatchShortName="' || newBatchShortName || '"'
        || ').'
      )
    , true
  );
end renameBatch;

/* proc: deleteBatch(batchId)
  �������� �����.

  ���������:
  batchId                     - id �����
*/
procedure deleteBatch(
  batchId integer
)
is
  batchShortName varchar2(30);
  /*
    �������� ����������.
  */
  procedure deleteSchedule(
    batchId integer
  )
  is
  begin
    delete from
      sch_interval iv
    where
      iv.schedule_id in
        (
        select
          t.schedule_id
        from
          sch_schedule t
        where
          t.batch_id = batchId
        )
    ;
    delete from
      sch_schedule t
    where
      t.batch_id = batchId
    ;
  end deleteSchedule;

  /*
    �������� ����� �����.
  */
  procedure deleteBatchRole( batchId integer)
  is
  begin
    delete from
      sch_batch_role t
    where
      t.batch_id = batchId
    ;
  end deleteBatchRole;

  /*
    �������� �����������.
  */
  procedure deleteContent(
    batchId integer
  )
  is
  begin
    delete from
      sch_condition cn
    where
      cn.batch_content_id in
        (
        select
          t.batch_content_id
        from
          sch_batch_content t
        where
          t.batch_id = batchId
        )
    ;
    delete from
      sch_batch_content t
    where
      t.batch_id = batchId
    ;
  end deleteContent;

  /*
    �������� ������ �����.
  */
  procedure deleteBatch(
    batchId integer
  )
  is
  begin
    delete from
      sch_batch t
    where
      t.batch_id = batchId
      and t.activated_flag = 0
    ;
    if sql%rowcount = 0 then
      raise_application_error(
        pkg_Error.IllegalArgument
        , '���������������� ���� �� ������'
      );
    end if;
  end deleteBatch;

  /*
    �������� �������������� job.
  */
  procedure deleteUnusedJob is
  begin
    delete from
      sch_job jb
    where
      public_flag = 0
      and jb.job_id not in
        (
        select
          bc.job_id
        from
          sch_batch_content bc
        )
    ;
  end deleteUnusedJob;

-- deleteBatch
begin
  select batch_short_name
  into batchShortName
  from sch_batch
  where batch_id = batchId
  ;
  deleteSchedule( batchId);
  deleteBatchRole( batchId);
  deleteContent( batchId);
  sch_batch_option_t( batchId => batchId).deleteAll();
  deleteBatch( batchId);
  deleteUnusedJob();
  outputInfo(
    rpad( 'Batch ' || batchShortName, 30)
    || ' - removed'
  );
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ �������� ����� ('
        || ' batchId=' || to_char( batchId)
        || ')'
      )
    , true
  );
end deleteBatch;

/* proc: deleteBatch
  �������� �����.

  ���������:
  batchShortName              - �������� ������������ �����
  activatedFlag               - ���� �������� �������������� ������ ( 1 �������
                                �������������� ����, 0 ������� ������ ���� ����
                                �� �����������, ��-��������� 0)
*/
procedure deleteBatch(
  batchShortName varchar2
  , activatedFlag number := null
)
is

  -- ������ ��������� �������
  btr sch_batch%rowtype;

begin
  pkg_SchedulerMain.getBatch( btr, batchShortName => batchShortName);
  if coalesce( activatedFlag, 0) = 0 and btr.activated_flag = 1 then
    raise_application_error(
      pkg_Error.IllegalArgument
      , '����� ' || batchShortName || ' ����������� � �� ����� ���� ������.'
    );
  elsif btr.activated_flag = 0 then
    deleteBatch(
      batchId => btr.batch_id
    );
  elsif activatedFlag = 1 and btr.activated_flag = 1 then
    pkg_Scheduler.deactivateBatch(
      batchId => btr.batch_id
      , operatorId => pkg_operator.getCurrentUserId()
    );
    deleteBatch(
      batchId => btr.batch_id
    );
  end if;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ �������� ����� ('
        || ' batchShortName="' || batchShortName || '"'
        || ')'
      )
    , true
  );
end deleteBatch;

/* proc: deleteModuleBatch
  �������� ���� ������, ������������� ������
  ������������ ��� �������� ������, ������������� ������ ��� ��� �������������
  
  ���������:
  moduleName                  - ������������ ������
*/
procedure deleteModuleBatch(
  moduleName varchar2 
)
is
  -- id ������
  moduleId integer;
begin
  moduleId := pkg_ModuleInfo.getModuleId(
    moduleName            => moduleName
    , raiseExceptionFlag  => 1
  );
  for curBatch in (
select
  b.batch_id
  , b.batch_short_name
  , b.activated_flag
from
  sch_batch b
where
  b.module_id = moduleId
  )
  loop
    if curBatch.activated_flag = 1 then
      pkg_Scheduler.deactivateBatch(
        batchId      => curBatch.batch_id
        , operatorId => pkg_operator.getCurrentUserId()
      );
    end if;
    deleteBatch(
      batchId         => curBatch.batch_id
    );
  end loop;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ �������� ����� ('
        || ' moduleName="' || moduleName || '"'
        || ')'
      )
    , true
  );
end deleteModuleBatch;



/* group: �������� ������ �� �� */

/* func: createBatchConfigXml
  �������� �������� ����� � XML.

  ���������:
  batchShortName              - �������� ������������ �����
  seperateFileFlag            - �������� �� ����������� xml ���������
                                ( ��� batch.xml)
                                ( 1 ��, 0 ��� ( �� ���������))
*/
function createBatchConfigXml(
  batchShortName varchar2
  , separateFileFlag integer := null
)
return clob
is
  batch sch_batch%rowtype;

  batchConfigXml clob;

  /*
    ���������� ���������� � ���������� � xml.
  */
  procedure addScheduleXml
  is
  begin
    for schedule in (
      select
        *
      from
        sch_schedule
      where
        batch_id = batch.batch_id
      order by
        schedule_id
    ) loop
      batchConfigXml := batchConfigXml || '
  <schedule>
    <name>' || getXmlString( schedule.schedule_name_rus) || '</name>'
        ||
        case when
          schedule.schedule_name_eng <> 'NA'
        then '
    <name_eng>' || schedule.schedule_name_eng || '</name_eng>'
        end
      ;
      for scheduleInterval in (
        select
          decode(
            interval_type_code
            , 'MM', 'MM'
            , 'DD', 'DD'
            , 'DW', 'dw'
            , 'HH', 'hh24'
            , 'MI', 'mi'
          ) as interval_type_code
          , i.min_value
          , i.max_value
          , i.step
          ,
          decode(
            interval_type_code
            , 'MM', 1
            , 'DD', 2
            , 'DW', 3
            , 'HH', 4
            , 'MI', 5
          ) as order_number
        from
          sch_interval i
        where
          schedule_id = schedule.schedule_id
        order by
          5
      ) loop
        batchConfigXml := batchConfigXml || '
    <interval type="' || scheduleInterval.interval_type_code || '">'
        ;
        batchConfigXml := batchConfigXml ||
        case when
          scheduleInterval.min_value = scheduleInterval.max_value
        then '
      <value>' || to_char( scheduleInterval.min_value) || '</value>'
        else '
      <min_value>' || to_char( scheduleInterval.min_value) || '</min_value>
      <max_value>' || to_char( scheduleInterval.max_value) || '</max_value>'
          ||
          case when
            scheduleInterval.step <> 1
          then '
      <step>' || to_char( scheduleInterval.step) || '</step>'
          end
        end
        || '
    </interval>'
        ;
      end loop;
      batchConfigXml := batchConfigXml || '
  </schedule>'
      ;
    end loop;
  end addScheduleXml;

  /*
    ���������� ���������� � ���������� �����.
  */
  procedure addOptionXml
  is

    -- ��������� �����
    opt sch_batch_option_t := sch_batch_option_t(
      batchShortName  => batch.batch_short_name
      , moduleId      => batch.module_id
    );


    cursor optionCur is
      select
        d.option_short_name
        , d.value_type_code
        , d.option_name
        , nullif( d.encryption_flag, 0)
          as encryption_flag
        , nullif(
            d.access_level_code
            , sch_batch_option_t.getFullAccessLevelCode()
          )
          as access_level_code
        , d.option_description
      from
        table(
          -- ����� ���������� ���� ��������� ��� ������������� � Oracle 10.2
          cast( opt.getOptionValue() as opt_option_value_table_t)
        ) d
      order by
        1
    ;

    cursor valueCur( optionShortName varchar2) is
      select
        d.value_list_flag
        , d.prod_value_flag
        , d.instance_name
        , nullif( d.list_separator, ';') as list_separator
        , d.date_value
        , d.number_value
        , d.string_value
      from
        table(
          -- ����� ���������� ���� ��������� ��� ������������� � Oracle 10.2
          cast( opt.getValue( optionShortName) as opt_value_table_t)
        ) d
      order by
        1, 2 desc, 3
    ;

    -- ��� �������� *value*
    valueTag varchar2(100);



    /*
      ���������� �������� ��������� � ���� ������ ��� ������� � XML
      ( ��������, �������� �� null, ������ ����� �� ����� ��� 1 ��������)
    */
    function getXmlValue(
      dateValue date
      , numberValue number
      , stringValue varchar2
    )
    return varchar2
    is
    begin
      return
        case
          when dateValue is not null then
            to_char(
              dateValue
              , 'dd.mm.yyyy'
                || case when dateValue != trunc( dateValue) then
                    ' hh24:mi:ss'
                  end
            )
          when numberValue is not null then
            to_char(
              numberValue
              , 'tm9'
              , 'NLS_NUMERIC_CHARACTERS = ''. '''
            )
          when stringValue is not null then
            getXmlString( stringValue)
        end
      ;
    end getXmlValue;



  -- addOptionXml
  begin
    for opr in optionCur loop
      batchConfigXml := batchConfigXml || '
  <option'
        || ' short_name="' || getXmlString( opr.option_short_name) || '"'
        || ' type="'
          || case opr.value_type_code
              when sch_batch_option_t.getDateValueTypeCode() then
                Date_OptionType
              when sch_batch_option_t.getNumberValueTypeCode() then
                Number_OptionType
              when sch_batch_option_t.getStringValueTypeCode() then
                String_OptionType
            end
          || '"'
        || ' name="' || getXmlString( opr.option_name) || '"'
        || case when opr.encryption_flag is not null then
            ' encryption="' || opr.encryption_flag || '"'
          end
        || case when opr.access_level_code is not null then
            ' access_level="'
              || case opr.access_level_code
                when sch_batch_option_t.getFullAccessLevelCode() then
                  Full_OptionAccessLevel
                when sch_batch_option_t.getReadAccessLevelCode() then
                  Read_OptionAccessLevel
                when sch_batch_option_t.getValueAccessLevelCode() then
                  Value_OptionAccessLevel
              end
              || '"'
          end
        || case when opr.option_description is not null then
            ' description="' || getXmlString( opr.option_description) || '"'
          end
        || '>'
      ;
      for vlr in valueCur( opr.option_short_name) loop
        valueTag :=
          case vlr.prod_value_flag
            when 1 then 'production_'
            when 0 then 'test_'
            else ''
          end
          || 'value'
          || case when vlr.value_list_flag = 1  then
              '_list'
            end
        ;
        batchConfigXml := batchConfigXml || '
    <' || valueTag
          || case when vlr.instance_name is not null then
              ' instance="' || getXmlString( vlr.instance_name) || '"'
            end
          || '>'
        ;
        if vlr.value_list_flag = 1 then
          for i in 1 ..
                opt.getValueCount(
                  optionShortName => opr.option_short_name
                )
              loop
            batchConfigXml := batchConfigXml
              || '<item>'
              || getXmlValue(
                  dateValue     =>
                      case when
                        opr.value_type_code
                          = sch_batch_option_t.getDateValueTypeCode()
                      then
                        opt.getDate(
                          optionShortName   => opr.option_short_name
                          , prodValueFlag   => vlr.prod_value_flag
                          , instanceName    => vlr.instance_name
                          , valueIndex      => i
                        )
                      end
                  , numberValue =>
                      case when
                        opr.value_type_code
                          = sch_batch_option_t.getNumberValueTypeCode()
                      then
                        opt.getNumber(
                          optionShortName   => opr.option_short_name
                          , prodValueFlag   => vlr.prod_value_flag
                          , instanceName    => vlr.instance_name
                          , valueIndex      => i
                        )
                      end
                  , stringValue =>
                      case when
                        opr.value_type_code
                          = sch_batch_option_t.getStringValueTypeCode()
                      then
                        opt.getString(
                          optionShortName   => opr.option_short_name
                          , prodValueFlag   => vlr.prod_value_flag
                          , instanceName    => vlr.instance_name
                          , valueIndex      => i
                        )
                      end
                )
              || '</item>'
            ;
          end loop;
        else
          batchConfigXml := batchConfigXml
            || getXmlValue(
                dateValue     => vlr.date_value
                , numberValue => vlr.number_value
                , stringValue => vlr.string_value
              )
          ;
        end if;
        batchConfigXml := batchConfigXml
          || '</' || valueTag || '>'
        ;
      end loop;
      batchConfigXml := batchConfigXml || '
  </option>'
      ;
    end loop;
  end addOptionXml;

  /*
    ��������� ���������� ����� �� ���������.
  */
  function getMinute(
    dsInterval interval day to second
  )
  return number
  is
  begin
    return
      extract( second from dsInterval) / 60
        + extract( minute from dsInterval)
        + extract( hour from dsInterval) * 60
        + extract( day from dsInterval) * 60 * 24
    ;
  end getMinute;

-- createBatchConfigXml
begin
  select
    *
  into
    batch
  from
    sch_batch
  where
    batch_short_name = batchShortName
  ;
  batchConfigXml :=
  case when
    separateFileFlag = 1
  then
'<?xml version="1.0" encoding="Windows-1251"?>
'
  end
  ||
'<batch_config'
  ||
  case when
    separateFileFlag = 1
  then
    ' short_name="' || batchShortName || '"'
  end
  || '>'
  ||
  case when
    batch.retrial_count is not null
  then '
  <retry_count>' || to_char( batch.retrial_count) || '</retry_count>'
  end
  ||
  case when
    batch.retrial_timeout is not null
  then '
  <retry_interval>'
  || rtrim( to_char(
       getMinute( batch.retrial_timeout)
       , 'FM9999999999999999990.99999'
     ), '.')
  || '</retry_interval>'
  end
  ||
  case when
    batch.nls_language is not null
  then '
  <nls_language>' || batch.nls_language || '</nls_language>'
  end
  ||
  case when
    batch.nls_language is not null
  then '
  <nls_territory>' || batch.nls_territory || '</nls_territory>'
  end
  ;
  addScheduleXml();
  addOptionXml();
  batchConfigXml := batchConfigXml || '
</batch_config>'
  ;
  return
    batchConfigXml
  ;
end createBatchConfigXml;

/* proc: unloadBatchConfigXml
  �������� �������� ����� � XML-����.

  ���������:
  batchShortName              - �������� ������������ �����
  filePath                    - ���� � ����� ��� �������
*/
procedure unloadBatchConfigXml(
  batchShortName varchar2
  , filePath varchar2
)
is
  xmlText clob;
-- unloadBatchConfigXml
begin
  xmlText := createBatchConfigXml(
    batchShortName => batchShortName
    , separateFileFlag => 1
  );
  unloadClobToFile(
    xmlText
    , filePath
  );
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ �������� ������ �������� ����� � XML-���� ( '
        || 'batchShortName="' || batchShortName ||'"'
        || ', filePath="' || filePath || '"'
        || ')'
      )
    , true
  );
end unloadBatchConfigXml;

/* func: createBatchXml
  �������� ������ ����� � XML.

  ���������:
  batchShortName              - �������� ������������ �����
  skipConfigFlag              - ���������� �� ��������� �����
                                ( ��-��������� ���������)
*/
function createBatchXml(
  batchShortName varchar2
  , skipConfigFlag number := null
)
return clob
is
  batch sch_batch%rowtype;
  -- ����� ��� ���������� �����
  batchContentXml clob;

  /*
    �������� ������ xml ��� ���������� �����.
  */
  procedure createBatchContentXml
  is
    type ContentNumberColT is table of integer index by varchar2(38);
    contentNumberCol ContentNumberColT;
    conditionFound boolean;

    /*
      �������������� result_Id � ������.
    */
    function resultIdToChar(
      resultId integer
    )
    return varchar2
    is
      resultCode varchar2(10);
    begin
      resultCode :=
        case
          resultId
        when
          pkg_Scheduler.True_ResultId
        then
          'true'
        when
          pkg_Scheduler.False_ResultId
        then
          'false'
        when
          pkg_Scheduler.Error_ResultId
        then
          'error'
        when
          pkg_Scheduler.RunError_ResultId
        then
          'run_error'
        when
          pkg_Scheduler.Skip_ResultId
        then
          'skip'
        when
          pkg_Scheduler.RetryAttempt_ResultId
        then
          'retry'
        end
      ;
      if resultCode is null then
        raise_application_error(
          pkg_Error.IllegalArgument
          , '���������� ������������� result_id � ������ ( resultId=' || to_char( resultId) || ')'
        );
      else
        return
          resultCode
        ;
      end if;
    end resultIdToChar;

  begin
    batchContentXml := '';
    for content in (
      select
        rownum as content_number
        , c.*
      from
        (
        select
          c.batch_content_id
          , j.job_short_name
          , j.public_flag
          , m.module_name
        from
          sch_batch_content c
        inner join
          sch_job j
        on
          j.job_id = c.job_id
        inner join
          v_mod_module m
        on
          m.module_id = j.module_id
        where
          c.batch_id = batch.batch_id
        order by
          c.order_by
        ) c
    )
    loop
      contentNumberCol( to_char( content.batch_content_id)) := content.content_number;
      batchContentXml := batchContentXml || '
  <content id="' || to_char( content.content_number) || '" job="' || content.job_short_name || '"'
        || case when
             content.public_flag = 1
           then
             ' module="' || content.module_name || '"'
           end
      ;
      conditionFound := false;
      for condition in (
        select
          check_batch_content_id
          , result_id
        from
          sch_condition
        where
          batch_content_id = content.batch_content_id
        order by
          check_batch_content_id
      )
      loop
        if not conditionFound then
          batchContentXml := batchContentXml || '>';
          conditionFound := true;
        end if;
        batchContentXml := batchContentXml || '
    <condition id="'
          -- ������������ ��� � ������� ����� ���� ������ ���������� job
          || to_char( contentNumberCol( to_char( condition.check_batch_content_id)))
          || '">' || resultIdToChar( condition.result_id) || '</condition>'
        ;
      end loop;
      if conditionFound then
        batchContentXml := batchContentXml || '
  </content>';
      else
        batchContentXml := batchContentXml || '/>';
      end if;
    end loop;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ �������� xml ��� �����������'
        )
      , true
    );
  end createBatchContentXml;

-- createBatchXml
begin
  select
    *
  into
    batch
  from
    sch_batch
  where
    batch_short_name = batchShortName
  ;
  createBatchContentXml();
  return
'<?xml version="1.0" encoding="Windows-1251"?>
<batch short_name="' || batch.batch_short_name || '">
  <name>' || batch.batch_name_rus || '</name>'
  ||
  case when
    batch.batch_name_eng <> 'NA'
  then
'
   <name_eng>' || batch.batch_name_eng || '</name_eng>'
  end
  ||
  case when
    coalesce( skipConfigFlag, 0) = 0
  then '
  ' || -- ������
    replace( createBatchConfigXml(
      batchShortName => batchShortName
      , separateFileFlag => 0
    ), chr(10), chr(10) || '  ')
  end
  || batchContentXml || '
</batch>'
  ;
end createBatchXml;

/* proc: unloadBatchXml
  �������� ������ ����� � XML-����.

  ���������:
  batchShortName              - �������� ������������ �����
  filePath                    - ���� � ����� ��� �������
  skipConfigFlag              - ���������� �� ��������� �����
                                ( ��-��������� ���������)
*/
procedure unloadBatchXml(
  batchShortName varchar2
  , filePath varchar2
  , skipConfigFlag number := null
)
is
  -- ����� xml
  xmlText clob;
-- unloadBatchXml
begin
  xmlText := createBatchXml(
    batchShortName => batchShortName
    , skipConfigFlag => skipConfigFlag
  );
  unloadClobToFile(
    xmlText
    , filePath
  );
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ �������� ������ ����� � XML-���� ( '
        || 'batchShortName="' || batchShortName ||'"'
        || ', filePath="' || filePath || '"'
        || ', skipConfigFlag=' || to_char( skipConfigFlag)
        || ')'
      )
    , true
  );
end unloadBatchXml;

/* func: createJobText
  �������������� ������ ������� ( job) � ��������� ������.

  ���������:
  jobId                       - id ������� ( job)
  xmlText                     - ���������� ����� xml
*/
function createJobText(
  jobId integer
)
return clob
is

  -- ������ ��� ���������� ������ job
  cursor jobCur is
    select
      job_what
      , job_name
      , description
    from
      sch_job
    where
      job_id = jobId
    ;
  -- ������ job
  job jobCur%rowtype;

-- createJob
begin
  open jobCur;
  fetch
    jobCur
  into
    job
  ;
  close jobCur;
  return
'-- ' || replace( job.job_name, chr(10), chr(10) || '-- ') || chr(10)
|| case when
     job.description is not null
     and normalizeText( job.description) <> normalizeText( job.job_name)
   then
     '-- ' || replace( normalizeText( job.description), chr(10), chr(10) || '-- ') || chr(10)
   end
|| normalizeText( job.job_what)
  ;
end createJobText;

/* proc: unloadJob(filePath)
  �������� ������ ������� ( job) � ����.

  ���������:
  jobId                       - id ������� ( job)
  filePath                    - ���� � ����� ��� ��������
*/
procedure unloadJob(
  jobId integer
  , filePath varchar2
)
is
  xmlText clob;
-- unloadJob
begin
  xmlText := createJobText(
    jobId => jobId
  );
  unloadClobToFile(
    xmlText
    , filePath
  );
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ �������� ������ ����� � XML-���� ( '
        || 'jobId=' || to_char( jobId)
        || ', filePath="' || filePath || '"'
        || ')'
      )
    , true
  );

end unloadJob;

/* proc: unloadBatch
  �������� ������ �����.

  ���������:
  batchShortNameList          - ������ �������� ������������ ������ ����� ','
  batchParentPath             - �������� ���������� ��� ������
  publicJobPath               - ���������� ��� ��������� job-��
                                � ������ �������������� ������ �����
  configPath                  - ���������� ��� �������� �������� ������
                                ��-��������� ��������� ����������� ������ �
                                ������� �����.
*/
procedure unloadBatch(
  batchShortNameList varchar2
  , batchParentPath varchar2
  , publicJobPath varchar2
  , configPath varchar2 := null
)
is

  batchIndex pls_integer := 0;
  batchShortName sch_batch.batch_short_name%type;

  /*
    �������� ������ �����.
  */
  procedure unloadBatch(
    batchPath varchar2
  )
  is
  -- unloadBatch
  begin
    checkDirectory( batchPath);
    unloadBatchXml(
      batchShortName => batchShortName
      , filePath => getFilePath( batchPath, 'batch.xml')
      , skipConfigFlag => case when configPath is not null then 1 else 0 end
    );
    checkDirectory( publicJobPath);
    for batchContent in (
      select
        j.job_id
        , j.batch_short_name
        , j.public_flag
        , j.job_short_name
      from
        sch_batch b
      inner join
        sch_batch_content c
      on
        c.batch_id = b.batch_id
      inner join
        sch_job j
      on
        j.job_id = c.job_id
        and ( j.public_flag = 0 or j.module_Id = b.module_id)
      where
        b.batch_short_name = batchShortName
    )
    loop
      if batchContent.batch_short_name is not null
        and batchContent.batch_short_name <> batchShortName
      then
        raise_application_error(
          pkg_Error.IllegalArgument
          , '� ����� ������ job, ������� �� ����� ��� ������������ ( '
            || 'batchShortName="' || batchShortName || '"'
            || ', j.batch_short_name="' || batchContent.batch_short_name || '"'
            || ')'
        );
      end if;
      unloadJob(
        jobId => batchContent.job_id
        , filePath =>
            getFilePath(
              case when
                batchContent.batch_short_name is not null
              then
                batchPath
              when
                batchContent.batch_short_name is null
                and batchContent.public_flag = 0
              then
                batchParentPath
              when
                batchContent.public_flag = 1
              then
                publicJobPath
              end
              , batchContent.job_short_name || '.job.sql'
            )
      );
    end loop;
    if configPath is not null then
      checkDirectory( getFilePath( configPath, batchShortName));
      unloadBatchConfigXml(
        batchShortName => batchShortName
        , filePath =>
            getFilePath(
              getFilePath( configPath, batchShortName)
              , 'batch_config.xml'
            )
      );
    end if;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ �������� ������ ����� ('
          || 'batchShortName="' || batchShortName || '"'
          || ', batchParentPath="' || batchParentPath || '"'
          || ', publicJobPath="' || publicJobPath || '"'
          || ', configPath="' || configPath || '"'
          || ')'
        )
      , true
    );
  end unloadBatch;

-- unloadBatch
begin
  loop
    batchIndex := batchIndex + 1;
    batchShortName := substr(
      ',' || batchShortNameList || ','
      , instr( ',' || batchShortNameList || ',', ',', 1, batchIndex) + 1
      , instr( ',' || batchShortNameList || ',', ',', 1, batchIndex + 1)
        - instr( ',' || batchShortNameList || ',', ',', 1, batchIndex)
        - 1
    );
    exit when batchShortName is null;
    -- �������� ������������� ������
    select
      batch_short_name
    into
      batchShortName
    from
      sch_batch
    where
      batch_short_name = batchShortName
    ;
    unloadBatch(
      batchPath => getFilePath( batchParentPath, batchShortName)
    );
  end loop;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ �������� ������ ����� ('
        || 'batchShortNameList="' || batchShortNameList || '"'
        || ', batchParentPath="' || batchParentPath || '"'
        || ', publicJobPath="' || publicJobPath || '"'
        || ', configPath="' || configPath || '"'
        || ')'
      )
    , true
  );
end unloadBatch;

end pkg_SchedulerLoad;
/
