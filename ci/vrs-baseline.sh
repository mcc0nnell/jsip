#!/usr/bin/env bash
set -euo pipefail

required_tools=(java javac ant svnversion git)
for tool in "${required_tools[@]}"; do
  if ! command -v "$tool" >/dev/null 2>&1; then
    echo "missing required tool: $tool" >&2
    exit 2
  fi
done

required_files=(
  build.xml
  ant-build-config.properties
  tck.properties
  lib/log4j-1.2.15.jar
  lib/junit-3.8.1.jar
  ant-tasks/lib/ant.jar
  ant-tasks/lib/jdom.jar
)
for path in "${required_files[@]}"; do
  if [[ ! -f "$path" ]]; then
    echo "missing inherited baseline input: $path" >&2
    exit 2
  fi
done

java_version="$(java -version 2>&1 | head -n 1)"
javac_version="$(javac -version 2>&1 | head -n 1)"
if [[ "$java_version" != *'1.8.'* ]] || [[ "$javac_version" != javac\ 1.8.* ]]; then
  echo "JAIN-SIP baseline requires JDK 8" >&2
  echo "java: $java_version" >&2
  echo "javac: $javac_version" >&2
  exit 2
fi

subject_commit="$(git rev-parse --verify 'HEAD^{commit}')"

echo "== JAIN-SIP VRS baseline =="
echo "commit: $subject_commit"
echo "$java_version"
echo "$javac_version"
ant -version
svnversion --version --quiet
git --version

echo "== inherited inputs =="
printf '%s\n' "${required_files[@]}"
echo "note: version.txt is legacy svnversion-derived build metadata; the exact Git commit above is the source identity"

echo "== build =="
ant make

echo "== TCK =="
ant runtck

echo "== evidence paths =="
printf '%s\n' \
  'test-reports/' \
  'logs/' \
  '*.jar' \
  'version.txt' \
  'TIMESTAMP'
