docker-ubuntu-18.04-desktop
====

デスクトップ付きの ubuntu 18.04 で、 vnc クライアントか web ブラウザから入れるやつ。

## Build

```
$ docker build -t docker-ubuntu-18.04-desktop .
```

## Run

```
docker run -it -p 5900:5900 -p 8080:8080 -u 1000:1000 docker-ubuntu-18.04-desktop
```

てきとうな vnc クライアントで localhost:5900 で繋ぐか、てきとうな web ブラウザで localhost:8080 に繋げば、デスクトップが見えるはず。

