title: ????????



???????:

1. ??????? ?????? ????????? ?? ??????, ??????????? ? ?????? SvnSearch, ??????????? ? ???? ??????? ?? SVN. 
?????? SvnSearch ????????? ? ????? ?????????????? ??????? ? ??????????? ?????? 
(?????? ? ??????? <ss_file>).

2. ????????? ?????????? ???????????? ??????? ???? ?? ????? ??????????? ??????? ? ????????? ????????? ? ?????????? ???????. 
?????? ????????????? ? ???????????? ????????????? ??????? ?????? ?? ?????? ??????, ??????????? ?????????????? ??????? ? ????????. ??? ?????????? ?? ????.

3. ????????? ?????????? ??? ?????????? ???????????? ????? ???????? ? ????? ?
- ?????? ?????????????? ?????? map.xml. 
- ???????????, ???????? ??????????????, ??????? ????????????? ? ????????? ??????????????? ???????????. ???????, ??????????? ???????? ? ???? ?????????? ????????????.

4. ?????? ???????????????? ?????? ????? ? SVN. ??????? ??? ???????????.

5. ????? ???????????? ???????? ?? "??????? ??????". ??? ?????????????, ??????? ????? ????????? ???????????/???????? ????????.
    
6. ?????? ??????????? ? SVN ? ??????????? Oracle. ?? ???????? ? ??????? ModuleInfo.

???????????:
1. ??????? ??? ???????? ??????????? ???????????? ????? ????????:

- <md_module_dependency> - ????? ???????????? ???????;
- <md_object_dependency> ? ????? ???????????? ???????? ????????? (???????, ?????, ????????????? ? ?.?). ??????? ?????? ???? ???? ??? ???????? ???????????? ?? ?????? ??????????? ??.

2. ?????, ??? ?????????? ???????????? ????? ???????? ?? ?????? ????????? ??????????

- ??????????/?????????? ??????? <md_module_dependency> ?? ??????????? ?????? map.xml, ?????????? ? <search.ss_file>;
- ??????????/?????????? ??????? <md_module_dependency> ?? ??????????? ?????????? ????????????? all_dependencies ;
- ? ?????? ??????????? ?? ???????? ?????????? ????????????? all_dependencies ? ??????????? <md_object_dependency>, ????????????? ? ?? Exchange.

3. ????? pkg_ModuleDependency, ?????????? ???????

- ??????? ?????????? ???????????? ????? ???????? (???????????? ? ??????):

i. refreshAllModuleDependencyFromSVN - ?????????? ?? ?????? ?????? map.xml

ii. refreshAllModuleDependencyFromSYS - ?????????? ?? ?????? ?????????? ????????????? all_dependencies ? ?????? ????????

- ??????? ??? ?????? ? ????????? ????????????? (?????? ? ???????? <md_module_dependency>):

i. findDependency ? ?????????? ?????? ???????????? ??? ??????

ii. deleteDependency ? ??????? ?????? ???????????? ??? ??????

iii. createDependency ? ??????? ??????????? ?????? ?? ??????

4. ????? pkg_ModuleDependencySource, ?????????? ??????? ??????? ???????? ???????????? ????? ????????? ?? ????????? ????????????? ? ???-??????? <md_object_dependency>

i. <unloadObjectDependency> ? ????????? ??????????? ?? all_dependencies ? <md_object_dependency>.

5. ?????????????

- v_md_module_dependency  - ??????????? ??????? ???? ?? ?????. ?? ?????? ??????? <md_module_dependency> ???? ??????????? ???? module_name ? ?.?.

