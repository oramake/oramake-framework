-- trigger: opt_option_bu_history
-- ��� ��������� ������ � <opt_option> ��������� ������������ ������ ��
-- ������� ������� � <opt_option_history>.
create or replace trigger opt_option_bu_history
  before update
  on opt_option
  for each row
declare

  -- ������ ������ � ���� ������
  hs opt_option_history%rowtype;

begin

  -- �������� ������������ ����������� �����
  if :new.module_id <> :old.module_id
      or coalesce(
          :new.object_short_name != :old.object_short_name
          , coalesce( :new.object_short_name, :old.object_short_name)
            is not null
        )
      or coalesce(
          :new.object_type_id != :old.object_type_id
          , coalesce( :new.object_type_id, :old.object_type_id)
            is not null
        )
      or :new.option_short_name <> :old.option_short_name
      then
    raise_application_error(
      pkg_Error.ProcessError
      , '��������� �������� �������� ����� ����������� �����'
        || ' ( module_id, object_short_name, option_short_name)'
        || ' � ���� object_type_id.'
    );
  end if;

  -- ���������� �������� ��������� ���� Id ��������� �� ��� ����� ����
  if not updating( 'change_operator_id') or :new.change_operator_id is null
      then
    :new.change_operator_id := pkg_Operator.getCurrentUserId();
  end if;

  -- ��������� ����� ���������� ������
  :new.change_date := sysdate;

  -- ����������� ������� ����������
  :new.change_number := :old.change_number + 1;

  -- ��������� ���� � �������
  hs.option_id                      := :old.option_id;
  hs.module_id                      := :old.module_id;
  hs.object_short_name              := :old.object_short_name;
  hs.object_type_id                 := :old.object_type_id;
  hs.option_short_name              := :old.option_short_name;
  hs.value_type_code                := :old.value_type_code;
  hs.value_list_flag                := :old.value_list_flag;
  hs.encryption_flag                := :old.encryption_flag;
  hs.test_prod_sensitive_flag       := :old.test_prod_sensitive_flag;
  hs.access_level_code              := :old.access_level_code;
  hs.option_name                    := :old.option_name;
  hs.option_description             := :old.option_description;

  -- ������������� ��������� ����
  hs.deleted                        := :old.deleted;
  hs.change_number                  := :old.change_number;
  hs.change_date                    := :old.change_date;
  hs.change_operator_id             := :old.change_operator_id;
  hs.base_date_ins                  := :old.date_ins;
  hs.base_operator_id               := :old.operator_id;
  hs.date_ins                       := :new.change_date;
  hs.operator_id                    := :new.change_operator_id;

  -- ��������� ������ ������
  select
    opt_option_history_seq.nextval
  into
    hs.option_history_id
  from
    dual
  ;
  insert into opt_option_history values hs;
end;
/
