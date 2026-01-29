# Nitella
# ============================================================================

BUILD_DIR := bin

# Build info
COMMIT_HASH ?= $(shell git rev-parse --short HEAD 2>/dev/null || echo "unknown")
BUILD_DATE := $(shell date +"%Y-%m-%dT%H:%M:%SZ")
LD_FLAGS := -X main.commitHash=$(COMMIT_HASH) -X main.buildDate=$(BUILD_DATE)

.PHONY: all build proto test clean deps fmt lint

all: build

# ============================================================================
# Build All
# ============================================================================

build: proto geoip_build mock_build

# ============================================================================
# Proto Generation
# ============================================================================

proto: geoip_proto

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
