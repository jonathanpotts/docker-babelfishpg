# Build stage
FROM alpine:latest

# Install build dependencies
RUN apk add git icu-dev libxml2-dev openssl openssl-dev python3-dev openjdk8-jre pkgconf \
  perl g++ gcc libc-dev linux-headers make cmake bison flex util-linux-dev \
  && apk add libpq-dev --repository=http://dl-cdn.alpinelinux.org/alpine/edge/main \
  && apk add ossp-uuid-dev --repository=http://dl-cdn.alpinelinux.org/alpine/edge/testing

# Clone babelfish sources
WORKDIR /workplace

RUN git clone https://github.com/babelfish-for-postgresql/postgresql_modified_for_babelfish.git \
  && git clone https://github.com/babelfish-for-postgresql/babelfish_extensions.git

# Build Postgres engine
WORKDIR /workplace/postgresql_modified_for_babelfish

RUN ./configure --without-readline --without-zlib --enable-debug CFLAGS="-ggdb" \
  --with-libxml --with-uuid=ossp --with-icu

RUN make && make install

WORKDIR /workplace/postgresql_modified_for_babelfish/contrib

RUN make && make install

# Build antlr4
WORKDIR /workplace/babelfish_extensions/contrib/babelfishpg_tsql/antlr/thirdparty/antlr/

RUN cp antlr-4.9.2-complete.jar /usr/local/lib

WORKDIR /workplace

RUN wget http://www.antlr.org/download/antlr4-cpp-runtime-4.9.2-source.zip
RUN unzip -d antlr4 antlr4-cpp-runtime-4.9.2-source.zip
RUN mkdir antlr4/build

WORKDIR /workplace/antlr4/build

RUN cmake .. -DANTLR_JAR_LOCATION=/usr/local/lib/antlr-4.9.2-complete.jar -DCMAKE_INSTALL_PREFIX=/usr/local -DWITH_DEMO=True
RUN make && make install
RUN cp /usr/local/lib/libantlr4-runtime.so.4.9.2 /usr/local/pgsql/lib

# Set environment variables for building extensions
ENV PG_CONFIG=/usr/local/pgsql/bin/pg_config
ENV PG_SRC=/workplace/postgresql_modified_for_babelfish
ENV cmake=/usr/bin/cmake

# Build extensions
WORKDIR /workplace/babelfish_extensions/contrib/babelfishpg_money
RUN make && make install

WORKDIR /workplace/babelfish_extensions/contrib/babelfishpg_common
RUN make && make install

WORKDIR /workplace/babelfish_extensions/contrib/babelfishpg_tds
RUN make && make install

WORKDIR /workplace/babelfish_extensions/contrib/babelfishpg_tsql
RUN make && make install

# Run stage
FROM alpine:latest

# Copy binaries to run stage
WORKDIR /usr/local/pgsql
COPY --from=0 /usr/local/pgsql .

# Install runtime dependencies
RUN apk add libxml2 icu openssl libuuid \
  && apk add ossp-uuid --repository=http://dl-cdn.alpinelinux.org/alpine/edge/testing

# Create postgres user
RUN addgroup -S postgres && adduser -S postgres -G postgres

# Enable data volume
RUN mkdir /data
VOLUME /data
RUN mkdir /data/postgres
RUN chown postgres /data/postgres

# Change to postgres user
USER postgres

# Expose ports
EXPOSE 1433 5432

# Set start command
ADD start.sh /
CMD [ "/start.sh" ]
