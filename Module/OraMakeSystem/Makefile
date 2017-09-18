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
	install-oms \
	install-oms-msys2 \
	uninstall					\
	uninstall-oms-msys2 \
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

# build var: WIN_ROOT
# Путь к корневому каталогу установки в Windows
# ( в случае невозможности установки по указанному пути установка будет
# произведена в "C:\OraMakeSystem")
WIN_ROOT := /cygdrive/d/OraMakeSystem

# Альтернативный каталог установки, используемый в случае отсутствия
# родительского каталога для WIN_ROOT
#
altWinRoot = /cygdrive/c/OraMakeSystem

# build var: prefix
# Общий префикс для инсталляционных каталогов.
# Примечание: Этот каталог должен существовать еще до начала инсталляции.
prefix := /usr/local

# build var: FORCE
# Флаг затирания настроек приложения
# ( 1 затирать ( удалять), по умолчанию сохранять).
#
# Замечания:
# - в случае установки для Windows при указании FORCE=1 также будут удален
#   корневой каталог установки <WIN_ROOT> со всеми файлами;
#
FORCE =

# Каталог для общих данных
shareDir = $(prefix)/share/oms

# Каталог для настроек
configDir     = $(prefix)/etc/oms

# Флаг установки в MSYS2 ( Windows)
# ( 1 да, "" нет)
MSYS2_FLAG =

ifeq ($(OSTYPE),msys)

MSYS2_FLAG = 1

override WIN_ROOT := $(shell \
	if [[ -d "$(dir $(WIN_ROOT))" ]]; then \
		echo "$(WIN_ROOT)"; \
	else \
		echo "$(altWinRoot)"; \
	fi \
)

override prefix := $(WIN_ROOT)$(prefix)


# Установка MSYS2
install-msys2:
	@if [[ ! -d "$(WIN_ROOT)" ]]; then \
		mkdir "$(WIN_ROOT)"; \
	fi \
	&& cp \
		--preserve=mode,ownership,timestamps \
		--no-dereference --preserve=links \
		--recursive \
		--target-directory="$(WIN_ROOT)" \
		Build/Win32/MSYS2/* \
	&& if [[ ! -d "$(WIN_ROOT)/usr/local" ]]; then \
		mkdir -p "$(WIN_ROOT)/usr/local"; \
	fi


install: install-msys2


# Установка файлов OMS, предназначенных только для MSYS2
install-oms-msys2:
	@if [[ ! -d "$(WIN_ROOT)/cmd" ]]; then \
		mkdir "$(WIN_ROOT)/cmd"; \
	fi \
	&& cp \
		--preserve=mode,ownership,timestamps \
		--no-dereference --preserve=links \
		--target-directory="$(WIN_ROOT)/cmd" \
		Build/Win32/MSYS2/cmd/* \
	&& cp \
		--preserve=mode,ownership,timestamps \
		--no-dereference --preserve=links \
		--target-directory="$(WIN_ROOT)" \
		Build/Win32/MSYS2/*.cmd


install-oms: install-oms-msys2


# Удаление файлов OMS, предназначенных только для MSYS2
uninstall-oms-msys2:
	-@rm -rf \
		"$(WIN_ROOT)/cmd" \
		$(WIN_ROOT)/*.cmd


uninstall: uninstall-oms-msys2

endif

# Выполняет установку файлов OraMakeSystem
install-oms:
	@( cd $(scriptDir)										\
		&& if [[ ! -d "$(prefix)/bin" ]]; then \
				mkdir "$(prefix)/bin"; \
			fi \
		&& install --mode=755 --target-directory=$(prefix)/bin 		\
		$(scriptPrefix)	\
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
	&& cp --force Config/Legacy/* "$(shareDir)/Config" \
	&& if [[ -z "$(MSYS2_FLAG)" ]]; then \
			echo "installed with prefix: $(prefix)" \
			&& if [[ -z "$(FORCE)" ]]; then \
					echo "( use \"make install FORCE=1\" to rewrite config files in $(configDir))"; \
				fi; \
		else \
			echo "installed into: \"$$(cygpath --windows "$(WIN_ROOT)")\"" \
			&& if [[ -z "$(FORCE)" ]]; then \
					echo "( use \"make install FORCE=1\" to rewrite config files in \"$$(cygpath --windows "$(configDir)")\")"; \
				fi; \
		fi



# target: install
# Выполняет установку приложения.

install: install-oms



# target: uninstall
# Отменяет установку приложения.

uninstall:
	-@rm -f \
		$(prefix)/bin/$(scriptPrefix) \
		$(prefix)/bin/$(scriptPrefix)-*[^~]; \
	rm -rf "$(shareDir)"; \
	if [[ -z "$(MSYS2_FLAG)" ]]; then \
		if [[  -n "$(FORCE)" ]]; then \
			rm -rf "$(configDir)"; \
		else \
			echo "OraMakeSystem files deleted"; \
			echo "( use \"make uninstall FORCE=1\" to delete config files in $(configDir))"; \
		fi; \
	else \
		winRoot=$$(cygpath --windows "$(WIN_ROOT)"); \
		if ! [[ -d "$(WIN_ROOT)" ]]; then \
			echo "Installation directory not found: \"$$winRoot\""; \
		elif [[  -n "$(FORCE)" ]]; then \
			rm -rf "$(WIN_ROOT)" \
			&& echo "Installation directory removed: \"$$winRoot\""; \
		else \
			echo "OraMakeSystem files deleted"; \
			echo "( use \"make uninstall FORCE=1\" to delete installation directory \"$$winRoot\")"; \
		fi; \
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
	    -e 's/^set omsVersion=[0-9.]*$$/set omsVersion=$(OMS_VERSION)/' \
	    $(scriptDir)/*[^~] \
	    $(dataDir)/NewModule/DB/OmsModule/init.mk \
	    $(dataDir)/NewModule/DB/OmsModule/common.mk \
	    $(buildDir)/Win32/MSYS2/cmd/exec-command.cmd \
	  && unix2dos \
	    $(dataDir)/NewModule/DB/OmsModule/init.mk \
	    $(dataDir)/NewModule/DB/OmsModule/common.mk \
	    $(buildDir)/Win32/MSYS2/cmd/exec-command.cmd \
	    2>/dev/null \
	  && sed --in-place \
	    -e 's/^SubTitle: Версия [0-9.]*$$/SubTitle: Версия $(OMS_VERSION)/' \
	    $(buildDir)/NaturalDocs/Menu.txt \
	  && $(MAKE) gendoc \
	  ; \
	else \
	  echo "No value for parameter OMS_VERSION"; \
		echo '( for example usage: "make set-oms-version OMS_VERSION=2.0.0")'; \
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

