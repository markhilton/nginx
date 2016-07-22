#!/bin/bash


#
# install dependency packages
#
YUM_CMD=$(which yum)
APT_GET_CMD=$(which apt-get)
GIT=$(which git)

if [ -e "$YUM_CMD" ]; then
    yum -y install gcc-c++ pcre-devel zlib-devel make unzip openssl-devel
elif [ -e "$APT_GET_CMD" ]; then
    apt-get -y install build-essential zlib1g-dev libpcre3 libpcre3-dev unzip libssl-dev libgeoip-dev libgeoip1
else
    echo "error cannot find package manager for this linux distribution"
    exit 1;
fi

 

#
# clone or update git repositories
#
cd "$(dirname "$0")"

CURDIR=`pwd`

declare -A DEPENDENCIES

DEPENDENCIES[nginx]=https://github.com/nginx/nginx.git
DEPENDENCIES[ngx_pagespeed]=https://github.com/pagespeed/ngx_pagespeed.git
DEPENDENCIES[headers-more-nginx-module]=https://github.com/openresty/headers-more-nginx-module.git
DEPENDENCIES[ngx_http_substitutions_filter_module]=https://github.com/yaoweibin/ngx_http_substitutions_filter_module.git

for i in ${!DEPENDENCIES[@]}; do
    # update or clone dependiencies
    if [ -d "$i" ]; then
    	echo "Updating $i"
	cd $i
        $GIT pull

    # clone repo if not present
    else
    	echo "Cloning $i"
        $GIT clone ${DEPENDENCIES[$i]}
    fi
done

#
# compile
#
cp ./configure ${CURDIR}/nginx/
cd ${CURDIR}/nginx
cp auto/configure ./

./configure \
--with-http_ssl_module \
--with-http_geoip_module \
--with-http_realip_module \
--with-http_stub_status_module \
--add-module=${CURDIR}/ngx_pagespeed \
--add-module=${CURDIR}/headers-more-nginx-module \
--add-module=${CURDIR}/ngx_http_substitutions_filter_module



