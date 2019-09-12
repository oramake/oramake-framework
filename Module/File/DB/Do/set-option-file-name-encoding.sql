-- script: Do/set-option-file-name-encoding.sql
-- ��������� ����� <pkg_FileBase.FileNameEncoding_OptSName>;
--
declare
  optionList opt_option_list_t :=
    opt_option_list_t(pkg_FileOrigin.Module_Name);
begin
  if optionList.existsOption(pkg_FileBase.FileNameEncoding_OptSName) = 0 then
    optionList.createOption(
      optionShortName => pkg_FileBase.FileNameEncoding_OptSName
    , optionName => '��������� ��� ������, ���������� �� ������������ �������'
    , valueTypeCode => pkg_OptionMain.String_ValueTypeCode
    );
  end if;
  optionList.setString(pkg_FileBase.FileNameEncoding_OptSName, 'Windows-1252');
end;
/
