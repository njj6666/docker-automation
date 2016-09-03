--setenv.sh
export PG_PASSWORD=123456
export WORKSPACE=`pwd`     # docker-automation/

#postgres:
--Dockerfile:
docker build -t njj6666/postgres:v1 -f Dockerfiles/PG-Dockerfile .

docker run --name mypostgres -e POSTGRES_PASSWORD=${PG_PASSWORD} -d postgres

--interact
docker run -it --net compose_default --rm --name dbcli2 -e PGPASSWORD=${PG_PASSWORD}  --link mypostgres:postgres postgres psql -h postgres -U postgres

-- populate data 
docker run -it --rm -e PGPASSWORD=${PG_PASSWORD} -v ${WORKSPACE}/webapp/data:/tmp/data --link mypostgres:postgres postgres psql -h postgres -U postgres -f /tmp/data/pgdata.sql

create table employees(id int, name char(30), role char(30));
insert into employees values(1,'Robin','owner');
insert into employees values(2,'Becky','manager');

#env
POSTGRES_ENV_GOSU_VERSION="1.7"
declare -x POSTGRES_ENV_LANG="en_US.utf8"
declare -x POSTGRES_ENV_PGDATA="/var/lib/postgresql/data"
declare -x POSTGRES_ENV_PG_MAJOR="9.5"
declare -x POSTGRES_ENV_PG_VERSION="9.5.3-1.pgdg80+1"
declare -x POSTGRES_ENV_POSTGRES_PASSWORD="123456"
declare -x POSTGRES_NAME="/cocky_pasteur/postgres"
declare -x POSTGRES_PORT="tcp://172.17.0.2:5432"
declare -x POSTGRES_PORT_5432_TCP="tcp://172.17.0.2:5432"
declare -x POSTGRES_PORT_5432_TCP_ADDR="172.17.0.2"
declare -x POSTGRES_PORT_5432_TCP_PORT="5432"
declare -x POSTGRES_PORT_5432_TCP_PROTO="tcp"

#web container
docker run --name web1 -itd --link mypostgres:postgres -v ${WORKSPACE}/webapp/artifacts/webdemo.war:/usr/local/tomcat/webapps/webdemo.war tomcat

docker run --name web2 -itd --link mypostgres:postgres -v ${WORKSPACE}/webapp/artifacts/webdemo.war:/usr/local/tomcat/webapps/webdemo.war tomcat

#load balancer:
docker run --name lb -d -p 8081:80 -p 8082:443 -p 8083:8088 -v {WORKSPACE}/webapp/nginx.conf:/etc/nginx/nginx.conf nginx

-----------------------------------------------------------------------

单机单节点自动化
1.编写Dockerfile
{WORKSPACE}/webapp/Dockerfiles/PG-Dockerfile
{WORKSPACE}/webapp/Dockerfiles/tomcat/Dockerfile
{WORKSPACE}/webapp/Dockerfiles/loadbalancer/Dockerfile

2.docker build -t jijun/postgres:latest  Dockerfiles/postgres/

3.编写Compose file

dbcli:
    build:
      context: ${WORKSPACE}/webapp/Dockerfiles
      dockerfile: PG-Dockerfile
    environment:
      PGPASSWORD: ${PG_PASSWORD}
    volumes:
      - ${WORKSPACE}/webapp/data:/tmp/data
    container_name: dbcli
    depends_on: 
      - db
      - web
    entrypoint:
      - psql 
      - -h 
      - mypostgres 
      - -U 
      - postgres 
      - -f 
      - /tmp/data/pgdata.sql