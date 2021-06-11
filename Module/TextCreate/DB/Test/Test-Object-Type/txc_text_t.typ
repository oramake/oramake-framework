create or replace type txc_text_t
as object
(

/* clobTable
  ��������� ������ � ���� ������� clob
*/
 clobTable txc_clob_table_t 
  
/*  buffer
  ����� ��� ���������� ������
*/
, buffer varchar2( 32767)

/*  maxBufferLength
  ������������ ����� ������ 
*/
, maxBufferLength integer

/*  maxClobLength
  ������������ ����� clob
*/
, maxClobLength integer

/*  currentClobLength
  ������� ����� clob
*/
, currentClobLength integer
  
/*  logger
  ������������ ������ ��� ������������
*/
, logger lg_logger_t  


/* txc_text_t
  ������� ������ ��������� ������ 
  ( <body::txc_text_t>).
*/
, constructor function txc_text_t(
    initMaxClobLength integer := null
  )
  return self as result

/* txc_text_t(destinationClob)
  ������� ������ ��������� ������ 
  ( <body::txc_text_t>).
*/
, constructor function txc_text_t(
    destinationClob in out nocopy clob
    , initMaxClobLength integer := null
  ) return self as result

/*  AddClob( newClob)
  ��������� � ��������������
  ����� ������� � ��������� <clobTable>
  ( <body::AddClob(newClob)>)
*/ 
, member procedure AddClob(
    newClob in out nocopy clob
  )   
  
/* AddClob 
  ��������� � ��������������
  ����� ������� � ��������� <clobTable>
*/ 
,  member procedure AddClob  

/*  CloseClob
  ��������� ��������� clob � ���������, ���� ����
  ( <body::CloseClob>)
*/
, member procedure CloseClob

/*  Finalize(destClob)
  ���������� ������������ ������.
  ���������� ����� � <GetClob>, <GetClobTable>
  ( <body::Finalize(destClob)>)
*/
, member procedure Finalize( 
    destClob in out nocopy clob
  )

/*  GetClob
  ���������� �������������� �����
  � ���� clob ( <body::GetClob>)
*/
, member function GetClob( self in out txc_text_t) 
  return clob  
  
/*  GetClobTable
  ���������� �������������� �����
  � ���� ��������� ���� <txt_clob_table_t>.
*/
, member function GetClobTable( self in out txc_text_t) 
  return txc_clob_table_t  
  
/*  Append
  ��������� ������ � ����������� �����
  ( <body::Append>)
*/ 
, member procedure Append( 
    str varchar2
  )

/*  Append(clob)
  ��������� ������ � ����������� �����
  ( <body::Append(clob)>)
*/ 
, member procedure Append( 
    str varchar2
    , destClob in out nocopy clob
  )

/* Append(func)
  ��������� ������ � ����������� �����
  ���� ����� �������� clob 
  �� ��������� <maxClobLength> � ��������� true,
  ����� ���������� false
  ( <body::Append(func)>)
*/ 
, member function Append( 
    self in out txc_text_t
    , str varchar2
  ) return boolean

/* Append(func,clob)
  ��������� ������ � ����������� �����
  ���� ����� �������� clob 
  �� ��������� <maxClobLength> � ��������� true,
  ����� ���������� false
  ( <body::Append(func,clob)>)
*/ 
, member function Append( 
    self in out txc_text_t
    , str varchar2
    , destClob in out nocopy clob
  ) return boolean
  
/* Clear 
  ������� �������������� �����
  ( <body::Clear>)
*/ 
, member procedure Clear
  
)  
/
