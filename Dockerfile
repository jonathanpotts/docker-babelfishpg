# Build stage
FROM ubuntu:20.04

# Specify babelfish version by using a tag from:
# https://github.com/babelfish-for-postgresql/babelfish-for-postgresql/tags
ARG BABELFISH_VERSION=BABEL_2_3_0__PG_14_6

ENV DEBIAN_FRONTEND=noninteractive
ENV BABELFISH_HOME=/opt/babelfish

# Install build dependencies
RUN apt update && apt install -y --no-install-recommends\
	build-essential flex libxml2-dev libxml2-utils\
	libxslt-dev libssl-dev libreadline-dev zlib1g-dev\
	libldap2-dev libpam0g-dev gettext uuid uuid-dev\
	cmake lld apt-utils libossp-uuid-dev gnulib bison\
	xsltproc icu-devtools libicu66\
	libicu-dev gawk\
	curl openjdk-8-jre openssl\
	g++ libssl-dev python-dev libpq-dev\
	pkg-config libutfcpp-dev\
	gnupg unixodbc-dev net-tools unzip wget python3-dev

# Download babelfish sources
WORKDIR /workplace

ENV BABELFISH_REPO=babelfish-for-postgresql/babelfish-for-postgresql
ENV BABELFISH_URL=https://github.com/${BABELFISH_REPO}
ENV BABELFISH_TAG=${BABELFISH_VERSION}
ENV BABELFISH_FILE=${BABELFISH_VERSION}.tar.gz

RUN wget ${BABELFISH_URL}/releases/download/${BABELFISH_TAG}/${BABELFISH_FILE}
RUN tar -xvzf ${BABELFISH_FILE}

# Set environment variables
ENV PG_SRC=/workplace/${BABELFISH_VERSION}

WORKDIR ${PG_SRC}

ENV PG_CONFIG=${BABELFISH_HOME}/bin/pg_config

# Compile ANTLR 4
ENV ANTLR4_VERSION=4.9.3
ENV ANTLR4_JAVA_BIN=/usr/bin/java
ENV ANTLR4_RUNTIME_LIBRARIES=/usr/include/antlr4-runtime
ENV ANTLR_FILE=antlr-${ANTLR4_VERSION}-complete.jar
ENV ANTLR_EXECUTABLE=/usr/local/lib/${ANTLR_FILE}
ENV ANTLR_CONTRIB=${PG_SRC}/contrib/babelfishpg_tsql/antlr/thirdparty/antlr
ENV ANTLR_RUNTIME=/workplace/antlr4

RUN cp ${ANTLR_CONTRIB}/${ANTLR_FILE} /usr/local/lib

WORKDIR /workplace

ENV ANTLR_DOWNLOAD=http://www.antlr.org/download
ENV ANTLR_CPP_SOURCE=antlr4-cpp-runtime-${ANTLR4_VERSION}-source.zip

RUN wget ${ANTLR_DOWNLOAD}/${ANTLR_CPP_SOURCE}
RUN unzip -d ${ANTLR_RUNTIME} ${ANTLR_CPP_SOURCE}

WORKDIR ${ANTLR_RUNTIME}/build

RUN cmake .. -D\
	ANTLR_JAR_LOCATION=${ANTLR_EXECUTABLE}\
	-DCMAKE_INSTALL_PREFIX=/usr/local -DWITH_DEMO=True
RUN make && make install

# Build modified PostgreSQL for Babelfish
WORKDIR ${PG_SRC}

RUN ./configure CFLAGS="-ggdb"\
	--prefix=${BABELFISH_HOME}/\
	--enable-debug\
	--with-ldap\
	--with-libxml\
	--with-pam\
	--with-uuid=ossp\
	--enable-nls\
	--with-libxslt\
	--with-icu\
	--with-openssl\
	--with-python
					
RUN make DESTDIR=${BABELFISH_HOME}/ 2>error.txt && make install

WORKDIR ${PG_SRC}/contrib

RUN make && make install

# Compile the ANTLR parser generator
RUN cp /usr/local/lib/libantlr4-runtime.so.${ANTLR4_VERSION}\
	${BABELFISH_HOME}/lib
					 
WORKDIR ${PG_SRC}/contrib/babelfishpg_tsql/antlr 
RUN cmake -Wno-dev .
RUN make all

# Compile the contrib modules and build Babelfish
WORKDIR ${PG_SRC}/contrib/babelfishpg_common
RUN make && make PG_CONFIG=${PG_CONFIG} install

WORKDIR ${PG_SRC}/contrib/babelfishpg_money
RUN make && make PG_CONFIG=${PG_CONFIG} install

WORKDIR ${PG_SRC}/contrib/babelfishpg_tds
RUN make && make PG_CONFIG=${PG_CONFIG} install

WORKDIR ${PG_SRC}/contrib/babelfishpg_tsql
RUN make && make PG_CONFIG=${PG_CONFIG} install

# Run stage
FROM ubuntu:20.04
ENV DEBIAN_FRONTEND=noninteractive
ENV BABELFISH_HOME=/opt/babelfish

# Copy binaries to run stage
WORKDIR ${BABELFISH_HOME}
COPY --from=0 ${BABELFISH_HOME} .

# Install runtime dependencies
RUN apt update && apt install -y --no-install-recommends\
	libssl1.1 openssl libldap-2.4-2 libxml2 libpam0g uuid libossp-uuid16\
	libxslt1.1 libicu66 libpq5 unixodbc python3-dev

# Enable data volume
ENV BABELFISH_DATA=/data/babelfish
RUN mkdir /data
VOLUME /data
RUN mkdir ${BABELFISH_DATA}

# Create postgres user
RUN adduser postgres --home ${BABELFISH_DATA}
RUN chown postgres ${BABELFISH_DATA}
RUN chmod 750 ${BABELFISH_DATA}

# Change to postgres user
USER postgres

# Expose ports
EXPOSE 1433 5432

# Set entry point
COPY start.sh /
ENTRYPOINT [ "/start.sh" ]
