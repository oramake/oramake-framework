title: ????????



group: ????? ????????

?????? ???????? ??????? ??? ?????????? ??????, ??????????????? ???
????????????? ? ?????????? ???????. ?????, ? ?????? ????????? ???????
?????????? ????????????????? ?????????????.

??????? ?????? ???????? ? ??????? ??????????? ( authid current_user).

?????????????? ?????? ?????????? ??????:

1. <?????????? ? ??????? ????????? ??????>

2. <?????????? ? ??????? ????????? ?????? ? ?????????????? ????????? ???????>

3. <?????????? ? ??????? fast-???????????? ?????????????????? ?????????????>

?????? ??????????? ? ??????? ???????? ?????????? ( ?.?. ???? ?? ???????? 1-?
?????, ????????????? 2-?).

??? ????????? ???????? ?????????? ???????, ??????????? ???????????? ???????
??? ?????????, ?????????? ??????????? ????????? ?????????
( ??. <???????????? ???????>, <?????????? ?????? ???????????? ??????>).

????????? ?????????? ????????????????? ?????????????:

1. <?????????? ???. ????????????? ?? ??????, ???? ???? ? ????????? ??????>


group: ?????????? ? ??????? ????????? ??????

????????? ?????? ??????? ? ??????? ????????? ???????????? ? ??? ? ??????????
?????? ? ???????? ??????????? ????????? ????????? merge ? delete
( ??. <pkg_DataSync.refreshByCompare>).

??????????? ?? ??????????:

- ???????????? ????????? ??? ??????? ??????? ?????? ?? ????????????
  ?????????????????? ? ???????? ?? ?? ( ????????? ???????: ?????????? ???????
  ?????? ???????? ?? ????? 1 ??????);



group: ?????????? ? ??????? ????????? ?????? ? ?????????????? ????????? ???????

???????? ???????????????? ????????? ??????
<?????????? ? ??????? ????????? ??????>: ?????????? ?????? ??????????????
??????????? ?? ????????? ???????, ??????? ????? ???????????? ? ???????? merge
? delete. ? ?????????? ??????? ?????????? ?????? ??????????? ???? ??? ( ???
?????????? ????????? ???????) ?????? ???? ( ???????? ??? ?????????? ??????
merge ? delete). ?????? ????? ????????????? ???????????? ? ?????? ??????????
??????? ?????????? ??????.

??????????? ?? ??????????:

- ???????????? ????????? ??? ??????? ??????? ?????? ?? ????????????
  ?????????????????? ? ???????? ?? ?? ( ????????? ???????: ?????????? ???????
  ?????? ???????? ?? ????? 1 ??????);



group: ?????????? ? ??????? fast-???????????? ?????????????????? ?????????????

??? ??????????? ?????????? ??????? ???????????? fast-???????????
????????????????? ????????????? ? ?????? "on prebuilt table" ?? ??????
???????, ??????? ????????? ?????????.  ????????????????? ????????????? ?????
???? ??????? ( ???????????) ????????????? ??? ?????????? ??????? ?
?????????????? ???????, ??????????????? ? ?????????????? ?????????
????????????? ? ????????? ??????? ( ??. <pkg_DataSync.refreshByMView>).

??????????? ?? ??????????:

- ? ?????? ??????? ??????? ??? ????????? ????????? ????? ???? ?????? ( ???
  ??????????) ?????????? fast-?????????? ?????????????????? ?????????????;

- ??? fast-?????????? ?????????????????? ????????????? ?????? ???? ??????? ????
  ?? ???????? ????????, ??? ????? ???? ???????????? ??-?? ?????????? ????????
  ????????? ???????? ??????;

?????????:

- ? ?????? ???????? ????? ?????? ??????? ? ??????? ? ????? ??????? ? ????????
  ????????????? ??? ???????? ?????????????????? ????????????? ?????
  ????????? ??????
  "ORA-12060: shape of prebuilt table does not match definition query".

  ??? ?????????? ???????? ? ????? ???????, ?? ???????? ? ????????? ????, ?
  ???????? ????????????? ????? ???????????? ???????? ?????????? ???? cast.
  ??? ?????????? ????????? ????? ?? ?????????????? ????????? ? ????????????
  ????? ???????????? SQL-??????? to_single_byte.
  ??????? ?????????? ???? ??????? ?????????? ????? ???????? ??????
  "ORA-12016: materialized view does not include all primary key columns"
  ??? ???????? ?-?????????????. ?.?. ???? ??????? ?????????? ????? ?
  ??????????? ??????? ?????? ??????????????? ??????????? ????? ???????
  ?? ????????? ????????????? ???? ????? ????????? ? ??????? ? ?????????????
  ?????????????? ??????? ??? ??????? ?????????? ????? ? ??????? ?????????? ?
  ? ?????, ??????????????? ????????????, ? ??? ??????? ? ??????? ???????
  ?????????? ????? ???????????? ?????????? ???? ? ??????? cast.



group: ?????????? ???. ????????????? ?? ??????, ???? ???? ? ????????? ??????

????????? ????????? ?????????? ????????????????? ????????????? ?? ??????, ???? ????
???? ? ????????? ????? (? ??????????? ?? ?????????? ??????????). ?????? ?????????????????
????????????? ??????????? ?????? ????????? ??? ?????.

??? ?????????? ????????????????? ????????????? ?? ?????? ????????? ??????? ?????????
list ? method. ???? method ?? ??????, ?? ?????????? ????? ??????????? ? ??????? ?? ?????????
(?????? ??? force).

??? ?????????? ???? ????????????????? ????????????? ? ????????? ?????? ????? ?????? ???????? ownerName,
?????? ????????? list ? method ????????? ?? ?????????. ? ????????? ownerName ????? ????????? ?????? ????
? ???????????? ???????.

? ??????, ???? ??????? ???????? ????????? isFastMethod, ?? ??? ??????????
????? ?????????? ?????? ????????????? ? ??????????????? ????????? ??????
?????????? ( ????? FAST ??? ???????? ????????? true, ? ????????? ??????
??? ???????? ????????? false).

? ?????? ???????? ? ????????? list, ? ?????????? ownerName, isFastMethod,
?????????? ????? ?????????????? ?? ????????? list, ? ???????? ??????????
ownerName ? isFastMethod ????? ???????????????.

?????????:

- ? ????? ?????? ??????????? ??????????? varchar2(4000) ? ?????? ????????????
  ?????? ???. ????????????? ?? ?????????? ?????? ????, ???????????? ?????????
  ???. ????????????? ??????????? ? ??????? ???? dbms_utility.uncl_array,
  ???????????? ????? ? ???????? ????????? ? ????? dbms_mview.refresh( tab => ...).



group: ???????????? ???????

???????????? ??????? ???????? ???????? ?????? ?? ?????-?? ?????????? ??????? ?
???????????? ??? ?????????????? ?????? ?? ???? ??????? ??????? ????????
( ?????? ????????? ??? ??????????? ???????? ?????? ? ?????????). ???????
??????? ????????????? ? ?????? ?? ? ???????? ?????? ?? ???????????? ?????? ?
??????? ????????????????? ?????????????, ?????????? ?? ?????.

?????????? ? ???????????? ????????:
- ??????????? ???????????? ????????? ?????? ? ?????? ????????? ??????????
  ??????? ( ???????????? ?????????? ??? ??????? ???????);
- ?????????? ?????????????? ( ??? ???????????? ????????? ??????) ????????
  ?????????? ??????? ? ???????????? ????????;

??? ??????????? ?????????? ?????? ? ???????????? ??????? ????? ???????????
????????? ???? ? ????????? "int_", ??????? ?? ?????? ?????????????? ???????
????????.

??? ???????? ???????????? ???????????? ( ??? ????????????? ?????, ??????????
??????? ????????) ?????????? ????????? ??????? ?????? "?????????", ? ???????
?????? ?????????? ??????, ?? ??????????? ? ?????? ??????? ???????????. ???
???????? ????????? ????????????? ????????? ?????????? ? ?????? ?????????
????????? ??????????? ( ????????, ?????????? ? ???? ????? ??????).

? ??????????? ??????? ??? ???????????? ?????? ????????? ????????? ??????,
???????? ???????? ? ?????? ???????????? ?????? ??? ????????? ????? ???
"<??? ???????>2Dwh".

????? ??????????:
- ????????? ???????????? ???????, ? ?????, ??????, ????????????????? ???? ??
  ??? ???????, ??? ????????? ????????? ????????????????? ?????????????
  ?? ???? ???? ?????? ?? ??????? ?? ( ?????????);
- ??? ?????????? ?????? ? ???????????? ???????? ????????? ?????????????
  ?????????? ????????? ?? ???? ???????? ?????? ?????????? ???????
  ( ???????? ?????????????);
- ????????? ???????? ??????? ??? ??????????? ?????????? ?????? ????????????
  ?????? ?? ?????? ???????? ????????????? ( ?????????? ??????????? ? ???????
  ????????? ?????? ???? ? ??????? ?????????????????? ?????????????, ?
  ??????????? ?? ?????????? ???????);

? ?????????? ? ?????? ????????? ? ????????? ??? ?????? ???????? ??????
?????????? ?????? ??????????????? ????????? ? ???????? ?????????????.

? ??????,
???? ???????????? ??????????? ???????:

- ???????????? ??????? ??????????? ? ??????? fast-????????????
  ?????????????????? ?????????????,
- ??????????? ???????? ????????? ??????? ???????? ???????, ???????????? ? ????
  ????????????????? ?????????????, ?? ???????? ?? ?????? ??????????????????
  ?????????????,

?? ????? ??????????? ????????? ?????? ???????? ??????? ????? ??????? ?????????
?? ??? ???, ? ????? ?????????? ????????? ?????? ??? ???????. ??? ????????
? ???????????? ?????????????????? ????????????? ??? ?????????? ????????????
??????? ? ??????????????? ??????????? ?????? ? ??? ? ??????? ?????????
( ? ?????? ????????????? ????????? createMViewFlag ??? forceCreateMViewFlag,
??. <pkg_DataSync.refreshByMView>). ?.?. ????? ????????? ??????????????
???????? ????????? ??????? ? ???????????? ???????.

  ????????, ????? ???????? ????? ??????? ?? ????????? ?? ????????? ? ???????
mpr_data ?????? ModName. ??????? ????????:

- ??????? ??? ?? ??????? mpr_data;

(code)

drop materialized view log on mpr_data
/

(end)

- ????????? ??????? ? ??????? ? ????????? ??;

- ??????????????? ??? ?? ??????? mpr_data;

(code)

exec mpr_ModName_source_t().createMLog( forTableName => 'mpr_data');

(end)

?????????:
- ???? ???????????? ??????? ??????????? ? ??????? fast-????????????
  ?????????????????? ?????????????, ?? ????????? ???? ? ?????????? ?????
  ( ???? ??? ????) ?????? ???? ??????? ? ?????? ????????? ??? ?????????? commit
  ( "deferred") ??? ?????????? ??????
  "ORA-00001: unique constraint (...) violated"
  ( ??. <Note.67424.1 at https://support.oracle.com/CSP/main/article?cmd=show&type=NOT&id=67424.1> Materialized View Triggers, Constraints and Longs)



group: ?????????? ?????? ???????????? ??????

?????????????????? ?????????? ??????:

- *??????? ??????? ??? ???????? ?????????????*;

  ????????? ??????? ??? ???????? ?????????????
  ( DB/Install/Schema/Last/SourceSchema/v_*.vw), ???????????????
  ???????????? ????????. ????? ? ??? ????? ?????? ????? ??????????????? ?????
  ? ??????????? ???????. ? ????????? ??????? ??? ??????????? ??????????
  ?????? ????????? ???????? ?????????????? ????????? ????. ????????, ???
  fast-?????????? ?????????????????? ?????????????, ??????????? ??????????
  ??????, ????? ( ??. "Oracle Database Data Warehousing Guide"):
  - ???????? ???? ? rowid ??????, ??????????? ? ??????? ( ???? "int_%_rid");
  - ??????? ?????????? ????????? ?? ????? where ( ? ?????? ???????? ??????????
    ???????????? Oracle-????????? ? "(+)");
  - ?? ???????? ???????? ??????? ???? ? ?????? "with rowid";

  ??? ????????????? ?????????? ???????????? ??????? ???? ? rowid ?????
  ????????????????.

  ??? ??????????? ????????? ??? ???????????? ??????? ???? ???? ?????
  ????????????? ????? ?????????? ???? ? ???????????? ?????????????.

- *????????? ??????? ???????? ???????????? ?????? ?? ???????? ??????????????*

  ??? ????? ???????? ????????????? ????????? ? ??, ????? ????
  ?????????? pkg_ScriptUtility.generateInterfaceTable ( ?????? ScriptUtility
  ( Oracle/Module/ScriptUtility)) ??????????? ????????? ???????? ????????
  ???????????? ??????.

  ????? ????????? ? ??????? ??????????? ?, ? ?????? ?????????????, ??????????
  ( ?????? ?????????? ??????????? ?????, ?????????????? ??????????, ?????????
  ???? ( ???? ??? ?? ?????? ???? ???????), ??????????? ?????
  "initially deferred deferrable" ??? ??????????/?????????? ?????? ???
  ?????????? ? ??????? ?????????????????? ?????????????). ???????? ?????
  ??????????? ?????? ????????? ? ??????? ???????? ?????????????.

- *????????? ??????? ???????? ????????? ?????? ?? ???????? ??????????????*

  ????????? ??????? ????? ??????? ??? ???????????? ??????, ??????????? ???????
  <?????????? ? ??????? ????????? ?????? ? ?????????????? ????????? ???????>.

  ??? ????? ????? ???????? ???????? ????????????? ? ?? ??????????
  pkg_ScriptUtility.generateInterfaceTempTable ( ?????? ScriptUtility
  ( Oracle/Module/ScriptUtility)) ??????????? ????????? ???????? ????????
  ????????? ??????.

- *???????? ????????? ??? ??? ?????????? ????????? ? ???????? ?????*

  ????????? ???-??????? ???? <dsn_data_sync_source_t>, ?? ???????? ???????????
  ?????? ??? ?????????? ?????????, ? ???????????? ??????????? ????? ?????????
  ????????????? <dsn_data_sync_source_t.initialize> ? ?????????? ??????????
  ??????????.

- *???????? ??????? ?????????/???????? ?????? ? ???????? ?????*

- *???????? ????????? ??? ??? ?????????? ????????????? ?????????*

  ????????? ???-??????? ???? <dsn_data_sync_t>, ?? ???????? ???????????
  ?????? ??? ?????????? ?????????, ? ???????????? ??????????? ????? ?????????
  ????????????? <dsn_data_sync_t.initialize> ? ?????????? ??????????
  ??????????.

- *???????? ??????? ?????????/???????? ?????? ? ???????? ?????*

- *???????? ???????? ??????? ??? ?????????? ???????????? ??????*

  ???? ???????????? ??????? ?? ??????????? ????????????, ??? ???????
  ??????????? ???????? ???????, ?? ????? ??????? ?????????-???????
  ??? ????????? ?????????? ???????????? ?????? ( ? ??????? ?????????) ?
  ???????? ?? ?? ????????? ???????. ????? ????? ?????? ??? ?????? ???? ??
  ?????????.
