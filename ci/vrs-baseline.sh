#!/usr/bin/env bash
set -euo pipefail

required_tools=(java javac ant svnversion git)
for tool in "${required_tools[@]}"; do
  if ! command -v "$tool" >/dev/null 2>&1; then
    echo "missing required tool: $tool" >&2
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

echo "== JAIN-SIP VRS baseline =="
echo "commit: $(git rev-parse HEAD)"
echo "$java_version"
echo "$javac_version"
ant -version
svnversion --version --quiet
git --version

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
