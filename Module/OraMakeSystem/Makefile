# makefile: Сборка

# Префикс названия скриптов
scriptPrefix				= oms

# Каталог для данных сборки проекта
buildDir						= Build

# Каталог с постоянными данными модуля
dataDir  					  = Data

# Каталог со скриптами
scriptDir 					= Script

# Каталог с дистрибутивами используемых библиотек
usedLibDir 					= UsedLib



.PHONY: 						\
	all 							\
	clean							\
	install						\
	install-msys2 \
	uninstall					\
	gendoc						\
	gendoc-clean			\
	set-oms-version		\



# group: Общие цели



# target: all
# Целиком собирает проект.

all:								\
	gendoc						\



# target: clean
# Удаляет файлы, созданные при сборке.

clean:							\
	gendoc-clean			\



# group: Установка

# Получаем тип ОС
OSTYPE := $(shell echo $$OSTYPE)

# build var: MSYS2_ROOT
# Путь к корневому каталогу установки в Windows, в который будут установлены
# пакеты MSYS2
MSYS2_ROOT = /cygdrive/d/OraMakeSystem

# build var: DESTDIR
# Префикс для установки.
DESTDIR := /usr/local

# build var: FORCE
# Флаг затирания настроек приложения
# ( 1 затирать ( удалять), по умолчанию сохранять).
#
# Замечания:
# - в случае установки в MSYS2 ( для Windows) при указании FORCE=1 также будут
#   удален корневой каталог установки <MSYS2_ROOT> со всеми файлами;
#
FORCE         =

# Каталог для общих данных
shareDir = $(DESTDIR)/share/oms

# Каталог для настроек
configDir     = $(DESTDIR)/etc/oms

# Флаг установки в MSYS2 ( Windows)
# ( 1 да, "" нет)
MSYS2_FLAG =

ifeq ($(OSTYPE),msys)

MSYS2_FLAG = 1

DESTDIR := $(MSYS2_ROOT)$(DESTDIR)

install: install-msys2

# Установка MSYS2
install-msys2:
	@if [[ ! -d "$(MSYS2_ROOT)" ]]; then \
		mkdir "$(MSYS2_ROOT)"; \
	fi \
	&& cp \
		--preserve=mode,ownership,timestamps \
		--no-dereference --preserve=links \
		--recursive \
		--target-directory="$(MSYS2_ROOT)" \
		Build/Win32/MSYS2/* \
	&& if [[ ! -d "$(DESTDIR)/bin" ]]; then \
		mkdir -p "$(DESTDIR)/bin"; \
	fi \
	&& echo "installed MSYS2 into: $(MSYS2_ROOT)"

endif

# target: install
# Выполняет установку приложения.

install:
	@( cd $(scriptDir)										\
		&& install --mode=755 --target-directory=$(DESTDIR)/bin 		\
		$(scriptPrefix)-*[^~]								\
	) 																		\
	&& rm -rf "$(shareDir)"								\
	&& mkdir -p "$(shareDir)"							\
	&& mkdir -p "$(configDir)"	  				\
	&& cp \
		--preserve=mode,ownership,timestamps \
		--no-dereference --preserve=links \
		--recursive \
		--target-directory="$(shareDir)" \
		Data SqlScript UsedLib \
	&& find \
		"$(shareDir)" \
		\( -name ".gitignore"  \
			-o -name ".gitattributes" \
			-o -name "*~" \
			-o -name "*.swp" \
		\) \
		-delete \
	&& cp -R $(if $(FORCE),--force,-n) Config/Default/* "$(configDir)" \
	&& mkdir -p "$(shareDir)/Config"		 	\
	&& cp --force Config/Legacy/* "$(shareDir)/Config"


# target: uninstall
# Отменяет установку приложения.

uninstall:
	-@rm -f $(DESTDIR)/bin/$(scriptPrefix)-*[^~];	\
	rm -rf "$(shareDir)"; \
	if [[  -n "$(FORCE)" ]]; then \
		rm -rf "$(if $(MSYS2_FLAG),$(MSYS2_ROOT),$(configDir))"; \
	fi;



# group: Генерация документации



# build var: GENDOC_DIR
# Каталог для генерируемой документации.
GENDOC_DIR = Doc/AutoGen

# build var: GENDOC_FLAGS
# Дополнительные параметры генерации документации.
GENDOC_FLAGS 	=

# Строка запуска утилиты генерации
gendocRun	= $(usedLibDir)/NaturalDocs/NaturalDocs/NaturalDocs

# Подкаталог системы контроля версий
versionControlDir = .svn

# Каталог с настройками утилиты генерации
gendocConfigDir = $(buildDir)/NaturalDocs

# Каталог с временными файлами утилиты генерации
gendocCacheDir = $(gendocConfigDir)/Data

# Обеспечиваем полное обновление документации при безусловной сборке.
ifneq ($(filter -B -wB --always-make,$(MAKEFLAGS)),)
	GENDOC_FLAGS += --rebuild
endif


# target: gendoc
# Генерация документации.

gendoc:
	@-rm -f $(scriptDir)/*~
	@[[ -n "$(GENDOC_DIR)" ]] 							\
	&& (																		\
		echo "Generate docs in \"$(GENDOC_DIR)\" ..."	\
		&& $(gendocRun)		 										\
			-i . 																\
			-xi "$(buildDir)" 									\
			-xi "$(dataDir)/UpdateModule" 									\
			-xi "$(dataDir)/NewModule/DB/OmsModule/NaturalDocs"	\
			-xi "$(dataDir)/NewModule/DB/OmsModule/Load"	\
			-xi "$(usedLibDir)" 								\
			-o HTML "$(GENDOC_DIR)" 						\
			-p "$(gendocConfigDir)" 						\
			--charset Windows-1251							\
			--style small 											\
			$(GENDOC_FLAGS)											\
            -hl off\
            )																			\
	|| exit 0																\



# target: gendoc-clean
# Удаляет сгенерированные файлы документации ( если они не зафиксированы в SVN).

gendoc-clean:
	@(cd "$(GENDOC_DIR)"										\
		&& [[ ! -d "styles/$(versionControlDir)" ]]	\
		&& rm -rf 													\
			files index javascript styles search	\
			index.html menu.html							\
	);																		\
	rm -rf $(gendocCacheDir)/*						\



# group: Установка значения версии



# build var: OMS_VERSION
# Новое значение для версии OMS.
# Параметр должен указываться при вызове <set-oms-version>.
OMS_VERSION=

# build var: OMS_VERSION_REVISION
# Новое значение для номера ревизии версии OMS.
# Параметр может указываться при вызове <set-oms-version>, по умолчанию номер
# ревизии рассчитывается на основе текущего времени ( число минут, прошедших с
# 1970-01-01 00:00:00 UTC).
OMS_VERSION_REVISION=

# target: set-oms-version
# Устанавливает новое значение версии OMS в файлах, а также обновляет значения
# номера ревизии OMS и даты изменения файла.
#
# Пример:
# $ make set-oms-version OMS_VERSION=1.2.0

set-oms-version:
	@if [[ -n "$(OMS_VERSION)" ]]; then \
		versionDate="$$(date '+%Y-%m-%d %T %z')"; \
		versionRevision="$(OMS_VERSION_REVISION)"; \
		if [[ -z "$(versionRevision)" ]]; then \
			sinceSecond="$$(date +%s)"; \
			versionRevision="$$(( sinceSecond / 60 ))"; \
		fi; \
	  sed --in-place \
			-e "s/\$$Revision:: [0-9]\\+ \\+\\$$/\$$Revision:: $$versionRevision \$$/" \
			-e "s/\$$Date:: [0-9-]\\+ [0-9:]\\+ [0-9+-]\\+ \\#\\$$/\$$Date:: $$versionDate \#\$$/" \
	    -e 's/^OMS_VERSION=[0-9.]*$$/OMS_VERSION=$(OMS_VERSION)/' \
	    $(scriptDir)/*[^~] \
	    $(dataDir)/NewModule/DB/OmsModule/init.mk \
	    $(dataDir)/NewModule/DB/OmsModule/common.mk \
	  && unix2dos \
	    $(dataDir)/NewModule/DB/OmsModule/init.mk \
	    $(dataDir)/NewModule/DB/OmsModule/common.mk \
	    2>/dev/null \
	  && sed --in-place \
	    -e 's/^SubTitle: Версия [0-9.]*$$/SubTitle: Версия $(OMS_VERSION)/' \
	    $(buildDir)/NaturalDocs/Menu.txt \
	  && $(MAKE) gendoc \
	  ; \
	else \
	  echo "No value for parameter OMS_VERSION."; \
	  exit 5; \
	fi




# group: Формирование патчей



# target: create-patch
# Формирует патчи по незафиксированным в SVN изменениям в шаблоне нового модуля.
# Формирование патчей должно выполняться при наличии изменений в шаблоне нового
# модуля. Патчи формируются скриптом <create-patch> и затем используются в
# <oms-update-module> для обновления версии OMS-файлов существующих модулей.

create-patch:
	@./$(scriptDir)/create-patch --overwrite

