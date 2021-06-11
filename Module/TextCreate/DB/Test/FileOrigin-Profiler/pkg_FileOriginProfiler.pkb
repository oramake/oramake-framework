create or replace package body pkg_FileOriginProfiler is

UnloadDataBuf_Size constant integer := 32767;

UnloadDataLob_MaxLength constant integer := 1000000000;

UnloadDataLob clob := null;

UnloadDataBuf varchar2(32767) := null;

UnloadWriteSize integer := null;

UnloadDataLobLength integer;

  logger lg_logger_t := lg_logger_t.GetLogger(
    moduleName => 'TextCreate'
    , objectName => 'pkg_FileOriginProfiler'
  );

procedure AppendUnloadData(
  str varchar2 := null
)
is

  len integer := nvl( length( str), 0);
  bufLen integer := nvl( length( unloadDataBuf), 0);
  addLen integer;
  oldUnloadDataLob integer :=  unloadDataLobLength;
  oldBufLen integer := bufLen;


  procedure OpenLob is
  --Создает LOB для выгружаемых данных.

                                        --ID временного документа
    docID doc_output_document.output_document_id%type;

  --OpenLob
  begin
    insert into doc_output_document     --Создаем новый документ
    (
      output_document
    )
    values
    (
      empty_clob()
    )
    returning output_document_id into docID;
    select                              --Получаем LOB нового документа
      output_document
    into unloadDataLob
    from
      doc_output_document
    where
      output_document_id = docID
    ;
                                        --Открываем LOB для записи
    dbms_lob.open( unloadDataLob, dbms_lob.lob_readwrite);
                                        --Определяем оптимальный размер
                                        --для записи в LOB
    unloadWriteSize := UnloadDataBuf_Size
      - mod( UnloadDataBuf_Size, dbms_lob.getChunkSize( unloadDataLob));
    pkg_Common.OutputMessage( 'unloadWriteSize=' || unloadWriteSize);  
    unloadDataLobLength := 0;
  end OpenLob;



  procedure CloseLob is
  --Закрывает LOB.
  begin
    dbms_lob.close( unloadDataLob);
    unloadDataLob := null;
    unloadDataLobLength := null;
  end CloseLob;



--AppendUnloadData
begin
  if len > 0 or bufLen > 0 then
                                        --Закрываем LOB, если достигается
                                        --ограничение по максимальной длине
    if unloadDataLobLength > 0
        and unloadDataLobLength + coalesce( len, 0) + coalesce( bufLen, 0)
         > UnloadDataLob_MaxLength
        then
      CloseLob;
    end if;
                                        --Открываем LOB, если его еще нет
    if unloadDataLob is null then
      OpenLob;
    end if;
    if len > 0 and bufLen + len < unloadWriteSize then
                                        --Добавляем данные в буфер
      unloadDataBuf := unloadDataBuf || str;
    else
                                        --Добавляем в LOB содержимое буфера
      addLen := greatest( least( unloadWriteSize - bufLen, len), 0);
      if addLen > 0 then
        unloadDataBuf := unloadDataBuf || substr( str, 1, addLen);
        bufLen := bufLen + addLen;
      end if;
      logger.Debug( 'bufLen=' || to_char( bufLen));
      if bufLen > 0 then 
        dbms_lob.writeAppend(
          unloadDataLob
          , bufLen
          , unloadDataBuf
        );
      end if;  
      unloadDataBuf := substr( str, 1 + addLen);
/*      if length( unloadDataBuf) > unloadWriteSize then
        raise_application_error(
          pkg_Error.ProcessError
          , logger.ErrorStack( 'Неверная длина буфера')
        );        
      end if;*/
      unloadDataLobLength := unloadDataLobLength + bufLen;
    end if;
  end if;
                                        --Закрываем LOB если вызов с null
  if str is null and unloadDataLob is not null then
    CloseLob;
  end if;
  
  if unloadDataLobLength <> dbms_lob.getlength( unloadDataLob) then
    raise_application_error(
      pkg_Error.ProcessError
      , logger.ErrorStack( 'Неверная длина clob')
    );
  end if;
  
  if oldUnloadDataLob + oldBufLen + len  
    <> unloadDataLobLength +  nvl( length( unloadDataBuf), 0)
  then
    raise_application_error(
      pkg_Error.ProcessError
      , logger.ErrorStack( 'Неверная длина clob и буфера')
    );  
  end if;   
exception when others then   
  raise_application_error(
    pkg_Error.ProcessError
    , logger.ErrorStack( 'Ошибка добавления строки('
        || 'oldUnloadDataLob=' || to_char( oldUnloadDataLob)
        || ', oldBufLen=' || to_char( oldBufLen)
        || ', unloadWriteSize=' || to_char( unloadWriteSize)
        || ', len=' || to_char( len)
        || ', unloadDataLobLength=' || to_char( unloadDataLobLength)
        || ', addLen=' || to_char( addLen)
        || ', nvl( length( unloadDataBuf), 0)=' 
        || to_char( nvl( length( unloadDataBuf), 0))
        || ')'
      )
    , true  
  );
end AppendUnloadData;


procedure DeleteUnloadData
is
begin
  UnloadDataLob := null;
  delete from doc_output_document;
end DeleteUnloadData;




end pkg_FileOriginProfiler;
/
