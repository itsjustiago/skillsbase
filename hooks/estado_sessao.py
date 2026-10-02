#!/usr/bin/env python3
# SessionStart: diz à sessão onde vive o ficheiro de estado desta pasta e, se ele
# existir, injeta-o. É o que permite compactar ou abrir chat novo sem re-explicar.
#
# O ficheiro vive em ~/.claude/estado/ e NÃO dentro do projeto: o /ship-merge faz
# `git add -A`, e um estado.md dentro do repo acabava commitado em todos os PRs.
import json, os, re, sys, time

MAX = 8000  # o estado é um resumo; mais do que isto é diário, não estado

# `--mostrar`: é o /preclear que chama, para saber que ficheiro reescrever e o que já
# lá está. O nome sai desta mesma conta para o skill e o hook nunca divergirem.
mostrar = "--mostrar" in sys.argv
if mostrar:
    dados = {"cwd": os.getcwd()}
else:
    try:
        dados = json.load(sys.stdin)
    except Exception:
        sys.exit(0)

cwd = dados.get("cwd") or os.getcwd()
origem = dados.get("source", "startup")
nome = re.sub(r"[^A-Za-z0-9]+", "-", cwd).strip("-")[-150:]
pasta = os.path.expanduser("~/.claude/estado")
ficheiro = os.path.join(pasta, nome + ".md")

if mostrar:
    print(f"Ficheiro: {ficheiro}")
    try:
        with open(ficheiro, encoding="utf-8") as f:
            print(f.read()[:MAX])
    except OSError:
        print("(ainda não existe)")
    sys.exit(0)

linhas = [
    f"Ficheiro de estado desta pasta: {ficheiro}",
    "Em trabalho longo, mantém-no atualizado nos marcos (objetivo, decisões, feito, "
    "próximo passo, agentes/processos em fundo). Curto — é estado, não diário.",
]

if os.path.exists(ficheiro):
    try:
        with open(ficheiro, encoding="utf-8") as f:
            conteudo = f.read()
        horas = (time.time() - os.path.getmtime(ficheiro)) / 3600
        idade = f"{horas:.0f}h" if horas < 48 else f"{horas / 24:.0f} dias"
        if len(conteudo) > MAX:
            conteudo = conteudo[:MAX] + "\n[…cortado — o estado passou o limite, encurta-o]"
        aviso = (
            "Continuas esta tarefa: retoma daqui sem pedir ao Tiago para re-explicar."
            if origem in ("compact", "clear", "resume")
            else "Pode ser de uma tarefa anterior nesta pasta — usa só se for o mesmo trabalho."
        )
        linhas += ["", f"Estado guardado (atualizado há {idade}). {aviso}", "", conteudo]
    except Exception:
        pass

print(json.dumps({
    "hookSpecificOutput": {
        "hookEventName": "SessionStart",
        "additionalContext": "\n".join(linhas),
    }
}))
