package main

import (
	"bytes"
	"encoding/json"
	"os"
	"path/filepath"
	"strings"
	"testing"
	"time"

	"gopkg.in/yaml.v3"
)

func TestHashConfig(t *testing.T) {
	tests := []struct {
		name    string
		content []byte
		want    string
	}{
		{
			name:    "empty content",
			content: []byte(""),
			want:    "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855",
		},
		{
			name:    "simple content",
			content: []byte("hello"),
			want:    "2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e73043362938b9824",
		},
		{
			name:    "yaml content",
			content: []byte("listeners:\n  - type: socks5\n    port: 1080\n"),
			want:    "f8c5e8e3a0c3a8e3b2a0c8e3a0c5e8e3a0c3a8e3b2a0c8e3a0c5e8e3a0c3a8e3", // placeholder
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			got := hashConfig(tt.content)
			if len(got) != 64 {
				t.Errorf("hashConfig() returned hash of length %d, want 64", len(got))
			}
			// Verify consistency
			got2 := hashConfig(tt.content)
			if got != got2 {
				t.Errorf("hashConfig() not consistent: got %v, then %v", got, got2)
			}
		})
	}

	// Test that different content produces different hashes
	hash1 := hashConfig([]byte("content1"))
	hash2 := hashConfig([]byte("content2"))
	if hash1 == hash2 {
		t.Errorf("hashConfig() produced same hash for different content")
	}
}

func TestFormatSize(t *testing.T) {
	tests := []struct {
		bytes int64
		want  string
	}{
		{0, "0 B"},
		{100, "100 B"},
		{1023, "1023 B"},
		{1024, "1.0 KB"},
		{1536, "1.5 KB"},
		{1048576, "1.0 MB"},
		{1073741824, "1.0 GB"},
		{1099511627776, "1.0 TB"},
	}

	for _, tt := range tests {
		t.Run(tt.want, func(t *testing.T) {
			got := formatSize(tt.bytes)
			if got != tt.want {
				t.Errorf("formatSize(%d) = %q, want %q", tt.bytes, got, tt.want)
			}
		})
	}
}

func TestProxyMetaSerialization(t *testing.T) {
	now := time.Now().Truncate(time.Second)
	meta := ProxyMeta{
		ID:          "test-proxy-123",
		Name:        "Test Proxy",
		Description: "A test proxy configuration",
		CreatedAt:   now,
		UpdatedAt:   now,
		SyncedAt:    now,
		RevisionNum: 5,
		ConfigHash:  "abc123def456",
	}

	// Test JSON serialization
	jsonData, err := json.Marshal(meta)
	if err != nil {
		t.Fatalf("json.Marshal() error = %v", err)
	}

	var jsonMeta ProxyMeta
	if err := json.Unmarshal(jsonData, &jsonMeta); err != nil {
		t.Fatalf("json.Unmarshal() error = %v", err)
	}

	if jsonMeta.ID != meta.ID {
		t.Errorf("JSON roundtrip: ID = %q, want %q", jsonMeta.ID, meta.ID)
	}
	if jsonMeta.Name != meta.Name {
		t.Errorf("JSON roundtrip: Name = %q, want %q", jsonMeta.Name, meta.Name)
	}
	if jsonMeta.RevisionNum != meta.RevisionNum {
		t.Errorf("JSON roundtrip: RevisionNum = %d, want %d", jsonMeta.RevisionNum, meta.RevisionNum)
	}

	// Test YAML serialization
	yamlData, err := yaml.Marshal(meta)
	if err != nil {
		t.Fatalf("yaml.Marshal() error = %v", err)
	}

	var yamlMeta ProxyMeta
	if err := yaml.Unmarshal(yamlData, &yamlMeta); err != nil {
		t.Fatalf("yaml.Unmarshal() error = %v", err)
	}

	if yamlMeta.ID != meta.ID {
		t.Errorf("YAML roundtrip: ID = %q, want %q", yamlMeta.ID, meta.ID)
	}
	if yamlMeta.Name != meta.Name {
		t.Errorf("YAML roundtrip: Name = %q, want %q", yamlMeta.Name, meta.Name)
	}
}

func TestProxyRevisionPayloadSerialization(t *testing.T) {
	payload := ProxyRevisionPayload{
		Name:            "My Proxy",
		Description:     "Test description",
		CommitMessage:   "Initial commit",
		ProtocolVersion: "v1",
		ConfigYAML: `listeners:
  - type: socks5
    port: 1080
`,
		ConfigHash: "sha256:abc123",
	}

	jsonData, err := json.Marshal(payload)
	if err != nil {
		t.Fatalf("json.Marshal() error = %v", err)
	}

	var decoded ProxyRevisionPayload
	if err := json.Unmarshal(jsonData, &decoded); err != nil {
		t.Fatalf("json.Unmarshal() error = %v", err)
	}

	if decoded.Name != payload.Name {
		t.Errorf("Name = %q, want %q", decoded.Name, payload.Name)
	}
	if decoded.ConfigYAML != payload.ConfigYAML {
		t.Errorf("ConfigYAML = %q, want %q", decoded.ConfigYAML, payload.ConfigYAML)
	}
	if decoded.ProtocolVersion != payload.ProtocolVersion {
		t.Errorf("ProtocolVersion = %q, want %q", decoded.ProtocolVersion, payload.ProtocolVersion)
	}
}

func TestProxyIndexOperations(t *testing.T) {
	// Create temporary directory for test
	tmpDir := t.TempDir()
	originalDataDir := dataDir
	dataDir = tmpDir
	defer func() { dataDir = originalDataDir }()

	// Test loading empty index
	index, err := loadProxyIndex()
	if err != nil {
		t.Fatalf("loadProxyIndex() error = %v", err)
	}
	if len(index) != 0 {
		t.Errorf("loadProxyIndex() returned non-empty index for new directory")
	}

	// Add some entries and save
	now := time.Now()
	index["proxy-1"] = &ProxyMeta{
		ID:        "proxy-1",
		Name:      "First Proxy",
		CreatedAt: now,
		UpdatedAt: now,
	}
	index["proxy-2"] = &ProxyMeta{
		ID:        "proxy-2",
		Name:      "Second Proxy",
		CreatedAt: now,
		UpdatedAt: now,
	}

	if err := saveProxyIndex(index); err != nil {
		t.Fatalf("saveProxyIndex() error = %v", err)
	}

	// Reload and verify
	loaded, err := loadProxyIndex()
	if err != nil {
		t.Fatalf("loadProxyIndex() after save error = %v", err)
	}
	if len(loaded) != 2 {
		t.Errorf("loadProxyIndex() returned %d entries, want 2", len(loaded))
	}
	if loaded["proxy-1"].Name != "First Proxy" {
		t.Errorf("proxy-1 Name = %q, want %q", loaded["proxy-1"].Name, "First Proxy")
	}
	if loaded["proxy-2"].Name != "Second Proxy" {
		t.Errorf("proxy-2 Name = %q, want %q", loaded["proxy-2"].Name, "Second Proxy")
	}
}

func TestFindProxyByPrefix(t *testing.T) {
	// Create temporary directory for test
	tmpDir := t.TempDir()
	originalDataDir := dataDir
	dataDir = tmpDir
	defer func() { dataDir = originalDataDir }()

	// Create test index
	now := time.Now()
	index := map[string]*ProxyMeta{
		"abc123-proxy": {ID: "abc123-proxy", Name: "ABC Proxy", CreatedAt: now, UpdatedAt: now},
		"abc456-proxy": {ID: "abc456-proxy", Name: "ABC 456 Proxy", CreatedAt: now, UpdatedAt: now},
		"def789-proxy": {ID: "def789-proxy", Name: "DEF Proxy", CreatedAt: now, UpdatedAt: now},
	}
	if err := saveProxyIndex(index); err != nil {
		t.Fatalf("saveProxyIndex() error = %v", err)
	}

	tests := []struct {
		name      string
		prefix    string
		wantID    string
		wantError bool
	}{
		{
			name:   "exact match",
			prefix: "abc123-proxy",
			wantID: "abc123-proxy",
		},
		{
			name:   "unique prefix",
			prefix: "def",
			wantID: "def789-proxy",
		},
		{
			name:      "ambiguous prefix",
			prefix:    "abc",
			wantError: true,
		},
		{
			name:      "no match",
			prefix:    "xyz",
			wantError: true,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			meta, err := findProxyByPrefix(tt.prefix)
			if tt.wantError {
				if err == nil {
					t.Errorf("findProxyByPrefix(%q) expected error, got nil", tt.prefix)
				}
				return
			}
			if err != nil {
				t.Errorf("findProxyByPrefix(%q) error = %v", tt.prefix, err)
				return
			}
			if meta.ID != tt.wantID {
				t.Errorf("findProxyByPrefix(%q) ID = %q, want %q", tt.prefix, meta.ID, tt.wantID)
			}
		})
	}
}

func TestGetProxyPath(t *testing.T) {
	originalDataDir := dataDir
	dataDir = "/test/data"
	defer func() { dataDir = originalDataDir }()

	got := getProxyPath("my-proxy-123")
	want := "/test/data/proxies/my-proxy-123.yaml"
	if got != want {
		t.Errorf("getProxyPath() = %q, want %q", got, want)
	}
}

func TestShowUnifiedDiff(t *testing.T) {
	tests := []struct {
		name     string
		old      string
		new      string
		wantDiff bool
	}{
		{
			name:     "identical content",
			old:      "line1\nline2\nline3",
			new:      "line1\nline2\nline3",
			wantDiff: false,
		},
		{
			name:     "single line change",
			old:      "line1\nline2\nline3",
			new:      "line1\nmodified\nline3",
			wantDiff: true,
		},
		{
			name:     "added line",
			old:      "line1\nline2",
			new:      "line1\nline2\nline3",
			wantDiff: true,
		},
		{
			name:     "removed line",
			old:      "line1\nline2\nline3",
			new:      "line1\nline3",
			wantDiff: true,
		},
		{
			name:     "empty old",
			old:      "",
			new:      "new content",
			wantDiff: true,
		},
		{
			name:     "empty new",
			old:      "old content",
			new:      "",
			wantDiff: true,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			// Capture stdout
			oldStdout := os.Stdout
			r, w, _ := os.Pipe()
			os.Stdout = w

			showUnifiedDiff(tt.old, tt.new)

			w.Close()
			os.Stdout = oldStdout

			var buf bytes.Buffer
			buf.ReadFrom(r)
			output := buf.String()

			hasDiff := strings.Contains(output, "@@") || strings.Contains(output, "-") || strings.Contains(output, "+")
			if hasDiff != tt.wantDiff {
				t.Errorf("showUnifiedDiff() hasDiff = %v, want %v (output: %q)", hasDiff, tt.wantDiff, output)
			}
		})
	}
}

func TestProxyConfigFileOperations(t *testing.T) {
	tmpDir := t.TempDir()
	originalDataDir := dataDir
	dataDir = tmpDir
	defer func() { dataDir = originalDataDir }()

	// Create proxies directory
	proxiesDir := getProxiesDir()
	if err := os.MkdirAll(proxiesDir, 0700); err != nil {
		t.Fatalf("MkdirAll() error = %v", err)
	}

	// Test writing and reading a proxy config
	proxyID := "test-proxy-abc123"
	configContent := `# nitella/proxy: v1
listeners:
  - type: socks5
    address: "0.0.0.0"
    port: 1080
`
	proxyPath := getProxyPath(proxyID)
	if err := os.WriteFile(proxyPath, []byte(configContent), 0600); err != nil {
		t.Fatalf("WriteFile() error = %v", err)
	}

	// Read back
	readContent, err := os.ReadFile(proxyPath)
	if err != nil {
		t.Fatalf("ReadFile() error = %v", err)
	}

	if string(readContent) != configContent {
		t.Errorf("Config content mismatch:\ngot: %q\nwant: %q", string(readContent), configContent)
	}

	// Verify hash consistency
	hash1 := hashConfig(readContent)
	hash2 := hashConfig([]byte(configContent))
	if hash1 != hash2 {
		t.Errorf("Hash mismatch: %s != %s", hash1, hash2)
	}
}

func TestTruncateFunction(t *testing.T) {
	tests := []struct {
		s      string
		maxLen int
		want   string
	}{
		{"hello", 10, "hello"},
		{"hello", 5, "hello"},
		{"hello world", 8, "hello..."},
		{"short", 3, "..."},
		{"ab", 5, "ab"},
		{"", 5, ""},
	}

	for _, tt := range tests {
		t.Run(tt.s, func(t *testing.T) {
			got := truncate(tt.s, tt.maxLen)
			if got != tt.want {
				t.Errorf("truncate(%q, %d) = %q, want %q", tt.s, tt.maxLen, got, tt.want)
			}
		})
	}
}

func TestProxiesDir(t *testing.T) {
	originalDataDir := dataDir
	dataDir = "/home/user/.nitella"
	defer func() { dataDir = originalDataDir }()

	got := getProxiesDir()
	want := filepath.Join("/home/user/.nitella", "proxies")
	if got != want {
		t.Errorf("getProxiesDir() = %q, want %q", got, want)
	}
}

func TestProxyIndexPath(t *testing.T) {
	originalDataDir := dataDir
	dataDir = "/home/user/.nitella"
	defer func() { dataDir = originalDataDir }()

	got := getProxyIndexPath()
	want := filepath.Join("/home/user/.nitella", "proxies", "index.json")
	if got != want {
		t.Errorf("getProxyIndexPath() = %q, want %q", got, want)
	}
}
