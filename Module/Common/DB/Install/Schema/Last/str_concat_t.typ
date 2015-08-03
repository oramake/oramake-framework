/*
 * dbtype: str_concat_t
 * ���������� ���������� ����, ������� ��������� ��������� ODCIAggregate.
 * ����������� � ����������� ������������ ������� str_concat(<varchar2_value>)
 * ��� ��������� ������ ������������ ������� str_concat, ������� ���������� ���������
 * ������������ �������� ���� value ����������� �������� '|' (� ���������� ����������)
 * �� ������ ��������.
 *
 * � ������� ���������� ����� ������ ���������:
 *     - ����������� ��-��������� - '|'
 *     - ������������ ����� ������������ ������ - 4000
 *     - ����� �� �������� '...' � ����� ������, ���� � ����� ��������� ������������ ����� - ��
 *     - ����� �� ������������ ����������, ���� ����� �������������� ������ ��������� ������������ ����� - ���
 *
 * ��. ����� - �������� ������� �������� ���������������� ������������ ����� � ������������ �
 *            ������.
 */

CREATE OR REPLACE TYPE str_concat_t AS OBJECT
(
   /* ivar: ls_sum
	* �������������� ������, ���������� ������������� ��������
	* ��������� �������� �� ��������� ����
	*/
  ls_sum VARCHAR2(4000)

,  /* ivar: delim_f
	* ������ ����������� �������� ��������� ��������
	*/
  delim_f char(1)

,  /* ivar: maxStringLength_f
	* ����������� ��������� ����� �������������� ������.
    * ����������� ��� (4000 - 3), ���������� ��� ������ ��������� ("...") � ����� ������.
	* ��. ���������� ������ ODCIAggregateIterate
	*/
  maxStringLength_f number

,  /* ivar: dots_f
	* ���������� ��������, ������� ���������� ����� �� ��������
	* � ����� �������������� ������ ��������� ("...")
	*  1 - ����� �������� ��������� ("...")
	*  0 - ��������� �������� �� �����
	*/
  dots_f number(1)

,  /* ivar: dots_f
	* ���������� ��������, ������� ���������� ����� �� ������������ Exception,
	* ���� ����� ����������� ����� ��������� ����������� ����������
	* (����������� ���������� ����� ����������� ���������� maxStringLength).
	*/
  makeError_f number(1)

, shouldPutDots number(1)

,  /* pproc: str_concat_t
	* ����������� ����, ������� ������ ���������, ����������� ��� ���������� ���������� �������
	* str_concat.
	* (<body::str_concat_t>)
	*/
  CONSTRUCTOR FUNCTION str_concat_t( delim char
                                    ,max_length NUMBER default 4000
									,dots number default 1
									,make_error number default 0)
  RETURN SELF AS RESULT


,  /* pproc: ODCIAggregateInitialize
	* ���������� ������� ���������� ODCIAggregate
	* ��������� ������������� ��������� ��� ���������� ������������ ������� str_concat
	* (<body::ODCIAggregateInitialize>)
	*/
  STATIC FUNCTION ODCIAggregateInitialize(ctx IN OUT str_concat_t)
   RETURN NUMBER


,  /* pproc: ODCIAggregateIterate
	* ���������� ������� ���������� ODCIAggregate
	* ��������� ������ �������� ������� ������������� str_concat
	* (<body::ODCIAggregateIterate>)
	*/
  MEMBER FUNCTION ODCIAggregateIterate(self  IN OUT str_concat_t
                                      ,value IN     VARCHAR2)
   RETURN NUMBER

,  /* pproc: ODCIAggregateMerge
	* ���������� ������� ���������� ODCIAggregate
	* ��������� ������ ������� ����������.
	* (<body::ODCIAggregateIterate>)
	*/
  MEMBER FUNCTION ODCIAggregateMerge(self IN OUT str_concat_t
                                    ,ctx  IN     str_concat_t)
   RETURN NUMBER

,  /* pproc: ODCIAggregateTerminate
	* ���������� ������� ���������� ODCIAggregateTerminate
	* ��������� ������ ���������� ��������� ���������� ������� str_concat. � �����������
	* ���������� ���������� � ������� str_concat.
	* (<body::ODCIAggregateTerminate>)
	*/
  MEMBER FUNCTION ODCIAggregateTerminate(self  IN str_concat_t
                                        ,value OUT VARCHAR2
                                        ,flags IN NUMBER)
   RETURN NUMBER
)
/