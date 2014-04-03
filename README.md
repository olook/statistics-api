statistics-api
==============

API para inserir log de eventos

Dependencias:
ruby-2.0.0-p353
bundler

Para Deploy da parte estática:
asw-cli (sudo pip install )

comando para deploy da lib JS: 
* aws s3 cp ./statistics.js s3://cdn-app/ --acl public-read


Url do estático: http://cdn-app-0.olook.com.br/statistics.js (atencao pq é uma cdn)
