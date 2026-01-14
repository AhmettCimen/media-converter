# Linux Araçları ve Kabuk Programlama Ödevi 

Bu proje, Linux komut satırında kullanılan ffmpeg ve ekstra olarak yt-dlp araçları için geliştirilmiş bir arayüz uygulamasıdır. Kullanıcılar bu script sayesinde karmaşık terminal komutları yazmadan video dönüştürme, ses dönüştürme ve Youtube üzerinden indirme işlemlerini gerçekleştirebilir.

Uygulama, PARDUS işletim sistemi üzerinde çalışabilecek şekilde tasarlanmıştır ve hem Grafik Arayüz (GUI) hem de Terminal Arayüzü (TUI) seçenekleri sunar.

# Proje Tanıtım Videosu 📹

Projenin kurulumu, kullanımı ve özelliklerini anlatan tanıtım videosuna aşağıdaki bağlantıdan ulaşabilirsiniz:

[linkKoyucam]

# Kurulum ve Sistem Gereksinimleri ⚙️

Projenin çalışabilmesi için sistemde aşağıdaki paketlerin yüklü olması gerekir:

ffmpeg
yad
whiptail
yt-dlp

Script çalıştırıldığında bu paketleri kontrol eder ve eksik varsa otomatik olarak kurar. Manuel kurulum yapmak isterseniz şu komutu kullanabilirsiniz:

sudo apt update
sudo apt install ffmpeg yad whiptail yt-dlp

Projeyi çalıştırmak için terminali açın ve şu komutları uygulayın:

chmod +x script.sh
./script.sh

# Kullanım Kılavuzu ve Ekran Görüntüleri 🖼️

Script çalıştırıldığında kullanıcıya arayüz tercihi sorulur. 1 tuşu grafik arayüzü, 2 tuşu terminal arayüzünü açar.

![Arayüz Seçim Ekranı](sc/giris_secim.png)

## 1. Grafiksel Kullanıcı Arayüzü (GUI - YAD) 🖥️

YAD kullanılarak hazırlanan bu arayüz fare ile kontrol edilir.

Ana Menü:
Kullanıcının işlem seçtiği ekrandır.

![YAD Ana Menü](sc/yad_menu.png)

Dosya ve Format Seçimi:
Dönüştürme işleminde dosya seçimi ve hedef formatın belirlendiği ekranlar.

![YAD Dosya Seçimi](sc/yad_dosya.png)

![YAD Format Seçimi](sc/yad_format.png)

Youtube İndirme:
Youtube linkinin girildiği ekran.

![YAD Link Girişi](sc/yad_youtube.png)

İşlem Durumu:
İşlem yapılırken çıkan ilerleme çubuğu.

![YAD İlerleme Çubuğu](sc/yad_progress.png)

## 2. Terminal Tabanlı Kullanıcı Arayüzü (TUI - Whiptail) ⌨️

Whiptail kullanılarak hazırlanan bu arayüz klavye ile kontrol edilir.

Ana Menü:
Ok tuşları ile işlem seçilen ekran.

![Whiptail Ana Menü](sc/whiptail_menu.png)

Video ve Ses Dönüştürme:
Dosya yolunun girildiği ve formatın seçildiği ekranlar.

![Whiptail Dosya Yolu](sc/whiptail_dosya.png)

![Whiptail Format Listesi](sc/whiptail_format.png)

Youtube İndirme:
Linkin yapıştırıldığı ekran.

![Whiptail Link Girişi](sc/whiptail_youtube.png)

İşlem Durumu:
Terminal üzerinde dolan ilerleme çubuğu.

![Whiptail İlerleme Çubuğu](sc/whiptail_progress.png)

# Teknik Detaylar 🛠️

Proje Bash script dili ile yazılmıştır.

check_dependencies fonksiyonu eksik paketleri kontrol eder.
generate_output_name fonksiyonu çıktı dosyası ismini ayarlar.
convert_media fonksiyonu ffmpeg işlemlerini yönetir.
download_media fonksiyonu yt-dlp işlemlerini yönetir.
run_gui ve run_tui fonksiyonları menü döngülerini sağlar.
