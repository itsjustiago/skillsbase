#!/usr/bin/env python3
"""PreToolUse (Bash): bloqueia matar processos por nome.

Porquê: um agente correu `pkill -f "cat" -x` e fechou várias apps abertas (tudo o que tinha "cat"
no caminho, /Applications/...). Só se pode matar pelo PID que o próprio agente lançou.
Exit 2 = bloqueado; a mensagem no stderr volta para o agente.
"""
import json
import re
import sys

try:
    cmd = json.load(sys.stdin).get("tool_input", {}).get("command", "") or ""
except Exception:
    sys.exit(0)

INICIO = r"(?:^|[;&|(`{]\s*|\$\(\s*|\b(?:sudo|xargs|exec|nohup|env|then|do)\s+)"
REGRAS = [
    (INICIO + r"(?:pkill|killall)\b", "pkill/killall matam por nome"),
    (r"\bkill\b[^;&|\n]*(?:\$\(|`)\s*(?:pgrep|pidof|ps|lsof)\b", "kill com PIDs vindos de pgrep/pidof/ps/lsof é matar por nome"),
    (r"\b(?:pgrep|pidof|ps|lsof)\b[^;\n]*\|\s*(?:\S+\s*\|\s*)*xargs\s+(?:-\S+\s+)*kill\b", "pgrep/ps/lsof | xargs kill é matar por nome"),
    (r"tell\s+application\s+[\"'][^\"']+[\"']\s+to\s+quit", "fechar aplicações por nome (osascript quit)"),
]

for padrao, razao in REGRAS:
    if re.search(padrao, cmd):
        sys.stderr.write(
            f"BLOQUEADO: {razao}. Nunca mates processos por nome. Só `kill <PID>` de um processo que TU lançaste "
            "(guarda o PID com `$!` ao lançar). Se precisas mesmo de fechar outra app, pede ao Tiago.\n"
        )
        sys.exit(2)
sys.exit(0)
