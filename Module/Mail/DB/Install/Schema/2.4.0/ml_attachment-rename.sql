-- �������� ������� �����������
@oms-drop-foreign-key ml_attachment
-- ��������
drop trigger ml_attachment_bi_define
;


-- �������������� �������
alter table
  ml_attachment
rename to
  ml_attachment_2_4_0
;

alter table
  ml_attachment_2_4_0
drop constraint ml_attachment_pk
;

-- �������
drop index
  ml_attachment_ix_message_id
;

-- �������� ��������������� ������� �� ���� ������� ������
create index ml_attachment_2_4_0_date_ins on ml_attachment_2_4_0 (
   date_ins
) tablespace &indexTablespace
;

create index ml_attachment_2_4_0_ix_mess_id on ml_attachment_2_4_0 (
   message_id
) tablespace &indexTablespace
;
