#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
if ! command -v node >/dev/null; then echo 'Instale Node.js 22.13 ou mais recente: https://nodejs.org/'; exit 1; fi
if [ -f .env ]; then set -a; . ./.env; set +a; fi
if ! command -v ffmpeg >/dev/null || ! command -v ffprobe >/dev/null; then echo 'ATENÇÃO: Instale FFmpeg para gerar os cortes. https://ffmpeg.org/download.html'; fi
if ! command -v yt-dlp >/dev/null && ! python -m yt_dlp --version >/dev/null 2>&1; then echo 'ATENÇÃO: para importar links do YouTube, instale yt-dlp: python -m pip install -U "yt-dlp[default]"'; fi
echo "Abrindo StreamCut Studio em http://localhost:${PORT:-3000}"
node server.js
