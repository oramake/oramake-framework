-- script: Install/Config/Local/get-saved-value.sql
-- Получение значения парметра *JOB_QUEUE_PROCESSES*, сохраненного в начале установки

define savingViewName = "&1"
define destinationName = "&2"
define &destinationName = ""

column "getSavedColumn" new_value &destinationName format A30

var temporaryVar varchar2( 30 )

begin
  if '&savingViewName' is not null then
    execute immediate 
'select 
  *
from    
  &savingViewName 
'
    into 
      :temporaryVar;
  else 
    :temporaryVar := null;
  end if;
exception when others then 
  -- If table or view does not exist
  if SQLCode = -942 then
    :temporaryVar := null;
  else 
    raise;
  end if;
end;
/ 
select 
  :temporaryVar as "getSavedColumn"
from
  dual
/
column "getSavedColumn" clear
