-- script: Install/Schema/Last/UserDb/run.sql
-- Выполняет установку последней версии объектов схемы в пользовательску БД.


-- Определяем табличное пространство для индексов
@oms-set-indexTablespace.sql


-- Определяем линк и схему в исходной БД
@oms-run Install/Schema/Last/UserDb/Custom/set-sourceDbLink.sql
@oms-run Install/Schema/Last/UserDb/Custom/set-sourceSchema.sql


-- Создание мат. представлений
@oms-run ./oms-recreate-mview.sql mv_cdr_day Install/Schema/Last/UserDb/mv_cdr_day.snp
@oms-run ./oms-recreate-mview.sql mv_cdr_day_type Install/Schema/Last/UserDb/mv_cdr_day_type.snp
