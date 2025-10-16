#!/bin/bash
# Renomeia arquivos de karaokê
# Remove: numeração inicial (com ou sem traço), palavras indesejadas, emojis, caracteres inválidos e espaços extras

read -rp "Digite o caminho da pasta: " PASTA

if [ ! -d "$PASTA" ]; then
    echo "❌ Pasta inválida!"
    exit 1
fi

cd "$PASTA" || exit

for ARQ in *; do
    [ -f "$ARQ" ] || continue

    EXT="${ARQ##*.}"
    BASE="${ARQ%.*}"

    # Remove qualquer numeração inicial, com ou sem traço
    NOVO=$(echo "$BASE" | sed -E 's/^[0-9]+[[:space:]]*-*[[:space:]]*//')

    # Remove palavras indesejadas e emojis
    NOVO=$(echo "$NOVO" | sed -E 's/(Karaok(e|ê)|Karaoke|VERSÃO KARAOKÊ|🎤)//Ig')

    # Remove caracteres inválidos
    NOVO=$(echo "$NOVO" | sed 's/[\/()⧸]//g')

    # Remove espaços duplicados e no início/fim
    NOVO=$(echo "$NOVO" | sed 's/[[:space:]]\+/ /g' | sed 's/^ //; s/ $//')

    # Se o nome ficar vazio, usa "musica"
    [ -z "$NOVO" ] && NOVO="musica"

    NOVO="${NOVO}.${EXT}"

    # Renomeia sem perguntar
    if [ "$ARQ" != "$NOVO" ]; then
        echo "Renomeando: '$ARQ' → '$NOVO'"
        mv -- "$ARQ" "$NOVO"
    fi
done

echo "✅ Renomeação concluída!"

