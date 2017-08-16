#!/bin/bash

for filePath in "$@"; do
  fileName=${filePath##*/}
  packageName=${fileName%%-[0-9]*}
  packagePath="MSYS2-packages/$fileName"
  isNewPackage=0

  if [[ "$filePath" != "$packagePath" ]] && [[ "$filePath" != "./$packagePath" ]]; then
    isNewPackage=1
  fi

  if (( isNewPackage )); then \
      cp "$filePath" MSYS2-packages \
      && git add "$packagePath"; \
    fi \
  && cd MSYS2 \
  && tar xfa "../$packagePath" \
  && if ! [[ -d usr/share/oms-msys2 ]]; then \
      mkdir -p "usr/share/oms-msys2"; \
    fi \
  && mkdir "usr/share/oms-msys2/$packageName" \
  && mv .??* "usr/share/oms-msys2/$packageName" \
  && git add . \
  && find . -type f -executable -exec git update-index --chmod=+x {} \; \
  && cd .. \
  && if (( isNewPackage )); then \
      git commit; \
    fi \
  || exit 30

done
