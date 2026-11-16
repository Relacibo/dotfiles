#!/usr/bin/env python3
"""Fordert den Entsperr-Dialog fuer den Login-Keyring an (gcr-Prompt).

Grund: Unter Hyprland greift der PAM-Handover nicht (Autologin/GDM-Quirk),
daher bewusst ein Prompt am Session-Start statt lazy dbus-Aktivierung.

Wichtig: Unlock + Prompt müssen über EINE persistente dbus-Verbindung laufen
(gnome-keyring wirft das Prompt-Objekt weg, sobald der Aufrufer sich trennt) —
deshalb secretstorage statt busctl-Zweistufen-Konstrukt.

Wird vom hyprland-Autostart aufgerufen; blockiert bis zur Antwort.
Ist der Keyring schon entsperrt (z.B. PAM-Unlock bei Passwort-Login),
passiert nichts.
"""

import sys

import secretstorage


def main() -> int:
    conn = secretstorage.dbus_init()
    collection = secretstorage.get_default_collection(conn)
    if not collection.is_locked():
        return 0  # schon offen (z.B. PAM-Unlock bei Passwort-Login)
    try:
        collection.unlock()  # blockiert, bis der gcr-Prompt beantwortet ist
    except Exception:
        return 1  # verworfen/abgebrochen — Apps fragen beim Zugriff selbst
    return 0


if __name__ == "__main__":
    sys.exit(main())
