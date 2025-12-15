#!/bin/bash
set -e

BINUTILS_VERSION=2.41
GCC_VERSION=13.2.0
PREFIX=$(pwd)/toolchain/install

mkdir -p toolchain/src toolchain/build

cd toolchain/src

wget https://ftp.gnu.org/gnu/binutils/binutils-${BINUTILS_VERSION}.tar.xz
wget https://ftp.gnu.org/gnu/gcc/gcc-${GCC_VERSION}/gcc-${GCC_VERSION}.tar.xz

tar -xf binutils-${BINUTILS_VERSION}.tar.xz
tar -xf gcc-${GCC_VERSION}.tar.xz

cd ../build
mkdir -p binutils gcc

cd binutils
../../src/binutils-${BINUTILS_VERSION}/configure \
  --target=x86_64-elf \
  --prefix=${PREFIX} \
  --with-sysroot \
  --disable-nls \
  --disable-werror

make -j$(nproc)
make install

cd ../gcc
../../src/gcc-${GCC_VERSION}/configure \
  --target=x86_64-elf \
  --prefix=${PREFIX} \
  --disable-nls \
  --enable-languages=c \
  --without-headers

make all-gcc -j$(nproc)
make install-gcc
