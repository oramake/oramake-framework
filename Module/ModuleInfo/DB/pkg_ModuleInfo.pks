create or replace package pkg_ModuleInfo is
/* package: pkg_ModuleInfo
  Интерфейсный пакет модуля ModuleInfo.

  SVN root: Oracle/Module/ModuleInfo
*/



/* group: Константы */



/* group: Типы установок */

/* const: Object_InstallTypeCode
  Код типа установки "Изменение объектов схемы и данных".
*/
Object_InstallTypeCode constant varchar2(10) := 'OBJ';

/* const: Privs_InstallTypeCode
  Код типа установки "Настройка прав доступа".
*/
Privs_InstallTypeCode constant varchar2(10) := 'PRI';



/* group: Функции */



/* group: Модуль в БД */

/* pfunc: getModuleId
  Получение id модуля.


  Параметры:
  findModuleString            - строка для поиска модуля (
                                может совпадать с одним из трёх атрибутов
                                модуля: названием, путём к корневому каталогу,
                                первоначальным путём к корневому каталогу в
                                Subversion)
  moduleName                  - название модуля ( например "ModuleInfo")
  svnRoot                     - путь к корневому каталогу модуля в Subversion
                                ( начиная с имени репозитария, например
                                "Oracle/Module/ModuleInfo")
  initialSvnPath              - первоначальный путь к корневому каталогу
                                модуля в Subversion ( начиная с имени
                                репозитария и влючая номер правки, в которой
                                он был создан, например
                                "Oracle/Module/ModuleInfo@711")
  raiseExceptionFlag          - выбрасывать ли исключение если модуль не найден
                                ( по-умолчанию 1-выбрасывать);

  Возврат:
  Id модуля ( значение module_id из таблицы <mod_module>) либо null если
  запись не найдена и raiseExceptionFlag = 0.

  ( <body::getModuleId>)
*/
function getModuleId(
  findModuleString varchar2 := null
  , moduleName varchar2 := null
  , svnRoot varchar2 := null
  , initialSvnPath varchar2 := null
  , raiseExceptionFlag number := null
)
return varchar2;

/* pfunc: getInstallModuleVersion
  Возвращает установленную в БД версию модуля.
  При определении версии учитываются только версии объектов схемы основных
  частей модулей.

  Параметры:
  svnRoot                     - путь к корневому каталогу модуля в Subversion
                                ( начиная с имени репозитария, например
                                "Oracle/Module/ModuleInfo")
  initialSvnPath              - первоначальный путь к корневому каталогу
                                модуля в Subversion ( начиная с имени
                                репозитария и влючая номер правки, в которой
                                он был создан, например
                                "Oracle/Module/ModuleInfo@711")
  mainObjectSchema            - схема, в которой расположены объекты основной
                                части модуля ( необходимо указывать в случае
                                наличия установок в разные схемы)

  Возврат:
  номер установленной версии либо null при отсутствии данных по установке.

  Замечания:
  - должен быть указано отлично от null значение svnRoot либо initialSvnPath,
    при этом в случае указания initialSvnPath значение svnRoot игнорируется;
  - регистр значений параметров несущественен;

  ( <body::getInstallModuleVersion>)
*/
function getInstallModuleVersion(
  svnRoot varchar2 := null
  , initialSvnPath varchar2 := null
  , mainObjectSchema varchar2 := null
)
return varchar2;



/* group: Установка приложений */

/* pfunc: getAppInstallVersion
  Возвращает установленную версию приложения.

  Параметры:
  deploymentPath              - путь для развертывания приложения
  svnRoot                     - путь к корневому каталогу модуля в Subversion
                                ( начиная с имени репозитария, например
                                "Oracle/Module/ModuleInfo")
  initialSvnPath              - первоначальный путь к корневому каталогу
                                модуля в Subversion ( начиная с имени
                                репозитария и влючая номер правки, в которой
                                он был создан, например
                                "Oracle/Module/ModuleInfo@711")

  Возврат:
  номер установленной версии либо null при отсутствии данных по установке.

  Замечания:
  - должен быть указано отлично от null значение svnRoot либо initialSvnPath,
    при этом в случае указания initialSvnPath значение svnRoot игнорируется;
  - регистр значений параметров несущественен;

  ( <body::getAppInstallVersion>)
*/
function getAppInstallVersion(
  deploymentPath varchar2
  , svnRoot varchar2 := null
  , initialSvnPath varchar2 := null
)
return varchar2;

/* pfunc: startAppInstall
  Сохраняет информацию о начале установки приложения.
  Функция должна вызываться перед началом установки приложения, при этом после
  завершения установки приложения ( с успешным либо неуспешным результатом)
  должна быть вызвана функция <finishAppInstall>.

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
  deploymentPath              - путь для развертывания приложения
  installVersion              - устанавливаемая версия приложения
  svnPath                     - путь в Subversion, из которого были получены
                                файлы модуля ( начиная с имени репозитария,
                                null в случае отсутствия информации)
  svnVersionInfo              - информация о версии файлов модуля из Subversion
                                ( в формате вывода утилиты svnversion,
                                null в случае отсутствия информации)
  operatorId                  - Id оператора, выполняющего операцию
                                ( по умолчанию текущий)

  Возврат:
  Id добавленной записи ( поле app_install_result_id таблицы
  <mod_app_install_result>).

  Замечания:
  - при вызове функции очищается информация о текущей установленной версией
    приложения, т.к. считается, что ранее установленная версия приложения
    деинсталлируется перед установкой новой версии;

  ( <body::startAppInstall>)
*/
function startAppInstall(
  moduleSvnRoot varchar2
  , moduleInitialSvnPath varchar2
  , moduleVersion varchar2
  , deploymentPath varchar2
  , installVersion varchar2
  , svnPath varchar2 := null
  , svnVersionInfo varchar2 := null
  , operatorId integer := null
)
return integer;

/* pproc: finishAppInstall
  Сохраняет информацию о завершении установки приложения.

  Параметры:
  appInstallResultId          - Id записи о начале установки приложения,
                                который был возвращен функцией <startAppInstall>
  statusCode                  - Код результата выполнения установки
                                ( 0 означает отсутствие ошибок, при этом
                                  устанавливаемая версия становится текущей)
  errorMessage                - Текст сообщения об ошибках при выполнении
                                установки
                                ( сохраняются первые 4000 символов)
                                ( по умолчанию отсутствует)
  installDate                 - Дата завершения установки ( по умолчанию
                                текущая)
  operatorId                  - Id оператора, выполняющего операцию
                                ( по умолчанию текущий)

  Замечания:
  - параметр javaReturnCode является устаревшим и временно сохранен для
    обеспечения совместимости, вместо него следует использовать statusCode;

  ( <body::finishAppInstall>)
*/
procedure finishAppInstall(
  appInstallResultId integer
  , statusCode integer := null
  , errorMessage varchar2 := null
  , installDate date := null
  , operatorId integer := null
  , javaReturnCode integer := null
);

end pkg_ModuleInfo;
/
