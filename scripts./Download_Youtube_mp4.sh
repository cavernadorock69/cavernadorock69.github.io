#!/bin/bash

# ===================================================================================
# Script para Baixar Mídia do YouTube com Instalação Automática de Dependências
# Versão 11 - Adicionado suporte a conversão para MPEG usando WinFF
# Autor: Manus AI (adaptado)
# ===================================================================================

# --- Cores ---
C_GREEN='\033[0;32m'; C_YELLOW='\033[1;33m'; C_RED='\033[0;31m'; C_BLUE='\033[0;34m'; C_NC='\033[0m'

# --- Função de Instalação de Dependências ---
install_dependencies() {
    local missing_deps=()
    if ! command -v yt-dlp &> /dev/null; then missing_deps+=("yt-dlp"); fi
    if ! command -v ffmpeg &> /dev/null; then missing_deps+=("ffmpeg"); fi
    if ! command -v winff &> /dev/null; then missing_deps+=("winff"); fi
    if ! command -v curl &> /dev/null && ! command -v wget &> /dev/null; then missing_deps+=("curl"); fi

    if [ ${#missing_deps[@]} -gt 0 ]; then
        echo -e "${C_YELLOW}Dependências não encontradas: ${missing_deps[*]}.${C_NC}"
        read -p "Deseja que o script tente instalá-las agora? (s/n): " choice
        if [[ "$choice" == "s" || "$choice" == "S" ]]; then
            echo -e "${C_BLUE}Atualizando a lista de pacotes (pode pedir sua senha)...${C_NC}"; sudo apt-get update
            sudo apt-get install -y ffmpeg winff curl
            if [[ " ${missing_deps[*]} " =~ " yt-dlp " ]]; then
                echo -e "\n${C_BLUE}Instalando 'yt-dlp' (última versão)...${C_NC}"
                if command -v curl &> /dev/null; then
                    sudo curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o /usr/local/bin/yt-dlp
                else
                    sudo wget https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -O /usr/local/bin/yt-dlp
                fi
                sudo chmod a+rx /usr/local/bin/yt-dlp
            fi
            echo -e "\n${C_GREEN}Tentativa de instalação concluída! Verificando novamente...${C_NC}"
        else
            echo -e "${C_RED}Instalação cancelada.${C_NC}"; exit 1
        fi
    fi
    if ! command -v yt-dlp &> /dev/null || ! command -v ffmpeg &> /dev/null || ! command -v winff &> /dev/null; then
        echo -e "${C_RED}Falha ao instalar dependências.${C_NC}"; exit 1
    fi
    echo -e "${C_GREEN}Dependências estão prontas!${C_NC}\n"
}

# --- Função Principal de Download ---
start_download() {
    read -p "Insira a URL do vídeo ou da playlist: " MEDIA_URL
    if [ -z "$MEDIA_URL" ]; then echo -e "${C_RED}URL não pode ser vazia.${C_NC}"; return; fi

    echo -e "\nQual formato você deseja baixar?"
    echo "1: ${C_YELLOW}MP4${C_NC} (Vídeo + Áudio)"
    echo "2: ${C_YELLOW}MP3${C_NC} (Apenas Áudio)"
    echo "3: ${C_YELLOW}MPG${C_NC} (Vídeo convertido para MPEG)"
    read -p "Escolha uma opção (1, 2 ou 3): " FORMAT_CHOICE

    local FORMAT_FOLDER=""
    local BASE_DIR=""
    local cmd=("yt-dlp")

    case $FORMAT_CHOICE in
        1) FORMAT_FOLDER="MP4"; BASE_DIR="${HOME}/Vídeos"; cmd+=(-f 'bestvideo+bestaudio/best' --merge-output-format mp4);;
        2) FORMAT_FOLDER="MP3"; BASE_DIR="${HOME}/Músicas"; cmd+=(-x --audio-format mp3 --audio-quality 0);;
        3) FORMAT_FOLDER="MPG"; BASE_DIR="${HOME}/Vídeos"; cmd+=(-f 'bestvideo+bestaudio/best' --merge-output-format mp4);;
        *) echo -e "${C_RED}Opção de formato inválida.${C_NC}"; return;;
    esac

    # --- FUNCIONALIDADE DE COOKIES ---
    echo -e "\nPara evitar erros de 'Sign in', é recomendado usar os cookies do seu navegador."
    echo -e "Certifique-se de que você está ${C_YELLOW}logado no YouTube${C_NC} no navegador escolhido."
    echo "Qual navegador você usa?"
    echo "1: Firefox"
    echo "2: Chrome / Chromium"
    echo "3: Edge"
    echo "4: Vivaldi"
    echo "5: Nenhum (não recomendado para playlists grandes)"
    read -p "Escolha uma opção: " BROWSER_CHOICE

    case $BROWSER_CHOICE in
        1) cmd+=(--cookies-from-browser firefox);;
        2) cmd+=(--cookies-from-browser chrome);;
        3) cmd+=(--cookies-from-browser edge);;
        4) cmd+=(--cookies-from-browser vivaldi);;
        5) echo -e "${C_YELLOW}Continuando sem cookies. Poderão ocorrer erros.${C_NC}";;
        *) echo -e "${C_YELLOW}Opção inválida. Continuando sem cookies.${C_NC}";;
    esac

    # --- CAMINHO DE SAÍDA CORRIGIDO ---
    local OUTPUT_TEMPLATE="${BASE_DIR}/${FORMAT_FOLDER}/%(playlist_title,title)s/%(playlist_index,NA)s - %(title)s.%(ext)s"
    cmd+=(-o "$OUTPUT_TEMPLATE" "$MEDIA_URL")

    echo -e "\n${C_BLUE}Iniciando download...${C_NC}"
    echo -e "Os arquivos serão salvos em: ${C_YELLOW}${BASE_DIR}/${FORMAT_FOLDER}/${C_NC}"

    # Adiciona atraso aleatório para evitar bloqueios
    cmd+=(--sleep-interval 5 --max-sleep-interval 10)
    echo -e "Usando um pequeno atraso entre os vídeos para evitar bloqueios."

    # Executa o comando de forma segura
    "${cmd[@]}"

    # --- Conversão para MPG com WinFF ---
    if [[ "$FORMAT_CHOICE" == "3" ]]; then
        echo -e "\n${C_BLUE}Convertendo arquivos para MPEG com WinFF...${C_NC}"
        find "${BASE_DIR}/${FORMAT_FOLDER}" -type f -name "*.mp4" | while read -r file; do
            mpg_file="${file%.mp4}.mpg"
            # Conversão WinFF (perfil MPEG2 genérico)
            winff -i "$file" -o "$(dirname "$file")" -f MPEG2 -ext mpg
            rm "$file"  # remove o MP4 original
        done
        echo -e "${C_GREEN}Conversão para MPEG concluída com WinFF!${C_NC}"
    fi

    echo -e "\n${C_GREEN}Download concluído!${C_NC}"
}

# --- Execução do Script ---
install_dependencies
while true; do
    echo -e "\n--- ${C_YELLOW}YouTube Downloader v11 (MP4/MP3/MPG + Cookie Auth + WinFF)${C_NC} ---"
    echo "1: Iniciar um novo download"
    echo "2: Sair"
    read -p "Escolha uma opção (1 ou 2): " main_choice
    case $main_choice in
        1) start_download;;
        2) echo -e "${C_GREEN}Saindo...${C_NC}"; exit 0;;
        *) echo -e "${C_RED}Opção inválida.${C_NC}";;
    esac
done

