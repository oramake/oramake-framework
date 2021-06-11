create or replace package body pkg_TextCreate is
/* package body: pkg_TextCreate::body */

/* iconst: Max_Varchar2_Length
  Максимальный размер строки в Oracle
*/
  Max_Varchar2_Length integer := 32767;

/* ivar: buffer
  Строковый буфер для добавления
  в clob, максимальный размер которого
  ограничен <maxBufferLength>
*/
  buffer varchar2( 32767);

/* ivar: destinationClob
  Формируемый clob. Инициализируется в <newText>
*/
  destinationClob clob;

/* ivar: maxBufferLength
  Ограничение размера текстового буфера
  для оптимизации добавления в clob
*/
  maxBufferLength integer;

/* ivar: currentClobLength
  Текущая длина destinationClob.
  Переменная используется для оптимизации.
*/
  currentClobLength integer;


/* ivar: logger
  Объект для логирования
*/
  logger lg_logger_t := lg_logger_t.GetLogger(
    moduleName => Module_Name
    , objectName => 'pkg_TextCreate'
  );



/* group: Функции */



/* group: Формирование текстовых данных */

/* proc: newText
  Инициализирует новый текст для формирования

  Подробности:
    - использует dbms_lob.createtemporary
      для инициализации clob
    - открывает clob на запись
    - инициализирует переменные <currentClobLength>,
      <maxBufferLength>
    - очищает <buffer>
*/
procedure newText
is
begin
  if destinationClob is not null then
    logger.Debug( 'destinationClob.is_open=' ||
      to_char( dbms_lob.isopen( destinationClob))
    );
    -- Принудительно очищаем временный lob, т.к. Oracle
    -- его не очищает и при повторном вызове освобождение
    -- занимаемого lob'ом места не происходит, вместо этого
    -- открывается новый временный lob
    destinationClob := null;
  end if;
  dbms_lob.createtemporary( destinationClob, true);

  -- Открываем clob для записи
  dbms_lob.open( destinationClob, dbms_lob.lob_readwrite);
  currentClobLength := 0;
  buffer := null;

  -- Для оптимизации максимальный размер буфера берём по модулю
  -- dbms_lob.getChunkSize
  maxBufferLength :=
    Max_Varchar2_Length
    - mod( Max_Varchar2_Length, dbms_lob.getChunkSize( destinationClob));
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.ErrorStack(
        'Ошибка инициализации текста для формирования ('
        || 'currentClobLength=' || to_char( currentClobLength)
        || ', currentBufferSize=' || to_char( coalesce( length( buffer), 0))
        || ')'
      )
    , true
  );
end newText;

/* proc: append ( str )
  Добавление строки в текст

  Параметры:
    str - строка, при null сбрасывает содержимое буфера

  Замечание:
    - если до вызова добавления не был вызван <NewText>, то есть
      текст не был проинициализирован ранее, то генерируется
      исключение
*/
procedure append(
  str varchar2
)
is
begin
  if destinationClob is null then
    raise_application_error(
      pkg_Error.ProcessError
      , logger.ErrorStack(
         'Текст не проинициализирован. Следует вызвать функцию NewText'
        )
    );
  end if;
  Append(
    destClob => destinationClob
    , clobLength => currentClobLength
    , stringBuffer => buffer
    , maxBufferSize => maxBufferLength
    , str => str
  );
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.ErrorStack(
        'Ошибка добавления строки ('
        || 'str="'
        ||
           case when length( str) <= 1000 then
             str || '"'
           else
             substr( str, 1, 1000-3) || '"' || '...'
           end
        || ')'
      )
    , true
  );
end Append;

/* proc: append ( clob )
   Добавление clob в текст

   Параметры:
     с                         - текстовая информация в виде clob

   Замечание:
    - если до вызова добавления не был вызван <newText>, то есть
      текст не был проинициализирован ранее, то генерируется
      исключение
*/
procedure append (
  c in clob
  )
is
-- append
begin
  if destinationClob is null then
    raise_application_error(
        pkg_Error.ProcessError
      , logger.ErrorStack(
         'Текст не проинициализирован. Следует вызвать функцию newText()'
        )
      );
  end if;
  append( '' );
  dbms_lob.append(
      dest_lob => destinationClob
    , src_lob  => c
    );

exception
  when others then
    raise_application_error(
        pkg_Error.ErrorStackInfo
      , logger.errorStack(
          'Ошибка добавления clob'
          )
      , true
      );

end append;

/* func: getClob
  Получает сформированный текст в виде clob

  Параметры:
    filename                 - название файла внутри архива

  Возврат:
    - <destinationClob>

  Замечание:
    - сбрасывает буфер в <destinationClob> с помощью append('')
    - закрывает <destinationClob>,
      предварительно проверяя, открыт ли он
*/
function getClob
return clob
is

-- getClob
begin

  Append( '');

  if dbms_lob.isopen( destinationClob ) = 1 then
    dbms_lob.close( destinationClob);
  end if;

  return destinationClob;

exception
  when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.ErrorStack(
          'Ошибка получения clob ( '
          || 'currentClobLength=' || to_char( currentClobLength)
          || ', maxBufferLength=' || to_char( maxBufferLength)
          || ', buffer.length=' || to_char( length( buffer), 0)
          || ')'
        )
      , true
    );
end getClob;

/* proc: append ( destClob )
  Добавление строки в текст
  c использованием собственных переменных хранения

  Параметры:
    destClob                 - clob для формирования
    clobLength               - текущий размер clob. Передаётся для
                               оптимизации
    stringBuffer             - строковый буфер
    maxBufferSize            - максимальный размер буфера
    str                      - строка для добавления,
                               при null ( '') сбрасывает содержимое буфера
                               в clob

  Замечание:
    - destClob, clobLength, maxBufferSize должны быть
      инициализированы
*/
procedure append(
  destClob in out nocopy clob
  , clobLength in out nocopy integer
  , stringBuffer in out nocopy varchar2
  , maxBufferSize integer
  , str varchar2
)
is
  -- Длина добавляемой строки
  strLength integer := coalesce( length( str), 0);

  -- Текущая длина буфера
  currentBufferSize integer := coalesce(  length( buffer), 0);

  -- Количество циклов добавлений в lob
  cycleCount integer;

begin
  if str is null and currentBufferSize > 0 then
    -- Если явно был явно вызван сброс буфера
    dbms_lob.writeappend(
      destClob
      , currentBufferSize
      , stringBuffer
    );
    clobLength := clobLength + currentBufferSize;
    stringBuffer := null;
  elsif strLength + currentBufferSize > maxBufferSize  then
    cycleCount := trunc(( strLength + currentBufferSize)/ maxBufferLength);
    -- Итерация по кускам размера maxBufferLength конкатеннации
    -- stringBuffer || str
    for i in 1..cycleCount loop
      if i = 1 and currentBufferSize > 0 then
        -- На первой итерации учитываем буфер
        stringBuffer :=
           stringBuffer
           || substr( str, 1, maxBufferSize - currentBufferSize);
        dbms_lob.writeappend(
          destClob
          , maxBufferSize
          , stringBuffer
        );
      else
        -- На следующих итерациях идём по кускам добавляемой строки
        -- Данная часть предназначена для случаев, если длина строки
        -- превышает макс. размер буфера
        dbms_lob.writeappend(
          destClob
          , maxBufferSize
          , substr(
              str
              , maxBufferSize*(i-1) - currentBufferSize + 1
              , maxBufferSize
            )
        );
      end if;
    end loop;
    stringBuffer := substr( str
      , maxBufferSize * cycleCount - currentBufferSize + 1
    );
    clobLength := clobLength + maxBufferSize*cycleCount;
  elsif length( str) > 0 then
    stringBuffer := stringBuffer || str;
  end if;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.ErrorStack(
        'Ошибка добавления строки ('
        || 'clobLength=' || to_char( clobLength)
        || ', strLength=' || to_char( strLength)
        || ', currentBufferSize=' || to_char( currentBufferSize)
        || ', maxBufferSize=' || to_char( maxBufferSize)
        || ', cycleCount=' || to_char( cycleCount)
        || ', str="'
        ||
           case when length( str) <= 1000 then
             str || '"'
           else
             substr( str, 1, 1000-3) || '"' || '...'
           end
        || ')'
      )
    , true
  );
end append;


/* func: getZip
  Получает сформированный zip-архив. С возможностью выбора кодировки.

  Параметры:
    filename                 - название файла внутри архива
    charsetName              - наименование кодировки ( по-умолчанию кодировка БД)

  Возврат:
    destinationBlob          - blob с zip-архивом

  Замечание:
      Вызывает GetClob, т.е. предварительно выполняются все действия.
*/
function getZip(
  filename      varchar2
  , charsetName varchar2 default null
)
return blob
is

  destinationBlob blob    := null;
  sourceClob      clob    := null;

-- getZip
begin

  sourceClob := getClob();

  if sourceClob is not null then
    destinationBlob :=
      pkg_TextCreateJava.blobCompress(
        sourceBlob       =>
          convertToBlob(
            sourceClob
            , charsetName
          )
        , sourceFileName => fileName
      )
    ;
  end if;

  return destinationBlob;

exception
  when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.ErrorStack( 'Ошибка получения zip.')
      , true
    );
end getZip;


/* group: Преобразование текстовых данных */

/* func: convertToClob
  Преобразование BLOB ( большого объекта двоичных данных) в CLOB ( большого
  объекта текстовых данных). С возможностью выбора кодировки.

  Параметры:
    binaryData               - двоичные данные для преобразования
    charsetName              - наименование кодировки ( по-умолчанию кодировка БД)

  Возврат:
    resultText               - преобразованные текстовые данные
*/
function convertToClob(
  binaryData    blob
  , charsetName varchar2 default null
)
return clob
is

  -- Параметры convertToClob
  destOffset    integer := 1;
  srcOffset     integer := 1;
  warning       integer := dbms_lob.no_warning;
  langContext   integer := dbms_lob.default_lang_ctx;
  blobCharsetId integer :=
    nvl(
      nls_charset_id( charsetName)
      , dbms_lob.default_csid
    )
  ;
  resultText    clob;

-- convertToClob
begin

  dbms_lob.createTemporary( resultText, true);

  dbms_lob.convertToClob(
    dest_lob       => resultText
    , src_blob     => binaryData
    , amount       => dbms_lob.lobmaxsize
    , dest_offset  => destOffset
    , src_offset   => srcOffset
    , blob_csid    => blobCharsetId
    , lang_context => langContext
    , warning      => warning
  );

  if warning = dbms_lob.warn_inconvertible_char then
    logger.warn( 'При конвертации обнаружились неопределённые символы ( заменены на "?")');
  end if;

  return resultText;

exception
  when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack( 'Ошибка преобразования BLOB в CLOB')
      , true
    );
end convertToClob;


/* func: convertToBlob
  Преобразование СLOB ( большого объекта текстовых данных) в BLOB ( большого
  объекта двоичных данных). С возможностью выбора кодировки.

  Параметры:
    textData                 - текстовые данные для преобразования
    charsetName              - наименование кодировки ( по-умолчанию кодировка БД)

  Возврат:
    resultBlob               - преобразованные двоичные данные
*/
function convertToBlob(
  textData      clob
  , charsetName varchar2 default null
)
return blob
is

  -- Параметры convertToBlob
  destOffset    integer := 1;
  srcOffset     integer := 1;
  warning       integer := dbms_lob.no_warning;
  langContext   integer := dbms_lob.default_lang_ctx;
  blobCharsetId integer :=
    nvl(
      nls_charset_id( charsetName)
      , dbms_lob.default_csid
    )
  ;

  -- Результирующий бинарный объект
  resultBlob blob;

-- convertToBlob
begin

  dbms_lob.createTemporary( resultBlob, true);

  dbms_lob.convertToBlob(
    dest_lob       => resultBlob
    , src_clob     => textData
    , amount       => dbms_lob.lobmaxsize
    , dest_offset  => destOffset
    , src_offset   => srcOffset
    , blob_csid    => blobCharsetId
    , lang_context => langContext
    , warning      => warning
  );

  if warning = dbms_lob.warn_inconvertible_char then
    logger.warn( 'При конвертации обнаружились неопределённые символы ( заменены на "?")');
  end if;

  return
    resultBlob
  ;
exception
  when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack( 'Ошибка преобразования CLOB в BLOB')
      , true
    );
end convertToBlob;

/* func: base64Decode
  Преобразование Base64 ( большого объекта текстовых данных в кодировке
  Base64) в BLOB ( большого объекта двоичных данных).

  Входные параметры:
    textData                                  - Данные в Base64

  Возврат:
    resultBlob                                - Результирующий blob
*/
function base64Decode(
  textData      clob
)
return blob
is
  offset        integer := 1;
  bufferSize    binary_integer := 48;
  bufferVarchar varchar2(48);
  bufferRaw     raw(48);

  -- Результирующий бинарный объект
  resultBlob blob;

-- base64Decode
begin
  dbms_lob.createTemporary( resultBlob, true);

  for i in 1..ceil( coalesce( dbms_lob.getlength( textData), 0) / bufferSize) loop
    dbms_lob.read( textData, bufferSize, offset, bufferVarchar);
    bufferRaw := utl_encode.base64_decode( utl_raw.cast_to_raw( bufferVarchar));
    dbms_lob.writeappend( resultBlob, utl_raw.length( bufferRaw), bufferRaw);
    offset := offset + bufferSize;
  end loop;

  return resultBlob;
exception
  when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.ErrorStack(
          'Во время декодирования Base64 произошла ошибка.'
        )
      , true
    );
end base64Decode;

/* func: base64Encode
  Преобразование BLOB ( большого объекта двоичных данных)
  в Base64 ( большого объекта текстовых данных в кодировке Base64).

  Входные параметры:
    binaryData                                - Двоичные данные для преобразования

  Возврат:
    resultClob                                - Результирующий clob
*/
function base64Encode(
  binaryData    blob
)
return clob
is
  amount         integer := 23826;
  offset         integer := 1;
  bufferRaw      raw(32767);
  bufferVarchar  varchar2(32767);
  fileLength     integer := dbms_lob.getlength( binaryData);

  -- Результирующий clob объект
  resultClob clob;

-- base64Encode
begin
  dbms_lob.createtemporary( resultClob, true);

  while offset <= fileLength loop
    dbms_lob.read( binaryData, amount, offset, bufferRaw);
    offset := offset + amount;
    bufferVarchar := utl_raw.cast_to_varchar2( utl_encode.base64_encode( bufferRaw));
    bufferVarchar := replace( bufferVarchar, chr( 13) || chr( 10));
    dbms_lob.writeappend( resultClob, length( bufferVarchar), bufferVarchar);
  end loop;

  return resultClob;
exception
  when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.ErrorStack(
          'Во время шифрования в Base64 произошла ошибка.'
        )
      , true
    );
end base64Encode;

end pkg_TextCreate;
/
