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

pkg_TextParserBase.pkb.$(lu): \
	pkg_TextParserBase.pks.$(lu)

tpr_csv_iterator_t.typ.$(lu): \
  tpr_string_table_t.typ.$(lu) \
	tpr_clob_table_t.typ.$(lu)

tpr_csv_iterator_t.tyb.$(lu):  \
  tpr_csv_iterator_t.typ.$(lu) \
	pkg_TextParserBase.pks.$(lu)

tpr_line_iterator_t.tyb.$(lu): \
  tpr_line_iterator_t.typ.$(lu) \
	pkg_TextParserBase.pks.$(lu)

