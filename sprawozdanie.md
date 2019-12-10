# TEMAT: Tworzenie środowiska programistycznego przy pomocy Vagranta i Virtualboxa, krok po kroku

#### Wstęp! Czym jest Vagrant, co chcemy z nim zrobić?

Vagrant jest narzędziem pozwalającym na zautomatyzowanie tworzenia i uruchamiania maszyn wirtualnych, rozwijanym przez Hashicorp. Współpracuje m. in. z Virtualboxem, VMware oraz Dockerem. Sercem Vagrantowego projektu jest Vagrantfile, plik konfiguracyjny napisany w języku Ruby, zawierający informacje nt. ustawień maszyn wirtualnych które mają być utworzone.

Celem tego projektu jest stworzenie przy użyciu Vagranta kompletnego środowiska programistycznego - maszyny wirtualnej postawionej na Virtualboxie, zawierającą niestandardowy edytor tekstu oraz kompilator, pozwalający na rozpoczęcie pracy od razu po uruchomieniu maszyny.

#### Stan startowy - pobieranie i uruchamianie gotowego pakietu z systemem.

Przed rozpoczęciem należy zainstalować Virtualbox i Vagranta. Oba programy są bezpłatne, i można pobrać je ze stron producentów.

"Box", ang. "pudełko", to format pakietów używanych przez Vagranta do zarządzania środowiskami. Boxy mogą być używane na każdym systemie obsługiwanym przez Vagranta. Hashicorp utrzymuje repozytorium z boksami stworzonymi przez użytkowników, dostępne pod adresem https://app.vagrantup.com/boxes/search. Można tam znaleźć stworzone przez firmę boxy ze zoptymalizowaną wersją Ubuntu o przedłużonym okresie wsparcia. Aby zainstalować sam system, bez dodatków, wystarczy zmienić zawartość pliku Vagrantfile na:

```Ruby
Vagrant.configure("2") do |config|
  config.vm.box = "hashicorp/bionic64"
  config.vm.box_version = "1.0.282"
end

```

Aby stworzyć tą maszynę, po zapisaniu zawartości Vagrantfile'a wystarczy wykonać polecenie ```vagrant up``` w folderu w którym się on znajduje, albo w podfolderze tego folderu. Box zostanie automatycznie pobrany przy pierwszym uruchomieniu, i maszyna zostanie uruchomiona.

Domyślnie maszyny wirtualne tworzone przez Vagranta z pomocą Virtualboxa są uruchamiane w trybie "headless", tzn. nie są w ogóle widoczne z poziomu komputera gospodarza, i można połączyć się z nimi zdalnie. Jeżeli chcemy z jakiegokolwiek powodu korzystać z interfejsu graficznego Virtualboxa, musimy dodać do pliku konfiguracyjnego poniższy fragment:

```Ruby
config.vm.provider "virtualbox" do |providerConfig|
  providerConfig.gui = true
end
```

#### Instalacja oprogramowania!

Mając tak przygotowaną maszynę wirtualną, chcemy zainstalować na niej oprogramowanie z którego będziemy korzystać. Zacznijmy od instalacji środowiska graficznego - box z systemem pozwala tylko na pracę w trybie konsolowym.

Zdecydowano się na instalację środowiska XFCE. 

#### Efekt końcowy, kopia Vagrantfile'a i link do Gita.
