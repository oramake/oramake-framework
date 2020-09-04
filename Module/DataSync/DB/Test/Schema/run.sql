-- script: Test/Schema/run.sql
-- Создание тестовых объектов схемы.
--

--
-- Тестирование обновления данных
--
@@dsn_test_source.tab



-- Метод сравнения данных
@@dsn_test_compare.tab

-- с дополнительными полями
@@dsn_test_compare_ext.tab
@@dsn_test_compare_ext_bu_chg.trg

@@v_dsn_test_compare.vw



-- Метод сравнения данных с использованием временной таблицы
@@dsn_test_cmptemp.tab
@@dsn_test_cmptemp_tmp.tab

-- с дополнительными полями
@@dsn_test_cmptemp_ext.tab

@@v_dsn_test_cmptemp.vw



-- Метод с помощью м-представления
@@dsn_test_mview.tab

-- с дополнительными полями
@@dsn_test_mview_ext.tab
@@dsn_test_mview_ext_bu_chg.trg

@@v_dsn_test_mview.vw
@@v_dsn_test_mview_ext.vw


--
-- Тестирование выгрузки данных с помощью appendData
--

@@dsn_test_app_source.tab

@@dsn_test_app_dst.tab
@@v_dsn_test_app_dst_src.vw

@@dsn_test_app_dst_a1.tab
@@v_dsn_test_app_dst_a1_src.vw
@@dsn_test_app_dst_a2.tab
