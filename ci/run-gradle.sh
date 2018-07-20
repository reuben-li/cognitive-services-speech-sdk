#!/bin/bash
#
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT license.
#

USAGE="Usage: $0 samples-dir [<path-to-maven-repository>]"

SAMPLES_DIR="${1?$USAGE}"

if [[ -n $1 ]]; then
  PACKAGE_PATH="$(cygpath -aw "$2")"
else
  PACKAGE_PATH=
fi

echo $PACKAGE_PATH

set -e -x -o pipefail

readarray -t PROJECTS < <(find "$SAMPLES_DIR" -name gradlew.bat -printf '%h\n')

for dir in "${PROJECTS[@]}"; do
  echo $dir
  pushd "$dir"
  [[ -e gradlew.bat ]]
  [[ -e build.gradle ]]

  # Patch in local repo if package path specified

  [[ -n $PACKAGE_PATH ]] && {

  cat >> build.gradle <<MAVEN
allprojects {
    repositories {
        maven {
            url '${PACKAGE_PATH//\\/\\\\}'
        }
    }
}
MAVEN
    }

    ./gradlew assemble

  popd
done
