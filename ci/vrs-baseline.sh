#!/usr/bin/env bash
set -euo pipefail

required_tools=(java javac ant svnversion git)
for tool in "${required_tools[@]}"; do
  if ! command -v "$tool" >/dev/null 2>&1; then
    echo "missing required tool: $tool" >&2
    exit 2
  fi
done

echo "== JAIN-SIP VRS baseline =="
echo "commit: $(git rev-parse HEAD)"
java -version
javac -version
ant -version
svnversion --version --quiet

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
