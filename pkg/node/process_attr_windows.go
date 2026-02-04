//go:build windows

package node

import (
	"os/exec"
)

func setSysProcAttr(cmd *exec.Cmd) {
	// No Pdeathsig on Windows
}
