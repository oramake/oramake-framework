create or replace package body pkg_ContextSearchUtility is
/* package body: pkg_ContextSearchUtility::body */



/* group: ���������� */

/* ivar: logger
  ����� ������.
*/
logger lg_logger_t := lg_logger_t.getLogger(
  moduleName    => 'TextService'
  , objectName  => 'pkg_ContextSearchUtility'
);



/* group: ������� */

/* func: normalizeSearchPhrase
  ������������ ������ ������������ ������.

  ���������:
  searchPhrase                - ������ ������������ ������

  �������:
  - ��������������� ������;

  ����������:
  - ���� ������ ��������� � ������� ( ��������� ��� �������), ��
    ������� � ������ � � ����� ��������� � ������������ ���������� ������
    ��� ����;
  - ����� ��� ����������� ������� ( ��� �������, ����� �������, �������, ����
    � ����) ���������� �� �������; ��������� ������� ������ ��� ���������
    �������� ������ ���������� �� ��������������� ���� ������;

  ���������:
  - �������� � ������� ���������� � �������
    <Test/normalize-search-phrase.sql>;
*/
function normalizeSearchPhrase(
  searchPhrase varchar2
)
return varchar2
is
-- normalizeSearchPhrase
begin
  if searchPhrase like '"%"' or searchPhrase like '''%''' then
    return substr( searchPhrase, 2, length( searchPhrase) - 2);
  else
    return
      regexp_replace(
      regexp_replace(
        -- ��� ������� ����� ����, ����, ������� �������� �� �������
        regexp_replace( searchPhrase, '[^[:alnum:]^,^ ]', ' ')
        -- ������� ������������� ������� � �������
        , '([ ])+', '\1'
      )
        , '([,])+', '\1'
      );
  end if;
end normalizeSearchPhrase;

end pkg_ContextSearchUtility;
/
