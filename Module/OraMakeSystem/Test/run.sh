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

# Directory for temporary files
tmpFileDir="${TEMP:-/tmp}"

# Directory for test module
modDir="${tmpFileDir}/oms-testModule"



# Main execution parameters

# Testing installation for Windows ( 1 yes, 0 no)
winFlag=

# Run tests with loading files into database ( 1 yes, 0 no)
loadFlag=

# Command for run "oms" script
oms=

# Command for run "make"
make=

# Command prefix for run oms-* scripts
omsPrefix=

# Loading user ( result of execution of oms-connection-info for testUserId)
loadUserId=

# Loading operator of AccessOperator module
# ( result of execution of oms-connection-info for testOperatorId)
loadOperatorId=



die()
{
  echo -e $@ >&2
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
  local caseName=$1
  echo "CASE: $caseName ..."
}



runCmd()
{
  "$@" >/dev/null \
    || die "Error executing command:\n$@"
}



runOms()
{
  startTestCase "oms $1"
  runCmd $oms "$@"
}



runMake()
{
  startTestCase "make $1"
  runCmd $make "$@"
}



checkOmsConnectInfoUser()
{
  startTestCase "oms-connect-info: user"
  loadUserId=$( \
      $omsPrefix-connect-info \
        --userid "$testUserId" \
        --default-db "" \
        --out-userid \
        --ignore-absent-password \
    ) \
    || die "Error on executing oms-connect-info for testUserId"

  if [[ -z "$loadUserId" ]]; then
    die "Empty result of executing oms-connect-info for testUserId"
  elif [[ "$loadUserId" == ${loadUserId%/*} ]]; then
    die "None password after executing oms-connect-info" \
      "( loadUserId=\"$loadUserId\")"
  fi
}



checkOmsConnectInfoOperator()
{
  startTestCase "oms-connect-info: operator"
  loadOperatorId=$( \
      $omsPrefix-connect-info \
        --operatorid "$testOperatorId" \
        --out-operatorid \
        --ignore-absent-password \
    ) \
    || die "Error on executing oms-connect-info for testOperatorId"

  if [[ -z "$loadOperatorId" ]]; then
    die "Empty result of executing oms-connect-info for testOperatorId"
  elif [[ "$loadOperatorId" == ${loadOperatorId%/*} ]]; then
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

  runCmd $omsPrefix-load \
        --userid "$loadUserId" \
        --operatorid "$loadOperatorId" \
        "$@"
}



# main

parseOption "$@"

if [[ -n "$winRoot" ]]; then
  winFlag=1
  oms=$winRoot/oms.cmd
  make=$winRoot/make.cmd
  omsPrefix="$winRoot/cmd/exec-command.cmd run.sh oms"
else
  winFlag=0
  oms="$installPrefix/bin/oms"
  make="make"
  omsPrefix="$oms"
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

# Remove exists testModule
if [[ -d "$modDir" ]]; then
  rm -rf "$modDir" \
    || die "Existing test module has not been deleted: $modDir"
fi

runOms create-module -d "$modDir" TestModule

cd "$modDir" || die "Test module directory not created: $modDir"

addTestFile

runMake gendoc
runOms set-version "1.0.1"

runOms gen-schema-run
runOms gen-schema-revert

runMake gendoc-menu

if (( loadFlag )); then
  checkOmsConnectInfoUser
fi
if [[ -n "$testOperatorId" ]]; then
  checkOmsConnectInfoOperator
fi
if (( loadFlag )); then
  startTestCase "oms-load"
  loadFile DB/Test/connection.sql
fi

cd - >/dev/null
rm -rf "$modDir" || die "Test module directory not deleted: $modDir"

echo result: OK
