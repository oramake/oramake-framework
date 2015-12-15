-- Удаление почтовых сообщений с истекшим сроком жизни
declare

                                        --Число удаленных сообщений
  nDeleted integer;

begin
  nDeleted := pkg_MailHandler.ClearExpiredMessage(
    checkDate => trunc( sysdate)
  );
  jobResultMessage := 'Удалено ' || to_char( nDeleted) || ' сообщени(е,й).';
end;