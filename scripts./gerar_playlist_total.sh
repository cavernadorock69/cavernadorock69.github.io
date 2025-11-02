#!/bin/bash

# Script COM NOMES DESCRITIVOS PARA AS PLAYLISTS - APENAS FLAC, MP3, MP4 e MKV
echo "Buscando itens de caverna_do_rock..."

# Buscar itens
curl -s "https://archive.org/advancedsearch.php?q=creator:caverna_do_rock+OR+uploader:cavernadorock69@gmail.com&fl[]=identifier&rows=1000&output=json" | \
jq -r '.response.docs[].identifier' > itens.txt

echo "Criando playlists..."
echo "#EXTM3U" > caverna_flac.m3u
echo "#EXTM3U" > caverna_mp3.m3u
echo "#EXTM3U" > caverna_mp4.m3u
echo "#EXTM3U" > caverna_mkv.m3u

while read item; do
    echo "Processando: $item"
    metadata=$(curl -s "https://archive.org/metadata/$item")
    
    artista=$(echo "$metadata" | jq -r '.metadata.artist // .metadata.creator // "Unknown"')
    album=$(echo "$metadata" | jq -r '.metadata.album // "Unknown"')
    
    # FLAC
    echo "$metadata" | jq -r '.files[] | select(.name | endswith(".flac")) | .name' | while read file; do
        if [ -n "$file" ]; then
            title=$(basename "$file" .flac | sed 's/^[0-9]*[.-]* //')
            echo "#EXTART:$artista" >> caverna_flac.m3u
            echo "#EXTALB:$album" >> caverna_flac.m3u
            echo "#EXTINF:-1,$title" >> caverna_flac.m3u
            echo "https://archive.org/download/$item/${file// /%20}" >> caverna_flac.m3u
            echo "" >> caverna_flac.m3u
        fi
    done
    
    # MP3
    echo "$metadata" | jq -r '.files[] | select(.name | endswith(".mp3")) | .name' | while read file; do
        if [ -n "$file" ]; then
            title=$(basename "$file" .mp3 | sed 's/^[0-9]*[.-]* //')
            echo "#EXTART:$artista" >> caverna_mp3.m3u
            echo "#EXTALB:$album" >> caverna_mp3.m3u
            echo "#EXTINF:-1,$title" >> caverna_mp3.m3u
            echo "https://archive.org/download/$item/${file// /%20}" >> caverna_mp3.m3u
            echo "" >> caverna_mp3.m3u
        fi
    done
    
    # MP4
    echo "$metadata" | jq -r '.files[] | select(.name | endswith(".mp4")) | .name' | while read file; do
        if [ -n "$file" ]; then
            title=$(basename "$file" .mp4 | sed 's/^[0-9]*[.-]* //')
            echo "#EXTART:$artista" >> caverna_mp4.m3u
            echo "#EXTALB:$album" >> caverna_mp4.m3u
            echo "#EXTINF:-1,$title" >> caverna_mp4.m3u
            echo "https://archive.org/download/$item/${file// /%20}" >> caverna_mp4.m3u
            echo "" >> caverna_mp4.m3u
        fi
    done
    
    # MKV
    echo "$metadata" | jq -r '.files[] | select(.name | endswith(".mkv")) | .name' | while read file; do
        if [ -n "$file" ]; then
            title=$(basename "$file" .mkv | sed 's/^[0-9]*[.-]* //')
            echo "#EXTART:$artista" >> caverna_mkv.m3u
            echo "#EXTALB:$album" >> caverna_mkv.m3u
            echo "#EXTINF:-1,$title" >> caverna_mkv.m3u
            echo "https://archive.org/download/$item/${file// /%20}" >> caverna_mkv.m3u
            echo "" >> caverna_mkv.m3u
        fi
    done
    
done < itens.txt

echo "=== PLAYLISTS CRIADAS ==="
echo "caverna_flac.m3u - $(grep -c '^https://' caverna_flac.m3u) músicas FLAC"
echo "caverna_mp3.m3u - $(grep -c '^https://' caverna_mp3.m3u) músicas MP3"
echo "caverna_mp4.m3u - $(grep -c '^https://' caverna_mp4.m3u) vídeos MP4"
echo "caverna_mkv.m3u - $(grep -c '^https://' caverna_mkv.m3u) vídeos MKV"
echo "========================="

rm -f itens.txt
