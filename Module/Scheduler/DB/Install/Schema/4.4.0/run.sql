-- script: Install/Schema/4.4.0/run.sql
-- ќбновление объектов схемы до версии 4.4.0.
--
-- ќсновные изменени€:
--  - удал€ютс€ последовательности sch_message_type_seq и
--    sch_interval_type_seq ( в случае их наличи€);
--
--

@oms-run drop-old-sequence.sql
