# script: oms-file-menu.awk
# ������ ��� ��������� ����� ���� �� ������ ������.
# ���������� � <oms-auto-doc>.

# Group: �������-�������

# func: logMessage
# ������� ���������� ���������
#
# ���������:
# msg                        - ���������� ���������
# messageDebugLevel          - ������� ����������� ���������
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
# ������� ��������� �� ������ � stderr � ��������� ���������� � ����� 1.
#
# ���������:
# msg               - ��������� �� ������
#
function exitError( msg) {
  print msg | "cat 1>&2";
  isFatalError = 1;
  exit 1;
}

# func: getPatternMatch
# ���������� ���������� ��������� ������������ �������, 
# ����������� ������� "*" - �������� ������������ ������ ��������.
# ����������� �������.
# 
# ������� ���������:
#   patternString            - ������
#   checkedString            - ����������� ������
#   asteriskNumber           - ����� ���������� ���������,
#                              �����. "*"
#   recursionLevel           - ������� ��������
#
#   j                        - ��������� ���������� �������� �����
#   lMatchedCount            - ��������� ���������� 
#                              ��������� �������
#   lNextPatternStart        - ��������� ���������� 
#                              ������ ��������� ����� �������
#   lNextPatternEnd          - ��������� ���������� 
#                              ����� ��������� ����� �������
#   lStartPos                - ��������� ����������  
#                              �������, �����. ����� �������, 
#                              � ����������� ������
#   lRelativeStartPos        - ��������� ������������� ���������� 
#                              ��� ���������� lStartPos
# 
# �������� ���������: 
#   asteriskList             - ������ ���������, �����. "*"
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
                                       # ���� ������ �������� ������  
  lNextPatternStart = match( patternString, /[^\*]/);
                                       # ����������� ������
  if( lNextPatternStart == 0 || patternString == checkedString) {
    logMessage( "trivial", 3);
    return 1;
                                       # ���� ������ ����������
                                       # �� � "*"
  } else if ( lNextPatternStart == 1) {
    logMessage( "does not start with *", 3);
                                       # ���� ��������� ����� �������
    lNextPatternStart = index( patternString, "*"); 
    if ( lNextPatternStart == 0) {
      lNextPatternStart = length( patternString)+1;
    }
                                       # ���� ������ ����� ���������,
    if( \
      substr( checkedString, 1, lNextPatternStart-1) \
      == substr( patternString, 1, lNextPatternStart-1) \
    ){
                                       # �� ������� ����� ������������ 
                                       # ������ �����                                       
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
                                       # ������ ���������� � "*"
  } else if (  lNextPatternStart > 1) {
    logMessage( "starts with *", 3);
                                       # ������ ��������� �����
                                       # �������
    if( lNextPatternStart == 0) {
      exitError( "������ ������ ��������� ����� �������:" \
        patternString \
      );
    }
                                       # ����� ��������� �����
                                       # �������
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
                                       # ���� �� ����� ����������       
    lMatchedCount = 0;   
                                       # ������� ��� ������ ����� �������
                                       # � ������
    lStartPos = 0;
                                       # ������ �� ������������  
    lSafeCycleCounter = 0;
    do {
      lSafeCycleCounter++;
      if( lSafeCycleCounter > 1000) {
        exitError( "������������ ��� �������� ������������ ������ �������");
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
                                       # ������� ��������� ����� �������
                                       # � ������                                       
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
  } # ���� ������ ���������� � "*" 
}

# Group: ������ ����������������� �����

# func: loadRuleString
# ��������� ������ � �������� � ��������� ����������
# � ��������
#
# ������� ���������:
#  
#  sourceString              - ������ ��� �������
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
# ��������� ������ � �������� ��� ���������� 
# � ��������� ���������� � ��������. �� �����������.
#
# ������� ���������:
#  
#  sourceString              - ������ ��� �������
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
# �������������� ������� ��� ���������� �����.
# 
# ��������� ���������� �����:
#
# - Last
#
# ��������� ���������� ������:
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
# ��������� ������ � ����������� � ��������� ����������
# � ����������. 
# 
# ������� ���������:
# 
# $0                         - ����������� ������
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

# Group: ������ ����� ����

# func: parseFileString
# ��������� ������ � ����������� � �����
# 
# ������� ���������:
#
# $0                         - ����������� ������
#
# �������� ���������:
# 
# itemName                   - ��� ������ ����
# filePath                   - ���� � �����
#
function parseFileString()
{
  lItemNamePos = index( $0, "File: ");
                                       # �������� ������ ������ 
  if ( lItemNamePos == 0) {
    exitError( "�������� ������ ������: �� ������� ������ 'File: '");
  } 
  lItemNamePos = lItemNamePos + length( "File: ");
  lLeftBracketPos = index( $0, "(");
                                       # �������� ������ ������ 
  if ( lLeftBracketPos == 0 || lLeftBracketPos < lItemNamePos) {
    exitError( "�������� ������ ������: �� ������� ����� ������");
  }
                                       # ��� ������ ����
  itemName = gensub(                   \
    /\`(\ )*|(\ )*\'/                  \
    , ""                               \
    , "g"                              \
    , substr( $0, lItemNamePos, lLeftBracketPos - lItemNamePos ) \
  );  
  logMessage( "itemName=" itemName, 3);
  $0 = substr( $0, lLeftBracketPos);
                                       # ������� ����� �������
                                       # ������ ������  
  lRightBracketPos = 0;
  lNextPos = 1;
                                       # ������ �� ������������  
  lSafeCycleCounter = 0;
  while (lNextPos != 0) {
    lSafeCycleCounter++;
    if( lSafeCycleCounter > 1000) {
      exitError( "������������ ��� ������ \")\"");
    }
    lNextPos = index( substr( $0, lRightBracketPos + 1), ")");
    if( lNextPos != 0) {
      lRightBracketPos = lRightBracketPos + lNextPos;  
    }
  }
  if ( lRightBracketPos == 0 ) {
    exitError( "�������� ������ ������: �� ������� ������ ������");
  } 
  $0 = substr( $0, 1, lRightBracketPos);
                                       # ��������� ���� �� ������
  filePath = gensub( /\`([\ \t])*\((.*)\)([\ \t])*\'/, "\\2", "g", $0)
                                       # ��������� ������ no auto-title
  gsub( \
    /\`([\ \t]*)(no auto-title)([\ \t]*)(\,)([\ \t]*)/ \
    , "" \
    , filePath \
  );
  logMessage( "filePath=" filePath, 3);
}

# func: parseFilePath
# ��������� ������ � ���� � �����
# 
# ������� ���������:
# 
# filePath                   - ���� � �����
#
# �������� ���������:
# 
# directoryPath              - ���� � ����������
# fileName                   - ��� �����
# baseFileName               - ������� ��� ����� ��� ����������
# 
function parseFilePath( filePath) {
                                       # ��������� ��� �����      
  lFileNamePos = match( filePath, /[^\/]*\'/);
  if ( lFileNamePos ==0) {
    exitError( "���������� ������� ��� �����: " filePath);
  }
  fileName = substr( filePath, lFileNamePos);
  logMessage( "fileName=" fileName, 3);
  directoryPath = \
    gensub( /\`\//, "", "g" \
    , gensub( /\'\//, "", "g" \
    , substr( filePath, 1, lFileNamePos-2) \
  )); 
  logMessage( "directoryPath=" directoryPath, 3);
                                        # ��������� ��� �����    
                                        # ��� ����������
  baseFileName = \
    gensub( /\`(.*)\.([^\.]*)\'/, "\\1", "g", fileName);
                                        # ���� � ����� ����� ��� "."
  if ( baseFileName == "") {
    baseFileName = fileName;
  };  
  if ( baseFileName =="") {
    exitError( "���������� ������� ������� ��� �����: " fileName);
  }
}  

# func: substituteVariables
# ������ ���������� � ������ �������
#
# ������� ���������:
#
# sourceString               - �������� ������
# 
# fileName                   - ��� �����
# baseFileName               - ������� ��� ����� ( ��� ����������)
# directoryPath              - ���� � ����������
# asterisk                   - ������, �����. ���������� *
# 
# �������:
#   - ������ � ���������������� ���������� ����������.
# 
function substituteVariables( \
  sourceString \
) 
{
                                       # �������� ���������� �� ��������        
  gsub( /\$\(fileName\)/, fileName, sourceString);
  gsub( /\$\(baseFileName\)/, baseFileName, sourceString);
  gsub( /\$\(directoryPath\)/, directoryPath, sourceString);
  gsub( /\$\(asterisk\)/, lAsterisk[1], sourceString);
  
                                       # �������� "//" �� "/"
  gsub( /\/\//, "/", sourceString);
  return ( sourceString);
}

# func: loadFileString
# ��������� ��������� ������ � ����������� � �����
# � ��������� �������, ����������� � ������ 
#
# ������� ���������:
#
# $0                         - ����������� ������
#
# ruleCount                  - ���������� ������
# ruleList_Pattern           - ������ �������� ����� � ������ 
# ruleList_GroupPath         - ������ �������� ����� � �������
# ruleList_ItemName          - ������ �������� ��� ������� ����
# 
# ���������� ���������:
#
# fileList_RuleCount         - ������ ��������� ������������� ��� �����
#                              ������
# fileList_RuleNumberList    - ������ ������� ������������� ������
# ruleMaxCount               - ������������ ���������� ������������� ������
#
# fileCount                  - ���������� ������
# fileList_Path              - ������ ����� � ������
# fileList_ItemName          - ������ ��� ������� ����
# fileList_isDefiniteName    - ������ ��������� ( 1-��, 0-���)
#                              ����� ������������ �������� ������ ����
#                              ( �����. no auto-title)
#
# fileList_groupPath         - ������ ����� ����� ����
#
function loadFileString()
{
  fileCount++;
  logMessage( "loadFileString: " $0, 2);
  parseFileString();
                                       # ���� ������ ��� �� ������
  lGroupPath = "";
                                       # ������� ���� �� �������
  fileList_RuleCount[ fileCount] = 0;
                                       # ���� ���������� �������,
  for( i = 1; i <= ruleCount; i++) {
                                       # ��������� ���������� ���������    
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
                                       # ���� ������������� �������
                                       # �������
    if( lPatternMatch > 0) {
                                       # ���������� ����� �������                                       
                                       # ������� ���, ������� ���������                                       
      for ( k = 1; k <= lPatternMatch; k++){
        fileList_RuleCount[ fileCount]++;                                         
        fileList_RuleNumberList[ fileCount, fileList_RuleCount[fileCount]] = i;
        logMessage( "fileList_RuleNumberList[ " fileCount ", " \
          fileList_RuleCount[fileCount] "]=" \
          fileList_RuleNumberList[ fileCount, fileList_RuleCount[ fileCount]] \
          , 3 \
        );   
      } 
                                       # ������������ ���������� ������
                                       # ��� ������ �����                                       
      if ( fileList_RuleCount[fileCount] > ruleMaxCount) {
        ruleMaxCount = fileList_RuleCount[fileCount];
        logMessage( "ruleMaxCount=" ruleMaxCount, 3);
      } 
                                       # ���� ����� ������� � �������
      if ( lGroupPath == "" && ruleList_GroupPath[ i] != "") { 
        logMessage( "ruleList_GroupPath[" i "]=" ruleList_GroupPath[ i], 3);
        parseFilePath( filePath);
        lGroupPath = substituteVariables( ruleList_GroupPath[ i]); 
        logMessage( "lGroupPath=" lGroupPath, 2);
        if ( lGroupPath == "") {
           exitError( "�������� ���� ��� ������ ����: " filePath);
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
      } # ���� ����� ������� � �������
    } # ���� ����� �������
  } # ���� �� ��������   
                                       # ���� ������� �� �����
  if ( lGroupPath == "") {
    exitError( "�� ������� ������� ��� �����: " filePath);
  }
                                       # ��������� ������ �����
                                       # � �������
  fileList_Path[ fileCount] = filePath;
  fileList_Name[ fileCount] = fileName;
  fileList_ItemName[ fileCount] = itemName;
  fileList_isDefiniteName[ fileCount] = lIsDefiniteItemName;
  fileList_groupPath[ fileCount] = lGroupPath;
}

# Group: ���������� � �����

# func: getComparedString
# �������� ������ ��� ����������
# � ������ ������ ������������� ������
# ����� ���� ��� ����������, ��� ��� �����, ����� ��������� ".",
# ������������� � ������, ��� 10 � ������� 10 ����� <�������� �����>
# � ��������� ������ ����� �� 10 ��������. ����������� ��������� 
# � ������ �������.
# 
# ������� ���������:
# 
# filePath                   - ���� � �����
# fileIndex                  - ������ �����
# ruleMaxCount               - ������������ ���������� ������������� ������
# fileList_RuleNumberList    - ������ ������� ������������� ������
#  
# �������:
#   - ������ ��� ����������
#
function getComparedString( \
  filePath \
  , fileIndex \
  , ruleMaxCount \
  , fileList_RuleNumberList \
)  
{  
                                       # ���������� ������ ��� ����������
                                       # ��������� �������
  lComparedString = "";
                                       # ������������ ����� ������ �������  
  lMaxRuleLength = length( ruleCount);
  for( j = 1; j <= ruleMaxCount; j++ ){
                                       # ��������� ������ ��������� ������
    if ( length( fileList_RuleNumberList[i]) > 10) {
      exitError( "�������� ������ ������� " fileList_RuleNumberList[i]  \
        " ������� ������");
    }
    lRuleNumber = fileList_RuleNumberList[ fileIndex, j];
                                       # ��������� ����� ������� ������ �����
    lRuleNumberString = sprintf( \
      "%." lMaxRuleLength "d" \
      , ( lRuleNumber == "" ? 0 : lRuleNumber) \
    );
    lComparedString = lComparedString " " lRuleNumberString;
  }
                                       # ��������� � ������ ������� "/"
                                       # ��� ����� �������� ������ �����
                                       # � ������                                       
  lFilePathString = \
    "/" gensub( /\`(.*)\.([^\.]*)\'/, "\\1", "g", filePath) "/";
  ;
  if ( lFilePathString == ""){
    lFilePathString = "/" filePath "/";
  }
  logMessage( "lFilePathString=" lFilePathString, 3);   
  lCurrentPos = 1;
  lNumberString = "";
                                       # ������ �� ������������  
  lSafeCycleCounter = 0;
  do {
    lSafeCycleCounter++;
    if( lSafeCycleCounter > 1000) {
      exitError( "������������ ��� ��������� ������ ��� ����������");
    }
                                       # ����� ����� � ������ ����      
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
        exitError( "������� ������� ����� � ������ ����: " lFilePathString);
      }
                                       # �������� ��������
                                       # � ��������� ����� ������ �����
      lNewNumberString = sprintf( \
        "%.10d" \
        , lLastVersionNumber - \
            substr( lNumberString, 2, length( lNumberString) - 2) \
      );      
      logMessage( "lNewNumberString=" lNewNumberString, 3);  
                                     # ��������� ������� ����� � ������
                                     # �� �����                                                                               
      lFilePathString = \
        substr( lFilePathString, 1, lNumberPos) \
        lNewNumberString \
        substr( lFilePathString, lNumberPos + length( lNumberString) - 1) \
      ;
      lCurrentPos = lNumberPos + length( lNewNumberString) + 1;
    }  
  } while ( lNumberPos > 0) \
  ;
                                       # ������� ������� "/" ����� � ������  
  lComparedString = lComparedString " " \
    substr( lFilePathString, 2, length( lFilePathString)-2);
  return tolower( lComparedString);
}

# func: sortFiles
# ��������� ������ ������ � ��������� ���������
# �������� ������� ������ � ������ ������
#
# ������� ���������:
# 
# fileList_RuleNumberList    - ������ ������� ������������� ������
# fileList_RuleCount         - ������ ��������� ������������� ������
# ruleMaxCount               - ������������ ���������� ������������� ������
# 
# ���������� ���������:
#
# fileList_Path              - ������ ����� � ������
# fileList_ItemName          - ������ ����� ��� ������� ����
# fileList_isDefiniteName    - ������ ��������� ( 1-��, 0-���)
#                              ����� ������������ �������� ������ ����
#                              ( �����. no auto-title)
#
# fileList_groupPath         - ������ ����� ����� ����
# 
function sortFiles()
{
  logMessage( "", 1);
  logMessage( "sortFiles()", 1);
  logMessage( "", 1);
                                       # ������������ ����� ������
  lLastVersionNumber = 10^10-1;
  logMessage( "ruleMaxCount=" ruleMaxCount, 2);
  for ( i = 1; i <= fileCount; i++) {
                                       # �������� �������    
    lCopyFileList_Path[ i] = fileList_Path[ i];
    lCopyFileList_ItemName[ i] = fileList_ItemName[ i];
    lCopyFileList_isDefiniteName[ i] = fileList_isDefiniteName[ i];
    lCopyFileList_groupPath[ i] = fileList_groupPath[ i];
    lCopyFileList_Name[ i] = fileList_Name[ i];
                                       # �������� ������ ��� ����������    
    lComparedString = \
      getComparedString( fileList_Path[ i], i, ruleMaxCount, fileList_RuleNumberList) " /" i;
    lComparedStringList[ i] = lComparedString;
    logMessage( "lComparedStringList[ " i "]=" lComparedStringList[ i], 1);   
  } 
  # ��������� 
  lSortedCount = asort( lComparedStringList);
  logMessage( "lSortedCount=" lSortedCount, 3);
  for ( i = 1; i <= fileCount; i++){
    if ( match( lComparedStringList[ i], /\ \/[0123456789]+\'/) == 0) {
      exitError( "������ ������ ������� ����� � ������ ��� ����������: " \
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
# ��������� ������
# 
# ���������:
# 
#   parentIndex              - ������ ������������ ������
#   groupName                - ��� ������
# 
# �������:
#   - ������ ����� ������
# 
function addGroup( parentIndex, groupName)
{
                                       # ���� �� �����, ���������      
                                       # ������                                       
  groupCount++;
  groupList_Name[ groupCount] = groupName;
                                       # ����� ������ ���� ��� ��������      
  groupList_ChildCount[ groupCount] = 0;
  groupList_FileCount[ groupCount] = 0; 
                                       # ��������� � �������� �������      
  groupList_ChildCount[ parentIndex]++;
  groupList_ChildIndexList[ \
    parentIndex \
    , groupList_ChildCount[ parentIndex] \
  ] = groupCount;
  groupList_ChildIndexByName[ parentIndex, groupName] = groupCount;
  groupList_SortRuleGroup[ groupCount] = 1;
  groupList_SortRuleFile[ groupCount] = 2;
                                       # ���������� ���� ������  
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
# ��������� ���� � ������������ ������ ����� � ������ 
#
# ������� ���������:
# 
# fileIndex                  - ������ ����� � �������� 
#                                fileList_Path
#                                , fileList_ItemName
#                                , fileList_isDefiniteName
#                                , fileList_groupPath
# groupPath                  - ���� � ������ ( ����� ����������� "/" )
#
# ���������� ���������:
# 
# groupCount                 - ���������� �����
# groupList_Name             - ������ ��� ����� 
#                              ( � ������ ������ - ���� ������������ ������)
# groupList_ChildCount       - ������ ���� �������� �������� �������� �����
# groupList_ChildIndexList   - ������ �������� �������� �������� ����� 
#                              � ������� groupList_Name
# groupList_FileCount        - ������ ���� �������� �������� �������� ������
# groupList_FileIndexList    - ������ �������� �������� ������
#
# groupList_ChildIndexByName - ������ �������� �������� ����� 
#                              � ������� groupList_Name �� ������
#
# groupList_Path             - ������ ����� �����
#
function addFile( fileIndex, groupPath)
{
  logMessage( \
    "add: file path: \"" fileList_Path[ fileIndex] "\"" \
    ", group path: \"" groupPath "\"" \
    , 2 \
  );
                                       # ������� �������,
                                       # � ������� "/" ������� � � �����                                       
  gsub( /\`[\/\ \t]*/, "", groupPath);
  gsub( /[\/\ \t]*\'/, "", groupPath);
  lGroupPathPartCount = split( groupPath, lGroupPathPartList, /\//); 
                                       # �������� ����� � �������� ������  
  lCurrentGroupIndex = 0;
                                       # ���������� j, ��� ���
                                       # i ��� ������������ �� ������� �����
  for( j = 1; j <= lGroupPathPartCount; j++) {
                                       # ������� ����� ������������ ������  
    lSearchedGroupIndex = \
      groupList_ChildIndexByName[ lCurrentGroupIndex, lGroupPathPartList[j]];
    logMessage( "lSearchedGroupIndex=" lSearchedGroupIndex, 3);  
                                       # ���� ������ ��� ����    
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
                                       # ����� �� �������� ������ � ����
                                       # ����� ��������� ������ �� ����
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
# ��������� ������ �����
#
# ������� ���������:
# 
# fileCount                  - ���������� ������
# fileList_Path              - ������ ����� � ������
# fileList_ItemName          - ������ ����� ��� ������� ����
# fileList_isDefiniteName    - ������ ��������� ( 1-��, 0-���)
#                              ����� ������������ �������� ������ ����
#                              ( �����. no auto-title)
#
# fileList_groupPath         - ������ ����� ����� ����
#
# �������� ���������:
# 
# groupCount                  - ���������� �����
# groupList_Name              - ������ ��� ����� 
#                              ( � ������ ������ - ���� ������������ ������)
# groupList_ChildIndexList        - ������ �������� �������� �������� ����� 
#                              � ������� groupList_Name
# groupList_ChildCount        - ������ ���� �������� �������� �������� �����
# groupList_FileCount         - ������ ���� �������� �������� �������� ������
# groupList_FileIndexList     - ������ �������� �������� ������
#
function createGroups()
{ 
  logMessage( "", 1);
  logMessage( "createGroups()", 1);
  logMessage( "", 1);
                                       # ��� �������� ���� �������� ������  
  groupCount = 0;
  groupList_ChildCount[ groupCount, 0] = 0;
  groupList_FileCount[ groupCount, 0] = 0;
  for ( i=1; i<= fileCount; i++) {
    addFile( i, fileList_groupPath[i]);
  }  
}

# func: printFiles
# ������� ����� ��� ������
# 
# ������� ���������:
# 
# groupIndex                 - ������ ������ 
# level                      - ������� ����������� ������
# i                          - ��������� ���������� ��� �������
# 
# groupList_FileCount        - ������ ���� �������� �������� �������� ������
# groupList_FileIndexList    - ������ �������� �������� ������
#
# fileList_Path              - ������ ����� � ������
# fileList_ItemName          - ������ ����� ��� ������� ����
# fileList_isDefiniteName    - ������ ��������� ( 1-��, 0-���)
#                              ����� ������������ �������� ������ ����
#                              ( �����. no auto-title)
function printFiles( groupIndex, level, i, j) 
{
  if ( level == 0) {
    exitError( "���� �� ����� ���������� �� ������� ������");
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
                                       # ��� �� ����������
                                       # ������ �� ��� ������ �����                                       
  for ( j = 1; j <= groupList_FileCount[ groupIndex]; j++) {
    lIsPrinted[ j] = 0;
  }
  for( i = 1; i <= lPatternCount + 1; i++) {
    for( j = 1; j <= groupList_FileCount[ groupIndex]; j++) {
      if( lIsPrinted[ j] == 0) {
        lFileIndex = groupList_FileIndexList[ groupIndex, j];
                                       # ���� ��� ����� �������
                                       # ��� "������" ��� �������
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
        } # ���� ������������� �������
      } # ���� ������ ��� �� ����������
    } # ���� �� ������
  } # ���� �� �������� ��� ���������� 
} 

# func: printGroups
# ������� ������ ����� � ������ � ������� ���� Natural Docs.
# ����������� �������
#
# ������� ���������:
# 
# groupIndex                 - ������ ������� ������
# level                      - ������� ����������� ������
# i                          - ��������� ���������� ��� �������
#
# groupCount                 - ���������� �����
# groupList_Name             - ������ ��� ����� 
#                              ( � ������ ������ - ���� ������������ ������)
# groupList_ChildCount       - ������ ���� �������� �������� �������� �����
# groupList_ChildIndexList   - ������ �������� �������� �������� ����� 
#                              � ������� groupList_Name
# groupList_FileCount        - ������ ���� �������� �������� �������� ������
# groupList_FileIndexList    - ������ �������� �������� ������
#
# fileCount                  - ���������� ������
# fileList_Path              - ������ ����� � ������
# fileList_ItemName          - ������ ����� ��� ������� ����
# fileList_isDefiniteName    - ������ ��������� ( 1-��, 0-���)
#                              ����� ������������ �������� ������ ����
#                              ( �����. no auto-title)
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
                                       # ��� �� ����������
                                       # �� ���� ������
  for ( j = 1; j <= groupList_ChildCount[ groupIndex]; j++) {
    lIsGroupPrinted[ level, j] = 0;
  }
  for( i = 1; i <= lPatternCount + 1; i++) {
    for( j = 1; j <= groupList_ChildCount[ groupIndex]; j++) {
                                       # ���� ������ ��� �� ����������    
      if( lIsGroupPrinted[ level, j] == 0) {
        lChildGroupIndex = groupList_ChildIndexList[ groupIndex, j];
                                       # ���� ��� ������ �������
                                       # ��� "������" ��� �������
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
        } # ���� ������������� �������
      } # ���� ������ ��� �� ����������
    } # ���� �� �������� �������
  } # ���� �� �������� ��� ���������� 
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

# ������������� ������ ������
BEGIN {
                                       # ����� ������ ��������
  isConfigMode = 1;
                                       # ����� ������ ������
                                       # � ������ ���� �������
  isFileRuleMode = 1;
  logMessage( "files ( debugLevel=" debugLevel ")", 1);
                                       # ��� ������ ������� ���� ������
                                       # ���� ( �����)                                       
  logMessage( "isItemFirst=" isItemFirst, 1);
                                       # �������������� ��������
  fileCount = 0;
  ruleCount = 0;
                                       # ������������ ���������� 
                                       # ������������� ������
  ruleMaxCount = 0;
}  

# ���� ��� ������ ����� ������
# 
# �������� <loadConfigString> ��� <loadFileString>.
#
{ 
  isComment = match( $0, /[\ \t]*\#.*/);
  if( isComment != 1) {
    isFileMatched = ( match( $0, /[^\#]*File: .*\(.*.)/) == 1);
    if ( isConfigMode == 1) {
                                       # ���� ���������
                                       # ����� ���� ��� �����                                       
      if ( isFileMatched) {
                                       # �������, ��� ������� 
                                       # �����������                                      
        isConfigMode = 0;
        logMessage( "isConfigMode=" isConfigMode, 3);
        logMessage( "ruleCount=" ruleCount, 3);
      }
    } 
    if ( isConfigMode == 1) {
                                       # ��������� ������� ������
      loadConfigString();
    } else if ( isFileMatched) {
                                       # ��������� ������� ������
                                       # ��������� ������� ������
      loadFileString();  
    }
  }  
}

END {
                                       # ��������� ��������� �����                         
                                       # �������� ������� ��������
                                       # ������ � ������
  sortFiles();  
                                       # ��������� ������
                                       # �������� ������� �������� ������
                                       # ������                                       
                                       # ��������� ������� �������� �������
                                       # ��������� �����
  createGroups();
                                       # ���������� ������� ������
                                       # �������� ������� �������� 
                                       # ������ ������ � � �������
  printGroups( 0, 0, 0, 0, 0, 0);  
}