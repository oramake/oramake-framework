begin
  -- �������� ������ ��� ��������� �����
  pkg_Mail.sendMail(
    sender                  =>
          pkg_Common.getMailAddressSource( pkg_Mail.Module_Name)
    , recipient             => pkg_Common.getMailAddressDestination()
    , subject               => '����'
    , messageText           =>
        '�������� ���������'
    , attachmentFileName    => null
    , attachmentType        => null
    , attachmentData        => null
  );
end;
/
