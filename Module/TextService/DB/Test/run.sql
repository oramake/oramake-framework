-- script: Test/run.sql
-- Выполняет тестирование модуля.

@oms-run levenshtein.sql
@oms-run normalize-word-list.sql
@oms-run normalize-search-phrase.sql
