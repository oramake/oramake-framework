--view: v_ml_attachment
--������������� ��� ��������� ����������
--� ���������
create or replace force view v_ml_attachment
(
  attachment_id
  , message_id
  , file_name
  , content_type
  , attachment_data_length
  , date_ins
  , operator_id
  , is_image_content_id
)
as
select
  /* SVN root: Exchange/Module/Mail */
  atc.attachment_id as attachment_id
  , atc.message_id as message_id
  , atc.file_name as file_name
  , atc.content_type as content_type
  , dbms_lob.getlength( atc.attachment_data) as attachment_data_length
  , atc.date_ins as date_ins
  , atc.operator_id as operator_id
  , atc.is_image_content_id 
from
  ml_attachment atc
/
comment on table v_ml_attachment is
'������������� ��� ��������� ����������
� ���������
[ SVN root: Exchange/Module/Mail ]'
/
comment on column v_ml_attachment.attachment_id is
'ID ��������';

comment on column v_ml_attachment.message_id is
'ID ���������';

comment on column v_ml_attachment.file_name is
'��� �����';

comment on column v_ml_attachment.content_type is
'��� �����������';

comment on column v_ml_attachment.attachment_data_length is
'������ ������ ��������';

comment on column v_ml_attachment.date_ins is
'���� ���������� ������';

comment on column v_ml_attachment.operator_id is
'ID ���������, ����������� ������';

comment on column v_ml_attachment.is_image_content_id is
'�������� �� �������� ������������
( 0 - ���, 1 - ��, ��-��������� ( null ) - �� �������� )
�������� ���� ������� �� �������� ����������� 
������������� ��������� ��������
';