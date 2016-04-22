LOAD_FILE_MASK = pkg_Option.pkb

override SKIP_FILE_MASK += \
  Install/Config/after-action.sql \
	, Install/Config/before-action.sql
