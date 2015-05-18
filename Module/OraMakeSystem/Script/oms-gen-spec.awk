# script: oms-gen-spec.awk
# Скрипт для генерации спефикации пакета по реализации ( body).
BEGIN {
  codeType = "IGNORE";
  codePartCount = 0;
}

# func: addCodePart
# Добавление нового участка кода
function addCodePart( \
  newCodeType  \
) \
{
  codeType = newCodeType;
  if ( newCodeType != "IGNORE") {
    codePartCount++;
    codePartList_codeType[ codePartCount] = newCodeType;
    codePartList_lineCount[ codePartCount] = 0;
  }
}

# func: addLine
# Добавление строки в текущий участок кода
function addLine() \
{
  if ( codeType != "IGNORE") {
    lineCount = codePartList_lineCount[ codePartCount];
    lineCount++;
    codePartList_lineList[ codePartCount, lineCount] = $0;
    codePartList_lineCount[ codePartCount] = lineCount;
  }
}

# Основной блок работы по строкам
{
  if ( codeType == "IGNORE" || codeType == "GROUP") {
    if ( match( $0, /\/\* *proc:/) || match( $0, /\/\* *func:/)) {
      addCodePart( "SPEC_COMMENT");
    } else if ( \
      match( $0, /\/\* *group:.*\*\//) \
    ) \
    {
      addCodePart( "GROUP");
    } else if ( codeType == "GROUP") {
      addCodePart( "IGNORE");
    }
  }
  else if ( codeType == "SPEC_COMMENT") {
    if ( match( tolower( $0), /\<procedure\>/) > 0 \
      || match( tolower( $0), /\<function\>/) > 0 \
    ) {
      addCodePart( "SPEC_CODE");
    }
  }
  else if ( codeType == "SPEC_CODE") {
    if \
      (  match( $0, /\<is\>/) \
        ||  match( $0, /\<as\>/) && match( $0, /\<as\>[[:space:]]*\<result\>/) == 0 \
      ) {
      addCodePart( "IGNORE");
    }
  } else {
    print "Внутренняя ошибка: ( codeType=" codeType ")" | "cat 1>&2"
  }
  addLine();
}

END {
  for ( i = 1; i <= codePartCount; i++ ) {
    lastLine = codePartList_lineList[i,codePartList_lineCount[i]];
    switch( codePartList_codeType[i]) {
      case "GROUP":
        # Если группа непуста
        if ( codePartList_codeType[i+1] == "SPEC_COMMENT") {
          print "";
          print "";
          print "";
          print codePartList_lineList[i,1];
        }
        break;
      case "SPEC_COMMENT":
        print "";
        commentLine = codePartList_lineList[i,1];
        commentPos = index( commentLine, "proc:");
        if ( commentPos == 0) {
          commentPos = index( commentLine, "func:");
        }
        commentName = substr( commentLine, commentPos + 6);
        for ( j = 1; j < codePartList_lineCount[i]; j++) {
          print \
            gensub( \
              / proc:/, " pproc:", "g" \
            , \
            gensub( \
              / func:/, " pfunc:", "g" \
            , codePartList_lineList[i,j] \
            ) \
            );
        }
        print gensub( /\*\//, "", "g", lastLine);
        print "  ( <body::" commentName ">)";
        print "*/";
        break;
      case "SPEC_CODE":
        for ( j = 1; j < codePartList_lineCount[i]; j++) {
          print codePartList_lineList[i,j];
        }
        # Используем "," для спецификации объектного типа
        if ( objectTypeFlag == 1 ) {
          if ( i < codePartCount) {
            specificationEnd = ",";
          } else {
            specificationEnd = "";
          }
        } else {
          specificationEnd = ";";
        }
        print lastLine specificationEnd;
        break;
    }
  }
}

