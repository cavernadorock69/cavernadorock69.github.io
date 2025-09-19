#!/bin/bash
# Uso: ./converter.sh /caminho/para/a/pasta

# --- Instalação do FFmpeg (caso não esteja instalado) ---
if ! command -v ffmpeg &> /dev/null; then
  echo "⚡ Instalando ffmpeg..."
  if command -v apt &> /dev/null; then
    sudo apt update && sudo apt install -y ffmpeg
  elif command -v dnf &> /dev/null; then
    sudo dnf install -y ffmpeg
  elif command -v pacman &> /dev/null; then
    sudo pacman -Sy ffmpeg --noconfirm
  else
    echo "❌ Gerenciador de pacotes não detectado. Instale o ffmpeg manualmente."
    exit 1
  fi
else
  echo "✅ ffmpeg já está instalado."
fi

# --- Verifica argumento ---
if [ -z "$1" ]; then
  echo "Uso: $0 /caminho/para/a/pasta"
  exit 1
fi

PASTA="$1"

# --- Conversão ---
find "$PASTA" -type f \( -iname "*.flac" -o -iname "*.wav" \) | while read -r arquivo; do
  dir=$(dirname "$arquivo")
  base=$(basename "$arquivo")
  nome="${base%.*}"
  saida="$dir/$nome.mp3"

  echo "🎵 Convertendo: $arquivo → $saida"

  # Conversão em MP3 (máxima qualidade CBR 320 kbps)
  ffmpeg -y -i "$arquivo" -c:a libmp3lame -b:a 320k -map_metadata 0 "$saida"

  # Apagar original se conversão foi bem-sucedida
  if [ $? -eq 0 ]; then
    rm -f "$arquivo"
    echo "🗑️ Original removido: $arquivo"
  else
    echo "⚠️ Erro ao converter: $arquivo"
  fi
done

echo "✅ Conversão finalizada!"

