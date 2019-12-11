#!/bin/bash

echo "instalowanie g++..."
sudo apt-get update -y
sudo dpkg -i /home/vagrant/atom-amd64.deb >> /dev/null # nie uda się, ponieważ brakuje dependencji - błędy wysyłamy w kosmos
sudo apt-get install -f -y # dodajemy dependencje
sudo dpkg -i /home/vagrant/atom-amd64.deb
