# This is an image of a wrapper based on official istio-proxy container.
# Using istio/proxyv2:1.20.2 as the base image
FROM istio/proxyv2:1.20.2

RUN /bin/bash -c "apt update -y \
    && apt install wget unzip -y \
    && apt install librdkafka-dev luarocks -y \
    && luarocks install lua-cjson \
    && echo 'finished installing dependencies'" 

RUN /bin/bash -c "wget https://github.com/akto-api-security/envoy-module/archive/refs/heads/feature/istio.zip \
    && echo 'downloaded module directory' \
    && unzip istio.zip \
    && lua_version=\$(lua -e 'print(_VERSION:match(\"%d+%.%d+\"))') \
    && mv ./envoy-module-feature-istio/rdkafka /usr/local/share/lua/\$lua_version/rdkafka \
    && mv ./envoy-module-feature-istio/aktoModule.lua /usr/local/share/lua/\$lua_version/aktoModule.lua \
    && chmod 777 /usr/local/share/lua/\$lua_version/aktoModule.lua \
    && chmod 777 /usr/local/share/lua/\$lua_version/rdkafka"
