-- func: opt_getLocalCryptoKey
-- Создает функцию, возвращающую ключ шифрования, используемый в текущей БД.
--
-- Замечания:
-- - ключ генерится динамически при создании функции, поэтому в случае ее
--  пересоздания расшифровать ранее зашифрованные значения настроечных
--  параметров будет невозможно;
-- - исходный код функции закодирован с помощью wrap;
-- - в случае копирования закодированного тела функции и установки ее в
--  другую БД будет возвращен другой ключ;
--

begin
  dbms_ddl.create_wrapped(
'create
-- В случае пересоздания функции расшифровать ранее зашифрованные данные будет
-- невозможно
--or replace
    function
  opt_getLocalCryptoKey
return raw
is

  -- Для AES256 Требуется 256-битный ключ
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

  -- Данные, уникальные для текущей БД ( сохраняются неизменными для копий БД,
  -- например для тестовых вариантов БД)
  objectId integer;
  createdDate date;

  -- Число, характеризующее установку
  installNumber number;

  -- Часть ключа, зависящая от установки
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
