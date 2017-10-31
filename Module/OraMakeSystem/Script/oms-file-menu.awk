# script: oms-file-menu.awk
# Скрипт для генерации части меню по файлам модуля.
# Вызывается в <oms-auto-doc>.

# Group: Функции-утилиты

# func: logMessage
# Выводит отладочное сообщение
#
# Параметры:
# msg                        - отладочное сообщение
# messageDebugLevel          - уровень отладочного сообщения
#
function logMessage(         \
  msg                        \
  , messageDebugLevel        \
)                            \
{ 
  if ( messageDebugLevel <= debugLevel) {
    print "# " commentLabel ": " msg;
  }  
}

# func: exitError
# Выводит сообщение об ошибке в stderr и завершает выполнение с кодом 1.
#
# Параметры:
# msg               - сообщение об ошибке
#
function exitError( msg) {
  print msg | "cat 1>&2";
  isFatalError = 1;
  exit 1;
}

# func: getPatternMatch
# Определяет количество вариантов соответствия шаблону, 
# содержащему символы "*" - означает произвольная строка символов.
# Рекурсивная функция.
# 
# Входные параметры:
#   patternString            - шаблон
#   checkedString            - проверяемая строка
#   asteriskNumber           - номер очередного выражения,
#                              соотв. "*"
#   recursionLevel           - уровень рекурсии
#
#   j                        - локальная переменная счётчика цикла
#   lMatchedCount            - локальная переменная 
#                              результат функции
#   lNextPatternStart        - локальная переменная 
#                              начало следующей части шаблона
#   lNextPatternEnd          - локальная переменная 
#                              коней следующей части шаблона
#   lStartPos                - локальная переменная  
#                              позиция, соотв. части шаблона, 
#                              в проверяемой строке
#   lRelativeStartPos        - локальная промежуточная переменная 
#                              для вычисления lStartPos
# 
# Выходные параметры: 
#   asteriskList             - массив выражений, соотв. "*"
#
function getPatternMatch(  \
  patternString \
  , checkedString \
  , asteriskList \
  , asteriskNumber \
  , recursionLevel \
  , j  \
  , lMatchedCount \
  , lNextPatternStart \
  , lNextPatternEnd \
  , lStartPos \
  , lRelativeStartPos \
) 
{
  logMessage( "getPatternMatch: (" \
    patternString \
    ", " checkedString \
    ", [asteriskList]" \
    ", " asteriskNumber \
    ", " recursionLevel \
    ", " j  \
    ", " lMatchedCount \
    ", " lNextPatternStart \
    ", " lNextPatternEnd \
    ", " lStartPos \
    ", " lRelativeStartPos \
    ")" \
    , 2 \
  );
                                       # Ищем первый значащий символ  
  lNextPatternStart = match( patternString, /[^\*]/);
                                       # Тривиальные случаи
  if( lNextPatternStart == 0 || patternString == checkedString) {
    logMessage( "trivial", 3);
    return 1;
                                       # Если шаблон начинается
                                       # не с "*"
  } else if ( lNextPatternStart == 1) {
    logMessage( "does not start with *", 3);
                                       # Ищем следующую часть шаблона
    lNextPatternStart = index( patternString, "*"); 
    if ( lNextPatternStart == 0) {
      lNextPatternStart = length( patternString)+1;
    }
                                       # Если первые части совпадают,
    if( \
      substr( checkedString, 1, lNextPatternStart-1) \
      == substr( patternString, 1, lNextPatternStart-1) \
    ){
                                       # то пробуем найти соответствие 
                                       # второй части                                       
      return \
        getPatternMatch( \
          substr( patternString, lNextPatternStart) \
          , substr( checkedString, lNextPatternStart) \
          , asteriskList \
          , asteriskNumber \
          , recursionLevel + 1 \
          , 0, 0, 0, 0, 0, 0 \
        );
    } else {
      return 0;
    }    
                                       # Шаблон начинается с "*"
  } else if (  lNextPatternStart > 1) {
    logMessage( "starts with *", 3);
                                       # Начало следующей части
                                       # шаблона
    if( lNextPatternStart == 0) {
      exitError( "Ошибка поиска следующей части шаблона:" \
        patternString \
      );
    }
                                       # Конец следующей части
                                       # шаблона
    lNextPatternEnd = \
      index( substr( patternString, lNextPatternStart), "*");
    if ( lNextPatternEnd != 0) {
      logMessage( "lNextPatternStart=" lNextPatternStart, 3);    
      logMessage( "lNextPatternEnd=" lNextPatternEnd, 3);    
      lNextPatternEnd = lNextPatternStart - 1 + lNextPatternEnd - 1;
      logMessage( "lNextPatternEnd=" lNextPatternEnd, 3);    
    } else {   
      lNextPatternEnd = length( patternString);
      logMessage( "lNextPatternEnd=" lNextPatternEnd, 3);    
    }  
    logMessage( "nextPatternPart=" \
      substr( \
        patternString \
        , lNextPatternStart \
        , lNextPatternEnd - lNextPatternStart + 1 \
      ) \
      , 3 \
    );
                                       # Пока не нашли совпадений       
    lMatchedCount = 0;   
                                       # Позиция для поиска части шаблона
                                       # в строке
    lStartPos = 0;
                                       # Защита от зацикливания  
    lSafeCycleCounter = 0;
    do {
      lSafeCycleCounter++;
      if( lSafeCycleCounter > 1000) {
        exitError( "Зацикливание при проверке соответствия строки шаблону");
      }
      lStartPos = lStartPos + 1;
      lRelativeStartPos = \
        index( \
          substr( checkedString, lStartPos) \
          , substr( \
              patternString \
              , lNextPatternStart \
              , lNextPatternEnd - lNextPatternStart + 1 \
            ) \
        );
      if ( lRelativeStartPos != 0) {  
        lStartPos = lRelativeStartPos + lStartPos - 1;
        logMessage( "lStartPos=" lStartPos, 3);
        asteriskList[ asteriskNumber] = substr( checkedString, 1, lStartPos-1);
                                       # Пробуем следующую часть шаблона
                                       # и строки                                       
        lMatchedCount = lMatchedCount + \
          getPatternMatch( \
            substr( patternString, lNextPatternEnd + 1) \
            , substr( \
                checkedString \
                , lStartPos + lNextPatternEnd - lNextPatternStart + 1 \
              ) \
            , asteriskList \
            , asteriskNumber + 1 \
            , recursionLevel + 1 \
            , 0, 0, 0, 0, 0, 0 \
          );        
      }  
    } while ( lRelativeStartPos != 0);
    return lMatchedCount;    
  } # Если шаблон начинается с "*" 
}

# Group: Разбор конфигурационного файла

# func: loadRuleString
# Разбирает строку с правилом и дополняет информацию
# в массивах
#
# Входные параметры:
#  
#  sourceString              - строка для разбора
#
function loadRuleString( sourceString) 
{
  split( sourceString, lStringList);
  ruleCount++;
  ruleList_Pattern[ ruleCount] =       \
    gensub( "_", " ", "g",             \
      gensub( "__", "_", "g", lStringList[1] ) \
    );    
  ruleList_GroupPath[ ruleCount] =      \
    gensub( "_", " ", "g",             \
      gensub( "__", "_", "g", lStringList[2] ) \
    );  
  ruleList_ItemName[ ruleCount] =       \
    gensub( "_", " ", "g",             \
      gensub( "__", "_", "g", lStringList[3] ) \
    );  
  logMessage( "", 1);
  logMessage( "add rule   : " ruleCount, 1);
  logMessage( "file path  : " ruleList_Pattern[ ruleCount], 1);
  logMessage( "group path : " ruleList_GroupPath[ ruleCount], 1);
  logMessage( "item name  : " ruleList_ItemName[ ruleCount], 1);
} 

# func: loadSortRuleString
# Разбирает строки с правилом для сортировки 
# и дополняет информацию в массивах. Не реализовано.
#
# Входные параметры:
#  
#  sourceString              - строка для разбора
#
function loadSortRuleString( sourceString) 
{
  logMessage( "loadSortRuleString: " sourceString, 3);
  lStartPos = 1;
  lEndPos = length( sourceString);
  if ( isInSortRule == 0) { 
    if ( match( sourceString, /\`[\_\t]*[^\_\t]*[\_\t]*\{/) == 1){
      isInSortRule = 1;
      logMessage( "isInSortRule=" isInSortRule, 3);
      bracketLevel = 1;
      lStartPos = index( sourceString, "{") + 1;
      sortRuleString = "";
    }
  } 
  if ( isInSortRule == 1) {
    for ( i = lStartPos; \
      i <= length( sourceString) && bracketLevel > 0; \
      i++ \
    ) {
      if ( substr( sourceString, i, 1) == "{") { 
        bracketLevel = bracketLevel + 1;
      } else if ( substr( sourceString, i, 1) == "}"){    
        bracketLevel = bracketLevel - 1; 
        if ( bracketLevel == 0) {
          lEndPos = i - 1;
        }  
      }
    }
    sortRuleString = sortRuleString \
      substr( sourceString, lStartPos, lEndPos - lStartPos + 1);
    ;  
    if ( bracketLevel <= 0) {
      logMessage( "sortRuleString=" sortRuleString, 2);
      isInSortRule = 0;
    }
  }  
}

# func: initSortRules
# Инициализирует правила для сортировки групп.
# 
# Приоритет сортировки групп:
#
# - Last
#
# Приоритет сортировки файлов:
#
#  - run.sql
#  - revert.sql
#  - readme.txt
#  - install.txt
#  - bugs.txt
#  - todo.txt
#  - Makefile
#  - version.txt
# 
function initSortRules()
{ 
  sortRuleList_PatternCount[1] = 1;
  sortRuleList_PatternList[1,1] = "Last";
  sortRuleList_PatternCount[2] = 7;
  sortRuleList_PatternList[2,1] = "run.sql";
  sortRuleList_PatternList[2,2] = "revert.sql";
  sortRuleList_PatternList[2,3] = "readme.txt";
  sortRuleList_PatternList[2,4] = "install.txt";
  sortRuleList_PatternList[2,5] = "bugs.txt";
  sortRuleList_PatternList[2,6] = "todo.txt";
  sortRuleList_PatternList[2,7] = "Makefile";
  sortRuleList_PatternList[2,8] = "version.txt";
} 

# func: loadConfigString
# Разбирает строку с настройками и дополняет информацию
# о настройках. 
# 
# Входные параметры:
# 
# $0                         - разбираемая строка
# 
function loadConfigString()
{ 
  logMessage( "loadConfigString: " $0, 2 );
  lString = "";
  isInQuotes = 0;
  for ( i=1; i<=length( $0); i++) {
    lChar = substr( $0, i, 1);
    if ( lChar == "\"") {
      isInQuotes = ! isInQuotes;
    } else  if ( isInQuotes && lChar == " ") {
      lString = lString "_";
    }    
    else if ( isInQuotes && lChar == "_") {
      lString = lString "__";
    } else {
      lString = lString lChar;
    }    
  }
  if ( $0 == "" && isFileRuleMode == 1) {
    isFileRuleMode = 0;
    logMessage( "isFileRuleMode=" isInSourceRule, 3);
    isInSortRule = 0;
    sortRuleString = "";
    initSortRules();
  }
  if ( isFileRuleMode == 1) { 
    loadRuleString( lString);
  } else { 
    loadSortRuleString( lString);
  }
}

# Group: Разбор файла меню

# func: parseFileString
# Разбирает строку с информацией о файле
# 
# Входные параметры:
#
# $0                         - разбираемая строка
#
# Выходные параметры:
# 
# itemName                   - имя пункта меню
# filePath                   - путь к файлу
#
function parseFileString()
{
  lItemNamePos = index( $0, "File: ");
                                       # Неверный формат строки 
  if ( lItemNamePos == 0) {
    exitError( "Неверный формат строки: не найдена строка 'File: '");
  } 
  lItemNamePos = lItemNamePos + length( "File: ");
  lLeftBracketPos = index( $0, "(");
                                       # Неверный формат строки 
  if ( lLeftBracketPos == 0 || lLeftBracketPos < lItemNamePos) {
    exitError( "Неверный формат строки: не найдена левая скобка");
  }
                                       # Имя пункта меню
  itemName = gensub(                   \
    /\`(\ )*|(\ )*\'/                  \
    , ""                               \
    , "g"                              \
    , substr( $0, lItemNamePos, lLeftBracketPos - lItemNamePos ) \
  );  
  logMessage( "itemName=" itemName, 3);
  $0 = substr( $0, lLeftBracketPos);
                                       # Пробуем найти крайнюю
                                       # правую скобку  
  lRightBracketPos = 0;
  lNextPos = 1;
                                       # Защита от зацикливания  
  lSafeCycleCounter = 0;
  while (lNextPos != 0) {
    lSafeCycleCounter++;
    if( lSafeCycleCounter > 1000) {
      exitError( "Зацикливание при поиске \")\"");
    }
    lNextPos = index( substr( $0, lRightBracketPos + 1), ")");
    if( lNextPos != 0) {
      lRightBracketPos = lRightBracketPos + lNextPos;  
    }
  }
  if ( lRightBracketPos == 0 ) {
    exitError( "Неверный формат строки: не найдена правая скобка");
  } 
  $0 = substr( $0, 1, lRightBracketPos);
                                       # Извлекаем путь из скобок
  filePath = gensub( /\`([\ \t])*\((.*)\)([\ \t])*\'/, "\\2", "g", $0)
                                       # Извлекаем строку no auto-title
  gsub( \
    /\`([\ \t]*)(no auto-title)([\ \t]*)(\,)([\ \t]*)/ \
    , "" \
    , filePath \
  );
  logMessage( "filePath=" filePath, 3);
}

# func: parseFilePath
# Разбирает строку с путём к файлу
# 
# Входные параметры:
# 
# filePath                   - путь к файлу
#
# Выходные параметры:
# 
# directoryPath              - путь к директории
# fileName                   - имя файла
# baseFileName               - базовое имя файла без расширения
# 
function parseFilePath( filePath) {
                                       # Извлекаем имя файла      
  lFileNamePos = match( filePath, /[^\/]*\'/);
  if ( lFileNamePos ==0) {
    exitError( "Невозможно извлечь имя файла: " filePath);
  }
  fileName = substr( filePath, lFileNamePos);
  logMessage( "fileName=" fileName, 3);
  directoryPath = \
    gensub( /\`\//, "", "g" \
    , gensub( /\'\//, "", "g" \
    , substr( filePath, 1, lFileNamePos-2) \
  )); 
  logMessage( "directoryPath=" directoryPath, 3);
                                        # Извлекаем имя файла    
                                        # без расширения
  baseFileName = \
    gensub( /\`(.*)\.([^\.]*)\'/, "\\1", "g", fileName);
                                        # Если в имени файла нет "."
  if ( baseFileName == "") {
    baseFileName = fileName;
  };  
  if ( baseFileName =="") {
    exitError( "Невозможно извлечь базовое имя файла: " fileName);
  }
}  

# func: substituteVariables
# Замена переменных в строке правила
#
# Входные параметры:
#
# sourceString               - исходная строка
# 
# fileName                   - имя файла
# baseFileName               - базовое имя файла ( без расширения)
# directoryPath              - путь к директории
# asterisk                   - массив, соотв. выражениям *
# 
# Возврат:
#   - строка с подстановленными значениями переменных.
# 
function substituteVariables( \
  sourceString \
) 
{
                                       # Заменяем переменные на значения        
  gsub( /\$\(fileName\)/, fileName, sourceString);
  gsub( /\$\(baseFileName\)/, baseFileName, sourceString);
  gsub( /\$\(directoryPath\)/, directoryPath, sourceString);
  gsub( /\$\(asterisk\)/, lAsterisk[1], sourceString);
  
                                       # Заменяем "//" на "/"
  gsub( /\/\//, "/", sourceString);
  return ( sourceString);
}

# func: loadFileString
# Разбирает считанную строку с информацией о файле
# и дополняет массивы, относящиеся к файлам 
#
# Входные параметры:
#
# $0                         - разбираемая строка
#
# ruleCount                  - количество правил
# ruleList_Pattern           - список шаблонов путей к файлам 
# ruleList_GroupPath         - список шаблонов путей к группам
# ruleList_ItemName          - список шаблонов имён пунктов меню
# 
# Изменяемые параметры:
#
# fileList_RuleCount         - массив количеств встретившихся для файла
#                              правил
# fileList_RuleNumberList    - списки номеров встретившихся правил
# ruleMaxCount               - максимальное количество встретившихся правил
#
# fileCount                  - количество файлов
# fileList_Path              - список путей к файлам
# fileList_ItemName          - список имён пунктов меню
# fileList_isDefiniteName    - список признаков ( 1-да, 0-нет)
#                              чётко определённого названия пункта меню
#                              ( соотв. no auto-title)
#
# fileList_groupPath         - список путей групп меню
#
function loadFileString()
{
  fileCount++;
  logMessage( "loadFileString: " $0, 2);
  parseFileString();
                                       # Путь группы ещё не найден
  lGroupPath = "";
                                       # Правила пока не найдены
  fileList_RuleCount[ fileCount] = 0;
                                       # Ищем подходящие правила,
  for( i = 1; i <= ruleCount; i++) {
                                       # Вычисляем количество вариантов    
    lPatternMatch = \
      getPatternMatch( \
        ruleList_Pattern[ i] \
        , filePath \
        , lAsterisk \
        , 1 \
        , 0 \
        , 0, 0, 0, 0, 0, 0 \
      );  
    logMessage( "lPatternMatch=" lPatternMatch, 2); 
                                       # Путь соответствует шаблону
                                       # правила
    if( lPatternMatch > 0) {
                                       # Запоминаем номер правила                                       
                                       # столько раз, сколько вариантов                                       
      for ( k = 1; k <= lPatternMatch; k++){
        fileList_RuleCount[ fileCount]++;                                         
        fileList_RuleNumberList[ fileCount, fileList_RuleCount[fileCount]] = i;
        logMessage( "fileList_RuleNumberList[ " fileCount ", " \
          fileList_RuleCount[fileCount] "]=" \
          fileList_RuleNumberList[ fileCount, fileList_RuleCount[ fileCount]] \
          , 3 \
        );   
      } 
                                       # Максимальное количество правил
                                       # для одного файла                                       
      if ( fileList_RuleCount[fileCount] > ruleMaxCount) {
        ruleMaxCount = fileList_RuleCount[fileCount];
        logMessage( "ruleMaxCount=" ruleMaxCount, 3);
      } 
                                       # Если нашли правило с группой
      if ( lGroupPath == "" && ruleList_GroupPath[ i] != "") { 
        logMessage( "ruleList_GroupPath[" i "]=" ruleList_GroupPath[ i], 3);
        parseFilePath( filePath);
        lGroupPath = substituteVariables( ruleList_GroupPath[ i]); 
        logMessage( "lGroupPath=" lGroupPath, 2);
        if ( lGroupPath == "") {
           exitError( "Итоговый путь для группы пуст: " filePath);
        }
        if ( ruleList_ItemName[ i] != "") {
          itemName = substituteVariables( ruleList_ItemName[ i]);   
          lIsDefiniteItemName = 1;
        }
        else {
          lIsDefiniteItemName = 0;
        } 
        logMessage( "lIsDefiniteItemName=" lIsDefiniteItemName, 3);
        logMessage( "itemName=" itemName, 3);
      } # Если нашли правило с группой
    } # Если нашли правило
  } # Цикл по правилам   
                                       # Если правило не нашли
  if ( lGroupPath == "") {
    exitError( "Не найдено правило для файла: " filePath);
  }
                                       # Добавляем данные файла
                                       # в массивы
  fileList_Path[ fileCount] = filePath;
  fileList_Name[ fileCount] = fileName;
  fileList_ItemName[ fileCount] = itemName;
  fileList_isDefiniteName[ fileCount] = lIsDefiniteItemName;
  fileList_groupPath[ fileCount] = lGroupPath;
}

# Group: Сортировка и вывод

# func: getComparedString
# Получает строку для сортировки
# В начале номера встретившихся правил
# затем путь без расширения, где все числа, между символами ".",
# преобразованы в строки, как 10 в степени 10 минус <исходное число>
# и дополнены нулями слева до 10 символов. Преобразует результат 
# в нижний регистр.
# 
# Входные параметры:
# 
# filePath                   - путь к файлу
# fileIndex                  - индекс файла
# ruleMaxCount               - максимальное количество встретившихся правил
# fileList_RuleNumberList    - списки номеров встретившихся правил
#  
# Возврат:
#   - строка для сортировки
#
function getComparedString( \
  filePath \
  , fileIndex \
  , ruleMaxCount \
  , fileList_RuleNumberList \
)  
{  
                                       # Составляем строки для сортировки
                                       # Результат функции
  lComparedString = "";
                                       # Максимальная длина номера правила  
  lMaxRuleLength = length( ruleCount);
  for( j = 1; j <= ruleMaxCount; j++ ){
                                       # Добавляем номера найденных правил
    if ( length( fileList_RuleNumberList[i]) > 10) {
      exitError( "Значение номера правила " fileList_RuleNumberList[i]  \
        " слишком велико");
    }
    lRuleNumber = fileList_RuleNumberList[ fileIndex, j];
                                       # Дополняем номер правила нулями слева
    lRuleNumberString = sprintf( \
      "%." lMaxRuleLength "d" \
      , ( lRuleNumber == "" ? 0 : lRuleNumber) \
    );
    lComparedString = lComparedString " " lRuleNumberString;
  }
                                       # Дополняем с концов символы "/"
                                       # для более простого поиска чисел
                                       # в строке                                       
  lFilePathString = \
    "/" gensub( /\`(.*)\.([^\.]*)\'/, "\\1", "g", filePath) "/";
  ;
  if ( lFilePathString == ""){
    lFilePathString = "/" filePath "/";
  }
  logMessage( "lFilePathString=" lFilePathString, 3);   
  lCurrentPos = 1;
  lNumberString = "";
                                       # Защита от зацикливания  
  lSafeCycleCounter = 0;
  do {
    lSafeCycleCounter++;
    if( lSafeCycleCounter > 1000) {
      exitError( "Зацикливание при получении строки для сортировки");
    }
                                       # Поиск числа в строке пути      
    lNumberPos = match( \
      substr( lFilePathString, lCurrentPos)  \
      , /(\/|\.)[0123456789]+(\/|\.)/    \
    );
    logMessage( "lNumberPos=" lNumberPos, 3);   
    if ( lNumberPos != 0) {
      lNumberPos = lNumberPos + lCurrentPos - 1; 
      lNumberString = substr( lFilePathString, lNumberPos, RLENGTH);
      logMessage( "lNumberString=" lNumberString, 3);  
      if( length( lNumberString) > 10 - 2) {
        exitError( "Слишком большое число в строке пути: " lFilePathString);
      }
                                       # Получаем разность
                                       # и дополняем число нулями слева
      lNewNumberString = sprintf( \
        "%.10d" \
        , lLastVersionNumber - \
            substr( lNumberString, 2, length( lNumberString) - 2) \
      );      
      logMessage( "lNewNumberString=" lNewNumberString, 3);  
                                     # Учитываем символы слева и справа
                                     # от числа                                                                               
      lFilePathString = \
        substr( lFilePathString, 1, lNumberPos) \
        lNewNumberString \
        substr( lFilePathString, lNumberPos + length( lNumberString) - 1) \
      ;
      lCurrentPos = lNumberPos + length( lNewNumberString) + 1;
    }  
  } while ( lNumberPos > 0) \
  ;
                                       # Удаляем символы "/" слева и справа  
  lComparedString = lComparedString " " \
    substr( lFilePathString, 2, length( lFilePathString)-2);
  return tolower( lComparedString);
}

# func: sortFiles
# Сортирует список файлов и связанных атрибутов
# согласно номерам правил и именам файлов
#
# Входные параметры:
# 
# fileList_RuleNumberList    - списки номеров встретившихся правил
# fileList_RuleCount         - массив количеств встретившихся правил
# ruleMaxCount               - максимальное количество встретившихся правил
# 
# Изменяемые параметры:
#
# fileList_Path              - список путей к файлам
# fileList_ItemName          - список чётко имён пунктов меню
# fileList_isDefiniteName    - список признаков ( 1-да, 0-нет)
#                              чётко определённого названия пункта меню
#                              ( соотв. no auto-title)
#
# fileList_groupPath         - список путей групп меню
# 
function sortFiles()
{
  logMessage( "", 1);
  logMessage( "sortFiles()", 1);
  logMessage( "", 1);
                                       # Максимальный номер версии
  lLastVersionNumber = 10^10-1;
  logMessage( "ruleMaxCount=" ruleMaxCount, 2);
  for ( i = 1; i <= fileCount; i++) {
                                       # Копируем массивы    
    lCopyFileList_Path[ i] = fileList_Path[ i];
    lCopyFileList_ItemName[ i] = fileList_ItemName[ i];
    lCopyFileList_isDefiniteName[ i] = fileList_isDefiniteName[ i];
    lCopyFileList_groupPath[ i] = fileList_groupPath[ i];
    lCopyFileList_Name[ i] = fileList_Name[ i];
                                       # Получаем строку для сортировки    
    lComparedString = \
      getComparedString( fileList_Path[ i], i, ruleMaxCount, fileList_RuleNumberList) " /" i;
    lComparedStringList[ i] = lComparedString;
    logMessage( "lComparedStringList[ " i "]=" lComparedStringList[ i], 1);   
  } 
  # Сортируем 
  lSortedCount = asort( lComparedStringList);
  logMessage( "lSortedCount=" lSortedCount, 3);
  for ( i = 1; i <= fileCount; i++){
    if ( match( lComparedStringList[ i], /\ \/[0123456789]+\'/) == 0) {
      exitError( "Ошибка поиска индекса файла в строке для сортировки: " \
        lComparedStringList[ i] \
      );  
    } 
    lFileIndex = substr( lComparedStringList[ i], RSTART + 2);
    logMessage( "lFileIndex=" lFileIndex, 3);
    fileList_Path[ i] = lCopyFileList_Path[ lFileIndex];
    fileList_ItemName[ i] = lCopyFileList_ItemName[ lFileIndex];
    fileList_isDefiniteName[ i] = lCopyFileList_isDefiniteName[ lFileIndex];
    fileList_groupPath[ i] = lCopyFileList_groupPath[ lFileIndex];
    fileList_Name[ i] = lCopyFileList_Name[ lFileIndex];
  }     
}

# func: addGroup
# Добавляет группу
# 
# Параметры:
# 
#   parentIndex              - индекс родительской группы
#   groupName                - имя группы
# 
# Возврат:
#   - индекс новой группы
# 
function addGroup( parentIndex, groupName)
{
                                       # Если не нашли, добавляем      
                                       # группу                                       
  groupCount++;
  groupList_Name[ groupCount] = groupName;
                                       # Новая группа пока без потомков      
  groupList_ChildCount[ groupCount] = 0;
  groupList_FileCount[ groupCount] = 0; 
                                       # Добавляем к потомкам текущей      
  groupList_ChildCount[ parentIndex]++;
  groupList_ChildIndexList[ \
    parentIndex \
    , groupList_ChildCount[ parentIndex] \
  ] = groupCount;
  groupList_ChildIndexByName[ parentIndex, groupName] = groupCount;
  groupList_SortRuleGroup[ groupCount] = 1;
  groupList_SortRuleFile[ groupCount] = 2;
                                       # Запоминаем путь группы  
  groupList_Path[ groupCount] = \
    gensub( /\`\\/, "", "g", groupList_Path[ parentIndex] "\\" groupName);
  logMessage( \
    "add group: \"" groupName "\"" \
    " child of \"" groupList_Name[ parentIndex] "\"" \
    " groupCount=" groupCount \
    , 2 \
  );
  return groupCount;
}  

# func: addFile
# Добавляет файл к формируемому списку групп и файлов 
#
# Входные параметры:
# 
# fileIndex                  - индекс файла в массивах 
#                                fileList_Path
#                                , fileList_ItemName
#                                , fileList_isDefiniteName
#                                , fileList_groupPath
# groupPath                  - путь к группе ( через разделитель "/" )
#
# Изменяемые параметры:
# 
# groupCount                 - количество групп
# groupList_Name             - список имён групп 
#                              ( в начале списка - одна родительская группа)
# groupList_ChildCount       - список длин массивов индексов дочерних групп
# groupList_ChildIndexList   - список массивов индексов дочерних групп 
#                              в массиве groupList_Name
# groupList_FileCount        - список длин массивов индексов дочерних файлов
# groupList_FileIndexList    - списки индексов дочерних файлов
#
# groupList_ChildIndexByName - списки индексов дочерних групп 
#                              в массиве groupList_Name по именам
#
# groupList_Path             - список путей групп
#
function addFile( fileIndex, groupPath)
{
  logMessage( \
    "add: file path: \"" fileList_Path[ fileIndex] "\"" \
    ", group path: \"" groupPath "\"" \
    , 2 \
  );
                                       # Удаляем пробелы,
                                       # и символы "/" вначале и в конце                                       
  gsub( /\`[\/\ \t]*/, "", groupPath);
  gsub( /[\/\ \t]*\'/, "", groupPath);
  lGroupPathPartCount = split( groupPath, lGroupPathPartList, /\//); 
                                       # Начинаем поиск с корневой группы  
  lCurrentGroupIndex = 0;
                                       # Используем j, так как
                                       # i уже используется во внешнем цикле
  for( j = 1; j <= lGroupPathPartCount; j++) {
                                       # Пробуем найти существующую группу  
    lSearchedGroupIndex = \
      groupList_ChildIndexByName[ lCurrentGroupIndex, lGroupPathPartList[j]];
    logMessage( "lSearchedGroupIndex=" lSearchedGroupIndex, 3);  
                                       # Если группа уже есть    
    if ( lSearchedGroupIndex != "") {
      lCurrentGroupIndex = lSearchedGroupIndex;
    } else {

      lCurrentGroupIndex = addGroup( \
        lCurrentGroupIndex \
        , lGroupPathPartList[j] \
      );
      logMessage( "addGroup: lCurrentGroupIndex=" lSearchedGroupIndex, 3); 
    } 
    logMessage( "lCurrentGroupIndex=" lSearchedGroupIndex, 3);  
  };
                                       # Дошли до конечной группы в пути
                                       # Можно добавлять ссылку на файл
  groupList_FileCount[ lCurrentGroupIndex]++;
  groupList_FileIndexList[ \
    lCurrentGroupIndex \
    , groupList_FileCount[ lCurrentGroupIndex] \
  ] = fileIndex; 
  logMessage( "groupList_FileCount[ " lCurrentGroupIndex "]=" \
    groupList_FileCount[ lCurrentGroupIndex] \
    , 3 \
  );   
  logMessage( "groupList_Path[ " lCurrentGroupIndex "]=" \
    groupList_Path[ lCurrentGroupIndex] \
    , 3 \
  );   
}

# func: createGroups
# Формируем список групп
#
# Входные параметры:
# 
# fileCount                  - количество файлов
# fileList_Path              - список путей к файлам
# fileList_ItemName          - список чётко имён пунктов меню
# fileList_isDefiniteName    - список признаков ( 1-да, 0-нет)
#                              чётко определённого названия пункта меню
#                              ( соотв. no auto-title)
#
# fileList_groupPath         - список путей групп меню
#
# Выходные параметры:
# 
# groupCount                  - количество групп
# groupList_Name              - список имён групп 
#                              ( в начале списка - одна родительская группа)
# groupList_ChildIndexList        - список массивов индексов дочерних групп 
#                              в массиве groupList_Name
# groupList_ChildCount        - список длин массивов индексов дочерних групп
# groupList_FileCount         - список длин массивов индексов дочерних файлов
# groupList_FileIndexList     - списки индексов дочерних файлов
#
function createGroups()
{ 
  logMessage( "", 1);
  logMessage( "createGroups()", 1);
  logMessage( "", 1);
                                       # Под индексом ноль корневая группа  
  groupCount = 0;
  groupList_ChildCount[ groupCount, 0] = 0;
  groupList_FileCount[ groupCount, 0] = 0;
  for ( i=1; i<= fileCount; i++) {
    addFile( i, fileList_groupPath[i]);
  }  
}

# func: printFiles
# Выводит файлы для группы
# 
# Входные параметры:
# 
# groupIndex                 - индекс группы 
# level                      - уровень вложенности группы
# i                          - локальная переменная для индекса
# 
# groupList_FileCount        - список длин массивов индексов дочерних файлов
# groupList_FileIndexList    - списки индексов дочерних файлов
#
# fileList_Path              - список путей к файлам
# fileList_ItemName          - список чётко имён пунктов меню
# fileList_isDefiniteName    - список признаков ( 1-да, 0-нет)
#                              чётко определённого названия пункта меню
#                              ( соотв. no auto-title)
function printFiles( groupIndex, level, i, j) 
{
  if ( level == 0) {
    exitError( "Файл не может находиться на нулевом уровне");
  }
  lFileSortRule = groupList_SortRuleFile[ groupIndex];
  logMessage( "lFileSortRule=" lFileSortRule, 3);
  lPatternCount = sortRuleList_PatternCount[ lFileSortRule];
  logMessage( "lPatternCount=" lPatternCount, 3);
  logMessage( "groupList_FileCount[ " groupIndex "]=" \
    groupList_FileCount[ groupIndex] \
    , 3 \
  );
  logMessage( "groupList_Path[ " groupIndex "]=" \
    groupList_Path[ groupIndex] \
    , 3 \
  );
                                       # Ещё не напечатана
                                       # строка ни для одного файла                                       
  for ( j = 1; j <= groupList_FileCount[ groupIndex]; j++) {
    lIsPrinted[ j] = 0;
  }
  for( i = 1; i <= lPatternCount + 1; i++) {
    for( j = 1; j <= groupList_FileCount[ groupIndex]; j++) {
      if( lIsPrinted[ j] == 0) {
        lFileIndex = groupList_FileIndexList[ groupIndex, j];
                                       # Если имя файла подошло
                                       # или "прошли" все шаблоны
        if ( i == lPatternCount + 1 || \
          getPatternMatch( \
            sortRuleList_PatternList[ lFileSortRule, i] \
            , fileList_Name[ lFileIndex] \
            , lAsterisk \
            , 1 \
            , 0 \
            , 0, 0, 0, 0, 0, 0 \
          ) > 0 \
        ) { 
          printf( "%" ( level * 2) "s", "");
          print "File: " fileList_ItemName[ lFileIndex] \
             "  (" \
             ( fileList_isDefiniteName[ lFileIndex] == 1 \
                ? "no auto-title, " : "" \
             ) \
             fileList_Path[lFileIndex] \
             ")" \
          ;
          lIsPrinted[ j] = 1;
        } # Если удовлетворяют шаблону
      } # Если строка ещё не напечатана
    } # Цикл по файлам
  } # Цикл по шаблонам для сортировки 
} 

# func: printGroups
# Выводит список групп и файлов в формате меню Natural Docs.
# Рекурсивная функция
#
# Входные параметры:
# 
# groupIndex                 - индекс текушей группы
# level                      - уровень вложенности группы
# i                          - локальная переменная для индекса
#
# groupCount                 - количество групп
# groupList_Name             - список имён групп 
#                              ( в начале списка - одна родительская группа)
# groupList_ChildCount       - список длин массивов индексов дочерних групп
# groupList_ChildIndexList   - список массивов индексов дочерних групп 
#                              в массиве groupList_Name
# groupList_FileCount        - список длин массивов индексов дочерних файлов
# groupList_FileIndexList    - списки индексов дочерних файлов
#
# fileCount                  - количество файлов
# fileList_Path              - список путей к файлам
# fileList_ItemName          - список чётко имён пунктов меню
# fileList_isDefiniteName    - список признаков ( 1-да, 0-нет)
#                              чётко определённого названия пункта меню
#                              ( соотв. no auto-title)
#
function printGroups( \
  groupIndex \
  , level \
  , i, j, lGroupSortRule, lPatternCount \
) 
{
  if ( level > 0 ) {
    printf( "%" ( ( level - 1)* 2) "s", "");
    print "Group: " groupList_Name[ groupIndex] "  {";
    print "";
    if ( isItemFirst == 1) {
      printFiles( groupIndex, level, 0, 0);
      if ( groupList_FileCount[ groupIndex] > 0 \
          && groupList_ChildCount[ groupIndex] > 0 \
      ){ 
        print "";
      }
    }
  }  else {
    logMessage( "", 1);
    logMessage( "printGroups()", 1);
    logMessage( "", 1);  
  }  
  lGroupSortRule = groupList_SortRuleGroup[ groupIndex];
  lPatternCount = sortRuleList_PatternCount[ lGroupSortRule];
                                       # Ещё не напечатана
                                       # ни одна группа
  for ( j = 1; j <= groupList_ChildCount[ groupIndex]; j++) {
    lIsGroupPrinted[ level, j] = 0;
  }
  for( i = 1; i <= lPatternCount + 1; i++) {
    for( j = 1; j <= groupList_ChildCount[ groupIndex]; j++) {
                                       # Если группа ещё не напечатана    
      if( lIsGroupPrinted[ level, j] == 0) {
        lChildGroupIndex = groupList_ChildIndexList[ groupIndex, j];
                                       # Если имя группы подошло
                                       # или "прошли" все шаблоны
        if ( i == lPatternCount + 1 || \
          getPatternMatch( \
            sortRuleList_PatternList[ lGroupSortRule, i] \
            , groupList_Name[ lChildGroupIndex] \
            , lAsterisk \
            , 1 \
            , 0 \
            , 0, 0, 0, 0, 0, 0 \
          ) > 0 \
        ) { 
          printGroups( lChildGroupIndex, level+1, 0, 0, 0, 0);
          lIsGroupPrinted[ level, j] = 1;
        } # Если удовлетворяют шаблону
      } # Если строка ещё не напечатана
    } # Цикл по дочерним группам
  } # Цикл по шаблонам для сортировки 
  logMessage( "groupList_ChildCount[ " groupIndex "]=" \
    groupList_ChildCount[ groupIndex] \
    , 4 \
  );
  if ( level > 0 ) {
    if ( isItemFirst != 1) {
      printFiles( groupIndex, level, 0, 0);
    }  
    printf( "%" ( level * 2) "s", "");
    print "}  # Group: " groupList_Name[ groupIndex];
    print "";
  }  
}

# Инициализация чтения потока
BEGIN {
                                       # Режим чтения настроек
  isConfigMode = 1;
                                       # Режим чтения правил
                                       # В начале идут правила
  isFileRuleMode = 1;
  logMessage( "files ( debugLevel=" debugLevel ")", 1);
                                       # При выводе вначеле идут пункты
                                       # меню ( файлы)                                       
  logMessage( "isItemFirst=" isItemFirst, 1);
                                       # Инициализируем счётчики
  fileCount = 0;
  ruleCount = 0;
                                       # максимальное количество 
                                       # встретившихся правил
  ruleMaxCount = 0;
}  

# Блок для чтения строк потока
# 
# Вызывает <loadConfigString> или <loadFileString>.
#
{ 
  isComment = match( $0, /[\ \t]*\#.*/);
  if( isComment != 1) {
    isFileMatched = ( match( $0, /[^\#]*File: .*\(.*.)/) == 1);
    if ( isConfigMode == 1) {
                                       # Если встретили
                                       # пункт меню для файла                                       
      if ( isFileMatched) {
                                       # считаем, что правила 
                                       # закончились                                      
        isConfigMode = 0;
        logMessage( "isConfigMode=" isConfigMode, 3);
        logMessage( "ruleCount=" ruleCount, 3);
      }
    } 
    if ( isConfigMode == 1) {
                                       # Дополняем массивы правил
      loadConfigString();
    } else if ( isFileMatched) {
                                       # Дополняем массивы файлов
                                       # используя массивы правил
      loadFileString();  
    }
  }  
}

END {
                                       # Сортируем считанные файлы                         
                                       # Входными данными являются
                                       # данные о файлах
  sortFiles();  
                                       # Формируем группы
                                       # Входными данными являются данные
                                       # файлов                                       
                                       # Выходными данными являются массивы
                                       # атрибутов групп
  createGroups();
                                       # Рекурсивно выводим группы
                                       # Входными данными являются 
                                       # данные файлов и о группах
  printGroups( 0, 0, 0, 0, 0, 0);  
}