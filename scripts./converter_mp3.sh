#!/bin/bash

# Pergunta ao usuário a pasta de origem
read -rp "Digite o caminho completo da pasta que deseja converter: " ORIGEM

# Expande o ~ se o usuário usar
ORIGEM="${ORIGEM/#\~/$HOME}"
ORIGEM="${ORIGEM%/}"

# Verifica se a pasta existe
if [ ! -d "$ORIGEM" ]; then
    echo "Pasta não encontrada: $ORIGEM"
    exit 1
fi

# Pasta de destino base
DESTINO="$HOME/Músicas/mp3"
mkdir -p "$DESTINO"

# Salva o IFS antigo
OLDIFS=$IFS
IFS=$'\n'

# Contadores para relatório
total=0
convertidos=0
erros=0
ignorados_existentes=0

# Usar array em vez de pipe para preservar variáveis
arquivos=($(find "$ORIGEM" -type f))

for arquivo in "${arquivos[@]}"; do
    # Ignora arquivos que já são MP3
    if [[ "$arquivo" == *.mp3 ]]; then
        echo "Ignorando arquivo MP3: $(basename "$arquivo")"
        continue
    fi

    # Ignora arquivos que não são de áudio (lista expandida)
    if [[ "$arquivo" == *.m3u || "$arquivo" == *.txt || "$arquivo" == *.jpg || \
          "$arquivo" == *.jpeg || "$arquivo" == *.png || "$arquivo" == *.cue || \
          "$arquivo" == *.log || "$arquivo" == *.accurip || "$arquivo" == *.m3u8 ]]; then
        echo "Ignorando arquivo não-áudio: $(basename "$arquivo")"
        continue
    fi

    # Verifica se arquivo não está vazio
    if [ ! -s "$arquivo" ]; then
        echo "Arquivo vazio ou inválido: $(basename "$arquivo")"
        ((erros++))
        ((total++))
        continue
    fi

    # Verifica se é realmente um arquivo de áudio usando 'file'
    if ! file "$arquivo" | grep -q -E "(Audio|WAVE|FLAC|OGG)"; then
        echo "Arquivo não reconhecido como áudio: $(basename "$arquivo")"
        ((erros++))
        ((total++))
        continue
    fi

    # Caminho relativo
    relativo="${arquivo#$ORIGEM/}"
    saida="$DESTINO/${relativo%.*}.mp3"
    
    # Cria pasta destino
    mkdir -p "$(dirname "$saida")"

    # NOVO TRECHO: verifica se o arquivo já existe
    if [ -f "$saida" ]; then
        echo "🔁 Já existe, ignorando: $(basename "$saida")"
        ((ignorados_existentes++))
        ((total++))
        echo "---"
        continue
    fi

    echo "Convertendo: $(basename "$arquivo") -> $(basename "$saida")"

    # Converte para MP3 com 320 kbps fixo
    if ffmpeg -nostdin -v error -y -i "$arquivo" -vn -ar 44100 -ac 2 -b:a 320k "$saida" 2>&1; then
        echo "✓ Sucesso: $(basename "$arquivo")"
        ((convertidos++))
    else
        echo "✗ Erro na conversão: $(basename "$arquivo")"
        [ -f "$saida" ] && rm -f "$saida"
        ((erros++))
    fi
    
    ((total++))
    echo "---"
done

# Restaura o IFS
IFS=$OLDIFS

echo "=========================================="
echo "RELATÓRIO FINAL:"
echo "Total de arquivos processados: $total"
echo "Arquivos convertidos com sucesso: $convertidos"
echo "Arquivos já existentes (ignorados): $ignorados_existentes"
echo "Arquivos com erro: $erros"
echo "Arquivos ignorados (não-áudio/MP3): $(( ${#arquivos[@]} - total ))"
echo "=========================================="

if [ $convertidos -eq 0 ] && [ $total -gt 0 ]; then
    echo "AVISO: Nenhum arquivo foi convertido!"
    echo "Possíveis causas:"
    echo "1. Arquivos já existiam convertidos"
    echo "2. Arquivos corrompidos"
    echo "3. FFmpeg não instalado corretamente"
    echo "4. Problemas de permissão"
    echo "5. Formatos não suportados"
fi
