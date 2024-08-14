FROM cgr.dev/chainguard/gcc-glibc:latest-dev
WORKDIR /home/build
COPY wolfssl-5.7.2-gplv3-fips-ready.zip .
COPY wolfprov-1.0.0.zip .
RUN apk update
RUN apk add autoconf automake bash build-base busybox libtool file openssl-dev openssl
RUN unzip -q wolfssl-5.7.2-gplv3-fips-ready.zip
WORKDIR /home/build/wolfssl-5.7.2-gplv3-fips-ready
RUN autoreconf -fiv
ENV CFLAGS="-O2 -Wall -fno-omit-frame-pointer -mno-omit-leaf-frame-pointer -march=x86-64-v2 -mtune=broadwell"
ENV CPPFLAGS="-O2 -Wp,-D_FORTIFY_SOURCE=3 -Wp,-D_GLIBCXX_ASSERTIONS -DECC_MIN_KEY_SZ=192 -DHAVE_AES_ECB -DHAVE_PUBLIC_FFDHE -DWC_RSA_NO_PADDING -DWOLFSSL_AES_DIRECT -DWOLFSSL_DH_EXTRA -DWOLFSSL_PSS_LONG_SALT -DWOLFSSL_PSS_SALT_LEN_DISCOVER -DWOLFSSL_PUBLIC_MP"
RUN ./configure --prefix=/usr --enable-aesccm --enable-aesctr --enable-aeskeywrap --enable-base16 --enable-certgen --enable-cmac --enable-compkey --enable-des3 --enable-enckeys --enable-keygen --enable-opensslcoexist --enable-sha --enable-x963kdf --enable-aesni --enable-intelasm --enable-fips=ready
RUN make
RUN ./fips-hash.sh
RUN make install
WORKDIR /home/build
RUN unzip -q wolfprov-1.0.0.zip
WORKDIR /home/build/wolfprov-1.0.0
RUN autoreconf -fiv
RUN ./configure --prefix=/usr
RUN make
RUN make install
RUN ln -s ../libwolfprov.so.0 /usr/lib/ossl-modules/fips.so
WORKDIR /home/build
# Reference outputs
RUN openssl version -a
RUN openssl list -providers --verbose
RUN openssl list -all-algorithms
# Wolfprovider usage starts here
COPY openssl.cnf .
ENV OPENSSL_CONF=/home/build/openssl.cnf
# Good
RUN openssl list -providers --verbose
# Good
RUN openssl list -all-algorithms

# Crash note the Segmentation fault core dumped
RUN sh -c 'openssl list -all-algorithms --verbose >/dev/null' || true

# Note 80EB9567897C0000:error:0308010C:digital envelope routines:inner_evp_generic_fetch:unsupported:crypto/evp/evp_fetch.c:355:Global default library context, Algorithm (KMAC-128 : 0), Properties (<null>)
RUN sh -c 'openssl speed -seconds 1' || true
