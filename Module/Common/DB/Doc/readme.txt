title: ��������

group: ����� ��������

������ �������� ������������������� ������� � ���� ������, ��������� ��� ����
������������� ��.

�������� �����������:
- ��������� ������ � ��;
- ����������� ���� ��: ������������/��������;
- �������� ����������� �� e-mail;
- �������� ���������� ���������� ��������;
- ������� �������������� ( ��������������, ����� ��������);
- ������� ��� �������;
- ������� ������������� ����� ( ��. <str_concat_t>);



group: �������� �������� ������� �������������

� Oracle 9i ���� �������� User-Defined ������������ �������, �.�. ������ ����� ��������� ��� ����������� ������.

��� ����� ��� ����� �������� ��������� ��� <impltype>, ������� ����� ������������� 4 �������� ������ ���������� ODCIAggregate
(code)
 - 	STATIC FUNCTION ODCIAggregateInitialize(actx IN OUT <impltype>) RETURN NUMBER
 -  MEMBER FUNCTION ODCIAggregateIterate(self IN OUT <impltype>, val <inputdatatype>) RETURN NUMBER
 -  MEMBER FUNCTION ODCIAggregateMerge(self IN OUT <impltype>, ctx2 IN <impltype>) RETURN NUMBER
 -  MEMBER FUNCTION ODCIAggregateTerminate(self IN <impltype>, ReturnValue OUT <return_type>, flags IN number) RETURN NUMBER

 ����� <impltype> 		- ����� ��������� ���, ������� �� ��������� ��� ���������� ������ ������������ �������
	   <inputdatatype> 	- ��� ��������� ������������ �������
	   <return_type> 	- ��� ���������� ������������ �������
(end)

����� ���������� �������� ���� �������.
(code)
 CREATE FUNCTION <AGR_FUNC_NAME>(<inputdatatype>) RETURN <return_type>
 PARALLEL_ENABLE /* ����������� ������������ ������� � ������������ ����������� (������ ���� �������� ����� ODCIAggregateMerge) */
 AGGREGATE USING <OBJ_TYPE_NAME>;  /* ���������� �������� */
(end)

��� ����� ������ �������� � ������ ������������ ����������

(see addci043.gif)

�����, �������������
(code)
SELECT <AGR_FUNC_NAME>(<FIELD_NAME>) FROM <TABLE_NAME>;
(end)

���������:
����� ��������� � ������������: http://download.oracle.com/docs/cd/B19306_01/appdev.102/b14289/dciaggfns.htm#sthref546


