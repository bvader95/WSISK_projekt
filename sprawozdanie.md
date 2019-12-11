# TEMAT: Tworzenie środowiska programistycznego przy pomocy Vagranta i Virtualboxa, krok po kroku

#### Wstęp - czym jest Vagrant, co chcemy z nim zrobić?

Vagrant jest narzędziem pozwalającym na zautomatyzowanie tworzenia i uruchamiania maszyn wirtualnych, rozwijanym przez Hashicorp. Współpracuje m. in. z Virtualboxem, VMware oraz Dockerem. Sercem Vagrantowego projektu jest Vagrantfile, plik konfiguracyjny napisany w języku Ruby, zawierający informacje nt. ustawień maszyn wirtualnych które mają być utworzone.

Celem tego projektu jest stworzenie przy użyciu Vagranta kompletnego środowiska programistycznego - maszyny wirtualnej postawionej na Virtualboxie, zawierającej niestandardowy edytor tekstu oraz kompilator, pozwalający na rozpoczęcie pracy od razu po uruchomieniu maszyny. Przy okazji zademonstrowane zostanie parę opcji pozwalających na dostosowanie maszyny do własnych potrzeb.

#### Plan minimum - pobieranie i uruchamianie gotowego pakietu z systemem.

Przed rozpoczęciem należy zainstalować Virtualbox i Vagranta. Oba programy są bezpłatne, i można pobrać je ze stron producentów. Vagrant pozwala na użycie innych programów wirtualizujących, ale domyślnie współpracuje z Virtualboxem.

"Box", ang. "pudełko", to format pakietów używanych przez Vagranta do zarządzania środowiskami. Boxy są tworzone dla konkretnego programu wirtualizacyjnego (np. box dla QEMU zadziała tylko z QEMU), ale działają na każdym systemie obsługiwanym przez Vagranta. Hashicorp utrzymuje repozytorium z boksami stworzonymi przez użytkowników, dostępne pod adresem https://app.vagrantup.com/boxes/search. Można tam znaleźć stworzone przez Hashicorp boxy z wersjami systemu Ubuntu o przedłużonym okresie wsparcia (LTS). Aby zainstalować sam system, bez dodatków, wystarczy zmienić zawartość pliku Vagrantfile na:

```Ruby
Vagrant.configure("2") do |config|
  config.vm.box = "hashicorp/bionic64" # Ubuntu Bionic Beaver 18.04, wersja 64-bitowa
  config.vm.box_version = "1.0.282"
end

```

Aby stworzyć tą maszynę, po zapisaniu zawartości Vagrantfile'a wystarczy wykonać polecenie ```vagrant up``` w folderu w którym się on znajduje, albo w podfolderze tego folderu. Box zostanie automatycznie pobrany przy pierwszym uruchomieniu, i maszyna zostanie uruchomiona. Parametry domyślnego konta: login "vagrant", hasło "vagrant". Domyślny użytkownik jest w stanie używać ```sudo``` bez podawania hasła - miej to na uwadze w dalszej części tekstu.

#### Modyfikacje konfiguracji i wirtualizowanego sprzętu.

Domyślnie maszyny wirtualne tworzone przez Vagranta z pomocą Virtualboxa są uruchamiane w trybie "headless" - pracują w tle, nie muszą (ale mogą) być uruchomione w trybie graficznym, i można się z nimi połączyć zdalnie przez ssh poleceniem ```vagrant ssh```. Jeżeli z jakiegoś powodu nie chcemy korzystać z trybu "headless", musimy dodać do konfiguracji w Vagrantfile'u następujący fragment:

```Ruby
  config.vm.provider "virtualbox" do |providerConfig| # konfiguracja dotycząca tylko maszyn tworzonych przez Virtualboxa
    providerConfig.gui = true
  end
```

#### Instalacja oprogramowania przy pomocy provisions.

Sam goły system nie spełnia naszych oczekiwań, więc zautomatyzujmy również pobieranie oprogramowania jakie będzie nam potrzebne. Zacznijmy od instalacji środowiska graficznego - box z systemem pozwala tylko na pracę w trybie konsolowym, co dla niedoświadczonego użytkownika może być problemem.

Vagrant pozwala na dostosowywanie (ang. provisioning) maszyn wirtualnych podczas ich tworzenia. Jedną z dostępnych opcji jest wykonywanie poleceń w powłoce, które można zrobić na dwa sposoby: bezpośrednio w skrypcie ("inline"), lub wczytując skrypt z systemu gospodarza ("path"). Oba sposoby zostaną zaprezentowane w tym rozdziale.

System Ubuntu zawiera menedżer oprogramowania "apt", pozwalający na automatyczne zainstalowanie oprogramowania, jeżeli gospodarz jest połączony z internetem. Apt pozwala na zainstalowanie środowiska graficznego XFCE jednym zadaniem:

```Ruby
config.vm.provision "shell", inline: "sudo apt-get update; sudo apt-get install xubuntu-core^ -y; shutdown -r now"
```

Pierwsze polecenie aktualizuje listy pakietów, drugie - wykonuje zadanie apta instalujące środowisko graficzne. Opcja -y pomija wszystkie zapytania do użytkownika. Trzecia komenda uruchamia maszynę ponownie.

Zadanie xubuntu-core pobiera tylko niezbędne minimum. Potrzebny jeszcze jest edytor tekstu i kompilator. Zdecydowano się na Atom - jest uniwersalny i łatwo go dostosować do potrzeb użytkownika. Ze strony twórców, https://atom.io/, pobrano pakiet .deb zawierający program i umieszczono go w folderze z plikiem Vagrantfile. Domyślnie wszystkie pliki i foldery dzielące folder z plikiem Vagrantfile trafiają do folderu współdzielonego ```/vagrant/``` w systemie gościa. Jeżeli chcemy umieścić plik w innym folderze, możemy zrobić to dodając do Vagrantfile'a poniższą linijkę:

```Ruby
config.vm.provision "file", source: "atom-amd64.deb", destination: "/home/vagrant/"
```

"Source" to lokalizacja pliku w systemie gospodarza - może być podana względem Vagrantfile'a, jak powyżej - a "destination" to folder w systemie gościa, gdzie zostanie on umieszczony.

Po umieszczeniu pakietu na systemie gościa, należy go zainstalować. Jako że proces ten wymaga dociągnięcia paru zależności z repozytorium, najlepiej zrobić to osobnym skryptem:

```bash
#!/bin/bash
sudo dpkg -i /home/vagrant/atom-amd64.deb >> /dev/null
sudo apt-get install -f
sudo dpkg -i /home/vagrant/atom-amd64.deb
```

Informacje o skrypcie - zapisanym jako install.sh - dodajemu do Vagrantifle'a w następujący sposób:

```Ruby
config.vm.provision "shell", path: "install.sh"
```

Pierwsze wywołanie dpkg nie zadziała, ponieważ brakuje zależności - spodziewano się tego, dlatego komunikaty o błędzie zostają wysłane do /dev/null. Problem ten zostanie naprawiony przez apt, więc druga instalacja powinna pójść bez problemu.

Na sam koniec w jeden z powyższych sposobów można zainstalować kompilator preferowany przez użytkownika - w naszym wypadku będzie to g++, i zainstalujemy je poleceniem umieszczonym bezpośrednio w Vagrantfile'u.

```Ruby
config.vm.provision "shell", inline: "sudo apt-get install g++ -y"
```

#### Efekt końcowy.

Vagrantfile wygląda obecnie nastepująco:
```Ruby
Vagrant.configure("2") do |config|
  config.vm.box = "hashicorp/bionic64"
  config.vm.box_version = "1.0.282"
  # config.vm.provider "virtualbox" do |providerConfig|
  #   providerConfig.gui = true
  # end
  config.vm.provision "shell", inline: "sudo apt-get update; sudo apt-get install xubuntu-core^ -y"
  config.vm.provision "file", source: "atom-amd64.deb", destination: "/home/vagrant/"
  config.vm.provision "shell", path: "install.sh"
  config.vm.provision "shell", inline: "sudo apt-get install g++ -y"
end
```
