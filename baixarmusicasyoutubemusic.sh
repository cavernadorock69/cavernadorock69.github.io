#!/bin/bash

# Script: conversormp3.sh
# Descrição: Baixa músicas/playlists do YouTube Music em MP3 com máxima qualidade

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configurações
BASE_DIR="$HOME/Músicas/mp3"

# Função para imprimir mensagens coloridas
print_message() {
    echo -e "${2}${1}${NC}"
}

# Função para verificar e instalar dependências
install_dependencies() {
    print_message "Verificando dependências..." "$BLUE"
    
    # Verificar se yt-dlp está instalado
    if ! command -v yt-dlp &> /dev/null; then
        print_message "Instalando yt-dlp..." "$YELLOW"
        sudo curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o /usr/local/bin/yt-dlp
        sudo chmod a+rx /usr/local/bin/yt-dlp
        print_message "✅ yt-dlp instalado com sucesso!" "$GREEN"
    else
        print_message "✅ yt-dlp já está instalado." "$GREEN"
    fi
    
    # Verificar se ffmpeg está instalado
    if ! command -v ffmpeg &> /dev/null; then
        print_message "Instalando ffmpeg..." "$YELLOW"
        sudo apt update && sudo apt install -y ffmpeg
        print_message "✅ ffmpeg instalado com sucesso!" "$GREEN"
    else
        print_message "✅ ffmpeg já está instalado." "$GREEN"
    fi
    
    # Verificar se atomicparsley está instalado
    if ! command -v AtomicParsley &> /dev/null; then
        print_message "Instalando atomicparsley..." "$YELLOW"
        sudo apt install -y atomicparsley
        print_message "✅ atomicparsley instalado com sucesso!" "$GREEN"
    else
        print_message "✅ atomicparsley já está instalado." "$GREEN"
    fi
}

# Função para criar diretório de downloads
create_download_dir() {
    if [ ! -d "$BASE_DIR" ]; then
        print_message "Criando diretório base: $BASE_DIR" "$YELLOW"
        mkdir -p "$BASE_DIR"
    fi
}

# Função para obter o nome da playlist
get_playlist_name() {
    local url="$1"
    local playlist_name
    
    # Tentar extrair nome da playlist
    playlist_name=$(yt-dlp --flat-playlist --get-title --no-warnings "$url" 2>/dev/null | head -n 1)
    
    # Se não conseguir, usar nome padrão
    if [ -z "$playlist_name" ] || [[ "$playlist_name" == *"ERROR"* ]]; then
        playlist_name="Playlist_$(date +%Y%m%d_%H%M%S)"
    fi
    
    # Remover caracteres inválidos para nome de pasta
    playlist_name=$(echo "$playlist_name" | tr -d '/\\:*?"<>|' | sed 's/&/e/g' | sed 's/ /_/g')
    
    echo "$playlist_name"
}

# Função para baixar música/playlist
download_audio() {
    local url="$1"
    local playlist_name="$2"
    
    local specific_dir="$BASE_DIR/$playlist_name"
    mkdir -p "$specific_dir"
    
    print_message "📥 Iniciando download para: $specific_dir" "$BLUE"
    print_message "🔗 URL: $url" "$CYAN"
    
    # Baixar com máxima qualidade
    yt-dlp \
        -x \
        --audio-format mp3 \
        --audio-quality 0 \
        --embed-thumbnail \
        --add-metadata \
        --output "$specific_dir/%(title)s.%(ext)s" \
        --no-overwrites \
        --console-title \
        "$url"
    
    if [ $? -eq 0 ]; then
        print_message "✅ Download concluído com sucesso!" "$GREEN"
        print_message "📁 Arquivos salvos em: $specific_dir" "$GREEN"
        
        # Mostrar estatísticas
        local file_count=$(find "$specific_dir" -name "*.mp3" | wc -l)
        print_message "🎵 Total de arquivos baixados: $file_count" "$CYAN"
    else
        print_message "❌ Erro durante o download" "$RED"
        exit 1
    fi
}

# Função principal
main() {
    clear
    echo ""
    print_message "🎵 YouTube Music Downloader 🎵" "$BLUE"
    print_message "=================================" "$BLUE"
    echo ""
    
    # Instalar dependências
    install_dependencies
    echo ""
    
    # Criar diretório de downloads
    create_download_dir
    
    # Obter URL
    print_message "📍 Cole a URL da música ou playlist do YouTube Music:" "$YELLOW"
    read -r url
    echo ""
    
    # Validar URL
    if [[ -z "$url" ]]; then
        print_message "❌ URL não fornecida. Saindo..." "$RED"
        exit 1
    fi
    
    if [[ ! "$url" =~ (youtube\.com|youtu\.be|music\.youtube\.com) ]]; then
        print_message "❌ URL inválida. Use URLs do YouTube ou YouTube Music." "$RED"
        exit 1
    fi
    
    # Obter nome da playlist
    print_message "📋 Obtendo informações da playlist..." "$BLUE"
    playlist_name=$(get_playlist_name "$url")
    echo ""
    
    # Confirmar download
    print_message "🎶 Nome da playlist: $playlist_name" "$CYAN"
    print_message "📁 Pasta de destino: $BASE_DIR/$playlist_name" "$CYAN"
    echo ""
    print_message "⏯️  Deseja iniciar o download? (s/N)" "$YELLOW"
    read -r confirm
    
    if [[ "$confirm" == "s" || "$confirm" == "S" || "$confirm" == "y" || "$confirm" == "Y" ]]; then
        echo ""
        download_audio "$url" "$playlist_name"
    else
        print_message "❌ Download cancelado" "$RED"
    fi
}

# Executar script
main
