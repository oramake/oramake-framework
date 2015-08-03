title: Описание

group: Общее описание

Модуль содержит общеупотребительные функции и коды ошибок, доступные для всех
пользователей БД.

Основные возможности:
- параметры сессии и БД;
- определение типа БД: промышленная/тестовая;
- отправка нотификации по e-mail;
- прогресс выполнения длительных операций;
- функции преобразования ( транслитерация, сумма прописью);
- функции для отладки;
- функция агрегирования строк ( см. <str_concat_t>);



group: Механизм создания функций агрегирования

С Oracle 9i были внедрены User-Defined Агрегирующие функции, т.е. теперь можно добавлять все необходимое самому.

Для этого нам нужно объявить объектный тип <impltype>, который будет реализовывать 4 основных метода интерфейса ODCIAggregate
(code)
 - 	STATIC FUNCTION ODCIAggregateInitialize(actx IN OUT <impltype>) RETURN NUMBER
 -  MEMBER FUNCTION ODCIAggregateIterate(self IN OUT <impltype>, val <inputdatatype>) RETURN NUMBER
 -  MEMBER FUNCTION ODCIAggregateMerge(self IN OUT <impltype>, ctx2 IN <impltype>) RETURN NUMBER
 -  MEMBER FUNCTION ODCIAggregateTerminate(self IN <impltype>, ReturnValue OUT <return_type>, flags IN number) RETURN NUMBER

 Здесь <impltype> 		- новый объектный тип, который мы объявляем для реализации логики агрегирующей функции
	   <inputdatatype> 	- тип аргумента агрегирующей функции
	   <return_type> 	- тип результата агрегирующей функции
(end)

Затем необходимо объявить саму функцию.
(code)
 CREATE FUNCTION <AGR_FUNC_NAME>(<inputdatatype>) RETURN <return_type>
 PARALLEL_ENABLE /* возможность использовать функцию в параллельных вычислениях (должен быть объявлен метод ODCIAggregateMerge) */
 AGGREGATE USING <OBJ_TYPE_NAME>;  /* объявление агрегата */
(end)

Вот схема работы агрегата в случае параллельных вычислений

(see addci043.gif)

Далее, использование
(code)
SELECT <AGR_FUNC_NAME>(<FIELD_NAME>) FROM <TABLE_NAME>;
(end)

Подробнее:
можно прочитать в документации: http://download.oracle.com/docs/cd/B19306_01/appdev.102/b14289/dciaggfns.htm#sthref546


