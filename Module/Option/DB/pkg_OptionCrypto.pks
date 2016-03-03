create or replace package pkg_OptionCrypto is
/* package: pkg_OptionCrypto
  Функции шифрования значений параметров.

  SVN root: Oracle/Module/Option
*/



/* group: Функции */

/* pfunc: isCryptoAvailable
  Возвращает флаг возможности использования функций шифрования.

  Возврат:
  1 если функции доступны, иначе 0.

  ( <body::isCryptoAvailable>)
*/
function isCryptoAvailable
return integer;

/* pfunc: encrypt
  Возвращает зашифрованное значение.

  Параметры:
  inputString                 - входная строка
  forbiddenChar               - запрещенный для использования в зашифрованном
                                значении символ
                                ( по умолчанию без ограничений)

  Возврат:
  зашифрованная строка.

  ( <body::encrypt>)
*/
function encrypt(
  inputString varchar2
  , forbiddenChar varchar2 := null
)
return varchar2;

/* pfunc: decrypt
  Возвращает расшифрованное значение.

  Параметры:
  inputString                 - входная строка

  Возврат:
  расшифрованная строка.

  ( <body::decrypt>)
*/
function decrypt(
  inputString varchar2
)
return varchar2;

end pkg_OptionCrypto;
/
