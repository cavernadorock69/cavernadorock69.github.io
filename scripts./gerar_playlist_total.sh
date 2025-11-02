#!/bin/bash

# Script MELHORADO - Extrai álbum da estrutura de pastas de forma mais inteligente
echo "Buscando itens de caverna_do_rock..."

# Buscar itens
curl -s "https://archive.org/advancedsearch.php?q=creator:caverna_do_rock+OR+uploader:cavernadorock69@gmail.com&fl[]=identifier&rows=1000&output=json" | \
jq -r '.response.docs[].identifier' > itens.txt

echo "Criando playlists..."
echo "#EXTM3U" > caverna_flac.m3u
echo "#EXTM3U" > caverna_mp3.m3u
echo "#EXTM3U" > caverna_mp4.m3u
echo "#EXTM3U" > caverna_mkv.m3u

# Função melhorada para extrair álbum
extrair_album_melhorado() {
    local file_path="$1"
    
    # Primeiro tentar padrão "ANO - NOME DO ÁLBUM"
    local album=$(echo "$file_path" | grep -oE '[0-9]{4} - [^/]+' | head -1)
    if [ -n "$album" ]; then
        echo "$album"
        return
    fi
    
    # Tentar padrão "NOME DO ÁLBUM (ANO)"
    album=$(echo "$file_path" | grep -oE '[^/]+ \([0-9]{4}\)' | head -1)
    if [ -n "$album" ]; then
        echo "$album"
        return
    fi
    
    # Extrair segunda pasta do caminho (assumindo estrutura Artista/Álbum/Arquivo)
    local path_parts=$(echo "$file_path" | tr '/' '\n')
    local part_count=$(echo "$path_parts" | wc -l)
    
    if [ "$part_count" -ge 3 ]; then
        # A segunda parte geralmente é o álbum
        album=$(echo "$path_parts" | sed -n '2p')
        if [ -n "$album" ] && [ "$album" != "." ]; then
            echo "$album"
            return
        fi
    fi
    
    # Último recurso: extrair qualquer pasta que não seja numérica ou muito curta
    album=$(echo "$file_path" | cut -d'/' -f2)
    if [ -n "$album" ] && [ "${#album}" -gt 3 ] && ! [[ "$album" =~ ^[0-9]+$ ]]; then
        echo "$album"
    else
        echo "Unknown Album"
    fi
}

processar_arquivo() {
    local tipo="$1"
    local file="$2"
    local artista="$3"
    local metadata="$4"
    local item="$5"
    
    if [ -n "$file" ]; then
        # Obter álbum - prioridade: metadados > estrutura pastas
        album_metadata=$(echo "$metadata" | jq -r '.metadata.album // "Unknown Album"')
        if [ "$album_metadata" = "Unknown Album" ] || [ "$album_metadata" = "null" ]; then
            album=$(extrair_album_melhorado "$file")
        else
            album="$album_metadata"
        fi
        
        # Extrair título
        case $tipo in
            "flac") title=$(basename "$file" .flac | sed 's/^[0-9]*[.-]*[[:space:]]*//') ;;
            "mp3") title=$(basename "$file" .mp3 | sed 's/^[0-9]*[.-]*[[:space:]]*//') ;;
            "mp4") title=$(basename "$file" .mp4 | sed 's/^[0-9]*[.-]*[[:space:]]*//') ;;
            "mkv") title=$(basename "$file" .mkv | sed 's/^[0-9]*[.-]*[[:space:]]*//') ;;
        esac
        
        # Escrever na playlist
        echo "#EXTART:$artista" >> "caverna_${tipo}.m3u"
        echo "#EXTALB:$album" >> "caverna_${tipo}.m3u"
        echo "#EXTINF:-1,$title" >> "caverna_${tipo}.m3u"
        echo "https://archive.org/download/$item/${file// /%20}" >> "caverna_${tipo}.m3u"
        echo "" >> "caverna_${tipo}.m3u"
    fi
}

while read item; do
    echo "Processando: $item"
    metadata=$(curl -s "https://archive.org/metadata/$item")
    
    artista=$(echo "$metadata" | jq -r '.metadata.artist // .metadata.creator // "Unknown Artist"')
    
    # Processar cada tipo de arquivo
    echo "$metadata" | jq -r '.files[] | select(.name | endswith(".flac")) | .name' | while read file; do
        processar_arquivo "flac" "$file" "$artista" "$metadata" "$item"
    done
    
    echo "$metadata" | jq -r '.files[] | select(.name | endswith(".mp3")) | .name' | while read file; do
        processar_arquivo "mp3" "$file" "$artista" "$metadata" "$item"
    done
    
    echo "$metadata" | jq -r '.files[] | select(.name | endswith(".mp4")) | .name' | while read file; do
        processar_arquivo "mp4" "$file" "$artista" "$metadata" "$item"
    done
    
    echo "$metadata" | jq -r '.files[] | select(.name | endswith(".mkv")) | .name' | while read file; do
        processar_arquivo "mkv" "$file" "$artista" "$metadata" "$item"
    done
    
done < itens.txt

echo "=== PLAYLISTS CRIADAS ==="
echo "caverna_flac.m3u - $(grep -c '^https://' caverna_flac.m3u) músicas FLAC"
echo "caverna_mp3.m3u - $(grep -c '^https://' caverna_mp3.m3u) músicas MP3"
echo "caverna_mp4.m3u - $(grep -c '^https://' caverna_mp4.m3u) vídeos MP4"
echo "caverna_mkv.m3u - $(grep -c '^https://' caverna_mkv.m3u) vídeos MKV"
echo "========================="

rm -f itens.txt
