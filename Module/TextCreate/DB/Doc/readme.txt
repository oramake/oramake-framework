title: ��������

������ ������������ ��� ������������ ��������� ������.

�����������:

- ������������ �������������� ������������ clob
	� ������ ������������ �� ������� ������
	( ��. <http://download.oracle.com/docs/cd/B28359_01/appdev.111/b28419/d_lob.htm#ARPLS600>);

������ ������������ clob:

( code)
begin
  pkg_TextCreate.newText();
  pkg_TextCreate.append( 'Hello, text!');
  pkg_Common.outputMessage(
    to_char( pkg_TextCreate.getClob())
  );
end;
/
( end code)

- ����������� ��������� ������ �� ��������, � �������;
