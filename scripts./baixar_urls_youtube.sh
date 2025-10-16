#!/bin/bash

# Pasta para salvar os vídeos
PASTA="Karaokes"
mkdir -p "$PASTA"

# Lista de URLs de pesquisa
URLS=(
https://www.youtube.com/results?search_query=Legião+Urbana+Tempo+Perdido+Karaokê
https://www.youtube.com/results?search_query=Legião+Urbana+Pais+e+Filhos+Karaokê
https://www.youtube.com/results?search_query=Legião+Urbana+Será+Karaokê
https://www.youtube.com/results?search_query=Legião+Urbana+Faroeste+Caboclo+Karaokê
https://www.youtube.com/results?search_query=Cazuza+Exagerado+Karaokê
https://www.youtube.com/results?search_query=Cazuza+O+Tempo+Não+Para+Karaokê
https://www.youtube.com/results?search_query=Cazuza+Codinome+Beija-Flor+Karaokê
https://www.youtube.com/results?search_query=Barão+Vermelho+Pro+Dia+Nascer+Feliz+Karaokê
https://www.youtube.com/results?search_query=Barão+Vermelho+Bete+Balanço+Karaokê
https://www.youtube.com/results?search_query=Barão+Vermelho+Por+Você+Karaokê
https://www.youtube.com/results?search_query=Titãs+Epitáfio+Karaokê
https://www.youtube.com/results?search_query=Titãs+Polícia+Karaokê
https://www.youtube.com/results?search_query=Titãs+Marvin+Karaokê
https://www.youtube.com/results?search_query=Paralamas+Meu+Erro+Karaokê
https://www.youtube.com/results?search_query=Paralamas+Alagados+Karaokê
https://www.youtube.com/results?search_query=Paralamas+Uma+Brasileira+Karaokê
https://www.youtube.com/results?search_query=Mutantes+Panis+et+Circenses+Karaokê
https://www.youtube.com/results?search_query=Mutantes+A+Minha+Menina+Karaokê
https://www.youtube.com/results?search_query=Raul+Seixas+Maluco+Beleza+Karaokê
https://www.youtube.com/results?search_query=Raul+Seixas+Metamorfose+Ambulante+Karaokê
https://www.youtube.com/results?search_query=Raul+Seixas+Gita+Karaokê
https://www.youtube.com/results?search_query=Kid+Abelha+Pintura+Íntima+Karaokê
https://www.youtube.com/results?search_query=Kid+Abelha+Como+Eu+Quero+Karaokê
https://www.youtube.com/results?search_query=Kid+Abelha+Nada+Sei+Karaokê
https://www.youtube.com/results?search_query=Skank+Garota+Nacional+Karaokê
https://www.youtube.com/results?search_query=Skank+Vou+Deixar+Karaokê
https://www.youtube.com/results?search_query=Skank+Te+Ver+Karaokê
https://www.youtube.com/results?search_query=Jota+Quest+Dias+Melhores+Karaokê
https://www.youtube.com/results?search_query=Jota+Quest+Só+Hoje+Karaokê
https://www.youtube.com/results?search_query=Jota+Quest+Do+Seu+Lado+Karaokê
https://www.youtube.com/results?search_query=Raimundos+Mulher+de+Fases+Karaokê
https://www.youtube.com/results?search_query=Raimundos+Eu+Quero+Ver+o+Oco+Karaokê
https://www.youtube.com/results?search_query=Raimundos+Puteiro+em+João+Pessoa+Karaokê
https://www.youtube.com/results?search_query=Engenheiros+Infinita+Highway+Karaokê
https://www.youtube.com/results?search_query=Engenheiros+O+Papa+é+Pop+Karaokê
https://www.youtube.com/results?search_query=Engenheiros+Toda+Forma+de+Poder+Karaokê
https://www.youtube.com/results?search_query=Lobão+Me+Chama+Karaokê
https://www.youtube.com/results?search_query=Lobão+Mulher+Liberdade+Karaokê
https://www.youtube.com/results?search_query=Legião+Urbana+Que+País+é+Este+Karaokê
https://www.youtube.com/results?search_query=Cássia+Eller+Malandragem+Karaokê
https://www.youtube.com/results?search_query=Cássia+Eller+Por+Enquanto+Karaokê
https://www.youtube.com/results?search_query=Paralamas+Lanterna+dos+Afogados+Karaokê
https://www.youtube.com/results?search_query=Titãs+Sonífera+Ilha+Karaokê
https://www.youtube.com/results?search_query=Ultraje+a+Rigor+Inútil+Karaokê
https://www.youtube.com/results?search_query=Ultraje+a+Rigor+Rebelde+Karaokê
https://www.youtube.com/results?search_query=Ultraje+a+Rigor+Ciúme+Karaokê
https://www.youtube.com/results?search_query=Capital+Inicial+Primeiros+Erros+Karaokê
https://www.youtube.com/results?search_query=Capital+Inicial+Natasha+Karaokê
https://www.youtube.com/results?search_query=Capital+Inicial+À+Sua+Maneira+Karaokê
https://www.youtube.com/results?search_query=Paralamas+Selvagem+Karaokê
https://www.youtube.com/results?search_query=Engenheiros+O+Homem+e+o+Cavalo+Karaokê
https://www.youtube.com/results?search_query=RPM+Olhar+43+Karaokê
https://www.youtube.com/results?search_query=RPM+Rádio+Pirata+Karaokê
https://www.youtube.com/results?search_query=RPM+Alvorada+Voraz+Karaokê
https://www.youtube.com/results?search_query=Kid+Abelha+Fixação+Karaokê
https://www.youtube.com/results?search_query=Kid+Abelha+Amo+Muito+Tudo+Isso+Karaokê
https://www.youtube.com/results?search_query=Legião+Urbana+Andrea+Doria+Karaokê
https://www.youtube.com/results?search_query=Legião+Urbana+Monte+Castelo+Karaokê
https://www.youtube.com/results?search_query=Cazuza+Blues+da+Piedade+Karaokê
https://www.youtube.com/results?search_query=Cazuza+Ideologia+Karaokê
https://www.youtube.com/results?search_query=Barão+Vermelho+Maior+Abandonado+Karaokê
https://www.youtube.com/results?search_query=Barão+Vermelho+Blues+do+Abandono+Karaokê
https://www.youtube.com/results?search_query=Titãs+Homem+Primata+Karaokê
https://www.youtube.com/results?search_query=Titãs+Comida+Karaokê
https://www.youtube.com/results?search_query=Paralamas+O+Calibre+Karaokê
https://www.youtube.com/results?search_query=Skank+É+Uma+Partida+de+Futebol+Karaokê
https://www.youtube.com/results?search_query=Skank+Jackie+Tequila+Karaokê
https://www.youtube.com/results?search_query=Skank+Sutilmente+Karaokê
https://www.youtube.com/results?search_query=Jota+Quest+Fênix+Karaokê
https://www.youtube.com/results?search_query=Jota+Quest+Encontrar+Alguém+Karaokê
https://www.youtube.com/results?search_query=Raimundos+Andréa+Karaokê
https://www.youtube.com/results?search_query=Raimundos+Digressão+Karaokê
https://www.youtube.com/results?search_query=Raimundos+Selim+Karaokê
https://www.youtube.com/results?search_query=Engenheiros+O+Exército+de+um+Homem+Só+Karaokê
https://www.youtube.com/results?search_query=Lobão+Vida+Bandida+Karaokê
https://www.youtube.com/results?search_query=Lobão+A+Vida+é+Doce+Karaokê
https://www.youtube.com/results?search_query=Cássia+Eller+Relicário+Karaokê
https://www.youtube.com/results?search_query=Cássia+Eller+Metrô+Linha+743+Karaokê
https://www.youtube.com/results?search_query=Capital+Inicial+Música+Urbana+Karaokê
https://www.youtube.com/results?search_query=Capital+Inicial+Fátima+Karaokê
https://www.youtube.com/results?search_query=RPM+Jovem+Guarda+Karaokê
https://www.youtube.com/results?search_query=RPM+Alvo+Certeiro+Karaokê
https://www.youtube.com/results?search_query=Ultraje+a+Rigor+Nós+Vamos+Invadir+Sua+Praia+Karaokê
https://www.youtube.com/results?search_query=Kid+Abelha+Luna+de+Cristal+Karaokê
https://www.youtube.com/results?search_query=Skank+Dois+Rios+Karaokê
# adicione o restante da lista aqui...
)

# Loop para baixar cada vídeo
for URL in "${URLS[@]}"
do
    echo "Baixando: $URL"
    yt-dlp -f "bestvideo[ext=mp4]+bestaudio[ext=m4a]/mp4" \
           -o "$PASTA/%(title)s.%(ext)s" \
           --noplaylist \
           "ytsearch1:$URL"
done

echo "Todos os downloads foram concluídos."

