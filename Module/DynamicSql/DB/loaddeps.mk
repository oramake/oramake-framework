#
# ??????????? ??? ???????? ?????? ? ??.
#
# ????? ? ???????????? ?????? ??????????? ? ?????????????? ?????????:
# .$(lu)      - ???????? ??? ?????? ?????????????
# .$(lu2)     - ???????? ??? ?????? ?????????????
# .$(lu3)     - ???????? ??? ??????? ?????????????
# ...         - ...
#
# ?????? ( ??????????? ???? ?????? pkg_TestModule ?? ??????????? ????????????
# ? ???????????? ?????? pkg_TestModule2 ??? ???????? ??? ?????? ?????????????):
#
# pkg_TestModule.pkb.$(lu): \
#   pkg_TestModule.pks.$(lu) \
#   pkg_TestModule2.pks.$(lu)
#
#
# ?????????:
# - ? ?????? ????? ?? ?????? ?????????????? ?????? ????????? ( ?????? ???? ???
#   ?????????????? ????? ???????????? ???????), ?.?. ?????? ????????? ?????
#   ??????????? ???????? ??? make ? ??? ????????? ????????? ????? ???????? ?
#   ???????????????????? ???????;
# - ? ??????, ???? ????????? ?????? ??????????? ????? ??????????? ????????
#   ????????????? ( ???????? ????? ??????), ?? ????? ???????????
#   ?????? ???? ??? ??????? ???? ?????? ??????, ????? ??? ???????? ?????
#   ????????? ?????? "*** No rule to make target ` ', needed by ...";
# - ????? ? ??????????? ?????? ??????????? ? ????? ???????????? ???????? DB
#   ? ?????? ????????, ???????? "Install/Schema/Last/test_view.vw.$(lu): ...";
#

dyn_dynamic_sql_t.tyb.$(lu): \
  dyn_dynamic_sql_t.typ.$(lu)


dyn_cursor_cache_t.tyb.$(lu): \
  dyn_cursor_cache_t.typ.$(lu) \
  pkg_DynamicSqlCache.pks.$(lu)


pkg_DynamicSqlCache.pkb.$(lu): \
  pkg_DynamicSqlCache.pks.$(lu)


