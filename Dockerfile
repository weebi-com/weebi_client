# Build stage
FROM debian:bookworm-slim AS build-env

# Install dependencies for Flutter, including the Linux desktop toolchain that
# `flutter doctor` validates in Google Cloud Build.
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        clang \
        cmake \
        curl \
        git \
        libgtk-3-dev \
        libglu1-mesa \
        ninja-build \
        pkg-config \
        unzip \
        xz-utils \
        zip \
    && rm -rf /var/lib/apt/lists/*

ARG FLUTTER_SDK=/usr/local/flutter
ARG FLUTTER_VERSION=3.29.3
ARG APP=/app

RUN git clone --depth 1 --branch "$FLUTTER_VERSION" https://github.com/flutter/flutter.git "$FLUTTER_SDK"

ENV PATH="$FLUTTER_SDK/bin:$FLUTTER_SDK/bin/cache/dart-sdk/bin:${PATH}"

RUN flutter doctor -v
RUN flutter config --enable-web

WORKDIR $APP
COPY . .

# Link local packages declared in melos.yaml before building the web app.
RUN dart pub get
RUN dart run melos bootstrap

WORKDIR $APP/webapp
RUN flutter clean && flutter pub get
RUN flutter build web --verbose

# Runtime stage
FROM nginx:alpine

COPY webapp/nginx.conf /etc/nginx/templates/default.conf.template
COPY webapp/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

COPY --from=build-env /app/webapp/build/web/ /usr/share/nginx/html/

EXPOSE 8080

ENV LOCALE="fr"

ENTRYPOINT ["/entrypoint.sh"]
