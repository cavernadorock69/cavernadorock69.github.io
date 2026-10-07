#!/bin/bash
# ===========================================================
#   YouTube Downloader v18 (MP4 / MP3 + Capa + Tags / OPUS / MPG)
#   Autor: Fábio Dias Silveira (aperfeiçoado com GPT-5)
#   Data: 11/12/2025
# ===========================================================

# ==========================
# CONFIGURAÇÕES INICIAIS
# ==========================
BASE_DIR="$HOME/Músicas"
MP4_DIR="$BASE_DIR/MP4"
MP3_DIR="$BASE_DIR/MP3"
OPUS_DIR="$BASE_DIR/OPUS"
MPG_DIR="$BASE_DIR/MPG"
ERRO_DIR="$BASE_DIR/Erros"
LOG_FILE="$ERRO_DIR/yt_dlp_error.log"

# Cores para terminal
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
CYAN='\033[1;36m'
RESET='\033[0m'

# ==========================
# FUNÇÕES
# ==========================
criar_pastas() {
    mkdir -p "$MP4_DIR" "$MP3_DIR" "$OPUS_DIR" "$MPG_DIR" "$ERRO_DIR"
}

verificar_dependencias() {
    echo -e "${CYAN}🔍 Verificando dependências...${RESET}"
    for dep in yt-dlp ffmpeg curl; do
        if ! command -v "$dep" &>/dev/null; then
            echo -e "${YELLOW}Instalando $dep...${RESET}"
            sudo apt install -y "$dep"
        fi
    done
    echo -e "${GREEN}✔ Dependências prontas!${RESET}"
}

atualizar_yt_dlp() {
    echo -e "${CYAN}🔄 Atualizando yt-dlp...${RESET}"
    sudo yt-dlp -U
    echo -e "${GREEN}✔ yt-dlp atualizado com sucesso!${RESET}"
}

menu_formatos() {
    echo -e "\nQual formato você deseja baixar?"
    echo -e "1: ${YELLOW}MP4${RESET} (Vídeo + Áudio)"
    echo -e "2: ${YELLOW}MP3${RESET} (Áudio MP3 320kbps + Capa + Metadados)"
    echo -e "3: ${YELLOW}OPUS${RESET} (Áudio original sem perda de conversão)"
    echo -e "4: ${YELLOW}MPG${RESET} (Vídeo convertido para MPEG)"
    read -rp "Escolha uma opção (1, 2, 3 ou 4): " FORMATO_ESCOLHIDO
}

menu_navegador() {
    echo -e "\nPara evitar erros de login, use os cookies do seu navegador."
    echo -e "1: Firefox"
    echo -e "2: Chrome / Chromium"
    echo -e "3: Edge"
    echo -e "4: Vivaldi"
    echo -e "5: Nenhum (não recomendado)"
    read -rp "Escolha uma opção: " NAVEGADOR_ESCOLHIDO
}

corrigir_sabr() {
    echo -e "${YELLOW}⚙ Aplicando correção temporária para SABR streaming...${RESET}"
    export YT_DLP_ENABLE_EXPERIMENTAL=y
}

executar_download() {
    URL="$1"
    criar_pastas
    menu_formatos
    menu_navegador
    corrigir_sabr

    # ==========================
    # DEFINIR FORMATO
    # ==========================
    case $FORMATO_ESCOLHIDO in
        1)
            DESTINO="$MP4_DIR"
            OPCOES_FORMATO="-f bestvideo+bestaudio/best --merge-output-format mp4"
            PADRAO_SAIDA="$DESTINO/%(playlist_title|NO_PLAYLIST)s/%(title)s.%(ext)s"
            ;;
        2)
            DESTINO="$MP3_DIR"
            OPCOES_FORMATO="--extract-audio --audio-format mp3 --audio-quality 0 --embed-thumbnail --add-metadata --convert-thumbnails jpg"
            PADRAO_SAIDA="$DESTINO/%(playlist_title|NO_PLAYLIST)s/%(title)s.%(ext)s"
            ;;
        3)
            DESTINO="$OPUS_DIR"
            OPCOES_FORMATO="--extract-audio --audio-format opus --audio-quality 0"
            PADRAO_SAIDA="$DESTINO/%(playlist_title|NO_PLAYLIST)s/%(title)s.%(ext)s"
            ;;
        4)
            DESTINO="$MPG_DIR"
            OPCOES_FORMATO="-f bestvideo+bestaudio/best --recode-video mpg"
            PADRAO_SAIDA="$DESTINO/%(playlist_title|NO_PLAYLIST)s/%(title)s.%(ext)s"
            ;;
        *)
            echo -e "${RED}❌ Opção inválida!${RESET}"
            return
            ;;
    esac

    # ==========================
    # DETECTAR NAVEGADOR
    # ==========================
    case $NAVEGADOR_ESCOLHIDO in
        1) COOKIE="--cookies-from-browser firefox" ;;
        2) COOKIE="--cookies-from-browser chrome" ;;
        3) COOKIE="--cookies-from-browser edge" ;;
        4) COOKIE="--cookies-from-browser vivaldi" ;;
        5) COOKIE="" ;;
        *) COOKIE="--cookies-from-browser firefox" ;;
    esac

    echo -e "\n${CYAN}Iniciando download...${RESET}"
    echo -e "Arquivos serão salvos em: ${GREEN}$DESTINO${RESET}\n"

    echo -e "${YELLOW}Executando yt-dlp...${RESET}\n"
    
    yt-dlp $OPCOES_FORMATO $COOKIE --no-check-certificates \
        --user-agent 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)' \
        -o "$PADRAO_SAIDA" \
        --sleep-interval 5 --max-sleep-interval 15 --throttled-rate 100K "$URL" 2>>"$LOG_FILE"

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✔ Download concluído com sucesso!${RESET}"
    else
        echo -e "${RED}❌ Ocorreu um erro durante o download.${RESET}"
        echo "[$(date)] Erro ao baixar: $URL" >>"$LOG_FILE"
        echo -e "1. Verifique login nos cookies."
        echo -e "2. Atualize yt-dlp: sudo yt-dlp -U"
        echo -e "3. Tente novamente mais tarde."
        echo -e "4. Consulte o log: $LOG_FILE\n"
        echo "$URL" >>"$ERRO_DIR/urls_falhas.txt"
    fi
}

teste_rapido() {
    echo -e "${CYAN}🔧 Testando o yt-dlp...${RESET}"
    yt-dlp --version && yt-dlp https://www.youtube.com/watch?v=dQw4w9WgXcQ -F | head -n 15
}

menu_principal() {
    clear
    echo -e "${YELLOW}--- YouTube Downloader v18 ---${RESET}"
    echo "1: Iniciar um novo download"
    echo "2: Atualizar yt-dlp"
    echo "3: Teste rápido"
    echo "4: Sair"
    read -rp "Escolha uma opção (1, 2, 3 ou 4): " OPCAO

    case $OPCAO in
        1)
            read -rp "Insira a URL do vídeo ou playlist: " URL
            executar_download "$URL"
            ;;
        2)
            atualizar_yt_dlp
            ;;
        3)
            teste_rapido
            ;;
        4)
            echo -e "${GREEN}Saindo...${RESET}"
            exit 0
            ;;
        *)
            echo -e "${RED}❌ Opção inválida.${RESET}"
            ;;
    esac
}

# ==========================
# EXECUÇÃO PRINCIPAL
# ==========================
clear
criar_pastas
verificar_dependencias
menu_principal
