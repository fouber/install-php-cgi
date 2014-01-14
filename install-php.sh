#!/bin/bash

# bash -c "$( curl http://fouber.github.io/install-php-cgi/install-php.sh -k )" -o 5.3.5

echo

set -e
trap 'echo Error on line $BASH_SOURCE:$LINENO' ERR
trap 'rm -f $tmp' EXIT

if [ -z $2 ]
then
    PHP_PREFIX="`pwd`/php-linux"
else
    PHP_PREFIX="${2}"
fi

if [ ! -d "${PHP_PREFIX}" ]; then
    mkdir -p "${PHP_PREFIX}"
fi

TEMP="${HOME}/.php-linux"
if [ ! -d "${TEMP}" ]; then
    mkdir -p "${TEMP}"
fi

echo "**************************************"
echo "* Install libxml2 v2.7.8 to ${PHP_PREFIX}"
echo "**************************************"
echo 

cd "${TEMP}"
if [ ! -f "libxml2-2.7.8.tar.gz" ]; then
    ftp -n << !
open xmlsoft.org
user anonymous 123456
binary
cd "libxml2"
get "libxml2-2.7.8.tar.gz"
close
bye
!
fi

echo "**************************************"
echo "* Uncompress libxml2-2.7.8.tar.gz"
echo "**************************************"
echo 

tar zxvf "libxml2-2.7.8.tar.gz"
cd "libxml2-2.7.8"

echo "**************************************"
echo "* Compiling libxml2 ... "
echo "**************************************"
echo 

./configure --prefix=${PHP_PREFIX}
make -j 4 && make install

echo "**************************************"
echo "* libxml2 installed successfully"
echo "**************************************"
echo 

if [ -z $1 ]
then
    PHP_VERSION="5.2.17"
else
    PHP_VERSION="${1}"
fi

echo "**************************************"
echo "* Install php v${PHP_VERSION} to ${PHP_PREFIX}"
echo "**************************************"
echo 

cd "${TEMP}"

wget "http://museum.php.net/php5/php-${PHP_VERSION}.tar.gz"

echo "**************************************"
echo "* Uncompress php-${PHP_VERSION}.tar.gz"
echo "**************************************"
echo 

tar zxvf "php-${PHP_VERSION}.tar.gz"
cd "php-${PHP_VERSION}"

echo "**************************************"
echo "* Compiling php ... "
echo "**************************************"
echo 

./configure --prefix=${PHP_PREFIX} --enable-fastcgi --with-libxml-dir=${PHP_PREFIX} --with-curl --enable-mbstring   --with-zlib
make -j 4 && make install

if [ -e "${PHP_PREFIX}/bin/php-cgi.dSYM" ]
then
    ln -s "${PHP_PREFIX}/bin/php-cgi.dSYM" "${PHP_PREFIX}/bin/php-cgi"
fi

echo "**************************************"
echo "* Add the environment variable "
echo "**************************************"
echo 

sudo ln -s "${PHP_PREFIX}/bin/php-cgi" /usr/local/bin/php-cgi

cd "${PHP_PREFIX}"

php-cgi -v

rm -rf "${TEMP}"
