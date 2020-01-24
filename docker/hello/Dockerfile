FROM python:3.7-alpine

CMD mkdir /hello
COPY /sources /hello
WORKDIR /hello

RUN pip install --upgrade pip && \
    apk add --no-cache --virtual .build-deps gcc libc-dev linux-headers && \
    pip install -r requirements.txt && \
    pip install wheel uwsgi && \
    addgroup -g 101 nginx                                    &&  \
    adduser -G nginx -u 101 -h /hello -s /bin/sh -D nginx  &&  \
    chown -R 101:101 /hello

USER nginx

RUN mkdir -p sqlite_db && mkdir -p /hello/backend && \
    python migrate.py db init && \
    python migrate.py db migrate && \
    python migrate.py db upgrade && \
    mv sqlite_db/app.db .

CMD [ "/bin/sh", "-c", "test -f /hello/sqlite_db/app.db || mv /hello/app.db /hello/sqlite_db/app.db ; uwsgi --ini /hello/hello.ini" ]
