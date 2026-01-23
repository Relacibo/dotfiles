#!/usr/bin/python3
import sys
import io
import re
import os

# 1. ENV-CHECK (Bevor stdin gelesen wird!)
VENV_NAME = "chessimg2pos"
VENV_PATH = os.path.expanduser(f"~/.local/share/pipx/venvs/{VENV_NAME}/bin/python")

try:
    from chessimg2pos import predict_fen
except ImportError:
    # Falls wir nicht im Venv sind, wechsle sofort den Interpreter
    if os.path.exists(VENV_PATH) and sys.executable != VENV_PATH:
        os.execv(VENV_PATH, [VENV_PATH] + sys.argv)
    else:
        print(f"Fehler: Library nicht gefunden. Ist das pipx-Paket '{VENV_NAME}' installiert?", file=sys.stderr)
        sys.exit(1)

def fix_fen(fen):
    """Konvertiert 1111 -> 4 für Lichess-Kompatibilität."""
    if not fen:
        return None
    return re.sub(r'1+', lambda m: str(len(m.group(0))), fen)

def main():
    try:
        # Bild aus stdin lesen (Binärmodus für grim/hyprshot)
        image_data = sys.stdin.buffer.read()
        if not image_data:
            # Falls User den Screenshot abbricht (z.B. ESC bei slurp)
            sys.exit(0) 

        img_file = io.BytesIO(image_data)
        raw_fen = predict_fen(img_file)
        
        if not raw_fen or len(raw_fen.split('/')) != 8:
            print("Fehler: Kein Schachbrett erkannt.", file=sys.stderr)
            sys.exit(1)

        print(fix_fen(raw_fen))

    except Exception as e:
        print(f"Interner Fehler: {str(e)}", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    main()
