#!/bin/bash

# Verifica e instala o GNU parallel, se não estiver instalado
if ! command -v parallel &> /dev/null; then
    echo "GNU parallel não encontrado. Instalando..."
    sudo apt update && sudo apt install -y parallel
    if [ $? -ne 0 ]; then
        echo "Erro ao instalar o GNU parallel. O script não pode continuar."
        exit 1
    fi
    echo "GNU parallel instalado com sucesso."
fi

# Pergunta ao usuário a pasta de origem
read -rp "Digite o caminho completo da pasta que deseja converter: " ORIGEM

# Expande o ~
ORIGEM="${ORIGEM/#\~/$HOME}"
ORIGEM="${ORIGEM%/}"

# Verifica se pasta existe
if [ ! -d "$ORIGEM" ]; then
    echo "Pasta não encontrada: $ORIGEM"
    exit 1
fi

# Pasta destino
DESTINO="$HOME/Músicas/mp3"
mkdir -p "$DESTINO"

# Arquivos (todos)
mapfile -t arquivos < <(find "$ORIGEM" -type f)

# Contadores compartilhados (via arquivos temporários)
TMPDIR=$(mktemp -d)
touch "$TMPDIR/convertidos" "$TMPDIR/erros" "$TMPDIR/existentes" "$TMPDIR/total"

# ---- Função de processamento (executada em paralelo) ----
processar() {
    local arquivo="$1"
    local origem="$2"
    local destino="$3"
    local tmpdir="$4"

    # Se for MP3 → ignorar
    if [[ "$arquivo" == *.mp3 ]]; then
        echo "Ignorando MP3: $(basename "$arquivo")"
        exit 0
    fi

    # Ignora extensões não-áudio
    case "$arquivo" in
        *.m3u|*.m3u8|*.txt|*.jpg|*.jpeg|*.png|*.cue|*.log|*.accurip)
            echo "Ignorando não-audio: $(basename "$arquivo")"
            exit 0
            ;;
    esac

    # Arquivo vazio?
    if [ ! -s "$arquivo" ]; then
        echo "Arquivo vazio: $(basename "$arquivo")"
        echo 1 >> "$tmpdir/erros"
        echo 1 >> "$tmpdir/total"
        exit 0
    fi

    # ffprobe confirma áudio
    if ! ffprobe -v error -show_entries format=format_name \
        -of default=nw=1:nk=1 "$arquivo" >/dev/null 2>&1; then
        echo "Não é áudio: $(basename "$arquivo")"
        echo 1 >> "$tmpdir/erros"
        echo 1 >> "$tmpdir/total"
        exit 0
    fi

    # Caminho relativo
    local relativo="${arquivo#$origem/}"
    local saida="$destino/${relativo%.*}.mp3"

    mkdir -p "$(dirname "$saida")"

    # Já existe?
    if [ -f "$saida" ]; then
        echo "🔁 Já existe: $(basename "$saida")"
        echo 1 >> "$tmpdir/existentes"
        echo 1 >> "$tmpdir/total"
        exit 0
    fi

    echo "Convertendo: $(basename "$arquivo")"

    # Conversão
    if ffmpeg -nostdin -v error -y -i "$arquivo" -vn -ar 44100 -ac 2 -b:a 320k "$saida" 2>&1; then
        echo "✓ Sucesso: $(basename "$arquivo")"
        echo 1 >> "$tmpdir/convertidos"
    else
        echo "✗ Erro: $(basename "$arquivo")"
        rm -f "$saida"
        echo 1 >> "$tmpdir/erros"
    fi

    echo 1 >> "$tmpdir/total"
}

export -f processar

export ORIGEM DESTINO

# Usar GNU parallel (8 jobs por padrão)
# Ajuste --jobs para usar mais ou menos núcleos
parallel --jobs 8 processar {} "$ORIGEM" "$DESTINO" "$TMPDIR" ::: "${arquivos[@]}"

# ---- Cálculo dos resultados ----
convertidos=$(wc -l < "$TMPDIR/convertidos")
erros=$(wc -l < "$TMPDIR/erros")
existentes=$(wc -l < "$TMPDIR/existentes")
total=$(wc -l < "$TMPDIR/total")
ignorados=$(( ${#arquivos[@]} - total ))

# ---- Relatório Final ----
echo "=========================================="
echo "RELATÓRIO FINAL:"
echo "Total de arquivos processados: $total"
echo "Arquivos convertidos com sucesso: $convertidos"
echo "Arquivos já existentes (ignorados): $existentes"
echo "Arquivos com erro: $erros"
echo "Arquivos ignorados (não-áudio/MP3): $ignorados"
echo "=========================================="

if [ "$convertidos" -eq 0 ] && [ "$total" -gt 0 ]; then
    echo "AVISO: Nenhum arquivo foi convertido!"
    echo "Possíveis causas:"
    echo "1. Arquivos já existem convertidos"
    echo "2. Arquivos corrompidos"
    echo "3. FFmpeg com falha"
    echo "4. Permissões"
    echo "5. Formatos não suportados"
fi

rm -rf "$TMPDIR"
