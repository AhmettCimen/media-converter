#!/bin/bash

check_dependencies() {
    MISSING_PKGS=""
    
    if ! command -v ffmpeg &> /dev/null; then MISSING_PKGS="$MISSING_PKGS ffmpeg"; fi
    if ! command -v yad &> /dev/null; then MISSING_PKGS="$MISSING_PKGS yad"; fi
    if ! command -v whiptail &> /dev/null; then MISSING_PKGS="$MISSING_PKGS whiptail"; fi
    # Youtube indirme araci kontrolu eklendi
    if ! command -v yt-dlp &> /dev/null; then MISSING_PKGS="$MISSING_PKGS yt-dlp"; fi

    if [ ! -z "$MISSING_PKGS" ]; then
        echo "Gerekli paketler yukleniyor: $MISSING_PKGS"
        sudo apt update
        sudo apt install -y $MISSING_PKGS
    fi
}

check_dependencies

generate_output_name() {
    local input_file="$1"
    local target_ext="$2"
    local filename=$(basename -- "$input_file")
    local dirname=$(dirname -- "$input_file")
    local name="${filename%.*}"
    echo "${dirname}/${name}_converted.${target_ext}"
}

convert_media() {
    local input="$1"
    local output="$2"
    local mode="$3"

    if [ "$mode" == "gui" ]; then
        ffmpeg -i "$input" -y "$output" 2>&1 | \
        yad --progress --pulsate --title="Islem Yapiliyor" \
            --text="Lutfen bekleyin...\nDosya: $input" \
            --auto-close --width=400
        
        if [ $? -eq 0 ]; then
            yad --info --title="Basarili" --text="Islem tamamlandi!\nDosya: $output" --width=300
        else
            yad --error --title="Hata" --text="Donusturme sirasinda hata olustu."
        fi
    else
        {
            ffmpeg -i "$input" -y "$output" -hide_banner 
        } 2>&1 | whiptail --title "Islem Yapiliyor" --gauge "Lutfen bekleyin..." 6 60 50
        
        if [ -f "$output" ]; then
            whiptail --title "Basarili" --msgbox "Islem Tamamlandi!\nDosya: $output" 8 45
        else
            whiptail --title "Hata" --msgbox "Hata olustu." 8 45
        fi
    fi
}

# Youtube indirme fonksiyonu
download_media() {
    local url="$1"
    local type="$2" # video veya audio
    local mode="$3" # gui veya tui
    local cmd=""

    # Video ise MP4, Ses ise MP3 olarak ayarla
    if [ "$type" == "video" ]; then
        # En iyi video kalitesi ama mp4 uzantisinda zorla
        cmd="yt-dlp -f 'best[ext=mp4]' -o '%(title)s.%(ext)s' '$url'"
    else
        # Sesi ayikla ve mp3'e cevir
        cmd="yt-dlp -x --audio-format mp3 -o '%(title)s.%(ext)s' '$url'"
    fi

    if [ "$mode" == "gui" ]; then
        # Komutu calistir ve ciktisini yad'a gonder
        eval "$cmd" 2>&1 | \
        yad --progress --pulsate --title="Youtube Indiriliyor" \
            --text="Lutfen bekleyin...\nYoutube'dan veri cekiliyor." \
            --auto-close --width=400
        
        if [ $? -eq 0 ]; then
            yad --info --title="Basarili" --text="Indirme tamamlandi!\nDosya scriptin oldugu klasore kaydedildi." --width=350
        else
            yad --error --title="Hata" --text="Indirme sirasinda hata olustu.\nLinkin dogrulugunu kontrol edin."
        fi
    else
        # TUI modu
        {
            eval "$cmd"
        } 2>&1 | whiptail --title "Youtube Indiriliyor" --gauge "Dosya indiriliyor, lutfen bekleyin..." 6 60 50
        
        if [ $? -eq 0 ]; then
            whiptail --title "Basarili" --msgbox "Indirme Tamamlandi!" 8 45
        else
            whiptail --title "Hata" --msgbox "Indirme basarisiz oldu." 8 45
        fi
    fi
}

run_gui() {
    while true; do
        ACTION=$(yad --list --title="FFMPEG & Youtube Arayuzu" \
            --text="Islem Seciniz:" \
            --column="Kod" --column="Aciklama" --print-column=1 --hide-column=1 \
            --separator="" \
            --width=450 --height=350 \
            --mid-search \
            "V2V" "Video -> Video" \
            "V2A" "Video -> Ses" \
            "A2A" "Ses -> Ses" \
            "YT2V" "Youtube Link -> Video (MP4)" \
            "YT2A" "Youtube Link -> Ses (MP3)" \
            "EXIT" "Cikis")

        if [ -z "$ACTION" ] || [ "$ACTION" == "EXIT" ]; then
            break
        fi

        case $ACTION in
            V2V)
                FILE=$(yad --file --title="Video Sec" --file-filter="Video | *.mp4 *.mkv *.avi *.mov *.flv")
                if [ ! -z "$FILE" ]; then
                    FORMAT=$(yad --list --title="Format Sec" --text="Hedef Video Formati:" \
                        --column="Format" --print-column=1 --separator="" \
                        --height=200 --hide-header \
                        "mp4" "mkv" "avi" "mov" "flv" "webm")
                    
                    if [ ! -z "$FORMAT" ]; then
                        OUT=$(generate_output_name "$FILE" "$FORMAT")
                        convert_media "$FILE" "$OUT" "gui"
                    fi
                fi
                ;;
            V2A)
                FILE=$(yad --file --title="Video Sec" --file-filter="Video | *.mp4 *.mkv *.avi *.mov")
                if [ ! -z "$FILE" ]; then
                    FORMAT=$(yad --list --title="Format Sec" --text="Hedef Ses Formati:" \
                        --column="Format" --print-column=1 --separator="" \
                        --height=200 --hide-header \
                        "mp3" "wav" "aac" "ogg" "m4a")
                    
                    if [ ! -z "$FORMAT" ]; then
                        OUT=$(generate_output_name "$FILE" "$FORMAT")
                        convert_media "$FILE" "$OUT" "gui"
                    fi
                fi
                ;;
            A2A)
                FILE=$(yad --file --title="Ses Sec" --file-filter="Ses | *.mp3 *.wav *.aac *.ogg *.flac *.m4a *.wma")
                if [ ! -z "$FILE" ]; then
                    FORMAT=$(yad --list --title="Format Sec" --text="Hedef Ses Formati:" \
                        --column="Format" --print-column=1 --separator="" \
                        --height=250 --hide-header \
                        "mp3" "wav" "flac" "aac" "ogg" "m4a" "wma")
                    
                    if [ ! -z "$FORMAT" ]; then
                        OUT=$(generate_output_name "$FILE" "$FORMAT")
                        convert_media "$FILE" "$OUT" "gui"
                    fi
                fi
                ;;
            YT2V)
                URL=$(yad --entry --title="Youtube Video Indir" --text="Youtube Video Linkini Yapistirin:" --width=400)
                if [ ! -z "$URL" ]; then
                    download_media "$URL" "video" "gui"
                fi
                ;;
            YT2A)
                URL=$(yad --entry --title="Youtube Ses Indir" --text="Youtube Video Linkini Yapistirin (MP3 olacak):" --width=400)
                if [ ! -z "$URL" ]; then
                    download_media "$URL" "audio" "gui"
                fi
                ;;
        esac
    done
}

run_tui() {
    while true; do
        CHOICE=$(whiptail --title "FFMPEG & Youtube Arayuzu" --menu "Islem Seciniz" 18 60 6 \
            "1" "Video -> Video" \
            "2" "Video -> Ses" \
            "3" "Ses -> Ses" \
            "4" "Youtube Link -> Video" \
            "5" "Youtube Link -> Ses" \
            "6" "Cikis" 3>&1 1>&2 2>&3)

        if [ -z "$CHOICE" ] || [ "$CHOICE" == "6" ]; then
            break
        fi

        case $CHOICE in
            1)
                FILE=$(whiptail --inputbox "Video dosyasinin tam yolu:" 10 60 3>&1 1>&2 2>&3)
                if [ -f "$FILE" ]; then
                    FORMAT=$(whiptail --menu "Hedef Format:" 15 60 6 \
                        "mp4" "MP4" "mkv" "MKV" "avi" "AVI" "mov" "MOV" "webm" "WEBM" 3>&1 1>&2 2>&3)
                    
                    if [ ! -z "$FORMAT" ]; then
                        OUT=$(generate_output_name "$FILE" "$FORMAT")
                        convert_media "$FILE" "$OUT" "tui"
                    fi
                else
                    if [ ! -z "$FILE" ]; then whiptail --msgbox "Dosya bulunamadi!" 8 45; fi
                fi
                ;;
            2)
                FILE=$(whiptail --inputbox "Video dosyasinin tam yolu:" 10 60 3>&1 1>&2 2>&3)
                if [ -f "$FILE" ]; then
                    FORMAT=$(whiptail --menu "Hedef Ses Formati:" 15 60 5 \
                        "mp3" "MP3" "wav" "WAV" "aac" "AAC" "ogg" "OGG" "m4a" "M4A" 3>&1 1>&2 2>&3)
                    
                    if [ ! -z "$FORMAT" ]; then
                        OUT=$(generate_output_name "$FILE" "$FORMAT")
                        convert_media "$FILE" "$OUT" "tui"
                    fi
                else
                    if [ ! -z "$FILE" ]; then whiptail --msgbox "Dosya bulunamadi!" 8 45; fi
                fi
                ;;
            3)
                FILE=$(whiptail --inputbox "Ses dosyasinin tam yolu:" 10 60 3>&1 1>&2 2>&3)
                if [ -f "$FILE" ]; then
                    FORMAT=$(whiptail --menu "Hedef Ses Formati:" 15 60 7 \
                        "mp3" "MP3" "wav" "WAV" "flac" "FLAC" "aac" "AAC" "ogg" "OGG" "m4a" "M4A" "wma" "WMA" 3>&1 1>&2 2>&3)
                    
                    if [ ! -z "$FORMAT" ]; then
                        OUT=$(generate_output_name "$FILE" "$FORMAT")
                        convert_media "$FILE" "$OUT" "tui"
                    fi
                else
                    if [ ! -z "$FILE" ]; then whiptail --msgbox "Dosya bulunamadi!" 8 45; fi
                fi
                ;;
            4)
                URL=$(whiptail --inputbox "Youtube Linkini Giriniz (MP4):" 10 60 3>&1 1>&2 2>&3)
                if [ ! -z "$URL" ]; then
                    download_media "$URL" "video" "tui"
                fi
                ;;
            5)
                URL=$(whiptail --inputbox "Youtube Linkini Giriniz (MP3):" 10 60 3>&1 1>&2 2>&3)
                if [ ! -z "$URL" ]; then
                    download_media "$URL" "audio" "tui"
                fi
                ;;
        esac
    done
}

clear
echo "FFMPEG & YOUTUBE ARACI"
echo "1) Grafik Arayuz (GUI)"
echo "2) Terminal Arayuz (TUI)"
echo "3) Cikis"
read -p "Secim (1/2/3): " INTERFACE_CHOICE

case $INTERFACE_CHOICE in
    1)
        run_gui
        ;;
    2)
        run_tui
        ;;
    3)
        exit 0
        ;;
    *)
        echo "Gecersiz secim"
        exit 1
        ;;
esac
