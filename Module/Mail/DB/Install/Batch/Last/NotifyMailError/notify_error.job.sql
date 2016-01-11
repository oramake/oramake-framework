-- Нотификация по ошибкам работы с почтой
-- Нотификация по ошибкам работы с почтой.
-- 
-- SendLimitMinute               - лимит отправки сообщений в минутах
declare
                                        --Лимит отправки сообщений в минутах
  sendLimitMinute integer := pkg_Scheduler.GetContextInteger(
    'SendLimitMinute'
  );
                                        --Число ошибок
  nError integer;

begin
  nError := pkg_MailHandler.NotifyError(
    sendLimit => numtodsinterval( sendLimitMinute, 'MINUTE')
  );
                                        --Устанавливаем результат выполнения
  jobResultMessage :=
    'Проверка выполнена ( ' || to_char( nError) || ' ошибок).'
  ;
end;