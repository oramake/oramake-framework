#!/bin/bash

isCommitNewPackage=1

for filePath in "$@"; do
  fileName=${filePath##*/}
  packageName=${fileName%%-[0-9]*}
  packageNumber=${fileName:${#packageName}}
  packageNumber=${packageNumber%%-x86_64.*}
  packageNumber=${packageNumber#-}
  packagePath="MSYS2-packages/$fileName"
  tarOpt=
  case $fileName in
    *.zst) tarOpt="--use-compress-program=zstd";;
    *) tarOpt="--auto-compress"
  esac
  isNewPackage=0

  if [[ "$filePath" != "$packagePath" ]] && [[ "$filePath" != "./$packagePath" ]]; then
    isNewPackage=1
  fi

  if (( isNewPackage )); then \
      cp "$filePath" MSYS2-packages \
      && chmod -x "$packagePath" \
      && git add "$packagePath"; \
    fi \
  && cd MSYS2 \
  && tar $tarOpt -xf "../$packagePath" \
  && if ! [[ -d usr/share/oms-msys2 ]]; then \
      mkdir -p "usr/share/oms-msys2"; \
    fi \
  && mkdir "usr/share/oms-msys2/$packageName" \
  && mv .??* "usr/share/oms-msys2/$packageName" \
  && git add . \
  && for f in $(tar $tarOpt -tf "../$packagePath"); do \
      if [[ -f "$f" ]] && [[ -x "$f" ]]; then \
        find "$f" -perm /+x -exec git update-index --chmod=+x "$f" \; ; \
      fi; \
    done \
  && cd .. \
  && if (( isNewPackage && isCommitNewPackage )); then \
      git commit -m "chore(OraMakeSystem): add package $packageName $packageNumber for Build/Win64"; \
    fi \
  || exit 30

done
