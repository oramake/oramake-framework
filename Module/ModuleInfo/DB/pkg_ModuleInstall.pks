create or replace package pkg_ModuleInstall is
/* package: pkg_ModuleInstall
  Функции, используемые во время установки модуля.

  SVN root: Oracle/Module/ModuleInfo
*/



/* group: Функции */



/* group: Вспомогательные функции */



/* group: Установка файлов */

/* pfunc: startInstallFile
  Фиксирует начало установки файла.
  Вызывается перед установкой файла в той же сессии.

  Параметры:
  moduleSvnRoot               - путь к корневому каталогу устанавливаемого
                                модуля в Subversion ( начиная с имени
                                репозитария, например
                                "Oracle/Module/ModuleInfo")
  moduleInitialSvnPath        - первоначальный путь к корневому каталогу
                                устанавливаемого модуля в Subversion ( начиная
                                с имени репозитария и влючая номер правки, в
                                которой он был создан, например
                                "Oracle/Module/ModuleInfo@711")
  moduleVersion               - версия модуля ( например, "1.1.0")
  installVersion              - устанавливаемая версия модуля
  hostProcessStartTime        - время начала выполнения процесса, в котором
                                выполнялось действие ( указывается локальное
                                время на хосте)
  hostProcessId               - идентификатор процесса на хосте, в котором
                                выполнялось действие
  actionGoalList              - цели выполнения действия по установке модуля
                                ( список с пробелами в качестве разделителя)
  actionOptionList            - параметры действия по установке модуля
                                ( список с пробелами в качестве разделителя)
  svnPath                     - путь в Subversion, из которого были получены
                                файлы модуля ( начиная с имени репозитария,
                                null в случае отсутствия информации)
  svnVersionInfo              - информация о версии файлов модуля из Subversion
                                ( в формате вывода утилиты svnversion,
                                null в случае отсутствия информации)
  filePath                    - путь к устанавливаемому файлу
  fileModuleSvnRoot           - путь к корневому каталогу модуля, к которому
                                относится устанавливаемый файл, в Subversion
                                ( формат аналогичен параметру moduleSvnRoot,
                                по умолчанию считается, что файл относится к
                                устанавливаемому модулю)
  fileModuleInitialSvnPath    - первоначальный путь к корневому каталогу
                                модуля, к которому относится устанавливаемый
                                файл, в Subversion ( формат аналогичен
                                параметру moduleInitialSvnPath, по умолчанию
                                считается, что файл относится к
                                устанавливаемому модулю)
  fileModulePartNumber        - номер части модуля, к которой относится файл
                                ( по умолчанию не изменяется при наличии
                                записи в <mod_source_file>, а для новой
                                записи используется номер основной части)
  fileObjectName              - имя объекта в БД, которому соответствует файл
                                ( по умолчанию не соответствует объекту)
  fileObjectType              - тип объекта в БД, которому соответствует файл
                                ( по умолчанию не соответствует объекту)

  Возврат:
  Id для выполняемой установки файла ( значение install_file_id из таблицы
  <mod_install_file>).

  Замечания:
  - функция выполняется в автономной транзакции;

  ( <body::startInstallFile>)
*/
function startInstallFile(
  moduleSvnRoot varchar2
  , moduleInitialSvnPath varchar2
  , moduleVersion varchar2
  , installVersion varchar2 := null
  , hostProcessStartTime timestamp with time zone
  , hostProcessId integer
  , actionGoalList varchar2
  , actionOptionList varchar2
  , svnPath varchar2 := null
  , svnVersionInfo varchar2 := null
  , filePath varchar2
  , fileModuleSvnRoot varchar2 := null
  , fileModuleInitialSvnPath varchar2 := null
  , fileModulePartNumber integer := null
  , fileObjectName varchar2 := null
  , fileObjectType varchar2 := null
)
return integer;

/* pproc: finishInstallFile
  Фиксирует завершение установки файла.
  Вызывается после завершения установки файла в той же сессии, при этом
  перед установкой должна быть вызвана процедура <startInstallFile>.

  Параметры:
  installFileId               - Id установки файла ( по умолчанию текущая)

  Замечания:
  - процедура выполняется в автономной транзакции;

  ( <body::finishInstallFile>)
*/
procedure finishInstallFile(
  installFileId integer := null
);

/* pfunc: startInstallNestedFile
  Фиксирует начало установки вложенного файла.
  Предварительно в той же сессии должно быть зафиксировано начало установки
  файла верхнего уровня с помощью вызова функции <startInstallFile>.

  Параметры:
  filePath                    - путь к выполняемому файлу
  fileModuleSvnRoot           - путь к корневому каталогу модуля, к которому
                                относится выполняемый файл, в Subversion
                                ( формат аналогичен параметру moduleSvnRoot,
                                по умолчанию считается, что файл относится к
                                устанавливаемому модулю)
  fileModuleInitialSvnPath    - первоначальный путь к корневому каталогу
                                модуля, к которому относится выполняемый
                                файл, в Subversion ( формат аналогичен
                                параметру moduleInitialSvnPath, по умолчанию
                                считается, что файл относится к
                                устанавливаемому модулю)
  fileModulePartNumber        - номер части модуля, к которой относится файл
                                ( по умолчанию не изменяется при наличии
                                записи в <mod_source_file>, а для новой
                                записи используется номер части
                                устанавливаемого файла верхнего уровня если
                                он относится к тому же модулю, иначе номер
                                основной части)
  fileObjectName              - имя объекта в БД, которому соответствует файл
                                ( по умолчанию не соответствует объекту)
  fileObjectType              - тип объекта в БД, которому соответствует файл
                                ( по умолчанию не соответствует объекту)

  Возврат:
  Id записи, фиксирующей начало установки файла ( значение install_file_id из
  таблицы <mod_install_file>).

  Замечания:
  - функция выполняется в автономной транзакции;

  ( <body::startInstallNestedFile>)
*/
function startInstallNestedFile(
  filePath varchar2
  , fileModuleSvnRoot varchar2 := null
  , fileModuleInitialSvnPath varchar2 := null
  , fileModulePartNumber integer := null
  , fileObjectName varchar2 := null
  , fileObjectType varchar2 := null
)
return integer;

/* pproc: finishInstallNestedFile
  Фиксирует завершение установки вложенного файла.
  Вызывается после завершения установки вложенного файла в той же сессии, при
  этом перед началом выполнения вложенного файла должна быть вызвана функция
  <startInstallNestedFile>.

  Замечания:
  - процедура выполняется в автономной транзакции;

  ( <body::finishInstallNestedFile>)
*/
procedure finishInstallNestedFile;



/* group: Результат установки */

/* pfunc: createInstallResult
  Добавляет результат установки для действия по установке модуля.

  Параметры:
  moduleSvnRoot               - путь к корневому каталогу устанавливаемого
                                модуля в Subversion ( начиная с имени
                                репозитария, например
                                "Oracle/Module/ModuleInfo")
  moduleInitialSvnPath        - первоначальный путь к корневому каталогу
                                устанавливаемого модуля в Subversion ( начиная
                                с имени репозитария и влючая номер правки, в
                                которой он был создан, например
                                "Oracle/Module/ModuleInfo@711")
  hostProcessStartTime        - время начала выполнения процесса, в котором
                                выполнялось действие ( указывается локальное
                                время на хосте)
  hostProcessId               - идентификатор процесса на хосте, в котором
                                выполнялось действие
  moduleVersion               - версия модуля ( например, "1.1.0")
  actionGoalList              - цели выполнения действия по установке модуля
                                ( список с пробелами в качестве разделителя)
  actionOptionList            - параметры действия по установке модуля
                                ( список с пробелами в качестве разделителя)
  svnPath                     - путь в Subversion, из которого были получены
                                файлы модуля ( начиная с имени репозитария,
                                null в случае отсутствия информации)
  svnVersionInfo              - информация о версии файлов модуля из Subversion
                                ( в формате вывода утилиты svnversion,
                                null в случае отсутствия информации)
  modulePartNumber            - номер устанавливаемой части модуля
                                ( по умолчанию номер основной части)
  installVersion              - устанавливаемая версия
  installTypeCode             - код типа установки
  isFullInstall               - флаг полной установки ( 1 при полной установке,
                                0 при установке обновления)
  isRevertInstall             - флаг выполнения отмены установки версии
                                ( 1 отмена установки версии, 0 установка версии
                                ( по умолчанию))
  installUser                 - имя пользователя, под которым выполнялась
                                установка ( по умолчанию текущий)
  installDate                 - дата завершения установки ( по умолчанию
                                текущая)
  objectSchema                - схема, в которой расположены объекты данной
                                части модуля ( по умолчанию совпадает с
                                installUser, null если в нем указаны sys или
                                system)
  privsUser                   - имя пользователя или роли, для которой
                                выполнялась настройка прав доступа ( значение
                                должно быть указано только при установке прав
                                доступа)
  installScript               - стартовый установочный скрипт ( может
                                отсутствовать, если использовался тривиальный
                                вариант, например run.sql)
  resultVersion               - версия, получившаяся результате выполнения
                                установки, должна быть обязательно указана при
                                отмене установки обновления ( по умолчанию
                                installVersion в случае установки, null в
                                случае отмены полной установки)

  Возврат:
  Id добавленной записи ( поле install_result_id таблицы <mod_install_result>).

  Замечания:
  - версия, указанная в resultVersion, становится текущей установленной
    версией;

  ( <body::createInstallResult>)
*/
function createInstallResult(
  moduleSvnRoot varchar2
  , moduleInitialSvnPath varchar2
  , hostProcessStartTime timestamp with time zone
  , hostProcessId integer
  , moduleVersion varchar2
  , actionGoalList varchar2
  , actionOptionList varchar2
  , svnPath varchar2 := null
  , svnVersionInfo varchar2 := null
  , modulePartNumber integer
  , installVersion varchar2
  , installTypeCode varchar2
  , isFullInstall integer
  , isRevertInstall integer := null
  , installUser varchar2 := null
  , installDate date := null
  , objectSchema varchar2 := null
  , privsUser varchar2 := null
  , installScript varchar2 := null
  , resultVersion varchar2 := null
)
return integer;

end pkg_ModuleInstall;
/
