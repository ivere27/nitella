package cli

import "testing"

func TestDisplayWidthEmoji(t *testing.T) {
	cases := []struct {
		in   string
		want int
	}{
		{in: "abc", want: 3},
		{in: "🧆🐧🦩", want: 6},
		{in: "☘️", want: 2},
		{in: "🐕‍🦺", want: 2},
	}

	for _, tc := range cases {
		got := displayWidth(tc.in)
		if got != tc.want {
			t.Fatalf("displayWidth(%q) = %d, want %d", tc.in, got, tc.want)
		}
	}
}

func TestFitToDisplayWidth(t *testing.T) {
	full := "🧆🐧🦩🥕🐖🍒🌿☘️"
	out := fitToDisplayWidth(full, 28)
	if got := displayWidth(out); got != 28 {
		t.Fatalf("display width = %d, want 28", got)
	}
	if out != full+("            ") {
		t.Fatalf("unexpected padded output: %q", out)
	}

	trunc := fitToDisplayWidth(full, 10)
	if got := displayWidth(trunc); got != 10 {
		t.Fatalf("truncated display width = %d, want 10", got)
	}
	if trunc != "🧆🐧🦩... " {
		t.Fatalf("unexpected truncated output: %q", trunc)
	}
}
