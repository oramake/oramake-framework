/*
 * dbtype: str_concat_t
 * Объявление объектного типа, который реализует интерфейс ODCIAggregate.
 * Применяется в определении агрегирующей функции str_concat(<varchar2_value>)
 * Тип реализует логику агрегирующей функции str_concat, которая возвращает результат
 * конкатенации значений поля value разделенных символом '|' (в конкретной реализации)
 * по группе кортежей.
 *
 * В текущей реализации также заданы параметры:
 *     - разделитель по-умлочанию - '|'
 *     - максимальнуя длина возвращаемой строки - 4000
 *     - нужно ли выводить '...' в конце строки, если её длина превышает максимальную длину - да
 *     - нужно ли генерировать исключение, если длина результирующей строки превышает максимальную длину - нет
 *
 * См. также - Описание способа создания пользовательский агрегативный типов в документации к
 *            модулю.
 */

CREATE OR REPLACE TYPE str_concat_t AS OBJECT
(
   /* ivar: ls_sum
	* Результирующая строка, получаемая конкатенацией значений
	* различных кортежей по заданному полю
	*/
  ls_sum VARCHAR2(4000)

,  /* ivar: delim_f
	* Символ разделителя значений различных кортежей
	*/
  delim_f char(1)

,  /* ivar: maxStringLength_f
	* Максимально возможная длина результирующей строки.
    * Вычисляется как (4000 - 3), необходимо для вывода троеточия ("...") в конце строки.
	* См. реализацию метода ODCIAggregateIterate
	*/
  maxStringLength_f number

,  /* ivar: dots_f
	* Логическое значение, которое показывает нужно ли выводить
	* в конце результирующей строки троеточие ("...")
	*  1 - нужно выводить троеточие ("...")
	*  0 - троеточие выводить не нужно
	*/
  dots_f number(1)

,  /* ivar: dots_f
	* Логическое значение, которое показывает нужно ли генерировать Exception,
	* если длина суммируемых строк превышает максимально допустимую
	* (максимально допустимая длина управляется параметром maxStringLength).
	*/
  makeError_f number(1)

, shouldPutDots number(1)

,  /* pproc: str_concat_t
	* Конструктор типа, который задает параметры, применяемые при вычислении результата функции
	* str_concat.
	* (<body::str_concat_t>)
	*/
  CONSTRUCTOR FUNCTION str_concat_t( delim char
                                    ,max_length NUMBER default 4000
									,dots number default 1
									,make_error number default 0)
  RETURN SELF AS RESULT


,  /* pproc: ODCIAggregateInitialize
	* Реализация функции интерфейса ODCIAggregate
	* Выполняет инициализацию контекста для выполнения агрегирующей функции str_concat
	* (<body::ODCIAggregateInitialize>)
	*/
  STATIC FUNCTION ODCIAggregateInitialize(ctx IN OUT str_concat_t)
   RETURN NUMBER


,  /* pproc: ODCIAggregateIterate
	* Реализация функции интерфейса ODCIAggregate
	* Реализует логику итерации функции агрегирования str_concat
	* (<body::ODCIAggregateIterate>)
	*/
  MEMBER FUNCTION ODCIAggregateIterate(self  IN OUT str_concat_t
                                      ,value IN     VARCHAR2)
   RETURN NUMBER

,  /* pproc: ODCIAggregateMerge
	* Реализация функции интерфейса ODCIAggregate
	* Реализует логику слияния контекстов.
	* (<body::ODCIAggregateIterate>)
	*/
  MEMBER FUNCTION ODCIAggregateMerge(self IN OUT str_concat_t
                                    ,ctx  IN     str_concat_t)
   RETURN NUMBER

,  /* pproc: ODCIAggregateTerminate
	* Реализация функции интерфейса ODCIAggregateTerminate
	* Реализует логику завершения процедуры вычисления функции str_concat. И возвращение
	* результата вычислений в функцию str_concat.
	* (<body::ODCIAggregateTerminate>)
	*/
  MEMBER FUNCTION ODCIAggregateTerminate(self  IN str_concat_t
                                        ,value OUT VARCHAR2
                                        ,flags IN NUMBER)
   RETURN NUMBER
)
/