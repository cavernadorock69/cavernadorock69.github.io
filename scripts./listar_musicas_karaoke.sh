#!/bin/bash
# Gera lista simples de karaokês em TXT, uma música por linha, na mesma pasta de origem

read -rp "Digite o caminho da pasta dos karaokês: " PASTA

if [ ! -d "$PASTA" ]; then
    echo "❌ Pasta inválida!"
    exit 1
fi

NOME_PASTA=$(basename "$PASTA")
ARQUIVO_TXT="$PASTA/${NOME_PASTA}.txt"

# lista arquivos em ordem e limpa nomes
find "$PASTA" -maxdepth 1 -type f -printf "%f\n" | sort | \
sed 's/\.[^.]*$//' | \
sed -E 's/(Karaok(e|ê)|Karaoke|VERSÃO KARAOKÊ|🎤)//Ig' | \
sed 's/[[:space:]]\+/ /g' | sed 's/^ //; s/ $//' \
> "$ARQUIVO_TXT"

echo "✅ TXT gerado: $ARQUIVO_TXT"

