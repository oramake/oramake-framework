declare

  etalonString varchar2(1000) :=
    '�����������, �����, ������� / ������������� ����';

  /*
    ������������ ����������.
  */
  procedure checkDistance(
    target varchar2
  )
  is
  begin
    pkg_Common.outputMessage(
      '"' || target || '": '
      ||
      to_char(
        pkg_TextUtilityTest.normalizeAndLevenstein(
          source => etalonString
          , target => target
        )
     )
    );
  end checkDistance;

begin
  pkg_Common.outputMessage( '...');
  pkg_Common.outputMessage( 'Distance to "' || etalonString || '"');
  pkg_Common.outputMessage( '...');
  checkDistance( '����������� / ����� / ������� / ���������� / ����� / ����������� / �������');
  checkDistance( '����������� / ����� / ������� / ���������� / ���� / ���������� ��������/ �������� �����');
  checkDistance( '���������');
  checkDistance( '��������� 1�');
  etalonString := '/���/�����������';
  pkg_Common.outputMessage( '...');
  pkg_Common.outputMessage( 'Distance to "' || etalonString || '"');
  pkg_Common.outputMessage( '...');
  checkDistance( '/���/�������������/�����');
  checkDistance( '/���/����������� ����������������/���������');
end;
/
