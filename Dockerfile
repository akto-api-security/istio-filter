# This is an image of a wrapper based on official istio-proxy container.
# Using istio/proxyv2:1.20.2 as the base image
FROM istio/proxyv2:1.20.2

RUN /bin/bash -c "apt update -y \
    && apt install wget unzip -y \
    && apt install librdkafka-dev luarocks -y \
    && luarocks install lua-cjson \
    && echo 'finished installing dependencies'" 

RUN /bin/bash -c "wget https://github.com/akto-api-security/istio-filter/archive/refs/heads/master.zip \
    && echo 'downloaded module directory' \
    && unzip master.zip \
    && lua_version=\$(lua -e 'print(_VERSION:match(\"%d+%.%d+\"))') \
    && mv ./istio-filter-master/rdkafka /usr/local/share/lua/\$lua_version/rdkafka \
    && chmod 777 /usr/local/share/lua/\$lua_version/rdkafka"