# Pokédex - Projeto Flutter + PHP

Este projeto é uma Pokédex desenvolvida com Flutter no front-end e PHP com MySQL no back-end. O objetivo é demonstrar uma integração entre um aplicativo mobile e um servidor local que fornece e recebe dados.

---

## ✅ Requisitos

- PHP 8+ instalado (nativo ou via XAMPP/WAMP)
- Flutter SDK instalado
- MySQL/MariaDB local com as tabelas esperadas
- Dispositivo Android ou emulador
- Os arquivos PHP devem estar configurados para responder às rotas:
  - `/get_pokemon.php`
  - `/sync_user.php`
  - `/sync_pokemon.php`

---

## ▶️ Como rodar o servidor PHP

1. Abra o terminal ou prompt de comando.
2. Navegue até a pasta onde estão os arquivos `.php`:


cd caminho/para/seu_projeto/phpAPI
Inicie o servidor PHP com o comando:


Copiar
Editar
php -S 0.0.0.0:8000
Isso irá iniciar o servidor escutando todas as interfaces na porta 8000.
Exemplo de acesso via outro dispositivo na rede:
http://192.168.0.10:8000/get_pokemon.php

🤖 Como gerar o APK do aplicativo Flutter
No terminal, entre na pasta do projeto Flutter:


Copiar
Editar
cd caminho/para/seu_projeto/pokedexfatecdsm
Compile o APK de release com:

Copiar
Editar
flutter build apk
O arquivo final estará disponível em:

Copiar
Editar
build/app/outputs/flutter-apk/app-release.apk
Transfira e instale o APK no seu celular.