---
name: murks
description: Erzeugt strukturierte Koch-Rezepte und öffnet sie direkt in der murks Koch-PWA (https://relacibo.github.io/murks/). Kein Agent nötig. Benutzen wenn der User etwas kochen möchte, Zutaten hat, ein Rezept sucht oder fragt "was koche ich" — Schlüsselwörter: kochen, Rezept, Abendessen, Mittag, Zutaten, Pfannkuchen, Pasta usw.
---

# murks — Rezept generieren und öffnen

murks ist eine voice-first Koch-PWA. Ein strukturiertes Rezept als JSON im
`?recipe=`-Param öffnet das Brett **ohne Agent** direkt mit Strängen, Schritten
und Timern. Der konfigurierte Agent bleibt fürs Anpassen während des Kochens
zuständig.

## Ablauf

1. Vollständiges Rezept als JSON generieren (Regeln unten beachten).
2. JSON minifizieren (keine überflüssigen Leerzeichen).
3. URL bauen und Browser öffnen:

```bash
RECIPE_JSON='<minifiziertes JSON>'
URL="https://relacibo.github.io/murks/?recipe=$(python3 -c \
  'import sys,urllib.parse; print(urllib.parse.quote(sys.argv[1],safe=""))' \
  "$RECIPE_JSON")"
nohup xdg-open "$URL" >/dev/null 2>&1 &
```

Schlägt xdg-open fehl oder will der Nutzer das Rezept im Chat: URL ausgeben,
dann als Text generieren.

---

## Rezept-JSON-Format

```jsonc
{
  "title": "Zucchini-Pfanne mit Reis",   // optional, erscheint im Toast
  "servings": 2,                          // optional, nur Doku
  "ingredients": [
    { "name": "Basmatireis", "amount": "150 g" },
    { "name": "Zucchini", "amount": "2 Stück" }
  ],
  "flows": [
    {
      "name": "Reis",       // Pflicht, kurz
      "icon": "🍚",         // Pflicht, passendes Emoji
      "steps": [
        {
          "description": "150 g Basmatireis in 300 ml Wasser aufkochen, dann auf kleiner Flamme 15 Min. köcheln lassen.",
          "depends_on": [
            { "step_index": 0, "timer_seconds": 900 }
          ]
        }
      ]
    },
    {
      "name": "Gemüse",
      "icon": "🥒",
      "steps": [
        { "description": "Zucchini in Scheiben schneiden." },
        {
          "description": "Zucchini in Öl bei mittlerer Hitze 8 Min. braten.",
          "depends_on": [{ "step_index": 0 }]
        },
        {
          "description": "Mit Salz, Pfeffer, Knoblauch abschmecken und servieren.",
          "depends_on": [
            { "step_index": 1 },
            { "flow_index": 0, "step_index": 0 }
          ]
        }
      ]
    }
  ]
}
```

---

## Modellierungsregeln

### Reihenfolge ist NICHT implizit
Ohne `depends_on` laufen alle Schritte sofort parallel. **Jeder Folgeschritt
muss explizit an seinen Vorgänger gekettet werden** — auch Schritt 2 → Schritt 1.

### Zeitangaben als Kantentimer
Jede passive Wartezeit (backen, ziehen lassen, quellen) gehört als
`timer_seconds` an die Kante zur **Folgekarte** — nicht in die Beschreibung der
wartenden Karte.

```jsonc
// Karte "Reis köcheln lassen 15 Min." ...
{ "step_index": 0, "timer_seconds": 900 }  // 900 s = 15 Min.
// Die Folgekarte ("Reis vom Herd") nennt KEINE Zeit, nur was zu tun ist.
```

Kein Timer wenn das Ergebnis das Ende bestimmt ("bis goldbraun", "bis sämig")
oder der Koch aktiv ist ("unter Rühren aufkochen") — Zeit dann in der
Beschreibung der Karte selbst.

Endet das Rezept mit einer Wartezeit, immer eine finale Karte anhängen
("Anschneiden und servieren") mit timer_seconds auf der Kante.

### depends_on-Schema

| Felder | Bedeutung |
|--------|-----------|
| `step_index` | Vorgänger im **gleichen** Flow, 0-basiert, muss < eigener Index sein |
| `flow_index` + `step_index` | Vorgänger in einem **früheren** Flow (nur rückwärts!) |
| `timer_seconds` | Verzögerung in Sekunden nach Abschluss des Vorgängers |

### Flows sind topologisch sortiert
Cross-Flow-Abhängigkeiten zeigen **immer nur auf frühere Flows** — ein Schritt
in Flow 1 kann nur auf Schritte aus Flow 0 zeigen, nie auf Flow 2.

### So spät wie möglich einplanen (mit Puffer)
Ergebnisse, die altern (vorgeheizter Ofen, geschlagene Sahne, geschmolzene
Butter), gehören NICHT frei an den Anfang — verankere sie so, dass sie genau
dann fertig sind, wenn sie gebraucht werden.

**Beispiel Hirse** (9 Min kochen, 10 Min quellen):
```
Flow "Hirse":
  Schritt 0: "Hirse waschen und aufkochen"
  Schritt 1: "Deckel drauf, quellen lassen"
    depends_on: [{ "step_index": 0, "timer_seconds": 540 }]   // 9 Min kochen
  Schritt 2: "Mit Gabel lockern"
    depends_on: [{ "step_index": 1, "timer_seconds": 600 }]   // 10 Min quellen

Flow "Ofen":
  Schritt 0: "Ofen auf 180° vorheizen"   // ≈ 5 Min Vorheizzeit
    depends_on: [{ "flow_index": 0, "step_index": 1, "timer_seconds": 300 }]
    // Rechnung: Quellzeit 600 − Vorheizzeit 300 = 300 → Ofen startet 5 Min
    // vor Quell-Ende und ist exakt pünktlich heiß.
```

Bei Unsicherheit lieber etwas früher starten — ein heißer Ofen hält die
Temperatur, wartendes Essen wird kalt.

### priority "high"
Für zeitkritische Schritte (Ofen-Alarm etc.). Ein `"high"`-Schritt darf
**höchstens eine** `depends_on`-Kante haben. Sparsam verwenden.

### score (optional, Default 0)
Scheduling-Hinweis: höherer Wert = weiter oben in der aktiven Queue.
Engine propagiert rückwärts automatisch — nur auf der dringendsten Karte setzen.

### Beschreibungen
- Eigenständig ausführbar, Kernaussage zuerst.
- Zeitangaben ans **Ende** der Karte.
- Kurze Sätze, kein überflüssiges Markdown.
- Sprache: Deutsch.

---

## Häufige Fehler

- Schritt 2 ohne `depends_on` auf Schritt 1 → läuft sofort parallel (meistens falsch).
- Wartezeit in der wartenden Karte statt als `timer_seconds` auf der Kante.
- Cross-Flow-Kante auf einen **späteren** Flow → Importfehler.
- `priority: "high"` mit mehr als einer Abhängigkeit → Importfehler.
