# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

Ruby Version: 2.6.2

* Configuration
bundle install 

* Database creation
ra
* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...


```shell
git clone git@gitlab.com:lianker/iron_bank_api.git
```

```shell
bundle install
```

```shell
rails db:create db:migrate dev:setup
```

```shell
curl http://localhost:3000/users -H 'application/vnd.api+json'
```