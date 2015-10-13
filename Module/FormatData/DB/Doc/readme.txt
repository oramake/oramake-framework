title: Описание

Модуль применяется для форматирования и сравнения данных.

Основная цель создания модуля: собрать в одном месте низкоуровневые правила
сравнения клиентских данных, которые приходится использовать в различных
задачах, связанных с поиском и дедупликацией клиентов.

Пример: игнорирование различий между буквами "и" и "й" при сравнении ( в связи
с часто встречающейся ошибкой в этих буквах при вводе данных), игнорирование
несущественных различий в написании имен и отчеств с помощью использования
синонимов ( "Наталья" и "Наталия").

Предоставляемые модулем функции ( <pkg_FormatData>):
- format* ( форматирование);

  Функции выполняют естественное форматирование входных данных, удобное для
  последующего просмотра и поиска, без существенного изменения самих данных.

- getBase* ( базовая форма);

  Возвращают базовую форму для исходных данных ( в т.ч. с использованием
  справочника синонимов), предназначенную для поиска, возможно существенно
  отличающуюся от исходных данных.

- check* ( проверка корректности)

  Проверяет корректность указанного значения ( например, для номера ИНН
  проверяется контрольная сумма).


Для всех функций предоставляются парные функции *Expr, которые возвращают
SQL-выражение, позволяющее получить тот же самый результат, для использования
в динамическом SQL. Использование этих функций в динамическом SQL вместо вызова
PL/SQL вариантов позволяет получить существенный выигрыш в производительности
на больших объемах данных ( пример: использовие SQL-выражений из функции
getBaseCodeExpr для трех полей на 260 тыс. записей в динамическом SQL работает
более чем в 3 раза быстрее чем вызов из SQL функций getBaseCode на 260 тыс.
записей).

Примерная схема использования другими модулями:
- при регулярном обновлении исходных данных выполняется форматирование данных
  с помощью функций Format* и сохранение их в таблицу;

  При использовании функций getBase* рекомендуется сохранять в этой же таблице
  исходное значение.

(code)
  ...
                                        --Получаем данные
  execute immediate '
insert into
  tmp_table
(
  id
  , last_name
  , first_name
  , middle_name
  , birth_year
  , birth_month
  , birth_day
  , passport_serie
  , passport_number
  , base_last_name
  , base_first_name
  , base_middle_name
  , base_passport_serie
  , base_passport_number
)
select
  a.id
  , a.last_name
  , a.first_name
  , a.middle_name
  , ' || pkg_FormatData.formatCodeExpr( 'to_char( a.birth_year)', 4) || '
    as birth_year
  , ' || pkg_FormatData.formatCodeExpr( 'to_char( a.birth_month)', 2) || '
    as birth_month
  , ' || pkg_FormatData.formatCodeExpr( 'to_char( a.birth_day)', 2) || '
    as birth_day
  , a.passport_serie
  , a.passport_number
  , ' || pkg_FormatData.getBaseLastNameExpr( 'a.last_name') || '
    as base_last_name
  , ' || pkg_FormatData.getBaseFirstNameExpr( 'a.first_name') || '
    as base_first_name
  , ' || pkg_FormatData.getBaseMiddleNameExpr( 'a.middle_name') || '
    as base_middle_name
  , ' || pkg_FormatData.getBaseCodeExpr( 'a.passport_serie') || '
    as base_passport_serie
  , ' || pkg_FormatData.getBaseCodeExpr( 'a.passport_number') || '
    as base_passport_number
from
  tmp_table@' || sourceDbLink || ' a
'
  ;
  ...
(end)

- для выполнения поиска ключевые значения форматируются по тем же самым
  правилам, что и при обновлении данных, после чего выполняется поиск по
  сохраненным в таблице индексированным полям;

(code)
  ...
                                        --Выполняем поиск
  DoFind(
    lastName          => pkg_FormatData.getBaseLastName( lastName)
    , firstName       => pkg_FormatData.getBaseFirstName( firstName)
    , middleName      => pkg_FormatData.getBaseMiddleName( middleName)
    , lastNameOld     => pkg_FormatData.getBaseLastName( lastNameOld)
    , birthYear       => pkg_FormatData.formatCode( birthYear, 4)
    , birthMonth      => pkg_FormatData.formatCode( birthMonth, 2)
    , birthDay        => pkg_FormatData.formatCode( birthDay, 2)
    , passportSerie   => pkg_FormatData.getBaseCode( passportSerie)
    , passportNumber  => pkg_FormatData.getBaseCode( passportNumber)
  );
  ...
(end)
