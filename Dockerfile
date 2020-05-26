FROM swift:5.2-xenial

# Install Curl and node package repository
RUN apt-get update && apt-get install -y curl
RUN curl -sL https://deb.nodesource.com/setup_12.x | bash -

# TODO: Workaround for https://bugs.swift.org/browse/SR-10344
# (see also https://forums.swift.org/t/lldb-install-precludes-installing-python-in-image/24040)
RUN [ -d /usr/lib/python2.7/site-packages ] && mv /usr/lib/python2.7/site-packages /usr/lib/python2.7/dist-packages && ln -s dist-packages /usr/lib/python2.7/site-packages

# Install native dependencies
RUN apt-get update && apt-get install -y \
    nodejs \
    libopus-dev \
    libsodium-dev \
    libssl-dev \
    libcairo2-dev \
    poppler-utils \
    maxima \
    cabal-install \
    libsqlite3-dev

RUN cabal update && cabal install happy
RUN cabal update && cabal install mueval pointfree-1.1.1.6 pointful

# Add Cabal to PATH
ENV PATH /.cabal/bin:/root/.cabal/bin:$PATH

# Copy application
WORKDIR /d2
COPY . .

# Install Node dependencies
WORKDIR /d2/Node
RUN ./install-all

# Build
WORKDIR /d2
RUN swift build -c release

CMD ["./.build/release/D2"]
