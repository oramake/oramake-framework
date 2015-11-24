--script: Install/Schema/Last/revert.sql
--Выполняет деинсталяцию последней версии объектов модуля

drop package pkg_FileHandlerCachedDirectory
/
drop package pkg_FileHandler
/
drop package pkg_FileHandlerRequest
/
drop package pkg_FileHandlerBase
/
drop view v_flh_request_wait
/
drop view v_flh_cached_directory_wait
/
@@revert-schema