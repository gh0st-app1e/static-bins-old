
# Creates container with environment similar to github actions.
#FROM muslcc/x86_64:i686-linux-musl
FROM muslcc/x86_64:x86_64-linux-musl
#FROM muslcc/x86_64:arm-linux-musleabihf
#FROM muslcc/x86_64:aarch64-linux-musl

# Emulate github
ENV GITHUB_WORKSPACE=/github
COPY . $GITHUB_WORKSPACE/
RUN mkdir -p "$GITHUB_WORKSPACE" && \
  apk update && \
  apk add nano && \
  apk add python3 perl-parse-yapp rpcgen && \
  sh "$GITHUB_WORKSPACE/build/deps/install_common_deps_alpine" && \
  rm -rf /var/cache/apk/*

# This is required for some builds that require both host and cross compilers.
# Uncomment when testing arm/aarch64 cross-compilation.
#RUN sh "$GITHUB_WORKSPACE/build/deps/install_build_compiler"

ENV PKG_CONFIG_PATH="/x86_64-linux-musl/usr/lib/pkgconfig"

WORKDIR $GITHUB_WORKSPACE/build/targets/
ENTRYPOINT ["bash"]
