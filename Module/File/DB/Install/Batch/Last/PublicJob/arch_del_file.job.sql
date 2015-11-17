-- ������������� � �������� �����
-- ���������� ���� � ������� � ��������� ������.
--
-- ���������:
-- SourceFullFileName            - ������ ���� � ��������� �����
-- ArchivePath                   - ���� ��� �������������
-- ArchiveFileName               - ��� ����� ��� �������������
--                                 ( �� ��������� ����������� �� �������
--                                  to_char( sysdate, 'YYYYMMDD_HH24MiSS') +
--                                  '_ARCH_' + SourceFileName
--                                 )
-- SourceFileName                - ��� ��������� �����
--                                 ( ��������� ������ ���� �� �����
--                                 ArchiveFileName)
--
declare

  -- ������ ���� � ��������� �����
  sourceFile varchar2(1024) :=
    pkg_Scheduler.getContextString(
      'SourceFullFileName'
      , riseException => 1
    )
  ;

  -- ���� ��� �������������
  archPath varchar2(1024) :=
    pkg_Scheduler.getContextString(
      'ArchivePath'
      , riseException => 1
    )
  ;

  -- ��� ����� ��� �������������
  archFileName varchar2(1024) :=
    pkg_Scheduler.getContextString( 'ArchiveFileName')
  ;

begin
  if archFileName is null then
    archFileName :=
      to_char( sysdate, 'YYYYMMDD_HH24MiSS')
      || '_ARCH_'
      || pkg_Scheduler.getContextString(
          'SourceFileName'
          , riseException => 1
        )
    ;
  end if;
  archPath := pkg_File.getFilePath( archPath, archFileName);
  pkg_File.fileMove(
    fromPath    => sourceFile
    , toPath    => archPath
    , overwrite => 0
  );
  jobResultMessage := '���� ���������� � "' || archPath || '" � ������.';
end;
