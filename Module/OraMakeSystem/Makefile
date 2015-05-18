# makefile: Сборка

# Префикс названия скриптов
scriptPrefix				= oms

# Каталог для данных сборки проекта
buildDir						= Build

# Каталог с дистрибутивами используемых библиотек
configDir 					= Config

# Каталог со скриптами
scriptDir 					= Script

# Каталог с дистрибутивами используемых библиотек
usedLibDir 					= UsedLib



.PHONY: 						\
	all 							\
	clean							\
	install						\
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



# build var: DESTDIR
# Префикс для установки.
DESTDIR				=	/usr/local

# Каталог для общих настроек.
shareDir						= $(DESTDIR)/share/oms

# target: install
# Выполняет установку проекта.

install:
	@( cd $(scriptDir)										\
		&& install --mode=755 --target-directory=$(DESTDIR)/bin 		\
		$(scriptPrefix)-*[^~]								\
	) 																		\
	&& rm -rf "$(shareDir)"								\
	&& mkdir -p "$(shareDir)"							\
	&& tar --create --file=- 							\
				--exclude=.svn 									\
				--exclude=*~ 										\
				--exclude=*.swp 								\
				Config SqlScript UsedLib 				\
		| tar --extract --directory="$(shareDir)"



# target: uninstall
# Отменяет установку проекта.

uninstall:
	-@rm $(DESTDIR)/bin/$(scriptPrefix)-*[^~];	\
	rm -rf "$(shareDir)"
	


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
			-xi "$(configDir)/UpdateModule" 									\
			-xi "$(configDir)/NewModule/DB/OmsModule/NaturalDocs"	\
			-xi "$(configDir)/NewModule/DB/OmsModule/Load"	\
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
			files index javascript styles			\
			index.html menu.html							\
	);																		\
	rm -rf $(gendocCacheDir)/*						\
	


# group: Установка значения версии



# build var: OMS_VERSION
# Новое значение для версии OMS.
# Параметр должен указываться при вызове <set-oms-version>.
OMS_VERSION=

# target: set-oms-version
# Устанавливает новое значение версии OMS в файлах.
# Установка нового значения версии должно выполняться и фиксироваться
# непосредственно перед фиксацией новой версии в Tag.
#
# Пример:
# $ make set-oms-version OMS_VERSION=1.2.0

set-oms-version:
	@if [[ -n "$(OMS_VERSION)" ]]; then \
	  sed --in-place \
	    -e 's/^OMS_VERSION=[0-9.]*$$/OMS_VERSION=$(OMS_VERSION)/' \
	    $(scriptDir)/*[^~] \
	    $(configDir)/NewModule/DB/OmsModule/init.mk \
	    $(configDir)/NewModule/DB/OmsModule/common.mk \
	  && unix2dos \
	    $(configDir)/NewModule/DB/OmsModule/init.mk \
	    $(configDir)/NewModule/DB/OmsModule/common.mk \
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

