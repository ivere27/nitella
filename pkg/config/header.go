package config

import (
	"crypto/sha256"
	"encoding/hex"
	"errors"
	"fmt"
	"regexp"
	"strconv"
	"strings"
)

// Supported YAML types
const (
	TypeProxy = "proxy"
	TypeRules = "rules"
	TypeTier  = "tier"
	TypeNode  = "node"
)

// Current versions for each type
const (
	VersionProxy = 1
	VersionRules = 1
	VersionTier  = 1
	VersionNode  = 1
)

var headerRegex = regexp.MustCompile(`^#\s*nitella/(\w+):\s*v(\d+)(?:;\s*checksum=(.+))?$`)

// Header represents the parsed YAML header
type Header struct {
	Type     string // "proxy", "rules", "tier", "node"
	Version  int    // Per-type version (1, 2, ...)
	Checksum string // Optional, empty if not provided
}

// ParseHeader parses the first line of a nitella YAML file
func ParseHeader(firstLine string) (*Header, error) {
	firstLine = strings.TrimSpace(firstLine)
	matches := headerRegex.FindStringSubmatch(firstLine)
	if matches == nil {
		return nil, errors.New("invalid header format: expected '# nitella/<type>: v<version>'")
	}

	version, err := strconv.Atoi(matches[2])
	if err != nil {
		return nil, fmt.Errorf("invalid version number: %s", matches[2])
	}

	return &Header{
		Type:     matches[1],
		Version:  version,
		Checksum: matches[3], // empty if not present
	}, nil
}

// String returns the header as a formatted string
func (h *Header) String() string {
	if h.Checksum != "" {
		return fmt.Sprintf("# nitella/%s: v%d; checksum=%s", h.Type, h.Version, h.Checksum)
	}
	return fmt.Sprintf("# nitella/%s: v%d", h.Type, h.Version)
}

// IsValidType checks if the type is supported
func (h *Header) IsValidType() bool {
	switch h.Type {
	case TypeProxy, TypeRules, TypeTier, TypeNode:
		return true
	default:
		return false
	}
}

// GenerateChecksum calculates SHA256 of content after the header line
func GenerateChecksum(content []byte) string {
	// Find the first newline to skip header
	idx := 0
	for i, b := range content {
		if b == '\n' {
			idx = i + 1
			break
		}
	}

	// Hash content after header
	var hashContent []byte
	if idx < len(content) {
		hashContent = content[idx:]
	} else {
		hashContent = []byte{}
	}

	hash := sha256.Sum256(hashContent)
	return "sha256:" + hex.EncodeToString(hash[:])
}

// VerifyChecksum verifies the checksum if present in the header
func VerifyChecksum(content []byte) error {
	lines := strings.SplitN(string(content), "\n", 2)
	if len(lines) == 0 {
		return errors.New("empty content")
	}

	header, err := ParseHeader(lines[0])
	if err != nil {
		return err
	}

	// If no checksum, verification passes (checksum is optional)
	if header.Checksum == "" {
		return nil
	}

	actual := GenerateChecksum(content)
	if header.Checksum != actual {
		return fmt.Errorf("checksum mismatch: expected %s, got %s", header.Checksum, actual)
	}

	return nil
}

// WriteWithHeader prepends the header to content and optionally adds checksum
func WriteWithHeader(yamlType string, version int, content []byte, includeChecksum bool) []byte {
	header := &Header{
		Type:    yamlType,
		Version: version,
	}

	// Build content with header placeholder first
	headerLine := header.String() + "\n"
	fullContent := append([]byte(headerLine), content...)

	if includeChecksum {
		// Calculate checksum of content (after header line)
		header.Checksum = GenerateChecksum(fullContent)
		headerLine = header.String() + "\n"
		fullContent = append([]byte(headerLine), content...)
	}

	return fullContent
}

// ExtractContent returns the content without the header line
func ExtractContent(content []byte) ([]byte, *Header, error) {
	lines := strings.SplitN(string(content), "\n", 2)
	if len(lines) == 0 {
		return nil, nil, errors.New("empty content")
	}

	header, err := ParseHeader(lines[0])
	if err != nil {
		return nil, nil, err
	}

	var body []byte
	if len(lines) > 1 {
		body = []byte(lines[1])
	}

	return body, header, nil
}

// GetCurrentVersion returns the current version for a given type
func GetCurrentVersion(yamlType string) int {
	switch yamlType {
	case TypeProxy:
		return VersionProxy
	case TypeRules:
		return VersionRules
	case TypeTier:
		return VersionTier
	case TypeNode:
		return VersionNode
	default:
		return 0
	}
}
