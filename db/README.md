# Repositório local para os dados do banco mysql

## :name_badge: Não apague esse arquivo :name_badge:

## Informações importantes

- Aqui ficará todos os dados relacionados ao banco local criado para o moodle.
- Ele será criado como uma copia dos plugins instalados no repositório, portanto terá um esqueleto igual ao de prd, hmg, dev.
- Entretanto, não terá relação nenhuma com os dados de dev,hmg,prd portanto é uma base própria e sua.
- Se o contéudo dessa pasta for apagado, todo seu repositório será apagado e será necessario reinstalar o moodle local novamente
- Consequentemente essa pasta se preencherá novamente com a nova base criada

## Se quiser resetar a base local e reeinstalar o moodle, siga os seguintes passos:

- Entre na pasta ./db que está na raiz do projeto.
- Localize a pasta moodle_db e remova-a. (se não existir é porque o `docker-compose up` ainda não foi usado)
- Você deve apagar a pasta moodle_bd que está dentro dessa pasta bd.
- Em seguida executar novamente com  `docker-compose up`
- A pasta moodle_db será recriada e uma nova instalação do moodle acontecerá.

## Contribuição

- Em caso de melhorias, erros percebidos, sujestões, contribuia com o projeto para melhora-lo cada vez mais.

