#!/bin/bash
set -e

# Default TAG to unstable if not set
TAG="${TAG:-unstable}"
# Default CLEAN to true for backward compatibility
CLEAN="${CLEAN:-true}"
IMAGE_NAME="nitella-builder-$TAG"

# Capture git info on host
echo "Capturing git version info..."
HOST_COMMIT_HASH=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")
HOST_COMMIT_DATE=$(git log -1 --format='%cd' --date=format:'%Y-%m-%dT%H:%M:%SZ' 2>/dev/null || echo $(date +"%Y-%m-%dT%H:%M:%SZ"))
HOST_UID=$(id -u)
HOST_GID=$(id -g)

echo "Hash: $HOST_COMMIT_HASH"
echo "Date: $HOST_COMMIT_DATE"
echo "Clean build: $CLEAN"

# Check for local NDK to mount
HOST_NDK_PATH="$HOME/Android/Sdk/ndk"
NDK_MOUNT_ARG=""
if [ -d "$HOST_NDK_PATH" ]; then
    echo "Found local NDK at $HOST_NDK_PATH. Mounting to container..."
    NDK_MOUNT_ARG="-v $HOST_NDK_PATH:/opt/android-sdk/ndk"
fi

# Check for local Go module cache to mount
HOST_GO_MOD_CACHE_PATH="$HOME/go/pkg/mod"
GO_MOD_CACHE_MOUNT_ARG=""
if [ -d "$HOST_GO_MOD_CACHE_PATH" ]; then
    echo "Found local Go module cache at $HOST_GO_MOD_CACHE_PATH. Mounting to container..."
    GO_MOD_CACHE_MOUNT_ARG="-v $HOST_GO_MOD_CACHE_PATH:/go/pkg/mod"
fi

# Check for local Android SDK platforms to mount
HOST_ANDROID_PLATFORMS_PATH="$HOME/Android/Sdk/platforms"
ANDROID_PLATFORMS_MOUNT_ARG=""
if [ -d "$HOST_ANDROID_PLATFORMS_PATH" ]; then
    echo "Found local Android SDK platforms at $HOST_ANDROID_PLATFORMS_PATH. Mounting to container..."
    ANDROID_PLATFORMS_MOUNT_ARG="-v $HOST_ANDROID_PLATFORMS_PATH:/opt/android-sdk/platforms"
fi

# 1. Build the Docker image
echo "Building Docker image ($IMAGE_NAME)..."
docker build -f Dockerfile.android -t $IMAGE_NAME .

# 2. Run the build inside the container
echo "Running build in Docker..."

echo "Building with TAG: $TAG"

# Docker implementation of caching using Named Volumes
GO_BUILD_CACHE_VOLUME="nitella-go-build-cache"
GRADLE_CACHE_VOLUME="nitella-gradle-cache"

echo "Using Docker Named Volumes for caching:"
echo "  - Go Build Cache: $GO_BUILD_CACHE_VOLUME"
echo "  - Gradle Cache:   $GRADLE_CACHE_VOLUME"

docker run --rm --network host -v "$(pwd):/host_repo" $NDK_MOUNT_ARG $GO_MOD_CACHE_MOUNT_ARG $ANDROID_PLATFORMS_MOUNT_ARG \
    -v "$GO_BUILD_CACHE_VOLUME:/root/.cache/go-build" \
    -v "$GRADLE_CACHE_VOLUME:/root/.gradle" \
    -e HOST_COMMIT_HASH="$HOST_COMMIT_HASH" \
    -e HOST_COMMIT_DATE="$HOST_COMMIT_DATE" \
    -e HOST_UID="$HOST_UID" \
    -e HOST_GID="$HOST_GID" \
    -e TAG="$TAG" \
    -e CLEAN="$CLEAN" \
    -w /app $IMAGE_NAME /bin/bash -c '
    set -e
    git config --global --add safe.directory /app
    
    echo "--- Syncing source code to isolated build environment ---"
    rsync -a \
        --exclude=".git" \
        --exclude="**/build/" \
        --exclude="**/.gradle/" \
        --exclude="**/.dart_tool/" \
        --exclude="**/node_modules/" \
        /host_repo/ /app/

    echo "--- Applying patches ---"
    if [ -f "patches/fix-anet-go124.patch" ]; then
        echo "Applying fix-anet-go124.patch..."
        patch -p1 < patches/fix-anet-go124.patch
    fi

    # NDK Configuration
    NDK_ROOT="/opt/android-sdk/ndk/23.1.7779620"
    export NDK_HOME="$NDK_ROOT"
    
    # Define paths
    ANDROID_CC_ARM="$NDK_ROOT/toolchains/llvm/prebuilt/linux-x86_64/bin/armv7a-linux-androideabi21-clang"
    ANDROID_CC_ARM64="$NDK_ROOT/toolchains/llvm/prebuilt/linux-x86_64/bin/aarch64-linux-android21-clang"
    ANDROID_CC_X86_64="$NDK_ROOT/toolchains/llvm/prebuilt/linux-x86_64/bin/x86_64-linux-android21-clang"
    ANDROID_STRIP_ARM="$NDK_ROOT/toolchains/llvm/prebuilt/linux-x86_64/bin/llvm-strip"
    ANDROID_STRIP_ARM64="$NDK_ROOT/toolchains/llvm/prebuilt/linux-x86_64/bin/llvm-strip"
    
    # Export variables
    export COMMIT_HASH="$HOST_COMMIT_HASH"
    export COMMIT_DATE="$HOST_COMMIT_DATE"
    
    if [ "$CLEAN" = "true" ]; then
        echo "--- Running flutter clean (CLEAN=true) ---"
        cd app && flutter clean && cd ..
    fi
    
    echo "--- Installing dependencies (flutter pub get) ---"
    cd app && flutter pub get && cd ..
    
    echo "--- Running pre-build steps (make pre) ---"
    make pre

    echo "--- Building Protobufs (make proto) ---"
    make proto
    
    echo "--- Building Shared Libraries (make shared_android) ---"
    make shared_android \
        ANDROID_CC_ARM="$ANDROID_CC_ARM" \
        ANDROID_CC_ARM64="$ANDROID_CC_ARM64" \
        ANDROID_CC_X86_64="$ANDROID_CC_X86_64" \
        ANDROID_STRIP_ARM="$ANDROID_STRIP_ARM" \
        ANDROID_STRIP_ARM64="$ANDROID_STRIP_ARM64" \
        COMMIT_HASH="$HOST_COMMIT_HASH" \
        COMMIT_DATE="$COMMIT_DATE"
    
    echo "--- Cleaning stale Gradle locks ---"
    rm -rf app/android/.gradle
    
    # Enable Gradle build cache
    export GRADLE_OPTS="-Dorg.gradle.caching=true -Dorg.gradle.parallel=true"

    echo "--- Building Flutter AppBundle (make build_android) ---"
    cd app && flutter pub get && cd ..

    make build_android \
        COMMIT_HASH="$HOST_COMMIT_HASH" \
        COMMIT_DATE="$HOST_COMMIT_DATE" \
        TAG="$TAG"

    echo "--- Copying artifacts back to host ---"
    mkdir -p /host_repo/app/build/app/outputs/bundle/release/
    mkdir -p /host_repo/debug-info/$TAG

    find app/build/app/outputs/bundle -name "*.aab" -exec cp {} /host_repo/app/build/app/outputs/bundle/release/ \;
    
    if [ -d "app/debug-info" ]; then
        echo "--- found debug info, copying... ---"
        cp -r app/debug-info/* /host_repo/debug-info/$TAG/
    fi
    
    echo "--- Fixing permissions ---"
    chown -R $HOST_UID:$HOST_GID /host_repo/app/build

    echo "--- Build Complete ---"
'

echo "Done. Check app/build/app/outputs/bundle/release/ for the .aab file."