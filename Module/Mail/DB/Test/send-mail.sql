begin
  -- �������� ������ ��� ��������� �����
  pkg_Mail.sendMail(
    sender                  =>
          pkg_Common.getMailAddressSource( pkg_MailBase.Module_Name)
    , recipient             => pkg_Common.getMailAddressDestination()
    , subject               => '����'
    , messageText           =>
        '�������� ���������'
    , attachmentFileName    => null
    , attachmentType        => null
    , attachmentData        => null
    , smtpServer            => null
    , username              => null
    , password              => null
    , isHtml                => null
  );
end;
/
