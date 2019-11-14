# Iron Bank

Este projeto é para aprendizado do framework **Ruby on Rails**. Uma api capaz de fazer operações bancárias. 

> Todos os comandos a seguir devem ser executados no terminal

## Requisitos de sistema

- Ruby 2.6.2
- Rails 6.0.1
- Sqlite

para instalar o ruby siga as instruções no link
[instalação ruby](https://www.ruby-lang.org/pt/documentation/installation/)


No **Ubuntu** o Sqlite pode ser instalado através do comando

```shell
sudo apt install sqlite3 libsqlite3-dev
```

## Clonando o repositorio

```shell
git clone git@gitlab.com:lianker/iron_bank_api.git
```

Após clonar, entre na pasta

```shell
cd iron_bank_api
```

Instale as dependências com o bundle

```shell
bundle install
```

## Criando os dados

```shell
rails db:create db:migrate dev:setup
```

> A task `dev:setup` cria os dados necessários para a excução do exemplo mais adiante

## Rodando os testes

```shell
bundle exec rspec
```

## Exemplos

### Rodando o servidor

```shell
rails s
```
### Buscando Usuarios
Para os exemplos a seguir primeiro é preciso consultar os dados de usuario previamente cadastrados. Abaixo segue um exemplo

```shell
curl http://localhost:3000/users -H 'application/vnd.api+json'
```

### Consultando o saldo

Com os dados de algum dos usuários listados no comando anterior é possível consultar o saldo, onde:

- account_number: Numero da conta do usuario
- user_token: token do usuário

```shell
curl http://localhost:3000/operations/check_balance/<account_number> -H 'Accept: application/vnd.api+json' -H 'Authorization: Token <user_token>'
```

### Fazendo um transferência

para este exemplo é necessário uma conta de origem, uma conta de destino e uma quantia a ser transferida.

Variáveis
- source_account_number: número da conta de origem
- destination_account_number: Número da conta de destino
- user_token: token do usuário dono da conta de origem

```shell
curl -d '{"source_account_number": "<source_account_number>", "destination_account_number": "<destination_account_number>", "ammount": 98.0 }' -H "Content-Type: application/json" -H 'Authorization: Token <user_token>' -X POST http://localhost:3000/operations/transfer
```