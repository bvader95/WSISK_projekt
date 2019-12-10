# TEMAT: Tworzenie środowiska programistycznego przy pomocy Vagranta i Virtualboxa, krok po kroku

#### Wstęp - czym jest Vagrant, co chcemy z nim zrobić?

Vagrant jest narzędziem pozwalającym na zautomatyzowanie tworzenia i uruchamiania maszyn wirtualnych, rozwijanym przez Hashicorp. Współpracuje m. in. z Virtualboxem, VMware oraz Dockerem. Sercem Vagrantowego projektu jest Vagrantfile, plik konfiguracyjny napisany w języku Ruby, zawierający informacje nt. ustawień maszyn wirtualnych które mają być utworzone.

Celem tego projektu jest stworzenie przy użyciu Vagranta kompletnego środowiska programistycznego - maszyny wirtualnej postawionej na Virtualboxie, zawierającej niestandardowy edytor tekstu oraz kompilator, pozwalający na rozpoczęcie pracy od razu po uruchomieniu maszyny. Przy okazji zademonstrowane zostanie parę opcji pozwalających na dostosowanie maszyny do własnych potrzeb.

#### Plan minimum - pobieranie i uruchamianie gotowego pakietu z systemem.

Przed rozpoczęciem należy zainstalować Virtualbox i Vagranta. Oba programy są bezpłatne, i można pobrać je ze stron producentów. Vagrant pozwala na użycie innych programów wirtualizujących, ale domyślnie współpracuje z Virtualboxem.

"Box", ang. "pudełko", to format pakietów używanych przez Vagranta do zarządzania środowiskami. Boxy są tworzone dla konkretnego programu wirtualizacyjnego (box dla QEMU zadziała tylko z QEMU), ale działają na każdym systemie obsługiwanym przez Vagranta. Hashicorp utrzymuje repozytorium z boksami stworzonymi przez użytkowników, dostępne pod adresem https://app.vagrantup.com/boxes/search. Można tam znaleźć stworzone przez Hashicorp boxy z wersjami systemu Ubuntu o przedłużonym okresie wsparcia (LTS). Aby zainstalować sam system, bez dodatków, wystarczy zmienić zawartość pliku Vagrantfile na:

```Ruby
Vagrant.configure("2") do |config|
  config.vm.box = "hashicorp/bionic64"
  config.vm.box_version = "1.0.282"
end

```

Aby stworzyć tą maszynę, po zapisaniu zawartości Vagrantfile'a wystarczy wykonać polecenie ```vagrant up``` w folderu w którym się on znajduje, albo w podfolderze tego folderu. Box zostanie automatycznie pobrany przy pierwszym uruchomieniu, i maszyna zostanie uruchomiona. Dane użytkownika: login "vagrant", hasło "vagrant". Domyślny użytkownik jest w stanie używać ```sudo``` bez podawania hasła - miej to na uwadze w dalszej części tekstu.

#### Modyfikacje konfiguracji i wirtualizowanego sprzętu.

Domyślnie maszyny wirtualne tworzone przez Vagranta z pomocą Virtualboxa są uruchamiane w trybie "headless" - pracują w tle, nie muszą (ale mogą) być uruchomione w trybie graficznym, i można się z nimi połączyć zdalnie przez ssh poleceniem ```vagrant ssh```. Jeżeli z jakiegoś powodu nie chcemy korzystać z trybu "headless", musimy dodać do konfiguracji w Vagrantfile'u następujący fragment:

```Ruby
  config.vm.provider "virtualbox" do |providerConfig| # konfiguracja dotycząca tylko maszyn tworzonych przez Virtualboxa
    providerConfig.gui = true
  end
```

#### Instalacja oprogramowania przy pomocy provisions.

Mając tak przygotowaną maszynę wirtualną, chcemy zainstalować na niej oprogramowanie z którego będziemy korzystać. Zacznijmy od instalacji środowiska graficznego - box z systemem pozwala tylko na pracę w trybie konsolowym, co dla niedoświadczonego użytkownika może być problemem.

Vagrant pozwala na dostosowywanie (ang. provisioning) maszyn wirtualnych podczas ich tworzenia. Jedną z dostępnych opcji jest wykonywanie poleceń w powłoce, które można zrobić na dwa sposoby: bezpośrednio w skrypcie:

```Ruby
config.vm.provision "shell", inline: "echo Polecenie do wykonania"
```

lub wczytując skrypt z systemu gospodarza

```Ruby
config.vm.provision "shell", file: "/ścieżka/do/pliku.sh"
```

W połączeniu z menedżerem oprogramowania "apt" dostępnym w systemie Ubuntu pozwala na automatyczne zainstalowanie oprogramowania, jeżeli gospodarz jest połączony z internetem. Apt pozwala na zainstalowanie środowiska graficznego XFCE jednym zadaniem, poleceniem przedstawionym poniżej:

```Ruby
config.vm.provision "shell", inline: "sudo apt-get update; sudo apt-get install xubuntu-core^ -y; shutdown -r now"
```

Pierwsze polecenie aktualizuje listy pakietów, drugie - wykonuje zadanie apta instalujące środowisko graficzne. Opcja -y pomija wszystkie zapytania do użytkownika. Trzecia komenda uruchamia maszynę ponownie.

Po zainstalowaniu środowiska graficznego możemy zainstalować kompilator g++. Możemy to zrobić w ten sam sposób, ale można to też zrobić zewnętrznym skryptem. W tym samym folderze w którym znajduje się Vagrantfile utworzono prosty plik "install.sh":

```bash
#!/bin/bash
sudo apt-get install g++ -y
```

Na sam koniec zainstalujmy edytor tekstu Atom. Ze strony autora, https://atom.io/, pobrano pakiet .deb zawierający program i umieszczono go w folderze z plikiem Vagrantfile. Domyślnie wszystkie pliki dzielące folder z plikiem Vagrantfile trafiają do folderu współdzielonego ```/vagrant/``` w systemie gościa. Jeżeli chcemy umieścić plik w innym folderze, możemy zrobić to przy pomocy provision:

```Ruby
config.vm.provision "file", source: "files/atom-amd64.deb", destination: "/home/vagrant/"
```

"Source" to ścieżka do pliku na komputerze gospodarza, a "destination" to folder w systemie gościa, gdzie trafi nasz plik. Po umieszczeniu go w tym miejscu, należy go zainstalować i pobrać pakiety zależne. Możemy zrobić to przy pomocy już istniejącego skryptu "install.sh". Dodajmy do niego komendy automatuzyjące instalację:

```bash
#!/bin/bash
sudo apt-get install g++ -y

sudo dpkg -i /home/vagrant/atom-amd64.deb >> /dev/null # nie uda się, ponieważ brakuje dependencji - błędy wysyłamy w kosmos
sudo apt-get install -f # dodajemy dependencje
sudo dpkg -i /home/vagrant/atom-amd64.deb
```

#### Efekt końcowy.

Vagrantfile:
