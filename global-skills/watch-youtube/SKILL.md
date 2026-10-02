---
name: watch-youtube
autor: tiago
description: Ver vídeos do YouTube a sério — transcript completo (auto-captions limpas com timestamps) + frames extraídos nos momentos-chave para analisar o que aparece no ecrã. Usa quando o utilizador manda links do YouTube para analisar, resumir, comparar ou tirar ideias de demos/tutoriais.
---

# watch-youtube

Ferramentas (já instaladas em `~/.local/bin`; se faltarem, reinstala assim):
- `yt-dlp` — binário standalone: `curl -fsSL -o ~/.local/bin/yt-dlp https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp_macos && chmod +x ~/.local/bin/yt-dlp`
- `ffmpeg` — estático arm64: zip de `https://ffmpeg.martin-riedl.de/redirect/latest/macos/arm64/release/ffmpeg.zip`

## Fluxo (por vídeo, ID = o `v=` do URL)

1. **Legendas + metadados** (barato, faz sempre primeiro):
   ```sh
   yt-dlp --skip-download --write-auto-subs --sub-langs "en.*" --sub-format vtt -o "ID" "URL"
   yt-dlp --skip-download --print "%(title)s | %(channel)s | %(duration_string)s" "URL"
   ```
2. **Limpar o VTT** (as auto-captions vêm duplicadas em rolling): remove tags,
   deduplica linhas consecutivas/contidas na anterior, e carimba `[m:ss]` a
   cada ~30s.
3. **Ler o transcript inteiro** e identificar os timestamps onde algo é
   MOSTRADO no ecrã (demos de UI, código, diagramas).
4. **Frames só nesses momentos** (não varras o vídeo todo — tokens):
   ```sh
   yt-dlp --js-runtimes "node:$HOME/.local/node-v22/bin/node" \
     -f "b[height<=480][ext=mp4]/18/worst" -o "ID.mp4" "URL"
   ffmpeg -loglevel error -ss SEGUNDOS -i ID.mp4 -frames:v 1 -q:v 3 frame.jpg -y
   ```
   Lê os .jpg com a ferramenta Read. 6-10 frames por vídeo chegam.
5. Trabalha sempre no scratchpad da sessão, nunca no repo do utilizador.

## Regras de honestidade

- Distingue sempre o que OUVISTE (transcript) do que VISTE (frames).
- Se as legendas não existirem em nenhuma língua, di-lo — não inventes
  conteúdo a partir do título.
