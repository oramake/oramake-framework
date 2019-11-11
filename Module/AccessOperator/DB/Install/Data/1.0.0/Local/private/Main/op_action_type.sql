-- script: Install/Data/1.0.0/Local/private/Main/op_action_type.sql
-- ��������� ��������� ������ � ������� <op_action_type>


merge into
  op_action_type dst
using
  (
  select
    t.action_type_code
    , t.action_type_name_rus
    , t.action_type_name_en
    , t.action_type_comment
  from
    (
    select
      'CREATEOPERATOR' as action_type_code
      , '�������� ���������' as action_type_name_rus
      , 'Create operator' as action_type_name_en
      , '�������� ���������' as action_type_comment
    from
      dual
    union all
    select
      'CREATEOPERATORROLE' as action_type_code
      , '������ ���� ���������' as action_type_name_rus
      , 'Add role to operator' as action_type_name_en
      , '���������� ������ �������' as action_type_comment
    from
      dual
    union all
    select
      'DELETEOPERATORROLE' as action_type_code
      , '�������� ���� � ���������' as action_type_name_rus
      , 'Remove role from operator' as action_type_name_en
      , '�������� ������ �������' as action_type_comment
    from
      dual
    union all
    select
      'CREATEOPERATORGROUP' as action_type_code
      , '������ ������ ���������' as action_type_name_rus
      , 'Add group to operator' as action_type_name_en
      , '���������� ������ �������' as action_type_comment
    from
      dual
    union all
    select
      'DELETEOPERATORGROUP' as action_type_code
      , '�������� ������ � ���������' as action_type_name_rus
      , 'Remove group from operator' as action_type_name_en
      , '�������� ������ �������' as action_type_comment
    from
      dual
    union all
    select
      'CREATEGROUPROLE' as action_type_code
      , '���������� ���� � ������' as action_type_name_rus
      , 'Add role to group' as action_type_name_en
      , '���������� ������ �������' as action_type_comment
    from
      dual
    union all
    select
      'DELETEGROUPROLE' as action_type_code
      , '�������� ���� �� ������' as action_type_name_rus
      , 'Remove role from group' as action_type_name_en
      , '�������� ������ �������' as action_type_comment
    from
      dual
    union all
    select
      'CHANGEPASSWORD' as action_type_code
      , '��������� ������' as action_type_name_rus
      , 'Change password' as action_type_name_en
      , '��������� ������' as action_type_comment
    from
      dual
    union all
    select
      'BLOCKOPERATOR' as action_type_code
      , '������������ ���������' as action_type_name_rus
      , 'Blocking operator' as action_type_name_en
      , '������������ ���������' as action_type_comment
    from
      dual
    union all
    select
      'UNBLOCKOPERATOR' as action_type_code
      , '������������� ���������' as action_type_name_rus
      , 'Unblocking operator' as action_type_name_en
      , '������������� ���������' as action_type_comment
    from
      dual
    union all
    select
      'AUTOBLOCKOPERATOR' as action_type_code
      , '�������������� ���������' as action_type_name_rus
      , 'Auto blocking operator' as action_type_name_en
      , '�������������� ���������' as action_type_comment
    from
      dual
    union all
    select
      'CHANGEPERSONALDATA' as action_type_code
      , '��������� ������������ ������ ���������' as action_type_name_rus
      , 'Change personal data' as action_type_name_en
      , '��������� ������������ ������ ���������' as action_type_comment
    from
      dual
    ) t
  minus
  select
    act.action_type_code
    , act.action_type_name_rus
    , act.action_type_name_en
    , act.action_type_comment
  from
    op_action_type act
  ) src
on
  ( dst.action_type_code = src.action_type_code )
when matched then
  update set
    dst.action_type_name_rus = src.action_type_name_rus
    , dst.action_type_name_en = src.action_type_name_en
    , dst.action_type_comment = src.action_type_comment
when not matched then
  insert(
    dst.action_type_code
    , dst.action_type_name_rus
    , dst.action_type_name_en
    , dst.action_type_comment
    , dst.operator_id
  )
  values(
    src.action_type_code
    , src.action_type_name_rus
    , src.action_type_name_en
    , src.action_type_comment
    , 1
  )
/

commit
/
