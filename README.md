# docker-elastic-stack


## Usage

Primero, actualiza la contraseña de elasticsearch, tanto en `cerebro/application.conf` como en el fichero `.env.template`

Por defecto, las credenciales serán:
```
usuario: elastic
password: changeme
```

Después, ejecute el comando `./run.sh` para construir y desplegar el software

Si ya ha desplegado el software con anterioridad, simplemente ejecute:
`docker-compose up -p <COMPOSE_PROJECT> up`

Si desea desplegar liberando el terminal, ejecute:
`docker-compose up -p <COMPOSE_PROJECT> up -d`