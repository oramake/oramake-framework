-- func: opt_getLocalCryptoKey
-- ������� �������, ������������ ���� ����������, ������������ � ������� ��.
--
-- ���������:
-- - ���� ��������� ����������� ��� �������� �������, ������� � ������ ��
--  ������������ ������������ ����� ������������� �������� �����������
--  ���������� ����� ����������;
-- - �������� ��� ������� ����������� � ������� wrap;
-- - � ������ ����������� ��������������� ���� ������� � ��������� �� �
--  ������ �� ����� ��������� ������ ����;
--

begin
  dbms_ddl.create_wrapped(
'create
-- � ������ ������������ ������� ������������ ����� ������������� ������ �����
-- ����������
--or replace
    function
  opt_getLocalCryptoKey
return raw
is

  -- ��� AES256 ��������� 256-������ ����
  keyBase varchar2(64) :=
    ''7DF3819A7BC11CC0''
    || '''
      || substr( rawtohex( utl_raw.cast_from_binary_integer(
          floor( dbms_random.value( 0, 65536)
         ))), -4)
      || substr( rawtohex( utl_raw.cast_from_binary_integer(
          floor( dbms_random.value( 0, 65536)
         ))), -4)
      || substr( rawtohex( utl_raw.cast_from_binary_integer(
          floor( dbms_random.value( 0, 65536)
         ))), -4)
      || substr( rawtohex( utl_raw.cast_from_binary_integer(
          floor( dbms_random.value( 0, 65536)
         ))), -4)
      || '''
    || '''
      || substr( rawtohex( utl_raw.cast_from_binary_integer(
          floor( dbms_random.value( 0, 65536)
         ))), -4)
      || substr( rawtohex( utl_raw.cast_from_binary_integer(
          floor( dbms_random.value( 0, 65536)
         ))), -4)
      || substr( rawtohex( utl_raw.cast_from_binary_integer(
          floor( dbms_random.value( 0, 65536)
         ))), -4)
      || substr( rawtohex( utl_raw.cast_from_binary_integer(
          floor( dbms_random.value( 0, 65536)
         ))), -4)
      || '''
    || ''57BE3999AAF0913D''
  ;

  -- ������, ���������� ��� ������� �� ( ����������� ����������� ��� ����� ��,
  -- �������� ��� �������� ��������� ��)
  objectId integer;
  createdDate date;

  -- �����, ��������������� ���������
  installNumber number;

  -- ����� �����, ��������� �� ���������
  installKeyPart varchar2(4);

begin
  execute immediate ''
select
  t.object_id
  , t.created
from
  user_objects t
where
  t.object_name = :objectName
''
  into
    objectId
    , createdDate
  using
    in ''OPT_GETLOCALCRYPTOKEY''
  ;
  installNumber := dbms_utility.get_hash_value(
    name          =>
        to_char( objectId)
        || ''TmpJkst-salt''
        || to_char( createdDate, ''dd.mm yyyy hh24 "SDaBB" mi:ss'')
    , base        => 0
    , hash_size   => 65536
  );
  installKeyPart :=
    substr( rawtohex( utl_raw.cast_from_binary_integer( installNumber)), -4)
  ;
  return
    hextoraw(
      substr( keyBase, 1, 16)
      || substr( keyBase, 1 + 16, 16 - 2)
      || substr( installKeyPart, 1, 2)
      || substr( keyBase, 1 + 32, 16 - 2)
      || substr( installKeyPart, 1, 2)
      || substr( keyBase, 1 + 48, 16)
    )
  ;
end;
'
  );
end;
/
