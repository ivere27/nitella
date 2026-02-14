# Nitella
# ============================================================================

BUILD_DIR := bin

# Android NDK variables
ANDROID_CC_ARM ?= $(HOME)/android-ndk-r23c/toolchains/llvm/prebuilt/linux-x86_64/bin/armv7a-linux-androideabi21-clang
ANDROID_CC_ARM64 ?= $(HOME)/android-ndk-r23c/toolchains/llvm/prebuilt/linux-x86_64/bin/aarch64-linux-android21-clang
ANDROID_CC_X86_64 ?= $(HOME)/android-ndk-r23c/toolchains/llvm/prebuilt/linux-x86_64/bin/x86_64-linux-android21-clang
ANDROID_STRIP_ARM ?= $(HOME)/android-ndk-r23c/toolchains/llvm/prebuilt/linux-x86_64/bin/llvm-strip
ANDROID_STRIP_ARM64 ?= $(HOME)/android-ndk-r23c/toolchains/llvm/prebuilt/linux-x86_64/bin/llvm-strip

# Build info
COMMIT_HASH ?= $(shell git rev-parse --short HEAD 2>/dev/null || echo "unknown")
COMMIT_DATE ?= $(shell git log -1 --format='%cd' --date=format:'%Y-%m-%dT%H:%M:%SZ' 2>/dev/null || echo $(shell date +"%Y-%m-%dT%H:%M:%SZ"))
BUILD_DATE := $(shell date +"%Y-%m-%dT%H:%M:%SZ")
CURRENT_DIR := $(PWD)
LD_FLAGS := -X main.commitHash=$(COMMIT_HASH) -X main.commitDate=$(COMMIT_DATE) -X main.buildDate=$(BUILD_DATE)
TAGS ?= release
TAG ?= unstable

# Flutter flavoring
ifeq ($(TAG), unstable)
    FLAVOR := unstable
    DART_DEFINES_EXTRA := --dart-define=EXPERIMENTAL=true
else
    FLAVOR := stable
    DART_DEFINES_EXTRA :=
endif

MOBILE_BACKEND_PATH := ./cmd/mobile_backend

.PHONY: all build proto test clean deps fmt lint build_plugin
.PHONY: hub_build hub_server hubctl_build hub_proto hub_test hub_run hub_docker_build hub_docker_run
.PHONY: local_proto local_ffi_proto mobile_build mobile_android mobile_ios mobile_linux app_run
.PHONY: mobile_test mobile_test_e2e mobile_test_e2e_standalone mobile_test_e2e_visible mobile_test_clean
.PHONY: pre shared_android build_android run_android_release run_android_debug release_unstable release_unstable_clean release_stable release_stable_clean

all: build

# ============================================================================
# Build synurang FFI plugin
# ============================================================================

SYNURANG_REPO ?= github.com/ivere27/synurang

build_plugin:
	@echo "Building protoc-gen-synurang-ffi..."
	go install $(SYNURANG_REPO)/cmd/protoc-gen-synurang-ffi@latest
	@echo "Installed to $(shell go env GOPATH)/bin/protoc-gen-synurang-ffi"

# ============================================================================
# Build All
# ============================================================================

build: proto geoip_build mock_build nitellad_build nitella_build hub_build

# ============================================================================
# Proto Generation
# ============================================================================

proto: common_proto proxy_proto process_proto process_ffi_proto geoip_proto geoip_ffi_proto hub_proto local_proto

common_proto:
	@mkdir -p pkg/api/common
	protoc --proto_path=api \
		--go_out=pkg/api --go_opt=paths=source_relative \
		api/common/common.proto

proxy_proto: common_proto
	@mkdir -p pkg/api/proxy
	protoc --proto_path=api \
		--go_out=pkg/api --go_opt=paths=source_relative \
		--go-grpc_out=pkg/api --go-grpc_opt=paths=source_relative \
		api/proxy/proxy.proto

process_proto: common_proto proxy_proto
	@mkdir -p pkg/api/process
	protoc --proto_path=api \
		--go_out=pkg/api --go_opt=paths=source_relative \
		--go-grpc_out=pkg/api --go-grpc_opt=paths=source_relative \
		api/process/process.proto

process_ffi_proto: common_proto proxy_proto process_proto
	@mkdir -p pkg/api/process
	protoc --proto_path=api \
		--plugin=protoc-gen-synurang-ffi=$(shell go env GOPATH)/bin/protoc-gen-synurang-ffi \
		--synurang-ffi_out=pkg/api/process --synurang-ffi_opt=paths=source_relative,services=ProcessControl \
		api/process/process.proto

geoip_ffi_proto: common_proto geoip_proto
	@mkdir -p pkg/api/geoip
	protoc --proto_path=api \
		--plugin=protoc-gen-synurang-ffi=$(shell go env GOPATH)/bin/protoc-gen-synurang-ffi \
		--synurang-ffi_out=pkg/api/geoip --synurang-ffi_opt=paths=source_relative,services=GeoIPService \
		api/geoip/geoip.proto

local_proto: common_proto proxy_proto
	@mkdir -p pkg/api/local
	protoc --proto_path=api \
		--go_out=pkg/api --go_opt=paths=source_relative \
		--go-grpc_out=pkg/api --go-grpc_opt=paths=source_relative \
		api/local/nitella_local.proto

local_ffi_proto: common_proto proxy_proto local_proto
	@mkdir -p pkg/api/local app/lib/local
	protoc --proto_path=api \
		--plugin=protoc-gen-synurang-ffi=$(shell go env GOPATH)/bin/protoc-gen-synurang-ffi \
		--synurang-ffi_out=pkg/api/local --synurang-ffi_opt=paths=source_relative,services=MobileLogicService \
		api/local/nitella_local.proto
	@# Move generated Dart FFI file to Flutter source tree and fix imports
	mv pkg/api/local/nitella_local_ffi.pb.dart app/lib/local/nitella_local_ffi.pb.dart
	sed -i "s|import 'proxy/proxy.pb.dart';|import 'package:nitella_app/proxy/proxy.pb.dart' show ConfigureGeoIPResponse, GetGeoIPStatusResponse, RestartListenersResponse, Rule;|" app/lib/local/nitella_local_ffi.pb.dart
	sed -i "/import 'dart:typed_data';/d" app/lib/local/nitella_local_ffi.pb.dart

# ============================================================================
# Mobile Backend (FFI)
# ============================================================================

mobile_build: proto mobile_android

# Build Android shared libraries (.so) directly for FFI
mobile_android: proto
	@echo "Building nitella Android library and headers..."
	@echo "Building Android shared libraries in parallel..."
	@mkdir -p src
	GOARCH=arm64 GOOS=android CGO_ENABLED=1 CC=$(ANDROID_CC_ARM64) \
		go build -trimpath -tags "$(TAGS)" -ldflags "-s -w $(LD_FLAGS) -extldflags '-Wl,-z,max-page-size=16384'" -o libnitella-android-arm64.so -buildmode=c-shared $(MOBILE_BACKEND_PATH) & \
	GOARCH=arm GOOS=android GOARM=7 CGO_ENABLED=1 CC=$(ANDROID_CC_ARM) \
		go build -trimpath -tags "$(TAGS)" -ldflags "-s -w $(LD_FLAGS)" -o libnitella-android-arm.so -buildmode=c-shared $(MOBILE_BACKEND_PATH) & \
	GOARCH=amd64 GOOS=android CGO_ENABLED=1 CC=$(ANDROID_CC_X86_64) \
		go build -trimpath -tags "$(TAGS)" -ldflags "-s -w $(LD_FLAGS) -extldflags '-Wl,-z,max-page-size=16384'" -o libnitella-android-x86_64.so -buildmode=c-shared $(MOBILE_BACKEND_PATH) & \
	wait
	rm -f libnitella-android-*.h
	mv libnitella-android-arm64.so libnitella-android-arm.so libnitella-android-x86_64.so ./src/
	mkdir -p app/android/app/src/main/jniLibs/arm64-v8a
	cp ./src/libnitella-android-arm64.so app/android/app/src/main/jniLibs/arm64-v8a/libnitella.so
	mkdir -p app/android/app/src/main/jniLibs/armeabi-v7a
	cp ./src/libnitella-android-arm.so app/android/app/src/main/jniLibs/armeabi-v7a/libnitella.so
	mkdir -p app/android/app/src/main/jniLibs/x86_64
	cp ./src/libnitella-android-x86_64.so app/android/app/src/main/jniLibs/x86_64/libnitella.so

mobile_clean:
	rm -rf src/libnitella-android-*.so
	rm -rf app/android/app/src/main/jniLibs/*/libnitella.so

# Linux shared library for Flutter desktop
mobile_linux: proto
	@echo "Building Linux shared library..."
	CGO_ENABLED=1 go build -buildmode=c-shared \
		-ldflags "$(LD_FLAGS)" \
		-o libnitella.so ./cmd/mobile_backend
	@echo "Copying shared library and header to app/linux..."
	cp libnitella.so app/linux/
	cp libnitella.h app/linux/

# Run Flutter desktop app in debug mode
app_run: mobile_linux
	@echo "Running Flutter app..."
	cd app && flutter run -d linux

# ============================================================================
# Android Build & Run (FFI Mode)
# ============================================================================

pre:
	$(MAKE) build_plugin
	cd app && flutter pub get
	dart pub global activate protoc_plugin
	go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
	go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest

build_android:
	cd app && flutter build appbundle --release --obfuscate --split-debug-info=./debug-info --flavor $(FLAVOR) --dart-define=COMMIT_HASH=$(COMMIT_HASH) --dart-define=COMMIT_DATE=$(COMMIT_DATE) --dart-define=BUILD_DATE=$(BUILD_DATE) $(DART_DEFINES_EXTRA)

run_android_release:
	@DEVICE_ID=$$(flutter devices | grep "android" | head -n 1 | awk -F "•" '{print $$2}' | xargs); \
	if [ -z "$$DEVICE_ID" ]; then echo "No Android device found"; exit 1; fi; \
	echo "Using Android device: $$DEVICE_ID"; \
	cd app && flutter run -d $$DEVICE_ID --release --flavor $(FLAVOR) --dart-define=COMMIT_HASH=$(COMMIT_HASH) --dart-define=COMMIT_DATE=$(COMMIT_DATE) --dart-define=BUILD_DATE=$(BUILD_DATE) $(DART_DEFINES_EXTRA)

run_android_debug:
	@DEVICE_ID=$$(flutter devices | grep "android" | head -n 1 | awk -F "•" '{print $$2}' | xargs); \
	if [ -z "$$DEVICE_ID" ]; then echo "No Android device found"; exit 1; fi; \
	echo "Using Android device: $$DEVICE_ID"; \
	cd app && flutter run -d $$DEVICE_ID --debug --flavor $(FLAVOR) --dart-define=COMMIT_HASH=$(COMMIT_HASH) --dart-define=COMMIT_DATE=$(COMMIT_DATE) --dart-define=BUILD_DATE=$(BUILD_DATE) $(DART_DEFINES_EXTRA)

release_unstable:
	TAG=unstable CLEAN=false ./build_with_docker.sh

release_unstable_clean:
	TAG=unstable CLEAN=true ./build_with_docker.sh

release_stable:
	TAG=stable CLEAN=false ./build_with_docker.sh

release_stable_clean:
	TAG=stable CLEAN=true ./build_with_docker.sh

# ============================================================================
# Flutter Proto Generation
# ============================================================================

flutter_proto: flutter_common_proto flutter_proxy_proto flutter_hub_proto flutter_local_proto

flutter_common_proto:
	@mkdir -p app/lib/common
	protoc --proto_path=api \
		--dart_out=grpc:app/lib \
		api/common/common.proto

flutter_proxy_proto: flutter_common_proto
	@mkdir -p app/lib/proxy
	protoc --proto_path=api \
		--dart_out=grpc:app/lib \
		api/proxy/proxy.proto

flutter_hub_proto: flutter_common_proto
	@mkdir -p app/lib/hub
	protoc --proto_path=api \
		--dart_out=grpc:app/lib \
		api/hub/hub_common.proto \
		api/hub/hub_node.proto \
		api/hub/hub_mobile.proto

flutter_local_proto: flutter_common_proto flutter_proxy_proto
	@mkdir -p app/lib/local
	protoc --proto_path=api \
		--dart_out=grpc:app/lib \
		api/local/nitella_local.proto

flutter_clean:
	rm -f app/lib/common/*.pb*.dart
	rm -f app/lib/proxy/*.pb*.dart
	rm -f app/lib/hub/*.pb*.dart
	rm -f app/lib/local/*.pb*.dart

# ============================================================================
# Test
# ============================================================================

test:
	go test -v ./...

# ============================================================================
# Mobile Integration Tests
# ============================================================================

# Run full E2E tests (Mobile -> Hub -> Node -> Backend)
mobile_test_e2e:
	@echo "============================================"
	@echo "Running Full E2E Integration Tests"
	@echo "============================================"
	./scripts/run_full_e2e_test.sh

# Run E2E tests in standalone mode (faster, no Hub relay)
mobile_test_e2e_standalone:
	@echo "============================================"
	@echo "Running E2E Tests (Standalone Mode)"
	@echo "============================================"
	./scripts/run_full_e2e_test.sh --standalone

# Run E2E tests with VISIBLE window (real app opens, you see taps!)
mobile_test_e2e_visible:
	@echo "============================================"
	@echo "Running E2E Tests (VISIBLE MODE)"
	@echo "============================================"
	@echo "The app will open and you'll see automated UI interactions!"
	./scripts/run_full_e2e_test.sh --standalone --visible

# Run Flutter widget tests (no external services needed)
mobile_test:
	cd app && flutter test

# Clean up mobile test artifacts
mobile_test_clean:
	rm -rf .test-tmp .e2e-test-tmp
	rm -rf /tmp/nitella-mobile-test-*

# ============================================================================
# GeoIP Module
# ============================================================================

.PHONY: geoip_build geoip_server geoip_cli geoip_proto geoip_test geoip_test_integration
.PHONY: geoip_run geoip_run_cli geoip_run_config geoip_run_local

geoip_build: geoip_proto geoip_server geoip_cli

geoip_server: geoip_proto
	@mkdir -p $(BUILD_DIR)
	go build -ldflags "$(LD_FLAGS)" -o $(BUILD_DIR)/geoip-server ./cmd/geoip-server

geoip_cli: geoip_proto
	@mkdir -p $(BUILD_DIR)
	go build -ldflags "$(LD_FLAGS)" -o $(BUILD_DIR)/geoip ./cmd/geoip

geoip_proto:
	@mkdir -p pkg/api/common pkg/api/geoip
	protoc --proto_path=api \
		--go_out=pkg/api --go_opt=paths=source_relative \
		--go-grpc_out=pkg/api --go-grpc_opt=paths=source_relative \
		api/common/common.proto api/geoip/geoip.proto

geoip_test:
	go test -v ./pkg/geoip/...

geoip_test_integration: geoip_build
	go test -v ./test/integration/... -run "GeoIP|Lookup" -timeout 120s

# Run geoip server with default settings
geoip_run: geoip_server
	./$(BUILD_DIR)/geoip-server

# Run geoip CLI
# Usage: make geoip_run_cli TOKEN=your-token
TOKEN ?=
geoip_run_cli: geoip_cli
	./$(BUILD_DIR)/geoip $(if $(TOKEN),--token $(TOKEN))

# Run geoip server with config file
# Usage: make geoip_run_config CONFIG=provider.yaml
CONFIG ?= geoip_provider.yaml
geoip_run_config: geoip_server
	./$(BUILD_DIR)/geoip-server --config $(CONFIG)

# Run geoip server with local MaxMind database (optional)
# Auto-detects geoip_provider.yaml if it exists
# Usage: make geoip_run_local CITY_DB=/path/to/city.mmdb ISP_DB=/path/to/isp.mmdb
CITY_DB ?=
ISP_DB ?=
GEOIP_CONFIG ?= geoip_provider.yaml
geoip_run_local: geoip_server
	@if [ -f "$(GEOIP_CONFIG)" ]; then \
		echo "Loading config from $(GEOIP_CONFIG)"; \
		./$(BUILD_DIR)/geoip-server --config $(GEOIP_CONFIG) $(if $(CITY_DB),--city-db $(CITY_DB)) $(if $(ISP_DB),--isp-db $(ISP_DB)); \
	else \
		./$(BUILD_DIR)/geoip-server $(if $(CITY_DB),--city-db $(CITY_DB)) $(if $(ISP_DB),--isp-db $(ISP_DB)); \
	fi

geoip_clean:
	rm -f $(BUILD_DIR)/geoip-server $(BUILD_DIR)/geoip
	rm -f pkg/api/common/*.pb.go
	rm -f pkg/api/geoip/*.pb.go

# ============================================================================
# Nitellad Proxy Daemon
# ============================================================================

.PHONY: nitellad_build nitellad_run nitellad_test nitellad_test_integration nitella_build nitella_run nitellad_docker_build nitellad_docker_run

nitellad_build: proto
	@mkdir -p $(BUILD_DIR)
	go build -ldflags "$(LD_FLAGS)" -o $(BUILD_DIR)/nitellad ./cmd/nitellad

nitella_build: proto
	@mkdir -p $(BUILD_DIR)
	go build -ldflags "$(LD_FLAGS)" -o $(BUILD_DIR)/nitella ./cmd/nitella

nitellad_run: nitellad_build
	./$(BUILD_DIR)/nitellad

# Run nitella CLI
# Usage: make nitella_run TOKEN=xxx ADDR=localhost:50051
NITELLA_ADDR ?= localhost:50051
nitella_run: nitella_build
	./$(BUILD_DIR)/nitella --addr $(NITELLA_ADDR) $(if $(TOKEN),--token $(TOKEN))

nitellad_test:
	go test -v ./pkg/node/...

# Integration tests for nitellad and nitella (requires binaries)
# Tests: standalone mode, YAML config, multiple clients, rule enforcement (block/allow/mock)
# Tests: child process mode (ProcessListener), multiple children, CLI commands
# Mode tests run in both embedded and process mode to verify feature parity
# Only runs proxy-related tests (not geoip server, mock server tests)
nitellad_test_integration: nitellad_build nitella_build mock_build
	@echo "Running nitellad integration tests..."
	go test -v ./test/integration/... -run "Proxy|Rule|Connection|Client|AdminAPI|RateLimit|DDoS|Fallback|GeoIPLookup|ProcessListener|CLI|Mode" -timeout 300s

nitellad_clean:
	rm -f $(BUILD_DIR)/nitellad $(BUILD_DIR)/nitella
	rm -f pkg/api/proxy/*.pb.go

# ============================================================================
# Development
# ============================================================================

deps:
	go mod tidy
	go mod download

fmt:
	go fmt ./...

lint:
	golangci-lint run

# ============================================================================
# Clean
# ============================================================================

clean:
	rm -rf $(BUILD_DIR)
	rm -f pkg/api/hub/*.pb.go

# ============================================================================
# Docker
# ============================================================================

geoip_docker_build:
	docker build -f Dockerfile.geoip -t nitella-geoip .

# Run docker container (includes GeoLite2 databases)
# Usage: make geoip_docker_run
#        make geoip_docker_run GEOIP_TOKEN=my-secret-token
#        make geoip_docker_run GEOIP_CONFIG=my_config.yaml
GEOIP_TOKEN ?=
geoip_docker_run: geoip_docker_build
	@mkdir -p data
	@if [ -f "$(GEOIP_CONFIG)" ]; then \
		echo "Running with config: $(GEOIP_CONFIG)"; \
		docker run -it --rm \
			-p 50052:50052 -p 50053:50053 \
			$(if $(GEOIP_TOKEN),-e GEOIP_TOKEN=$(GEOIP_TOKEN)) \
			-v $(PWD)/$(GEOIP_CONFIG):/app/config/geoip_provider.yaml \
			-v $(PWD)/data:/app/data \
			nitella-geoip --config /app/config/geoip_provider.yaml \
			--db /app/data/geoip_cache.db \
			--city-db /app/db/GeoLite2-City.mmdb \
			--isp-db /app/db/GeoLite2-ASN.mmdb \
			--admin-port 50053; \
	else \
		echo "Running with GeoLite2 databases (no config file)"; \
		docker run -it --rm \
			-p 50052:50052 -p 50053:50053 \
			$(if $(GEOIP_TOKEN),-e GEOIP_TOKEN=$(GEOIP_TOKEN)) \
			-v $(PWD)/data:/app/data \
			nitella-geoip; \
	fi

# Nitellad Docker
nitellad_docker_build:
	docker build -f Dockerfile.nitellad -t nitellad .

# Run nitellad docker container (includes GeoLite2 databases)
# Usage: make nitellad_docker_run
#        make nitellad_docker_run NITELLA_TOKEN=my-secret-token
#        make nitellad_docker_run NITELLA_CONFIG=my_config.yaml BACKEND=host.docker.internal:3000
#        make nitellad_docker_run PROXY_PORT=9090 ADMIN_PORT=50051
NITELLA_TOKEN ?=
NITELLA_CONFIG ?=
PROXY_PORT ?= 8080
ADMIN_PORT ?= 50051
BACKEND ?=
nitellad_docker_run: nitellad_docker_build
	@mkdir -p data
	@if [ -n "$(NITELLA_CONFIG)" ] && [ -f "$(NITELLA_CONFIG)" ]; then \
		echo "Running with config: $(NITELLA_CONFIG)"; \
		docker run -it --rm \
			--add-host=host.docker.internal:host-gateway \
			-p $(PROXY_PORT):8080 -p $(ADMIN_PORT):50051 \
			$(if $(NITELLA_TOKEN),-e NITELLA_TOKEN=$(NITELLA_TOKEN)) \
			-v $(PWD)/$(NITELLA_CONFIG):/app/config/nitella.yaml \
			-v $(PWD)/data:/app/data \
			nitellad --config /app/config/nitella.yaml \
			--db-path /app/data/nitella.db \
			--stats-db /app/data/stats.db \
			--geoip-city /app/db/GeoLite2-City.mmdb \
			--geoip-isp /app/db/GeoLite2-ASN.mmdb \
			--geoip-cache /app/data/geoip_cache.db \
			--admin-port 50051; \
	else \
		echo "Running with default settings (listen :8080, admin :50051, no persistence)"; \
		docker run -it --rm \
			--add-host=host.docker.internal:host-gateway \
			-p $(PROXY_PORT):8080 -p $(ADMIN_PORT):50051 \
			$(if $(NITELLA_TOKEN),-e NITELLA_TOKEN=$(NITELLA_TOKEN)) \
			nitellad \
			--geoip-city /app/db/GeoLite2-City.mmdb \
			--geoip-isp /app/db/GeoLite2-ASN.mmdb \
			--admin-port 50051 \
			$(if $(BACKEND),--backend $(BACKEND)); \
	fi

# ============================================================================
# Mock Server Module
# ============================================================================

.PHONY: mock_build mock_run mock_test mock_test_integration mock_docker_build mock_docker_run

mock_build:
	@mkdir -p $(BUILD_DIR)
	go build -ldflags "$(LD_FLAGS)" -o $(BUILD_DIR)/mock ./cmd/mock

mock_test:
	go test -v ./pkg/mockproto/...

mock_test_integration: mock_build
	go test -v ./test/integration/... -run Mock -timeout 120s

# Run mock server
# Usage: make mock_run PORT=2222 PROTOCOL=ssh
MOCK_PORT ?= 8080
MOCK_PROTOCOL ?= http
mock_run: mock_build
	./$(BUILD_DIR)/mock -port $(MOCK_PORT) -protocol $(MOCK_PROTOCOL)

mock_clean:
	rm -f $(BUILD_DIR)/mock

# Docker
mock_docker_build:
	docker build -f Dockerfile.mock -t nitella-mock .

# Run mock docker container
# Usage: make mock_docker_run PORT=2222 PROTOCOL=ssh
mock_docker_run: mock_docker_build
	docker run -it --rm \
		-p $(MOCK_PORT):$(MOCK_PORT) \
		-e PORT=$(MOCK_PORT) \
		-e PROTOCOL=$(MOCK_PROTOCOL) \
		nitella-mock

# ============================================================================
# Hub Server Module
# ============================================================================

.PHONY: hub_build hub_server hubctl_build hub_proto hub_test hub_test_integration
.PHONY: hub_run hubctl_run hub_docker_build hub_docker_run hub_clean

hub_build: hub_proto hub_server hubctl_build

hub_server: hub_proto
	@mkdir -p $(BUILD_DIR)
	go build -ldflags "$(LD_FLAGS)" -o $(BUILD_DIR)/hub ./cmd/hub

hubctl_build: hub_proto
	@mkdir -p $(BUILD_DIR)
	go build -ldflags "$(LD_FLAGS)" -o $(BUILD_DIR)/hubctl ./cmd/hubctl

hub_proto: common_proto
	@mkdir -p pkg/api/hub
	protoc --proto_path=api \
		--go_out=pkg/api --go_opt=paths=source_relative \
		--go-grpc_out=pkg/api --go-grpc_opt=paths=source_relative \
		api/hub/hub_common.proto \
		api/hub/hub_node.proto \
		api/hub/hub_mobile.proto \
		api/hub/hub_admin.proto

hub_test:
	go test -v ./pkg/hub/...
	go test -v ./pkg/hubclient/...

# Comprehensive Hub integration tests
# Covers: registration, PAKE/QR pairing, multi-tenant, persistence, crash recovery, security
hub_test_integration: hub_build nitellad_build nitella_build
	@echo "============================================"
	@echo "Running Hub Integration Tests"
	@echo "============================================"
	@# Run basic integration tests
	go test -v ./test/integration/... -run "TestHub_" -timeout 300s
	@# Run hubctl tests
	go test -v ./test/integration/... -run "TestHubCtl_" -timeout 300s
	@# Run comprehensive tests
	go test -v ./test/integration/... -run "TestComprehensive_" -timeout 600s
	@echo "============================================"
	@echo "All Hub integration tests completed"
	@echo "============================================"

# Docker-based E2E tests (full system with containers)
hub_test_e2e_docker:
	@echo "============================================"
	@echo "Running Docker-based E2E Tests"
	@echo "============================================"
	cd test/e2e && docker-compose build
	cd test/e2e && docker-compose up -d hub mock-http mock-ssh mock-mysql
	@echo "Waiting for services..."
	@sleep 10
	cd test/e2e && docker-compose run --rm test-runner
	cd test/e2e && docker-compose down -v
	@echo "============================================"
	@echo "Docker E2E tests completed"
	@echo "============================================"

# Quick smoke test (fast verification)
hub_test_quick: hub_build
	@echo "Running quick smoke tests..."
	go test -v ./test/integration/... -run "TestHub_BasicHealth|TestHub_UserRegistration" -timeout 60s

# Clean up test artifacts
hub_test_clean:
	rm -rf /tmp/hub-test-* /tmp/nitella-test-*
	cd test/e2e && docker-compose down -v 2>/dev/null || true

# Run Hub server
# Usage: make hub_run
#        make hub_run HUB_PORT=50052 HUB_DB=hub.db
#        make hub_run HUB_TLS_CERT=cert.pem HUB_TLS_KEY=key.pem
HUB_PORT ?= 50052
HUB_HTTP_PORT ?= 9090
HUB_DB ?= hub.db
HUB_TLS_CERT ?=
HUB_TLS_KEY ?=
HUB_TLS_CA ?=
hub_run: hub_server
	./$(BUILD_DIR)/hub \
		--port $(HUB_PORT) \
		--http-port $(HUB_HTTP_PORT) \
		--db-path $(HUB_DB) \
		$(if $(HUB_TLS_CERT),--tls-cert $(HUB_TLS_CERT)) \
		$(if $(HUB_TLS_KEY),--tls-key $(HUB_TLS_KEY)) \
		$(if $(HUB_TLS_CA),--tls-ca $(HUB_TLS_CA))

# Run hubctl CLI
# Usage: make hubctl_run CMD="users list"
#        make hubctl_run HUB_ADDR=localhost:50052 CMD="stats"
HUB_ADDR ?= localhost:50052
HUB_ADMIN_KEY ?=
CMD ?= help
hubctl_run: hubctl_build
	./$(BUILD_DIR)/hubctl \
		--hub $(HUB_ADDR) \
		$(if $(HUB_ADMIN_KEY),--admin-key $(HUB_ADMIN_KEY)) \

		$(CMD)

hub_clean:
	rm -f $(BUILD_DIR)/hub $(BUILD_DIR)/hubctl
	rm -f pkg/api/hub/*.pb.go

# Docker
hub_docker_build:
	docker build -f Dockerfile.hub -t nitella-hub .

# Run Hub docker container
# Usage: make hub_docker_run
#        make hub_docker_run HUB_PORT=50052
#        make hub_docker_run HUB_TLS_CERT=cert.pem HUB_TLS_KEY=key.pem
hub_docker_run: hub_docker_build
	@mkdir -p data
	docker run -it --rm \
		-p $(HUB_PORT):50052 \
		-p $(HUB_HTTP_PORT):8080 \
		-v $(PWD)/data:/app/data \
		$(if $(HUB_TLS_CERT),-v $(PWD)/$(HUB_TLS_CERT):/app/certs/cert.pem) \
		$(if $(HUB_TLS_KEY),-v $(PWD)/$(HUB_TLS_KEY):/app/certs/key.pem) \
		$(if $(HUB_TLS_CA),-v $(PWD)/$(HUB_TLS_CA):/app/certs/ca.pem) \
		nitella-hub \
		--db-path /app/data/hub.db \
		$(if $(HUB_TLS_CERT),--tls-cert /app/certs/cert.pem) \
		$(if $(HUB_TLS_KEY),--tls-key /app/certs/key.pem) \
		$(if $(HUB_TLS_CA),--tls-ca /app/certs/ca.pem)

# ============================================================================
# Nitellad with Hub Mode
# ============================================================================

# Run nitellad with Hub registration
# Usage: make nitellad_hub_run HUB=hub.example.com:50052 HUB_USER_ID=user123 BACKEND=localhost:3000
HUB ?=
HUB_USER_ID ?=
HUB_NODE_NAME ?=
nitellad_hub_run: nitellad_build
	./$(BUILD_DIR)/nitellad \
		--listen :8080 \
		$(if $(BACKEND),--backend $(BACKEND)) \
		$(if $(HUB),--hub $(HUB)) \
		$(if $(HUB_USER_ID),--hub-user-id $(HUB_USER_ID)) \
		$(if $(HUB_NODE_NAME),--hub-node-name $(HUB_NODE_NAME)) \
		--admin-port 50051

# Run nitella CLI in Hub mode
# Usage: make nitella_hub_run HUB=hub.example.com:50052 HUB_TOKEN=xxx
HUB_TOKEN ?=
nitella_hub_run: nitella_build
	./$(BUILD_DIR)/nitella \
		$(if $(HUB),--hub $(HUB)) \
		$(if $(HUB_TOKEN),--hub-token $(HUB_TOKEN))
