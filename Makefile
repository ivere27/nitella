# Nitella
# ============================================================================

BUILD_DIR := bin

# Build info
COMMIT_HASH ?= $(shell git rev-parse --short HEAD 2>/dev/null || echo "unknown")
BUILD_DATE := $(shell date +"%Y-%m-%dT%H:%M:%SZ")
LD_FLAGS := -X main.commitHash=$(COMMIT_HASH) -X main.buildDate=$(BUILD_DATE)

.PHONY: all build proto test clean deps fmt lint build_plugin

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

build: proto geoip_build mock_build nitellad_build nitella_build

# ============================================================================
# Proto Generation
# ============================================================================

proto: common_proto proxy_proto process_proto geoip_proto geoip_ffi_proto

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

geoip_ffi_proto: common_proto geoip_proto
	@mkdir -p pkg/api/geoip
	protoc --proto_path=api \
		--plugin=protoc-gen-synurang-ffi=$(shell go env GOPATH)/bin/protoc-gen-synurang-ffi \
		--synurang-ffi_out=pkg/api/geoip --synurang-ffi_opt=paths=source_relative,services=GeoIPService \
		api/geoip/geoip.proto

# ============================================================================
# Test
# ============================================================================

test:
	go test -v ./...

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
