# How to use DEV environment

* First clone the repo:

```
git clone git@github.com:pitchup/Pitchup.com.git pitchup.com
cd pitchup.com
cp envs/sample.env .env
```

* Add this lines to /etc/hosts

```
127.0.0.1 local.pitchup.com m.local.pitchup.com
```

## Build it

Before running containers you need to build them first. Although trying to run the containers will build them:

```bash
docker-compose build --pull
```

## Init it

You'll have to download database dump. One was is to use S3cmd. Another is any other S3 browser:

* Install S3cmd from brew/macports/apt
* Configure it

```bash
grep 'AWS' ./ansible/playbooks/pitchup/inventory/group_vars/all.yaml
s3cmd --configure # Copy AWS credentials manually
```

* Download latest DB dump:

```bash
LATEST=`s3cmd ls s3://pitchupdb | tail -1  | awk '{print $2}'`
LATEST=`s3cmd ls $LATEST | tail -1 | awk '{print $2}'`
s3cmd get `s3cmd ls $LATEST | tail -1 | awk '{print $4}'`
```

* To import database dump you need to have the postgres container running.

```bash
docker-compose up -d postgres
```

```bash
gunzip < pitchup_prod.sql.gz | docker-compose run --rm postgres psql -h postgres -p 5432 -U postgres -d pitchup --
```

## Run it

Bring everything up (add -d flat if you want to run it in background)

```bash
docker-compose up
```

or: 

```bash
make dev
```

You can now access `https://local.pitchup.com`.

## Cleanup

### Clean it

You can clear up some of the images left around after docker builds. Warning you might delete stuff you are using.

```
make clean
```

### Kill it

Kill all running containers

```bash
make kill
```

### Destroy it

Remove all built containers, images and also volumes.

```bash
make destroy
```

WARNING: USE ONLY FOR FULL CLEANUP! If you do this, be prepared to have another lengthy wait as you will have to import.

