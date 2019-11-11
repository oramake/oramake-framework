-- script: Install/Data/3.7.0/opt_option.sql
-- Установка опций hash salt 

declare
  hashSalt varchar2(50) := dbms_random.string( 'a', 50 );
  
  optionList opt_option_list_t := opt_option_list_t(
    moduleName => pkg_Operator.Module_Name
  );
begin
  optionList.addString(
    optionShortName => pkg_Operator.HashSalt_OptSName
    , optionName => '"Соль" хэша пароля'
    , encryptionFlag => 1  
    , stringValue => hashSalt
    , operatorId => pkg_Operator.getCurrentUserId()
  );
end;
/

commit
/