package cli

import (
	"fmt"
	"strings"
)

// Column defines a table column with header and width.
type Column struct {
	Header string
	Width  int
}

// Table helps format tabular CLI output.
type Table struct {
	columns []Column
	format  string
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
	var parts []string
	t.width = 0
	for i, c := range t.columns {
		parts = append(parts, fmt.Sprintf("%%-%ds", c.Width))
		t.width += c.Width
		if i < len(t.columns)-1 {
			t.width += 2 // spacing between columns
		}
	}
	t.format = strings.Join(parts, "  ") + "\n"
}

// PrintHeader prints the header row and separator line.
func (t *Table) PrintHeader() {
	headers := make([]interface{}, len(t.columns))
	for i, c := range t.columns {
		headers[i] = c.Header
	}
	fmt.Println()
	fmt.Printf(t.format, headers...)
	fmt.Println(strings.Repeat("-", t.width))
}

// PrintRow prints a data row with the given values.
func (t *Table) PrintRow(values ...interface{}) {
	// Truncate string values that exceed column width
	truncated := make([]interface{}, len(values))
	for i, v := range values {
		if i < len(t.columns) {
			if s, ok := v.(string); ok && len(s) > t.columns[i].Width {
				truncated[i] = s[:t.columns[i].Width-3] + "..."
			} else {
				truncated[i] = v
			}
		} else {
			truncated[i] = v
		}
	}
	fmt.Printf(t.format, truncated...)
}

// PrintFooter prints a blank line after the table.
func (t *Table) PrintFooter() {
	fmt.Println()
}

// Width returns the total table width.
func (t *Table) Width() int {
	return t.width
}
