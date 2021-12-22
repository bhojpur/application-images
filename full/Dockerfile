# Ara does not supports ARG TRIGGER_REBUILD=2
FROM bhojpur/platform-base:latest

RUN echo "ws full starts"

### Install C/C++ compiler and associated tools ###
LABEL ara/layer=lang-c
LABEL ara/test=tests/lang-c.yaml
USER root
# Ara does not rebuild a layer until one of its lines are changed. Increase this counter to rebuild this layer.
ENV TRIGGER_REBUILD=3
RUN curl -o /var/lib/apt/ara-marks/llvm.gpg -fsSL https://apt.llvm.org/llvm-snapshot.gpg.key \
    && apt-key add /var/lib/apt/ara-marks/llvm.gpg \
    && echo "deb https://apt.llvm.org/focal/ llvm-toolchain-focal main" >> /etc/apt/sources.list.d/llvm.list \
    && install-packages \
        clang \
        clangd \
        clang-format \
        clang-tidy \
        gdb \
        lld

### Apache, PHP and Nginx ###
LABEL ara/layer=tool-nginx
LABEL ara/test=tests/lang-php.yaml
USER root
ENV TRIGGER_REBUILD=4
RUN add-apt-repository -y ppa:ondrej/php \
    && install-packages \
        apache2 \
        nginx \
        nginx-extras \
        composer \
        php8.0 \
        php8.0-dev \
        php8.0-bcmath \
        php8.0-ctype \
        php8.0-curl \
        php8.0-gd \
        php8.0-intl \
        php8.0-mbstring \
        php8.0-mysql \
        php8.0-pgsql \
        php8.0-sqlite3 \
        php8.0-tokenizer \
        php8.0-xml \
        php8.0-zip \
    && mkdir -p /var/run/nginx \
    && ln -s /etc/apache2/mods-available/rewrite.load /etc/apache2/mods-enabled/rewrite.load \
    && chown -R bhojpur:bhojpur /etc/apache2 /var/run/apache2 /var/lock/apache2 /var/log/apache2 \
    && chown -R bhojpur:bhojpur /etc/nginx /var/run/nginx /var/lib/nginx/ /var/log/nginx/
COPY --chown=bhojpur:bhojpur apache2/ /etc/apache2/
COPY --chown=bhojpur:bhojpur nginx /etc/nginx/

## The directory relative to your git repository that will be served by Apache / Nginx
ENV APACHE_DOCROOT_IN_REPO="public"
ENV NGINX_DOCROOT_IN_REPO="public"

### Homebrew ###
LABEL ara/layer=tool-brew
LABEL ara/test=tests/tool-brew.yaml
USER bhojpur
# Ara does not rebuild a layer until one of its lines are changed. Increase this counter to rebuild this layer.
ENV TRIGGER_BREW_REBUILD=5
RUN mkdir ~/.cache && /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
ENV PATH=$PATH:/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin/
ENV MANPATH="$MANPATH:/home/linuxbrew/.linuxbrew/share/man"
ENV INFOPATH="$INFOPATH:/home/linuxbrew/.linuxbrew/share/info"
ENV HOMEBREW_NO_AUTO_UPDATE=1

RUN sudo apt remove -y cmake \
    && brew install cmake

### Go ###
LABEL ara/layer=lang-go
LABEL ara/test=tests/lang-go.yaml
USER bhojpur
ENV GO_VERSION=1.17.3
ENV GOPATH=$HOME/go-packages
ENV GOROOT=$HOME/go
ENV PATH=$GOROOT/bin:$GOPATH/bin:$PATH
RUN curl -fsSL https://storage.googleapis.com/golang/go$GO_VERSION.linux-amd64.tar.gz | tar xzs && \
# install VS Code Go tools for use with gopls as per https://github.com/golang/vscode-go/blob/master/docs/tools.md
# also https://github.com/golang/vscode-go/blob/27bbf42a1523cadb19fad21e0f9d7c316b625684/src/goTools.ts#L139
    go get -v \
        github.com/uudashr/gopkgs/cmd/gopkgs@v2 \
        github.com/ramya-rao-a/go-outline \
        github.com/cweill/gotests/gotests \
        github.com/fatih/gomodifytags \
        github.com/josharian/impl \
        github.com/haya14busa/goplay/cmd/goplay \
        github.com/go-delve/delve/cmd/dlv \
        github.com/golangci/golangci-lint/cmd/golangci-lint && \
    GO111MODULE=on go get -v \
        golang.org/x/tools/gopls@v0.7.3 && \
    sudo rm -rf $GOPATH/src $GOPATH/pkg /home/bhojpur/.cache/go /home/bhojpur/.cache/go-build
# user Go packages
ENV GOPATH=/application/go
ENV PATH=/application/go/bin:$PATH

### Java ###
## Place '.gradle' and 'm2-repository' in /application because (1) that's a fast volume, (2) it survives application-restarts and (3) it can be warmed-up by pre-builds.
LABEL ara/layer=lang-java
LABEL ara/test=tests/lang-java.yaml
USER bhojpur
RUN curl -fsSL "https://get.sdkman.io" | bash \
 && bash -c ". /home/bhojpur/.sdkman/bin/sdkman-init.sh \
             && sdk install java 11.0.13.fx-zulu \
             && sdk install gradle \
             && sdk install maven \
             && sdk flush archives \
             && sdk flush temp \
             && mkdir /home/bhojpur/.m2 \
             && printf '<settings>\n  <localRepository>/application/m2-repository/</localRepository>\n</settings>\n' > /home/bhojpur/.m2/settings.xml \
             && echo 'export SDKMAN_DIR=\"/home/bhojpur/.sdkman\"' >> /home/bhojpur/.bashrc.d/99-java \
             && echo '[[ -s \"/home/bhojpur/.sdkman/bin/sdkman-init.sh\" ]] && source \"/home/bhojpur/.sdkman/bin/sdkman-init.sh\"' >> /home/bhojpur/.bashrc.d/99-java"
# above, we are adding the sdkman init to .bashrc (executing sdkman-init.sh does that), because one is executed on interactive shells, the other for non-interactive shells (e.g. plugin-host)
ENV GRADLE_USER_HOME=/application/.gradle/

### Node.js ###
LABEL ara/layer=lang-node
LABEL ara/test=tests/lang-node.yaml
USER bhojpur
ENV NODE_VERSION=16.13.0
ENV TRIGGER_REBUILD=1
RUN curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | PROFILE=/dev/null bash \
    && bash -c ". .nvm/nvm.sh \
        && nvm install $NODE_VERSION \
        && nvm alias default $NODE_VERSION \
        && npm install -g typescript yarn node-gyp" \
    && echo ". ~/.nvm/nvm-lazy.sh"  >> /home/bhojpur/.bashrc.d/50-node
# above, we are adding the lazy nvm init to .bashrc, because one is executed on interactive shells, the other for non-interactive shells (e.g. plugin-host)
COPY --chown=bhojpur:bhojpur nvm-lazy.sh /home/bhojpur/.nvm/nvm-lazy.sh
ENV PATH=$PATH:/home/bhojpur/.nvm/versions/node/v${NODE_VERSION}/bin

### Python ###
LABEL ara/layer=lang-python
LABEL ara/test=tests/lang-python.yaml
USER bhojpur
RUN sudo install-packages python3-pip

ENV PATH=$HOME/.pyenv/bin:$HOME/.pyenv/shims:$PATH
RUN curl -fsSL https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer | bash \
    && { echo; \
        echo 'eval "$(pyenv init -)"'; \
        echo 'eval "$(pyenv virtualenv-init -)"'; } >> /home/bhojpur/.bashrc.d/60-python \
    && pyenv update \
    && pyenv install 3.8.12 \
    && pyenv global 3.8.12 \
    && python3 -m pip install --no-cache-dir --upgrade pip \
    && python3 -m pip install --no-cache-dir --upgrade \
        setuptools wheel virtualenv pipenv pylint rope flake8 \
        mypy autopep8 pep8 pylama pydocstyle bandit notebook \
        twine \
    && sudo rm -rf /tmp/*
ENV PIP_USER=no
ENV PIPENV_VENV_IN_PROJECT=true
ENV PYTHONUSERBASE=/application/.pip-modules
ENV PATH=$PYTHONUSERBASE/bin:$PATH

### Ruby ###
LABEL ara/layer=lang-ruby
LABEL ara/test=tests/lang-ruby.yaml
USER bhojpur
RUN curl -fsSL https://rvm.io/mpapis.asc | gpg --import - \
    && curl -fsSL https://rvm.io/pkuczynski.asc | gpg --import - \
    && curl -fsSL https://get.rvm.io | bash -s stable \
    && bash -lc " \
        rvm requirements \
        && rvm install 2.7.4 \
        && rvm use 2.7.4 --default \
        && rvm rubygems current \
        && gem install bundler --no-document \
        && gem install solargraph --no-document" \
    && echo '[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*' >> /home/bhojpur/.bashrc.d/70-ruby
RUN echo "rvm_gems_path=/application/.rvm" > ~/.rvmrc

ENV GEM_HOME=/application/.rvm
ENV GEM_PATH=$GEM_HOME:$GEM_PATH
ENV PATH=/application/.rvm/bin:$PATH

### Rust ###
LABEL ara/layer=lang-rust
LABEL ara/test=tests/lang-rust.yaml
USER bhojpur
RUN cp /home/bhojpur/.profile /home/bhojpur/.profile_orig && \
    curl -fsSL https://sh.rustup.rs | sh -s -- -y --profile minimal --default-toolchain 1.56.1 \
    && .cargo/bin/rustup component add \
        rls \
        rust-analysis \
        rust-src \
        rustfmt \
    && .cargo/bin/rustup completions bash | sudo tee /etc/bash_completion.d/rustup.bash-completion > /dev/null \
    && .cargo/bin/rustup completions bash cargo | sudo tee /etc/bash_completion.d/rustup.cargo-bash-completion > /dev/null \
    && grep -v -F -x -f /home/bhojpur/.profile_orig /home/bhojpur/.profile > /home/bhojpur/.bashrc.d/80-rust
ENV PATH=$PATH:$HOME/.cargo/bin
# TODO: setting CARGO_HOME to /application/.cargo avoids manual updates. Remove after full application backups are GA.
ENV CARGO_HOME=/application/.cargo
ENV PATH=$CARGO_HOME/bin:$PATH

RUN sudo mkdir -p $CARGO_HOME \
    && sudo chown -R bhojpur:bhojpur $CARGO_HOME

RUN bash -lc "cargo install cargo-watch cargo-edit cargo-tree cargo-applications"

### Clojure ###
LABEL ara/layer=lang-clojure
LABEL ara/test=tests/lang-clojure.yaml
ENV TRIGGER_REBUILD=1
ENV CLOJURE_VERSION=1.10.3.1029
USER root
RUN install-packages rlwrap
RUN curl https://download.clojure.org/install/linux-install-$CLOJURE_VERSION.sh -o /tmp/linux-install-$CLOJURE_VERSION.sh \
    && chmod +x /tmp/linux-install-$CLOJURE_VERSION.sh \
    && /tmp/linux-install-$CLOJURE_VERSION.sh \
    && rm /tmp/linux-install-$CLOJURE_VERSION.sh

### Docker ###
LABEL ara/layer=tool-docker
LABEL ara/test=tests/tool-docker.yaml
USER root
ENV TRIGGER_REBUILD=3
# https://docs.docker.com/engine/install/ubuntu/
RUN curl -o /var/lib/apt/ara-marks/docker.gpg -fsSL https://download.docker.com/linux/ubuntu/gpg \
    && apt-key add /var/lib/apt/ara-marks/docker.gpg \
    && add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
    && install-packages docker-ce docker-ce-cli containerd.io

RUN curl -o /usr/bin/slirp4netns -fsSL https://github.com/rootless-containers/slirp4netns/releases/download/v1.1.12/slirp4netns-$(uname -m) \
    && chmod +x /usr/bin/slirp4netns

RUN curl -o /usr/local/bin/docker-compose -fsSL https://github.com/docker/compose/releases/download/1.29.2/docker-compose-Linux-x86_64 \
    && chmod +x /usr/local/bin/docker-compose

# https://github.com/wagoodman/dive
RUN curl -o /tmp/dive.deb -fsSL https://github.com/wagoodman/dive/releases/download/v0.10.0/dive_0.10.0_linux_amd64.deb \
    && apt install /tmp/dive.deb \
    && rm /tmp/dive.deb

### Install Tailscale ###
LABEL ara/layer=tool-tailscale
LABEL ara/test=tests/tool-tailscale.yaml
USER root
# Ara does not rebuild a layer until one of its lines are changed. Increase this counter to rebuild this layer.
ENV TRIGGER_REBUILD=1

RUN curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/focal.gpg | sudo apt-key add - \
    && curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/focal.list | sudo tee /etc/apt/sources.list.d/tailscale.list \
    && apt-get update \
    && apt-get install -y tailscale

### Install nix ###
LABEL ara/layer=tool-nix
LABEL ara/test=tests/tool-nix.yaml
ENV NIX_VERSION=2.3.14
# Ara does not rebuild a layer until one of its lines are changed. Increase this counter to rebuild this layer.
ENV TRIGGER_REBUILD=1

USER root
RUN addgroup --system nixbld \
  && adduser bhojpur nixbld \
  && for i in $(seq 1 30); do useradd -ms /bin/bash nixbld$i && adduser nixbld$i nixbld; done \
  && mkdir -m 0755 /nix && chown bhojpur /nix \
  && mkdir -p /etc/nix && echo 'sandbox = false' > /etc/nix/nix.conf

# Install Nix
USER bhojpur
ENV USER bhojpur
WORKDIR /home/bhojpur

RUN curl https://nixos.org/releases/nix/nix-$NIX_VERSION/install | sh

RUN echo '. /home/bhojpur/.nix-profile/etc/profile.d/nix.sh' >> /home/bhojpur/.bashrc
RUN mkdir -p /home/bhojpur/.config/nixpkgs && echo '{ allowUnfree = true; }' >> /home/bhojpur/.config/nixpkgs/config.nix

# Install cachix
RUN . /home/bhojpur/.nix-profile/etc/profile.d/nix.sh \
  && nix-env -iA cachix -f https://cachix.org/api/v1/install \
  && cachix use cachix

### Prologue (built across all layers) ###
LABEL ara/layer=ara-prologue
LABEL ara/test=tests/prologue.yaml
USER root
RUN curl -o /usr/bin/ara-util -fsSL https://github.com/bhojpur/ara/releases/download/v0.0.3/ara-util_0.0.3_Linux_x86_64 \
    && chmod +x /usr/bin/ara-util
# merge dpkg status files
RUN cp /var/lib/dpkg/status /tmp/dpkg-status \
    && for i in $(ls /var/lib/apt/ara-marks/*.status); do /usr/bin/ara-util debian dpkg-status-merge /tmp/dpkg-status $i > /tmp/dpkg-status; done \
    && cp -f /var/lib/dpkg/status /var/lib/dpkg/status-old \
    && cp -f /tmp/dpkg-status /var/lib/dpkg/status
# correct the path
ENV PATH=$PATH:/usr/games
# merge GPG keys for trusted APT repositories
RUN for i in $(ls /var/lib/apt/ara-marks/*.gpg); do apt-key add "$i"; done
# copy tests to enable the self-test of this image
COPY tests /var/lib/ara/tests

# share env
RUN echo "PATH="${PATH}"" | sudo tee /etc/environment

USER bhojpur
