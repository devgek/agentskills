---
name: gek-plain
description: Neues Projekt aus dem Template plain-project erstellen (Spring Boot 4, Spring Data JDBC, PostgreSQL, plain JavaScript).
disable-model-invocation: true
argument-hint: "[artifactId] [groupId] [Elternverzeichnis]"
---

Erstellt ein neues Projekt aus dem committeten Stand (`HEAD`) des Templates `D:\dev-kah\ideaprojects\plain-project`. Nicht committete Änderungen am Template fließen nicht ein.

Argumente: $ARGUMENTS

## Schritte

1. **Parameter klären.** Aus den Argumenten übernehmen, fehlende beim Benutzer erfragen:
   - `artifactId` (Pflicht, kebab-case, z. B. `my-shop`). Daraus leitet das Skript ab: Package-Segment `myshop`, Klasse `MyShopApplication`, DB-Name/-User `myshop`.
   - `groupId` (Default `com.kah`)
   - Elternverzeichnis (Default `/d/dev-kah/ideaprojects`); das Projekt landet in `<Elternverzeichnis>/<artifactId>`.

   Fertig, wenn alle drei Werte feststehen und der Benutzer die abgeleiteten Namen gesehen hat.

2. **Generieren** mit dem Bash-Tool:

   ```bash
   bash ~/.claude/skills/gek-plain/new-project.sh <artifactId> <groupId> <Elternverzeichnis>
   ```

   Das Skript kopiert das Template, verschiebt die Java-Packages, ersetzt alle Namen, entfernt die Template-Hinweise aus `README.md` und `pom.xml` und legt ein Git-Repo mit Initial-Commit an. Es bricht ab, wenn das Ziel schon existiert. Fertig, wenn es `TARGET=…` ausgibt.

3. **Prüfen** im neuen Projekt:
   - `grep -rniE "plainproject|plain-project|PlainProject" --exclude-dir=.git .` liefert keine Treffer.
   - `./mvnw -q test-compile` läuft grün (die Tests selbst brauchen Docker und laufen hier nicht).

   Fertig, wenn beides zutrifft. Sonst die Ursache beheben, per Amend in den Initial-Commit übernehmen und erneut prüfen.

4. **Übergeben.** Dem Benutzer Pfad, Package und Application-Klasse nennen und darauf hinweisen, dass das Beispiel-Feature `note` sowie `CONTEXT.md` und `PROPOSAL.md` noch zur Domäne des Templates gehören und für das neue Projekt angepasst oder entfernt werden sollten.
