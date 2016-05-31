# makefile: ������������� OMS

# ���� ������� ������ OMS-�������, �� ������ �������� ��� ������ ����.
#
# SVN Version Information:
# OMS root: Oracle/Module/OraMakeSystem
# $Revision: 2132 $
# $LastChangedDate:: 2014-07-08 18:40:00 +0300 #$

# ������ OMS-�������
OMS_VERSION=1.7.3



#
# group: ���������
#

#
# group: �����������
#

# build var: empty
# ������ ��������.
empty :=

# build var: comma
# �������.
comma := ,

# build var: space
# ������.
space := $(empty) $(empty)

# build var: rrb
# ������ ������� ������.
rrb   := )

# build var: tab
# ���������.
tab := $(empty)	$(empty)



#
# group: �������
#

#
# group: �����
#



# build func: getXmlElementValue
# ���������� �������� ���������� XML-��������.
#
# ���������:
# (1)     - ��� ��������
# (2)     - ����� XML, �� �������� ���������� �������� ��������
#
# ���������:
# - ��� ������� � ������ XML ���������� ��������� � ��������� ������,
#   ������������ �������� ������� ��������;
# - � ������������ �������� ������ ��������� ���������� �� ������, ����� ����
#   ��������� ��������� � �������� �������;
#
getXmlElementValue = $(strip \
  $(subst <$(1)>,,$(subst </$(1)>,,$(subst &\#20;,$(space), \
    $(firstword $(filter <$(1)>%</$(1)>, \
      $(subst <$(1)>,$(space)<$(1)>,$(subst </$(1)>,</$(1)>$(space), \
        $(subst $(space),&\#20;,$(subst $(tab),$(space),$(2))) \
      )) \
    )) \
  ))))



# build func: getMakeFlagList
# ���������� ����� ������� make.
#
# �������:
# �����, ��������� �� ������������� ���� ���������������� �����.
#
# ������:
# � ������ �������� ��� ������� make ����� "--ignore-errors -B" �������
# ������ "iB".
#
getMakeFlagList = $(if $(filter --,$(MAKEFLAGS)),$(filter-out --%, \
    $(call wordListTo,--,$(MAKEFLAGS)) \
  ))



# build func: isMakeFlag
# �������� ������������� ����� � ������ make.
#
# ���������:
# (1)     - ����������� ( �������������) ��� �����
#
# �������:
# ������������� ��� ����� ��� �� ������������� ��� ������ ������ ���� �����
# �� ��������������.
#
isMakeFlag = $(findstring $(strip $(1)),$(call getMakeFlagList))



# build func: nullif
# ���������� ������ ������, ���� ������ �������� ����� �������, �����
# ���������� ������ ��������.
#
# (1)     - �������� ������
# (2)     - ������ ��� ���������
#
nullif = $(if $(subst $(1),,$(2))$(subst $(2),,$(1)),$(1),)



# build func: ltrim
# ������� ��������� ������� �����, ��������������� ����������.
#
# ���������:
# $(1)    - �������� �����
# $(2)    - ��������� ������ ( ������������������ ��������)
#
# ���������:
# - ����� ��� ��������� ����� ��������� ��������� � �������� �������, � �����
#   ������������� ������� � �������� ����� ( ����������� ������� strip);
#
ltrim = \
  $(strip $(if $(1),$(if $(2),$(if $(patsubst $(2)%,,$(1)),$(1),$(call ltrim,$(patsubst $(2)%,%,$(1)),$(2))),$(1)),))



# build func: compareNumber
# ���������� ����� ��������������� �����.
#
# ���������:
# $(1)    - ������ �����
# $(2)    - ������ �����
#
# �������:
# 1       - ������ ����� ������ �������
# 0       - ������ ����� ����� �������
# -1      - ������ ����� ������ �������
#
compareNumber = \
  $(strip \
    $(call compareNumber_Internal, \
      $(call compareNumber_DigitList,$(call ltrim,$(1),0)), \
      $(call compareNumber_DigitList,$(call ltrim,$(2),0))))

# ���������� ������ ���� ����� $(1).
#
compareNumber_DigitList = \
  $(strip $(call compareNumber_SepDigit,$(1),0 1 2 3 4 5 6 7 8 9))

# ��������� � ������ $(1) ������� ����� ������� �� ������ $(2).
compareNumber_SepDigit = \
  $(if $(firstword $(2)), \
    $(call compareNumber_SepDigit, \
      $(subst $(firstword $(2)), $(firstword $(2)),$(1)), \
      $(wordlist 2,10,$(2))), \
    $(1))

# ���������� ����� ��������������� �����, ���������� � ���� ������ ���� ���
# ��������� ���������� �����.
#
compareNumber_Internal = \
  $(if $(firstword $(1) $(2)), \
    $(if $(firstword $(1)), \
      $(if $(firstword $(2)), \
        $(if $(word $(words $(1)),$(2)), \
          $(if $(word $(words $(2)),$(1)), \
            $(foreach cmp, \
              $(call compareNumber_CompareDigit \
                ,$(firstword $(1)),$(firstword $(2))), \
              $(if $(call nullif,$(strip $(cmp)),0), \
                $(cmp), \
                $(call compareNumber_Internal, \
                  $(wordlist 2,$(words $(1)),$(1)), \
                  $(wordlist 2,$(words $(2)),$(2))))), \
            -1), \
          1), \
        1), \
      -1), \
    0)

# ���������� ��� ����� ( ������ ���� ����������� �������).
#
compareNumber_CompareDigit = \
  $(if $(call nullif,$(1),$(2)), \
    $(if $(call nullif,$(1),$(firstword $(sort $(1) $(2)))),1,-1), \
    0)



# build func: translate
# ��������� ���������� �������� �������� ������.
#
# ���������:
# (1)     - �������� ������
# (2)     - ������ �������� ���� ��� ����������
# (3)     - ������ �������������� ���� ��� ����������
#
translate  = \
  $(if $(firstword $(2)),$(call \
    translate,$(subst $(firstword $(2)),$(firstword $(3)),$(1)),$(wordlist \
      2,$(words $(2)),$(2)),$(wordlist \
      2,$(words $(3)),$(3))),$(1))



# build func: translateWord
# ��������� ���������� ���� �������� ������.
#
# ���������:
# (1)     - �������� ������
# (2)     - ������ �������� ���� ��� ����������
# (3)     - ������ �������������� ���� ��� ����������
#
translateWord  = \
  $(if $(firstword $(2)),$(call \
    translateWord,$(patsubst $(firstword $(2)),$(firstword $(3)),$(1)), \
      $(wordlist 2,$(words $(2)),$(2)), \
      $(wordlist 2,$(words $(3)),$(3))),$(1))



# build func: wordListTo
# ���������� ������ ���� �� ������ � ������ � �� ���������� �����-�������
# ( �� ������� ������).
#
# ���������:
# (1)     - �����-������ ( ����� ������������ ��������� ������ "%")
# (2)     - �������� �����
#
wordListTo = $(if $(filter-out $(1),$(firstword $(2))),$(strip \
  $(firstword $(2)) $(call wordListTo,$(1),$(wordlist 2,$(words $(2)),$(2))) \
  ))



# build func: wordPosition
# ���������� ���������� ������ ���� ������, ������ ���������� �����.
# ����� � ������ ���������� ������� � 1.
#
# ���������:
# (1)                         - ����� ��� ������ � ������
# (2)                         - �����
#
# ������:
#
# "$(call wordPosition,aa,aa bb cc aa mm)" ���������� "1 4"
#
wordPosition = \
  $(if $(1),$(strip \
    $(call wordPosition_Internal,$(1),$(2),$(words $(2)),1) \
  ))

# ���������:
# (1)                         - ����� ��� ������ � ������
# (2)                         - ������� �����
# (3)                         - ����� ���� � �������� ������
# (4)                         - ������������ ����� � ������ ����, ������
#                               ������ ������� ����� $(2) � �������� ������
#
wordPosition_Internal = \
  $(if $(2), \
    $(if $(call nullif,$(1),$(firstword $(2))),,$(words $(4))) \
    $(call wordPosition_Internal,$(1),$(wordlist 2,$(3),$(2)),$(3),$(4) 1) \
  )



#
# group: ������� ��������
#

# build func: changeCase
# ��������� ������� ������ � ������ �������.
#
# ���������:
# (1)     - �������� ������
# (2)     - ��� ���� �������� ( U � ������� �������, L � ������ �������)
#
changeCase = $(call changeCase_Internal,$(1),$(strip $(subst L,,$(2))), \
  a b c d e f g h i j k l m n o p q r s t u v w x y z , \
  A B C D E F G H I J K L M N O P Q R S T U V W X Y Z \
  )

changeCase_Internal = $(call translate,$(1), \
  $(if $(2),$(3),$(4)), \
  $(if $(2),$(4),$(3)) \
  )



# build func: lower
# ��������� ������� ������ � ������ �������.
#
# ���������:
# (1)     - �������� ������
#
lower  = $(call changeCase,$(1),L)



# build func: upper
# ��������� ������� ������ � ������� �������.
#
# ���������:
# (1)     - �������� ������
#
upper  = $(call changeCase,$(1),U)



#
# group: ����� ������
#



# build func: compareVersion
# ���������� ������ ������.
# ����� ������ ������������ ����� ������������������ ����� ���������������
# �����, ����������� ������.
#
# ���������:
# $(1)    - ������ ����� ������
# $(2)    - ������ ����� ������
#
# �������:
# 1       - ������ ����� ������ �������
# 0       - ������ ����� ����� �������
# -1      - ������ ����� ������ �������
#
compareVersion = \
  $(strip $(call compareVersion_Internal,$(subst ., ,$(1)),$(subst ., ,$(2))))

# ���������� ������ ������, �������� ������� �����.
#
compareVersion_Internal = \
  $(if $(firstword $(1)$(2)), \
    $(foreach cmp, \
      $(call compareNumber,$(firstword $(1)),$(firstword $(2))), \
      $(if $(call nullif,$(cmp),0), \
        $(cmp), \
        $(call compareVersion_Internal, \
          $(wordlist 2,$(words $(1)),$(1)), \
          $(wordlist 2,$(words $(2)),$(2))))) \
    ,0)



# build func: getVersionDir
# ���������� �������� � �������� ������ � ����������� ���������� ������.
#
# ���������:
# $(1)    - ���� � ��������, � ������� ����������� �������� � ��������
#
# ���������:
# - �������� � �������� ������ ������ ��������������� ����� [0-9.]*
#
getVersionDir = \
  $(shell ls -1d --sort=v $(1)/[0-9.]* 2>/dev/null)



#
# group: ������ ������ �����������
#

# build func: getDbName
# ���������� ��� �� ( � ������ ��������).
#
# ���������:
# (1)     - ������ ����������� � �� � ������� [userName[/password]][@dbName]
# (2)     - ��� �� �� ��������� ( ������������, ���� � (1) �� �� �������)
#
getDbName = $(strip $(call lower, \
  $(if $(findstring @,$(1)), \
    $(word \
      $(words $(subst @, ,$(1)x)) \
      , $(subst @, ,$(1)) $(2) \
    ) \
    , $(2) \
  )))



# build func: getProductionDbName
# ���������� ��� ������������ ��.
#
# ��� ����������� ����� ������������ ��, � ������ �������� ��
# ( <getProductionDbName_TestDbList>) ����������� ����� �� ���������� ����� ��
# � � ������ ���������� ���������� ( ��� ����� ��������) ������ �����������
# ����� ������������ ��� ������������ �� �� <getProductionDbName_ProdDbList>,
# ����������� � ��� �� ������� � ������, ��� � ��������� ����������. �����
# � ������, ���� �������� ��� �������� ������ ������������ �� ( �����������
# ���������� ��� ����� �������� � �������, ���������� �
# <getProductionDbName_ProdDbList> � <getProductionDbName_ExtraDbList>), ��
# ������������ ������ ( � ������ ��������) ��� ���� ������������ ��. ���� ��
# ������� ���������� ��� ������������ ��, �� ������������ ������ ������.
#
# ���������:
# (1)     - �������� ��� ��
#
# �������:
# ������ ( � ������ ��������) ��� ������������ �� ���� ������ ������,
# ���� �� ������� ����������.
#
getProductionDbName = $(call \
  getProductionDbNameInternal,$(call lower,$(firstword $(1))))

getProductionDbNameInternal = $(strip $(if $(1), \
  $(call nullif,$(call translateWord,$(1), \
      $(getProductionDbName_TestDbList) \
        $(call lower,$(getProductionDbName_AllProdList)), \
      $(getProductionDbName_ProdDbList) \
        $(getProductionDbName_AllProdList) \
    ),$(1)) \
  ,))

# build var: getProductionDbName_TestDbList
# ������ �������� �� ��� ������� <getProductionDbName>.
# ����� ������ ����������� � ������ ��������, ��� ���� � ��� �� �� �������
# ����� ���������� <getProductionDbName_ProdDbList> ������ ���� �������
# ��� ������������ �� ��� ������ �������� ��.
#
getProductionDbName_TestDbList = \
  TestDb

# build var: getProductionDbName_ProdDbList
# ������������ �� ��� �������� ��, ��������� � ������
# <getProductionDbName_TestDbList>.
# ����� �� ������ ���� ������� � ������ �������� �������� � ������������
# � ������������ ���������� ����� ���������� �� ( ��������, ������ �����
# ����� � ������� �������� � �.�.).
#
getProductionDbName_ProdDbList = \
  ProdDb

# build var: getProductionDbName_ExtraDbList
# ������������ ��, ������������� � ������ <getProductionDbName_ProdDbList>
# ( ��� ������� ��� �������� ��).
# ����� �� ����������� � ������ �������� ( ����������
# <getProductionDbName_ProdDbList>).
#
getProductionDbName_ExtraDbList = \

# ������ ���� ������������ ��.
getProductionDbName_AllProdList = \
  $(sort $(getProductionDbName_ExtraDbList) $(getProductionDbName_ProdDbList))

# ��������� ������������ ������� ������� ���������� ���� ��
ifneq ($(words $(getProductionDbName_TestDbList)),$(words $(getProductionDbName_ProdDbList)))

tmpVar := $(error � ���������� getProductionDbName_TestDbList � getProductionDbName_ProdDbList ������� ��������� ����� ����)

endif

# ��������� ������������ ������� ���� ������������ ��
ifneq ($(words $(getProductionDbName_AllProdList)),$(words $(sort $(call lower,$(getProductionDbName_AllProdList)))))

tmpVar := $(error ��� ����� � ��� �� �� � ���������� getProductionDbName_ProdDbList � getProductionDbName_ExtraDbList ���������� ��������� ��������)

endif



# build func: getUserName
# ���������� ��� ������������ ( � ������ ��������).
#
# ���������:
# (1)     - ������ ����������� � �� � ������� [userName[/password]][@dbName]
#
getUserName = $(strip \
  $(if $(patsubst @%,,$(1)),$(call lower, \
    $(firstword $(subst /, ,$(firstword $(subst @, ,$(1))))) \
    , \
  )))



# build func: getUser
# ���������� ������������ �� � ������� userName@dbName ( � ������ ��������).
#
# ���������:
# (1)     - ������ ����������� � �� � ������� [userName[/password]][@dbName]
#
getUser = $(strip \
  $(call getUserName,$(1))$(addprefix @,$(call getDbName,$(1),)) \
  )



# build func: getLocalDbDir
# ���������� ��� ���������� �����������, ���������������� ��������� ��.
#
# ���������:
# $(1)                        - ��� ��
#
# �������:
# ��� ���������� ����������� ���� "-" ���� �� ������� ���������� ���
# ������������ ��.
#
getLocalDbDir = $(firstword $(call getProductionDbName,$(firstword $(1))) -)



# build func: getLocalUserDir
# ���������� ���� � ���������� �����������, ���������������� ����������
# ������������.
#
# ���������:
# $(1)                        - ������ � ������ �� � ������ ������������ �
#                               ������� "<dbName>/<userName>"
#
# �������:
# ���� � ���������� ����������� ( ������������ �������� "Local") ���� "-"
# ���� �� ���� ������� ��� ������������ ��� �� ������� ���������� ���
# ������������ ��.
#
getLocalUserDir = $(firstword $(if $(word 2,$(subst /, ,$(1))), \
  $(addsuffix /$(call getUserName,$(word 2,$(subst /, ,$(1)))), \
  $(call getProductionDbName,$(firstword $(subst /, ,$(1))))) \
  ,) -)



#
# group: ��������� ����������� ������
#

# build func: getArgumentDefineFileWord
# ���������� �����, ���������� ����� ������������ ����� � ������������ ���
# ���������� ��� ����������.
#
# ���������:
# $(1)    - ������ ����������� ������ ( ���� � ����������� $(lu*) ��� $(ru*))
#
getArgumentDefineFileWord = $(addsuffix $(rrb),$(1))



# build func: getArgumentDefine
# ���������� ����� ��� ���������� ����������, ������������ ��� �������� �����.
#
# ���������:
# $(1)    - ������ ����������� ������ ( ���� � ����������� $(lu*) ��� $(ru*))
# $(2)    - ������ ���������� ( ����� ������, ������ �������� � ��������)
#
getArgumentDefine = \
  $(addsuffix $(space)echo '$(2)'; ;;,$(call getArgumentDefineFileWord,$(1)))



# build func: getNzArgumentDefine
# ���������� ����� ��� ���������� ����������, ������������ ��� �������� �����
# � ������, ���� ������������ �� ������ ( �������� �� "") �������� ����������.
#
# ���������:
# $(1)    - ������ ����������� ������ ( ���� � ����������� $(lu*) ��� $(ru*))
# $(2)    - ������ ���������� ( ����� ������, ������ �������� � ��������)
#
getNzArgumentDefine = \
  $(if $(strip $(subst "",,$(2))),$(call getArgumentDefine,$(1),$(2)),)



# build func: ifArgumentDefined
# ��������� ���������� ���������� ��� ���������� ������������ ����� ( �� �������
# ������������).
#
# ���������:
# $(1)    - ����������� ���� ( ���� � ����������� $(lu*) ��� $(ru*))
# $(2)    - ������ ����������� ���������� ( ������ $(loadArgumentList))
#
# �������:
# - ���� ��������� ���������, �� ���������� ��� ����� $(1), ����� ������
#
ifArgumentDefined = \
  $(if $(filter $(call getArgumentDefineFileWord,$(1)),$(2)),$(1),)

