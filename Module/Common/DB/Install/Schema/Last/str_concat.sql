-- script: Install/Schema/Last/str_concat.sql
-- Устанавливает последнюю версию агрегирующей функции str_concat.
--

-- Тип
@oms-run str_concat_t.typ

-- Реализация  типа
@oms-run str_concat_t.tyb

-- Глобальная агрегирующая функция
@oms-run str_concat.prc
