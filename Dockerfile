FROM lnl7/nix:2.0

WORKDIR /tmp/z3

COPY default.nix /tmp/z3
COPY z3.cabal /tmp/z3

# Install tools needed by builtins.fetchTarball, and then install all
# dependencies into its own layer, which doesn't change.
RUN nix-env -f '<nixpkgs>' -i gnutar gzip && \
    nix-shell -Q -j2 --run true

COPY . /tmp/build
RUN nix-env -f . -i z3
