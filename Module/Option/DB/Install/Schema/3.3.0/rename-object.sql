alter table
  opt_option_new
rename to
  opt_option
/

alter index
  opt_option_new_pk
rename to
  opt_option_pk
/

alter table
  opt_option
rename constraint
  opt_option_new_pk
to
  opt_option_pk
/

-- предварительно компилируем для исключения в Oracle 12.1.0.1.0 ошибки
-- ORA-00600: internal error code, arguments: [kotaty805], [OPT_OPTION], [],
-- [], [], [], [], [], [], [], [], []
--
@oms-compile-invalid

alter trigger
  opt_option_new_bi_define
rename to
  opt_option_bi_define
/

alter trigger
  opt_option_new_bu_history
rename to
  opt_option_bu_history
/

drop view
  v_opt_option_new
/
@oms-run Install/Schema/Last/v_opt_option.vw



declare

  isOldExists integer;

  startValue integer;

begin
  select
    count(*)
  into isOldExists
  from
    user_sequences sq
  where
    sq.sequence_name = 'OPT_OPTION_VALUE_SEQ'
  ;
  if isOldExists = 1 then
    execute immediate
      'begin :startValue := opt_option_value_seq.nextval; end;'
    using
      out startValue
    ;
    execute immediate '
create sequence
  opt_value_seq
nomaxvalue
nominvalue
nocycle
start with ' || startValue
    ;
    execute immediate
      'drop sequence opt_option_value_seq'
    ;
    dbms_output.put_line(
      'opt_value_seq created with value: ' || startValue
    );
  end if;
end;
/
