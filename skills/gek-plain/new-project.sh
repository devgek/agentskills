#!/usr/bin/env bash
# Erstellt aus dem Template plain-project (Branch main auf GitHub) ein neues Projekt.
# Aufruf: new-project.sh <artifactId> [groupId] [Elternverzeichnis]
set -euo pipefail

TEMPLATE="${GEK_PLAIN_TEMPLATE:-https://github.com/devgek/plain-project.git}"   # URL oder lokaler Pfad eines Git-Repos
ARTIFACT="${1:?artifactId fehlt, z. B. my-shop}"
GROUP="${2:-com.kah}"
PARENT="${3:-/d/dev-kah/ideaprojects}"

[[ "$ARTIFACT" =~ ^[a-z][a-z0-9-]*[a-z0-9]$ ]] || { echo "artifactId muss kebab-case sein (a-z, 0-9, -): $ARTIFACT" >&2; exit 1; }
[[ "$GROUP" =~ ^[a-z][a-z0-9]*(\.[a-z][a-z0-9]*)*$ ]] || { echo "groupId ungültig: $GROUP" >&2; exit 1; }

TARGET="$PARENT/$ARTIFACT"
[[ -e "$TARGET" ]] && { echo "Ziel existiert bereits: $TARGET" >&2; exit 1; }

PKG_SEGMENT="${ARTIFACT//-/}"                                  # my-shop -> myshop
PACKAGE="$GROUP.$PKG_SEGMENT"                                   # com.kah.myshop
PACKAGE_PATH="${PACKAGE//.//}"                                  # com/kah/myshop
PASCAL="$(sed -E 's/(^|-)([a-z0-9])/\U\2/g' <<<"$ARTIFACT")"    # MyShop

# Nur der letzte Stand, ohne Historie des Templates
git clone -q --depth 1 --branch main "$TEMPLATE" "$TARGET"
cd "$TARGET"
rm -rf .git

# Java-Packages verschieben (main und test)
for root in src/main/java src/test/java; do
  mkdir -p "$root/$PACKAGE_PATH"
  mv "$root/com/kah/plainproject/"* "$root/$PACKAGE_PATH/"
  rmdir "$root/com/kah/plainproject"
  rmdir "$root/com/kah" "$root/com" 2>/dev/null || true
done
mv "src/main/java/$PACKAGE_PATH/PlainProjectApplication.java" "src/main/java/$PACKAGE_PATH/${PASCAL}Application.java"

# Namen in allen Textdateien ersetzen (Reihenfolge: spezifisch vor allgemein)
find . -type f ! -name mvnw ! -name mvnw.cmd ! -path './.mvn/*' -print0 | xargs -0 sed -i \
  -e "s/com\.kah\.plainproject/$PACKAGE/g" \
  -e "s#com/kah/plainproject#$PACKAGE_PATH#g" \
  -e "s/PlainProjectApplication/${PASCAL}Application/g" \
  -e "s/plain-project/$ARTIFACT/g" \
  -e "s/plainproject/$PKG_SEGMENT/g" \
  -e "s#<groupId>com\.kah</groupId>#<groupId>$GROUP</groupId>#" \
  -e "s/groupId \`com\.kah\`/groupId \`$GROUP\`/"

# Template-Hinweise aus pom.xml und README.md entfernen
sed -i 's#<description>Template: #<description>#' pom.xml
sed -i '/^## This project is used as a starting point/,+1d; s/^Template für Webapplikationen/Webapplikation/' README.md
sed -i '/^## Template für ein neues Projekt verwenden/,$d' README.md
sed -i -e :a -e '/^\n*$/{$d;N;ba' -e '}' README.md   # Leerzeilen am Ende entfernen

git init -q
git -c core.safecrlf=false add -A
git commit -q -m "Projekt $ARTIFACT aus Template plain-project erstellt"

echo "TARGET=$TARGET"
echo "PACKAGE=$PACKAGE"
echo "APPLICATION=${PASCAL}Application"
