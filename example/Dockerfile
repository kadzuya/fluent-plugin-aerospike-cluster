# or v0.14-onbuild
FROM fluent/fluentd:v0.12.31-onbuild

USER root

# below RUN includes plugin as examples elasticsearch is not required
# you may customize including plugins as you wish

RUN apk add --update --virtual .build-deps \
        sudo build-base ruby-dev \
 && sudo -u fluent gem install \
        fluent-plugin-aerospike-cluster \
 && sudo -u fluent gem sources --clear-all \
 && apk del .build-deps \
 && rm -rf /var/cache/apk/* \
           /home/fluent/.gem/ruby/2.3.0/cache/*.gem
