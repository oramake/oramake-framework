#!/bin/bash

# Testing module installation.

# Installation prefix
installPrefix=""

# Root directory of installation for Windows
winRoot=""

# Connection user ( userName[/passwd][@db])
testUserId=""

# Operator of AccessOperator module ( operatorName[/passwd])
testOperatorId=""

# Number of the test case to be tested
testCaseNumber=

# Directory for temporary files
tmpFileDir="${TEMP:-/tmp}"

# Directory for test module
modDir="${tmpFileDir}/oms-testModule-$$"



# Main execution parameters

# Testing installation for Windows ( 1 yes, 0 no)
winFlag=

# Run tests with loading files into database ( 1 yes, 0 no)
loadFlag=

# Command for run "oms" script
oms=

# Command for run "exec-command.cmd" ( only for Windows)
execCommand=

# Command for run "make"
make=

# Command prefix for run oms-* scripts
omsPrefix=

# Loading user ( result of execution of oms-connection-info for testUserId)
loadUserId=

# Loading operator of AccessOperator module
# ( result of execution of oms-connection-info for testOperatorId)
loadOperatorId=

# Имя группы тестовых случаев
checkCaseGroupName=""

# Serial number of current test case
checkCaseNumber=0

# Number of subsequent test cases for which the current test case is required
nextCaseUsedCount=0



die()
{
  echo -e $1 >&2
  shift
  if (( $# )); then
    cat <<< "$@" >&2
  fi
  [[ -d "$modDir" ]] \
    && echo "( test module dir: $modDir )" >&2
  exit 15
}



parseOption()
{
  while [ $# != 0 ]; do
    case $1 in
      --test-operatorid)
        testOperatorId="$2"; shift;
        ;;
      --test-userid)
        testUserId="$2"; shift;
        ;;
      --test-case-number)
        testCaseNumber=$2; shift;
        ;;
      --win-root)
        winRoot="$2"; shift;
        ;;
      -* | --*)
        die "Illegal option: \"$1\"."
        ;;
      *)
        installPrefix="$1"; shift;
        if [ $# != 0 ]; then
          die "Unexpected parameters: $@"
        fi
        break;
        ;;
    esac
    shift
  done
}



createFile()
{
  local filePath=$1
  local fileDir=${filePath%/*}
  [[ -d "$fileDir" ]] || mkdir -p "$fileDir" \
    || die "Error creating directory: $fileDir"
  cat - > "$filePath" \
    || die "Error creating file: $filePath"
}



addTestFile()
{
  createFile DB/Install/Schema/Last/test_table1.tab <<END
table: test_table1
END
  createFile DB/Test/connection.sql <<END
set feedback off
exec null
quit
END
}



startTestCase()
{
  local caseName=${checkCaseGroupName:+${checkCaseGroupName}: }$1
  local usedCount=$nextCaseUsedCount
  checkCaseNumber=$(( checkCaseNumber + 1 ))
  nextCaseUsedCount=0
  if [[ -n "$testCaseNumber" ]] \
      && (( checkCaseNumber > testCaseNumber \
          || checkCaseNumber + usedCount < testCaseNumber \
        )); then
    return 1
  fi
  echo "CASE $checkCaseNumber: $caseName ..."
  return 0
}



runCmd()
{
  "$@" \
    || die "Error executing command:" "$@"
}



runOms()
{
  startTestCase "oms $1" || return 1
  runCmd $oms "$@" >/dev/null
}



runMake()
{
  startTestCase "make $1" || return 1
  runCmd $make "$@" >/dev/null
}



checkWinScript()
{
  startTestCase "check scripts for Windows" || return 1

  # parse arguments
  runCmd $execCommand echo aaa 'kkk "jjj"' >/dev/null
  runCmd $execCommand echo '"jjj"' >/dev/null
  runCmd $execCommand echo 'j"jj' >/dev/null
  runCmd $execCommand echo >/dev/null

  $oms 0 2>/dev/null \
    && die "No error code when executing oms.cmd:" \
      "$oms 0 2>/dev/null"

  $make jjj >/dev/null 2>&1 \
    && die "No error code when executing make.cmd:" \
      "$make jjj >/dev/null 2>&1"

  local outStr
  outStr=$(runCmd $make --oms-version) \
    || die "Command finished with error"
  if [[ "$outStr" != make.cmd\ \(OMS\)\ [0-9.]* ]]; then
    die "Output of the command differs from expected:" "$outStr"
  fi
}



checkOmsConnectInfoUser()
{
  if [[ $testUserId == ${testUserId%/*} ]]; then
    nextCaseUsedCount=999
  fi
  startTestCase "oms-connect-info: user" \
    || { loadUserId=$testUserId; return 0; }

  loadUserId=$( \
      ${omsPrefix}oms-connect-info \
        --userid "$testUserId" \
        --default-db "" \
        --out-userid \
        --ignore-absent-password \
    ) \
    || die "Error on executing oms-connect-info for testUserId"

  if [[ -z $loadUserId ]]; then
    die "Empty result of executing oms-connect-info for testUserId"
  elif [[ $loadUserId == ${loadUserId%/*} ]]; then
    die "None password after executing oms-connect-info" \
      "( loadUserId=\"$loadUserId\")"
  fi
}



checkOmsConnectInfoOperator()
{
  if [[ $testOperatorId == ${testOperatorId%/*} ]]; then
    nextCaseUsedCount=999
  fi
  startTestCase "oms-connect-info: operator" \
    || { loadOperatorId=$testOperatorId; return 0; }

  loadOperatorId=$( \
      ${omsPrefix}oms-connect-info \
        --operatorid "$testOperatorId" \
        --out-operatorid \
        --ignore-absent-password \
    ) \
    || die "Error on executing oms-connect-info for testOperatorId"

  if [[ -z $loadOperatorId ]]; then
    die "Empty result of executing oms-connect-info for testOperatorId"
  elif [[ $loadOperatorId == ${loadOperatorId%/*} ]]; then
    die "None password after executing oms-connect-info" \
      "( loadOperatorId=\"$loadOperatorId\")"
  fi
}



loadFile()
{
  local loadFile=$1

  if ! [[ -f "$loadFile" ]]; then
    createFile "$loadFile"
  fi

  runCmd ${omsPrefix}oms-load \
        --userid "$loadUserId" \
        ${loadOperatorId:+--operatorid \"$loadOperatorId\"} \
        "$@"
}



checkOutputCyrillic()
{
  startTestCase "oms-load: output Cyrillic alphabet in CP1251" || return 0
  local cyr34Char=$'\xc2\xc3'
  createFile DB/Test/out-cyrillic.sql <<END
set feedback off
begin
  dbms_output.put_line(
    'first 4 characters of Cyrillic alphabet in CP1251: '
    || chr( to_number( 'c0', 'xx'))
    || chr( to_number( 'c1', 'xx'))
    || '$cyr34Char'
  );
end;
/
quit
END
  local oldNlsLang=$NLS_LANG
  export NLS_LANG=AMERICAN_CIS.CL8MSWIN1251
  local outStr=$(loadFile DB/Test/out-cyrillic.sql)
  NLS_LANG=$oldNlsLang
  if [[ ${outStr:0:54} \
        != $'first 4 characters of Cyrillic alphabet in CP1251: \xc0\xc1\xc2' \
      ]]; then
    die "Output of the command differs from expected:" "$outStr"
  else
    echo "$outStr"
    echo "!!! necessary to check the correctness of the output visually !!!"
  fi
}



# main

parseOption "$@"

if [[ -n "$winRoot" ]]; then
  winFlag=1
  oms=$winRoot/oms.cmd
  make=$winRoot/make.cmd
  execCommand="$winRoot/cmd/exec-command.cmd run.sh "
  omsPrefix="$execCommand "
else
  winFlag=0
  oms="$installPrefix/bin/oms"
  make="make"
  omsPrefix="$installPrefix/bin/"
fi

if [[ -n "$testUserId" ]]; then
  loadFlag=1
else
  loadFlag=0
fi


if (( winFlag )); then
  echo "Testing installation for Windows: \"$(cygpath --windows "$winRoot")\" ..."
  [[ -d "$winRoot" ]] || die "Windows root directory not found: $winRoot"
  [[ -f "$make" ]] || die "Script not found: $make"
else
  echo "Testing installation with prefix: $installPrefix ..."
fi

[[ -f "$oms" ]] || die "Script not found: $oms"

(( winFlag )) && checkWinScript

if (( loadFlag )); then
  checkOmsConnectInfoUser
fi
if [[ -n "$testOperatorId" ]]; then
  checkOmsConnectInfoOperator
fi

# Remove exists testModule
if [[ -d "$modDir" ]]; then
  rm -rf "$modDir" \
    || die "Existing test module has not been deleted: $modDir"
fi

for isUtf8 in "" 1; do
  checkCaseGroupName=${isUtf8:+UTF8}
  # Checks with using test module
  nextCaseUsedCount=999
  if runOms create-module \
      ${isUtf8:+--encoding utf-8} -d "$modDir" TestModule; then

    cd "$modDir" || die "Test module directory not created: $modDir"

    addTestFile

    runMake gendoc
    runOms set-version "1.0.1"

    runOms gen-schema-run
    runOms gen-schema-revert
    runOms gen-spec "DB/pkg_TestModule.pkb"

    runMake gendoc-menu

    runOms update-module

    if (( loadFlag && ! isUtf8 )); then
      startTestCase "oms-load: connection" && loadFile DB/Test/connection.sql
      checkOutputCyrillic
    fi

    cd - >/dev/null
    rm -rf "$modDir" || die "Test module directory not deleted: $modDir"
  fi
done

echo result: OK
