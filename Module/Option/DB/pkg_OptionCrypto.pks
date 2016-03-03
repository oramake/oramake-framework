create or replace package pkg_OptionCrypto is
/* package: pkg_OptionCrypto
  ������� ���������� �������� ����������.

  SVN root: Oracle/Module/Option
*/



/* group: ������� */

/* pfunc: isCryptoAvailable
  ���������� ���� ����������� ������������� ������� ����������.

  �������:
  1 ���� ������� ��������, ����� 0.

  ( <body::isCryptoAvailable>)
*/
function isCryptoAvailable
return integer;

/* pfunc: encrypt
  ���������� ������������� ��������.

  ���������:
  inputString                 - ������� ������
  forbiddenChar               - ����������� ��� ������������� � �������������
                                �������� ������
                                ( �� ��������� ��� �����������)

  �������:
  ������������� ������.

  ( <body::encrypt>)
*/
function encrypt(
  inputString varchar2
  , forbiddenChar varchar2 := null
)
return varchar2;

/* pfunc: decrypt
  ���������� �������������� ��������.

  ���������:
  inputString                 - ������� ������

  �������:
  �������������� ������.

  ( <body::decrypt>)
*/
function decrypt(
  inputString varchar2
)
return varchar2;

end pkg_OptionCrypto;
/
