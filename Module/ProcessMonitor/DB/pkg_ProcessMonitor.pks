create or replace package pkg_ProcessMonitor is
/* package: pkg_ProcessMonitor
  Интерфейсный пакет модуля ProcessMonitor.

  SVN root: Oracle/Module/ProcessMonitor
*/



/* group: Функции */



/* group: Трассировка */

/* pproc: hoursToString
  Перевод значения времени в часах в строку.

  Возврат:
  - строка в виде "? часов ?? минут"

  ( <body::hoursToString>)
*/
function hoursToString( hour number)
return varchar2;

/* pproc: sqlTraceOn(registeredSessionId)
   Включение трассировки для зарегистированной сессии.

   Параметры:
   registeredSessionId        - id зарегистрированной сессии ( ссылка на
                                <prm_registered_session>)
   isFinalTraceSending        - нужно ли отправлять письмо
                                о трассировке по завершению сессии
                                По-умолчанию не отправлять.
   recipient                  - получатель(и) сообщения
                                при отправке писем о трассировке.
                                По-умолчанию стандартный ящик для БД
                                (  функция pkg_Common.getMailAddressSource()).
   subject                    - тема письма при отправке писем.
                                По-умолчанию - нет.
   sqlTraceLevel              -  уровень трассировки. По умолчанию - 12
                                (см. описание уровней трассировки в <sqlTraceOn>)

  ( <body::sqlTraceOn(registeredSessionId)>)
*/
procedure sqlTraceOn(
  registeredSessionId integer
  , isFinalTraceSending integer := null
  , recipient varchar2 := null
  , subject varchar2 := null
  , sqlTraceLevel integer := null
);

/* pproc: sqlTraceOn
   Включение трассировки

   Параметры:
   sid                        - sid сессии ( по-умолчанию берётся текущая сессия)
   serial#                    - serial# сессии ( по-умолчанию берётся текущая сессия)
   isFinalTraceSending        - нужно ли отправлять письмо о трассировке по
                                завершению сессии. По умолчанию-нет.
   recipient                  - получатель(и) сообщения при отправке писем о
                                трассировке. По умолчанию-стандартный ящик для БД
                                ( модуль Common).
   subject                    - тема письма при отправке писем. По умолчанию-нет.
   sqlTraceLevel              - уровень трассировки. По-умолчанию 12.

   sqlTraceLevel может принимать следующие значения:

   sqlTraceLevel=1            - включает стандартные средства SQL_TRACE.
                                Результат не отличается от установки
                                SQL_TRACE=true.
   sqlTraceLevel=4            - включает стандартные средства SQL_TRACE и
                                добавляет в трассировочный файл значения
                                связываемых переменных.
   sqlTraceLevel=8            - включает стандартные средства SQL_TRACE и
                                добавляет в трассировочный файл информацию о
                                событиях ожидания на уровне запросов.
   sqlTraceLevel=12           - включает стандартные средства SQL_TRACE и
                                добавляет как значения связываемых переменных,
                                так и информацию об ожидании событий.

  ( <body::sqlTraceOn>)
*/
procedure sqlTraceOn(
  sid integer := null
  , serial# integer := null
  , isFinalTraceSending integer := null
  , recipient varchar2 := null
  , subject varchar2 := null
  , sqlTraceLevel integer := null
);

/* pfunc: copyTrace(registeredSessionId)
  Копирование файлов трассировки

  Параметры:
  registeredSessionId         - id зарегистрированной сессии ( ссылка на
                                <prm_registered_session>)
  traceCopyPath               - директория для копирования файлов трассировки
                                ( по-умолчанию берётся результат
                                  <pkg_ProcessMonitorUtility.getDefaultTraceCopyPath>)
  isSourceDeleted             - удалять ли исходный файл трассировки (
                                по-умолчанию не удалять).

  Возврат:
  - информация о копировании в виде текста;

  ( <body::copyTrace(registeredSessionId)>)
*/
function copyTrace(
  registeredSessionId integer
  , traceCopyPath varchar2
  , isSourceDeleted integer := null
)
return varchar2;

/* pfunc: copyTrace
  Копирование файлов трассировки

  Параметры:
  traceCopyPath               - директория для копирования файлов трассировки
                                ( по-умолчанию берётся результат
                                  <pkg_ProcessMonitorUtility.getDefaultTraceCopyPath>)
  isSourceDeleted             - удалять ли исходный файл трассировки (
                                по-умолчанию не удалять).
  sid                         - sid сессии ( по-умолчанию берётся текущая сессия)
  serial#                     - serial# сессии ( по-умолчанию берётся текущая сессия)

  Возврат:
    - информация о копировании в виде текста

  ( <body::copyTrace>)
*/
function copyTrace(
  traceCopyPath varchar2
  , isSourceDeleted integer := null
  , sid integer := null
  , serial# integer := null
)
return varchar2;

/* pproc: sendTrace
  Отправка ссылки на копию файлов трассировки

  Параметры:
  sid                         - sid сессии ( по-умолчанию берётся текущая
                                сессия)
  serial#                     - serial# сессии ( по-умолчанию берётся текущая
                                сессия)
  recipient                   - получатель(и) сообщения при отправке писем о
                                трассировке.  По-умолчанию стандартный ящик
                                для БД ( функция
                                pkg_Common.getMailAddressSource()).
  subject                     - тема письма при отправке писем.  По-умолчанию
                                указываются параметры сессии.
  isSourceDeleted             - удалять ли исходный файл трассировки (
                                по-умолчанию не удалять).
  traceCopyPath               - директория для копирования файлов трассировки
                                ( по-умолчанию берётся результат
                                  <pkg_ProcessMonitorUtility.getDefaultTraceCopyPath>)
  sqlTraceOff                 - отключать ли трассировку перед отправкой
                                письма (1-да).  По-умолчанию не отключать.

  ( <body::sendTrace>)
*/
procedure sendTrace(
  sid integer := null
  , serial# integer := null
  , recipient varchar2 := null
  , subject varchar2 := null
  , isSourceDeleted integer := null
  , traceCopyPath varchar2 := null
  , sqlTraceOff integer := null
);

/* pproc: sqlTraceOff
  Выключение трассировки

  Параметры:
  sid                         - sid сессии ( по-умолчанию текущая сессиия)
  serial#                     - serial# сессии ( по-умолчанию текущая сессиия)

  ( <body::sqlTraceOff>)
*/
procedure sqlTraceOff(
  sid integer := null
  , serial# integer := null
);

/* pproc: batchTraceOn
  Включение трассировки для сессии батча

  Параметры:
  sid                         - sid сессии ( по-умолчанию берётся текущая сессия)
  serial#                     - serial# сессии ( по-умолчанию берётся текущая сессия)
  isFinalTraceSending         - нужно ли отправлять письмо о трассировке по
                                завершению сессии
  sqlTraceLevel               - уровень трассировки (см. описание уровней
                                трассировки в <sqlTraceOn>)
  batchShortName              - наименование батча

  ( <body::batchTraceOn>)
*/
procedure batchTraceOn(
  sid integer
  , serial# integer
  , isFinalTraceSending integer
  , sqlTraceLevel integer
  , batchShortName varchar2
);



/* group: Слежение за процессами */

/* pfunc: formatLargeNumber
  Преобразование большого числа в строку ( с разделителями для лучшей
  читаемости).

  Параметры:
  numberValue                 - числовое значение

  ( <body::formatLargeNumber>)
*/
function formatLargeNumber(
  numberValue number
)
return varchar2;

/* pproc: batchBegin
  Процедура, вызываемая в начале работы батча.

  Параметры:
  sqlTraceLevel               - уровень трассировки (см. описание уровней
                                трассировки в <sqlTraceOn>)

  ( <body::batchBegin>)
*/
procedure batchBegin(
  sqlTraceLevel integer := null
);

/* pproc: batchEnd
  Процедура, вызываемая в конце работы батча.

  ( <body::batchEnd>)
*/
procedure batchEnd;

/* pproc: checkTrace
  Установка трассировки для зарегистрированных сессий.

  ( <body::checkTrace>)
*/
procedure checkTrace;

/* pproc: checkOraKill
  Выполнение oraKill для зарегистрированных сессий.

  ( <body::checkOraKill>)
*/
procedure checkOraKill;

/* pproc: checkSendTrace
  Отправка ссылок на копии файлов трассировки для зарегистрированных сессий.

  Параметры:
  isBatchEnd                  - нужно ли выполнить отправку для батча текущей
                                сессии (1-да) По-умолчанию нет.

  ( <body::checkSendTrace>)
*/
procedure checkSendTrace(
  isBatchEnd integer := null
);

/* pproc: checkBatchExecution
  Отслеживание работы батчей

  Параметры:
  warningTimePercent          - порог предупреждения ( в процентах)
  warningTimeHour             - порог предупреждения ( в часах)
  minWarningTimeHour          - минимальный порог предупреждения ( в часах)
  abortTimeHour               - порог прерывания ( в часах)
  orakillWaitTimeHour         - порог прерывания через orakill ( в часах).
                                Порог времени отсчитывается с начала
                                прерывания сессии.

  ( <body::checkBatchExecution>)
*/
procedure checkBatchExecution(
  warningTimePercent integer
  , warningTimeHour integer
  , minWarningTimeHour integer
  , abortTimeHour integer
  , orakillWaitTimeHour integer
  , traceCopyPath varchar2 := null
);

/* pfunc: getOsMemory
  Получение объёма памяти ( в байтах) затрачиваемого процессом Oracle.

  Замечание:
  - предполагается, что имя серсиса, соответствующего процессу содержит в себе
    имя oracle instance;

  ( <body::getOsMemory>)
*/
function getOsMemory
return number;

/* pproc: checkMemory
  Проверка превышения заданных порогов используемой оперативной памяти.

  Параметры:
  osMemoryThreshold           - объём памяти процесса операционной системы в
                                байтах, при котором выдаётся предупреждение
  pgaMemoryThreshold          - объём памяти PGA процессов Oracle, при котором
                                выдаётся предупреждение
  emailRecipient              - получатель(и) предупреждения

  Примечания:
  - должен быть задан хотя бы один порог ( osMemoryThreshold или
    pgaMemoryThreshold);

  ( <body::checkMemory>)
*/
procedure checkMemory(
  osMemoryThreshold number := null
  , pgaMemoryThreshold number := null
  , emailRecipient varchar2 := null
);



/* group: Настройки батча */

/* pproc: setBatchConfig
  Установка настроек для батча

  Параметры:
  batchShortName              - короткое наименование батча
  warningTimePercent          - порог предупреждения о длительном выполнении
                                ( в процентах)
  warningTimeHour             - порог предупреждения о длительном выполнении
                                ( в часах)
  abortTimeHour               - порог прерывания ( в часах)
  orakillWaitTimeHour         - порог ожидания для выполнения oraKill для сессии
                                в состоянии KILLED
  traceTimeHour               - порог установки и отправки файла трассировки
  isFinalTraceSending         - отправка ссылки на файл трассировки при завершении
                                пакетного задания
  sqlTraceLevel               - уровень трассировки
                                (см. описание уровней трассировки в <sqlTraceOn>)

  ( <body::setBatchConfig>)
*/
procedure setBatchConfig(
  batchShortName varchar2
  , warningTimePercent integer
  , warningTimeHour integer
  , abortTimeHour integer
  , orakillWaitTimeHour integer
  , traceTimeHour integer
  , sqlTraceLevel integer
  , isFinalTraceSending integer
);

/* pproc: deleteBatchConfig
  Удаление настроек для батча

  Параметры:
  batchShortName              - короткое наименование батча

  ( <body::deleteBatchConfig>)
*/
procedure deleteBatchConfig(
  batchShortName varchar2
);

end pkg_ProcessMonitor;
/
