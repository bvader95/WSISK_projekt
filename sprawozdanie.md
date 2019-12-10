# TEMAT: Tworzenie środowiska programistycznego przy pomocy Vagranta i Virtualboxa, krok po kroku

#### Wstęp - czym jest Vagrant, co chcemy z nim zrobić?

Vagrant jest narzędziem pozwalającym na zautomatyzowanie tworzenia i uruchamiania maszyn wirtualnych, rozwijanym przez Hashicorp. Współpracuje m. in. z Virtualboxem, VMware oraz Dockerem. Sercem Vagrantowego projektu jest Vagrantfile, plik konfiguracyjny napisany w języku Ruby, zawierający informacje nt. ustawień maszyn wirtualnych które mają być utworzone.

Celem tego projektu jest stworzenie przy użyciu Vagranta kompletnego środowiska programistycznego - maszyny wirtualnej postawionej na Virtualboxie, zawierającej niestandardowy edytor tekstu oraz kompilator, pozwalający na rozpoczęcie pracy od razu po uruchomieniu maszyny. Przy okazji zademonstrowane zostanie parę opcji pozwalających na dostosowanie maszyny do własnych potrzeb.

#### Plan minimum - pobieranie i uruchamianie gotowego pakietu z systemem.

Przed rozpoczęciem należy zainstalować Virtualbox i Vagranta. Oba programy są bezpłatne, i można pobrać je ze stron producentów. Vagrant pozwala na użycie innych programów wirtualizujących, ale domyślnie współpracuje z Virtualboxem.

"Box", ang. "pudełko", to format pakietów używanych przez Vagranta do zarządzania środowiskami. Boxy różnią się pomiędzy programami wirtualizacyjnymi, ale działają na każdym systemie obsługiwanym przez Vagranta. Hashicorp utrzymuje repozytorium z boksami stworzonymi przez użytkowników, dostępne pod adresem https://app.vagrantup.com/boxes/search. Można tam znaleźć stworzone przez Hashicorp boxy z wersjami systemu Ubuntu o przedłużonym okresie wsparcia (LTS). Aby zainstalować sam system, bez dodatków, wystarczy zmienić zawartość pliku Vagrantfile na:

```Ruby
Vagrant.configure("2") do |config|
  config.vm.box = "hashicorp/bionic64"
  config.vm.box_version = "1.0.282"
end

```

Aby stworzyć tą maszynę, po zapisaniu zawartości Vagrantfile'a wystarczy wykonać polecenie ```vagrant up``` w folderu w którym się on znajduje, albo w podfolderze tego folderu. Box zostanie automatycznie pobrany przy pierwszym uruchomieniu, i maszyna zostanie uruchomiona. Dane użytkownika: login "vagrant", hasło "vagrant".

#### Modyfikacje konfiguracji i wirtualizowanego sprzętu.

Domyślnie maszyny wirtualne tworzone przez Vagranta z pomocą Virtualboxa są uruchamiane w trybie "headless" - pracują w tle, nie muszą (ale mogą) być uruchomione w trybie graficznym, i można się z nimi połączyć zdalnie przez ssh poleceniem ```vagrant ssh```. Jeżeli z jakiegoś powodu nie chcemy korzystać z trybu "headless", musimy dodać do konfiguracji w Vagrantfile'u następujący fragment:

```Ruby
  config.vm.provider "virtualbox" do |providerConfig|
    providerConfig.gui = true
  end
```

W taki sposób definiowana jest konfiguracja zależna od dostawcy usług wirtualizacyjnych.

#### Instalacja oprogramowania.

Mając tak przygotowaną maszynę wirtualną, chcemy zainstalować na niej oprogramowanie z którego będziemy korzystać. Zacznijmy od instalacji środowiska graficznego - box z systemem pozwala tylko na pracę w trybie konsolowym, co dla niedoświadczonego użytkownika może być problemem.

Vagrant pozwala na dostosowywanie (ang. provisioning) maszyn wirtualnych podczas ich tworzenia. Jedną z dostępnych opcji jest wykonywanie poleceń w powłoce, które można zrobić na dwa sposoby: bezpośrednio w skrypcie:

```Ruby
config.vm.provision "shell", inline: "echo Polecenie do wykonania"
```

lub wczytując skrypt z gospodarza

```Ruby
config.vm.provision "shell", file: "/ścieżka/do/pliku.sh"
```

W połączeniu z menedżerem oprogramowania "apt" dostępnym w systemie Ubuntu pozwala na automatyczne zainstalowanie oprogramowania, jeżeli gospodarz jest połączony z internetem. Apt pozwala na zainstalowanie środowiska graficznego XFCE jednym zadaniem, poleceniem przedstawionym poniżej:

```Ruby
config.vm.provision "shell", inline: "sudo apt-get update; sudo apt-get install xubuntu-core^ -y"
```

Polecenie przed myślnikiem aktualizuje listy pakietów, a polecenie po - wykonuje zadanie apta instalujące środowisko graficzne. Opcja -y automatycznie odpowiada "tak" na wszystkie pytania.

#### Efekt końcowy.
