create or replace type txc_text_t
as object
(

/* clobTable
  Текстовые данные в виде массива clob
*/
 clobTable txc_clob_table_t 
  
/*  buffer
  Буфер для добавления данных
*/
, buffer varchar2( 32767)

/*  maxBufferLength
  Максимальная длина буфера 
*/
, maxBufferLength integer

/*  maxClobLength
  Максимальная длина clob
*/
, maxClobLength integer

/*  currentClobLength
  Текущая длина clob
*/
, currentClobLength integer
  
/*  logger
  Интерфейсный объект для логгирования
*/
, logger lg_logger_t  


/* txc_text_t
  Создает объект текстовых данных 
  ( <body::txc_text_t>).
*/
, constructor function txc_text_t(
    initMaxClobLength integer := null
  )
  return self as result

/* txc_text_t(destinationClob)
  Создает объект текстовых данных 
  ( <body::txc_text_t>).
*/
, constructor function txc_text_t(
    destinationClob in out nocopy clob
    , initMaxClobLength integer := null
  ) return self as result

/*  AddClob( newClob)
  Добавляет и инициализирует
  новый элемент в коллекцию <clobTable>
  ( <body::AddClob(newClob)>)
*/ 
, member procedure AddClob(
    newClob in out nocopy clob
  )   
  
/* AddClob 
  Добавляет и инициализирует
  новый элемент в коллекции <clobTable>
*/ 
,  member procedure AddClob  

/*  CloseClob
  Закрываем последний clob в коллекции, если есть
  ( <body::CloseClob>)
*/
, member procedure CloseClob

/*  Finalize(destClob)
  Завершение формирования текста.
  Вызывается также в <GetClob>, <GetClobTable>
  ( <body::Finalize(destClob)>)
*/
, member procedure Finalize( 
    destClob in out nocopy clob
  )

/*  GetClob
  Возвращает сформированный текст
  в виде clob ( <body::GetClob>)
*/
, member function GetClob( self in out txc_text_t) 
  return clob  
  
/*  GetClobTable
  Возвращает сформированный текст
  в виде коллекции типа <txt_clob_table_t>.
*/
, member function GetClobTable( self in out txc_text_t) 
  return txc_clob_table_t  
  
/*  Append
  Добавляет строку в формируемый текст
  ( <body::Append>)
*/ 
, member procedure Append( 
    str varchar2
  )

/*  Append(clob)
  Добавляет строку в формируемый текст
  ( <body::Append(clob)>)
*/ 
, member procedure Append( 
    str varchar2
    , destClob in out nocopy clob
  )

/* Append(func)
  Добавляет строку в формируемый текст
  если длина текущего clob 
  не превышает <maxClobLength> и возращает true,
  иначе возвращает false
  ( <body::Append(func)>)
*/ 
, member function Append( 
    self in out txc_text_t
    , str varchar2
  ) return boolean

/* Append(func,clob)
  Добавляет строку в формируемый текст
  если длина текущего clob 
  не превышает <maxClobLength> и возращает true,
  иначе возвращает false
  ( <body::Append(func,clob)>)
*/ 
, member function Append( 
    self in out txc_text_t
    , str varchar2
    , destClob in out nocopy clob
  ) return boolean
  
/* Clear 
  Очищает сформированный текст
  ( <body::Clear>)
*/ 
, member procedure Clear
  
)  
/
