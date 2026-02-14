package cli

import (
	"fmt"
	"strings"
	"unicode"
)

// Column defines a table column with header and width.
type Column struct {
	Header string
	Width  int
}

// Table helps format tabular CLI output.
type Table struct {
	columns []Column
	width   int
}

// NewTable creates a table with the given columns.
func NewTable(cols ...Column) *Table {
	t := &Table{columns: cols}
	t.buildFormat()
	return t
}

// buildFormat constructs the format string and calculates total width.
func (t *Table) buildFormat() {
	t.width = 0
	for i, c := range t.columns {
		t.width += c.Width
		if i < len(t.columns)-1 {
			t.width += 2 // spacing between columns
		}
	}
}

// PrintHeader prints the header row and separator line.
func (t *Table) PrintHeader() {
	headers := make([]string, len(t.columns))
	for i, c := range t.columns {
		headers[i] = fitToDisplayWidth(c.Header, c.Width)
	}
	fmt.Println()
	fmt.Println(strings.Join(headers, "  "))
	fmt.Println(strings.Repeat("-", t.width))
}

// PrintRow prints a data row with the given values.
func (t *Table) PrintRow(values ...interface{}) {
	row := make([]string, len(t.columns))
	for i := range t.columns {
		raw := ""
		if i < len(values) {
			raw = fmt.Sprint(values[i])
		}
		row[i] = fitToDisplayWidth(raw, t.columns[i].Width)
	}
	fmt.Println(strings.Join(row, "  "))
}

// PrintFooter prints a blank line after the table.
func (t *Table) PrintFooter() {
	fmt.Println()
}

// Width returns the total table width.
func (t *Table) Width() int {
	return t.width
}

type textCluster struct {
	text  string
	width int
}

func fitToDisplayWidth(s string, width int) string {
	if width <= 0 {
		return ""
	}

	clusters := splitTextClusters(s)
	totalWidth := 0
	for _, cl := range clusters {
		totalWidth += cl.width
	}
	if totalWidth <= width {
		return s + strings.Repeat(" ", width-totalWidth)
	}

	if width <= 3 {
		return clipToWidth(clusters, width)
	}

	keepWidth := width - 3
	kept := make([]textCluster, 0, len(clusters))
	acc := 0
	for _, cl := range clusters {
		if acc+cl.width > keepWidth {
			break
		}
		kept = append(kept, cl)
		acc += cl.width
	}

	var b strings.Builder
	for _, cl := range kept {
		b.WriteString(cl.text)
	}
	b.WriteString("...")
	out := b.String()
	outWidth := acc + 3
	if outWidth < width {
		out += strings.Repeat(" ", width-outWidth)
	}
	return out
}

func clipToWidth(clusters []textCluster, width int) string {
	if width <= 0 {
		return ""
	}
	acc := 0
	var b strings.Builder
	for _, cl := range clusters {
		if acc+cl.width > width {
			break
		}
		b.WriteString(cl.text)
		acc += cl.width
	}
	if acc < width {
		b.WriteString(strings.Repeat(" ", width-acc))
	}
	return b.String()
}

func splitTextClusters(s string) []textCluster {
	if s == "" {
		return nil
	}

	runes := []rune(s)
	clusters := make([]textCluster, 0, len(runes))
	for i := 0; i < len(runes); {
		start := i
		r := runes[i]

		// Ignore stray non-spacing/format runes.
		if isZeroWidthRune(r) {
			i++
			continue
		}

		// Regional indicator pairs (flag emoji) are a single cluster width.
		if isRegionalIndicator(r) && i+1 < len(runes) && isRegionalIndicator(runes[i+1]) {
			i += 2
			for i < len(runes) && (isVariationSelector(runes[i]) || isZeroWidthRune(runes[i])) {
				i++
			}
			clusters = append(clusters, textCluster{
				text:  string(runes[start:i]),
				width: 2,
			})
			continue
		}

		clusterWidth := runeDisplayWidth(r)
		i++
		for i < len(runes) {
			next := runes[i]
			switch {
			case isVariationSelector(next), isCombiningRune(next):
				i++
			case next == '\u200d': // Zero-width joiner: fold joined runes into one visual emoji cluster.
				clusterWidth = max(clusterWidth, 2)
				i++
				if i < len(runes) {
					joined := runes[i]
					clusterWidth = max(clusterWidth, runeDisplayWidth(joined))
					i++
				}
			case isEmojiModifier(next):
				clusterWidth = max(clusterWidth, 2)
				i++
			default:
				goto doneCluster
			}
		}
	doneCluster:
		if clusterWidth <= 0 {
			clusterWidth = 1
		}
		clusters = append(clusters, textCluster{
			text:  string(runes[start:i]),
			width: clusterWidth,
		})
	}

	return clusters
}

func displayWidth(s string) int {
	width := 0
	for _, cl := range splitTextClusters(s) {
		width += cl.width
	}
	return width
}

func runeDisplayWidth(r rune) int {
	if r == '\t' {
		return 4
	}
	if r < 0x20 || (r >= 0x7f && r < 0xa0) {
		return 0
	}
	if isZeroWidthRune(r) || isCombiningRune(r) {
		return 0
	}
	if isWideRune(r) || isEmojiRune(r) {
		return 2
	}
	return 1
}

func isCombiningRune(r rune) bool {
	return unicode.Is(unicode.Mn, r) || unicode.Is(unicode.Me, r)
}

func isZeroWidthRune(r rune) bool {
	switch r {
	case '\u200b', '\u200c', '\u200d', '\ufe0e', '\ufe0f':
		return true
	}
	return unicode.Is(unicode.Cf, r)
}

func isVariationSelector(r rune) bool {
	return (r >= 0xfe00 && r <= 0xfe0f) || (r >= 0xe0100 && r <= 0xe01ef)
}

func isEmojiModifier(r rune) bool {
	return r >= 0x1f3fb && r <= 0x1f3ff
}

func isRegionalIndicator(r rune) bool {
	return r >= 0x1f1e6 && r <= 0x1f1ff
}

func isEmojiRune(r rune) bool {
	switch {
	case r >= 0x1f300 && r <= 0x1faff:
		return true
	case r >= 0x2600 && r <= 0x26ff:
		return true
	case r >= 0x2700 && r <= 0x27bf:
		return true
	case r >= 0x2300 && r <= 0x23ff:
		return true
	case r >= 0x1f900 && r <= 0x1f9ff:
		return true
	case r >= 0x1fa70 && r <= 0x1faff:
		return true
	}
	return false
}

func isWideRune(r rune) bool {
	switch {
	case r >= 0x1100 && r <= 0x115f:
		return true
	case r == 0x2329 || r == 0x232a:
		return true
	case r >= 0x2e80 && r <= 0xa4cf && r != 0x303f:
		return true
	case r >= 0xac00 && r <= 0xd7a3:
		return true
	case r >= 0xf900 && r <= 0xfaff:
		return true
	case r >= 0xfe10 && r <= 0xfe19:
		return true
	case r >= 0xfe30 && r <= 0xfe6f:
		return true
	case r >= 0xff00 && r <= 0xff60:
		return true
	case r >= 0xffe0 && r <= 0xffe6:
		return true
	case r >= 0x20000 && r <= 0x2fffd:
		return true
	case r >= 0x30000 && r <= 0x3fffd:
		return true
	}
	return false
}

func max(a, b int) int {
	if a > b {
		return a
	}
	return b
}
