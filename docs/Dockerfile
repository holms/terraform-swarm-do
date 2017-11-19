FROM python:2-alpine
RUN pip install --upgrade pip
RUN apk add --update alpine-sdk jpeg-dev zlib-dev openssl-dev readline-dev
RUN pip install mkdocs nwdiag markdown-blockdiag pymdown-extensions
ADD . /docs
WORKDIR /docs
RUN mkdocs build --clean

FROM nginx:alpine
COPY --from=0 /docs/site /docs
ADD nginx.conf /etc/nginx/conf.d/default.conf
ADD .htpasswd /etc/nginx/.htpasswd
