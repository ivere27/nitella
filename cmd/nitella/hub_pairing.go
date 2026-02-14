package main

import (
	"bufio"
	"context"
	"fmt"
	"os"
	"os/signal"
	"strings"
	"syscall"
	"time"

	pb "github.com/ivere27/nitella/pkg/api/local"
)

func normalizeOnboardingErrorMessage(msg string) string {
	msg = strings.TrimSpace(msg)
	if msg == "" {
		return "unknown error"
	}

	prefixes := []string{
		"onboarding failed:",
		"failed to onboard hub:",
	}

	for {
		lowerMsg := strings.ToLower(msg)
		trimmed := false
		for _, prefix := range prefixes {
			if strings.HasPrefix(lowerMsg, prefix) {
				msg = strings.TrimSpace(msg[len(prefix):])
				trimmed = true
				break
			}
		}
		if !trimmed {
			break
		}
		if msg == "" {
			return "unknown error"
		}
	}

	return msg
}

func isHubAddressNotConfiguredError(msg string) bool {
	lowerMsg := strings.ToLower(strings.TrimSpace(msg))
	return strings.Contains(lowerMsg, "hub address not specified") ||
		strings.Contains(lowerMsg, "hub address not set") ||
		strings.Contains(lowerMsg, "hub address is not set") ||
		strings.Contains(lowerMsg, "missing hub address")
}

func printHubAddressConfigHint() {
	fmt.Println("Hint: set the Hub address first:")
	fmt.Println("  config set hub_address <host:port>")
}

func (h *HubCLI) cmdHubRegister(args []string) {
	cfg := h.loadHubConfig()

	inviteCode := ""
	if len(args) > 0 {
		inviteCode = args[0]
	}

	fmt.Println("Onboarding with Hub...")
	if inviteCode != "" {
		fmt.Printf("  Invite Code: %s\n", inviteCode)
	}

	resp, err := h.onboardHub(cfg, inviteCode, false)
	if err != nil {
		msg := normalizeOnboardingErrorMessage(err.Error())
		fmt.Printf("Onboarding failed: %s\n", msg)
		if isHubAddressNotConfiguredError(msg) {
			printHubAddressConfigHint()
		}
		return
	}
	if resp == nil {
		fmt.Println("Onboarding failed: empty response")
		return
	}
	if !resp.Success {
		msg := normalizeOnboardingErrorMessage(resp.GetError())
		fmt.Printf("Onboarding failed: %s\n", msg)
		if isHubAddressNotConfiguredError(msg) {
			printHubAddressConfigHint()
		}
		return
	}

	fmt.Println("\nOnboarding Successful!")
	fmt.Printf("  User ID:   %s\n", resp.UserId)
	fmt.Printf("  Tier:      %s\n", resp.Tier)
	fmt.Printf("  Max Nodes: %d\n", resp.MaxNodes)
}

// ============================================================================
// PAKE Pairing Commands
// ============================================================================

func (h *HubCLI) cmdHubPair(args []string) {
	cfg := h.ensureHubConnected()
	if cfg == nil {
		return
	}

	// Generate pairing code from backend.
	pairCtx, pairCancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer pairCancel()
	startResp, err := client.StartPairing(pairCtx, &pb.StartPairingRequest{})
	if err != nil {
		fmt.Printf("Error starting pairing: %v\n", err)
		return
	}
	if startResp == nil || startResp.PairingCode == "" {
		fmt.Println("Error starting pairing: backend did not return a pairing code")
		return
	}
	code := startResp.PairingCode

	fmt.Println()
	fmt.Println("╔══════════════════════════════════════════════════════════════╗")
	fmt.Println("║                    NODE PAIRING (PAKE)                        ║")
	fmt.Println("╠══════════════════════════════════════════════════════════════╣")
	fmt.Printf("║                                                                ║\n")
	fmt.Printf("║    Pairing Code:  %-42s  ║\n", code)
	fmt.Printf("║                                                                ║\n")
	fmt.Println("╠══════════════════════════════════════════════════════════════╣")
	fmt.Println("║  On your node, run:                                           ║")
	fmt.Printf("║    nitellad --hub %s --pair %s  ║\n", truncateStr(cfg.HubAddress, 15), code)
	fmt.Println("╚══════════════════════════════════════════════════════════════╝")
	fmt.Println()
	fmt.Println("Waiting for node to connect... (Ctrl+C to cancel)")

	waitCtx, stop := signal.NotifyContext(context.Background(), os.Interrupt, syscall.SIGINT)
	defer stop()

	joinCtx, joinCancel := context.WithTimeout(waitCtx, 5*time.Minute)
	defer joinCancel()

	joinResp, err := client.JoinPairing(joinCtx, &pb.JoinPairingRequest{
		PairingCode: code,
	})
	if err != nil {
		if joinCtx.Err() != nil {
			fmt.Println("\nPairing cancelled.")
			return
		}
		fmt.Printf("Error joining pairing: %v\n", err)
		return
	}
	if !joinResp.Success {
		errMsg := strings.TrimSpace(joinResp.Error)
		if errMsg == "" {
			errMsg = "unknown error"
		}
		fmt.Printf("Pairing error: %s\n", errMsg)
		return
	}
	if strings.TrimSpace(joinResp.SessionId) == "" {
		fmt.Println("Pairing error: backend did not return a session id")
		return
	}

	fmt.Println()
	fmt.Printf("Verification emoji: %s\n", joinResp.EmojiFingerprint)
	fmt.Println("Verify this matches what the node displays!")
	if joinResp.NodeName != "" {
		fmt.Printf("Node ID: %s\n", joinResp.NodeName)
	}
	fmt.Println()

	fmt.Println("╔══════════════════════════════════════════════════════════════╗")
	fmt.Println("║              CERTIFICATE SIGNING REQUEST                      ║")
	fmt.Println("╠══════════════════════════════════════════════════════════════╣")
	fmt.Printf("║  Node ID:     %-46s  ║\n", truncateStr(joinResp.NodeName, 46))
	fmt.Printf("║  Session ID:  %-46s  ║\n", truncateStr(joinResp.SessionId, 46))
	if strings.TrimSpace(joinResp.CsrFingerprint) != "" {
		fmt.Printf("║  CSR FP:      %-46s  ║\n", truncateStr(joinResp.CsrFingerprint, 46))
	}
	if strings.TrimSpace(joinResp.CsrHash) != "" {
		fmt.Printf("║  CSR Hash:    %-46s  ║\n", truncateStr(joinResp.CsrHash, 46))
	}
	if strings.TrimSpace(joinResp.Fingerprint) != "" {
		fmt.Printf("║  Fingerprint: %-46s  ║\n", truncateStr(joinResp.Fingerprint, 46))
	}
	if strings.TrimSpace(joinResp.EmojiHash) != "" {
		fmt.Printf("║  Emoji Hash:  %-46s  ║\n", truncateStr(joinResp.EmojiHash, 46))
	}
	fmt.Println("╠══════════════════════════════════════════════════════════════╣")
	fmt.Println("║  Do you want to sign this certificate? (yes/no)              ║")
	fmt.Println("╚══════════════════════════════════════════════════════════════╝")

	reader := bufio.NewReader(os.Stdin)
	fmt.Print("> ")
	response, _ := reader.ReadString('\n')
	response = strings.TrimSpace(strings.ToLower(response))

	if response != "yes" && response != "y" {
		_, _ = client.FinalizePairing(context.Background(), &pb.FinalizePairingRequest{
			SessionId: joinResp.SessionId,
			Accepted:  false,
		})
		fmt.Println("Pairing cancelled by user.")
		return
	}

	fmt.Println("Signing certificate...")

	finalizeCtx, finalizeCancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer finalizeCancel()

	finalizeResp, err := client.FinalizePairing(finalizeCtx, &pb.FinalizePairingRequest{
		SessionId: joinResp.SessionId,
		Accepted:  true,
	})
	if err != nil {
		fmt.Printf("Error completing pairing: %v\n", err)
		return
	}
	if !finalizeResp.Success {
		errMsg := strings.TrimSpace(finalizeResp.Error)
		if errMsg == "" {
			errMsg = "unknown error"
		}
		fmt.Printf("Pairing error: %s\n", errMsg)
		return
	}
	if finalizeResp.Node == nil {
		fmt.Println("Pairing completed but backend returned no node details")
		return
	}

	fmt.Println()
	fmt.Println("╔══════════════════════════════════════════════════════════════╗")
	fmt.Println("║                    PAIRING COMPLETE!                          ║")
	fmt.Println("╠══════════════════════════════════════════════════════════════╣")
	fmt.Printf("║  Node:        %-46s  ║\n", truncateStr(finalizeResp.Node.NodeId, 46))
	fmt.Printf("║  Fingerprint: %-46s  ║\n", finalizeResp.Node.Fingerprint)
	fmt.Println("║                                                                ║")
	fmt.Println("║  The node is now trusted and can connect via Hub.             ║")
	fmt.Println("╚══════════════════════════════════════════════════════════════╝")
	fmt.Println()
}

func (h *HubCLI) cmdHubPairOffline(args []string) {
	fmt.Println()
	fmt.Println("╔══════════════════════════════════════════════════════════════╗")
	fmt.Println("║              OFFLINE PAIRING (QR CODE)                        ║")
	fmt.Println("╠══════════════════════════════════════════════════════════════╣")
	fmt.Println("║                                                                ║")
	fmt.Println("║  1. On the node, run: nitellad --pair-offline                 ║")
	fmt.Println("║  2. The node will display a QR code with its CSR              ║")
	fmt.Println("║  3. Paste the QR data below (or scan with camera)             ║")
	fmt.Println("║                                                                ║")
	fmt.Println("╚══════════════════════════════════════════════════════════════╝")
	fmt.Println()
	fmt.Println("Paste the node's QR data (JSON) and press Enter:")
	fmt.Print("> ")

	reader := bufio.NewReader(os.Stdin)
	qrData, _ := reader.ReadString('\n')
	qrData = strings.TrimSpace(qrData)

	if qrData == "" {
		fmt.Println("No data provided. Cancelled.")
		return
	}

	// Use ScanQRCode via backend
	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()

	scanResp, err := client.ScanQRCode(ctx, &pb.ScanQRCodeRequest{
		QrData: []byte(qrData),
	})
	if err != nil || !scanResp.Success {
		errMsg := "unknown error"
		if err != nil {
			errMsg = err.Error()
		} else if scanResp.Error != "" {
			errMsg = scanResp.Error
		}
		fmt.Printf("Error processing QR data: %s\n", errMsg)
		return
	}

	fmt.Println()
	fmt.Println("╔══════════════════════════════════════════════════════════════╗")
	fmt.Println("║              CERTIFICATE SIGNING REQUEST                      ║")
	fmt.Println("╠══════════════════════════════════════════════════════════════╣")
	fmt.Printf("║  Node ID:          %-40s  ║\n", truncateStr(scanResp.NodeId, 40))
	fmt.Printf("║  Fingerprint:      %-40s  ║\n", scanResp.Fingerprint)
	fmt.Printf("║  Emoji Hash:       %-40s  ║\n", truncateStr(scanResp.EmojiHash, 40))
	fmt.Println("╠══════════════════════════════════════════════════════════════╣")
	fmt.Println("║  Sign this certificate? (yes/no)                              ║")
	fmt.Println("╚══════════════════════════════════════════════════════════════╝")

	fmt.Print("> ")
	response, _ := reader.ReadString('\n')
	response = strings.TrimSpace(strings.ToLower(response))

	if response != "yes" && response != "y" {
		if scanResp.SessionId != "" {
			_, _ = client.FinalizePairing(context.Background(), &pb.FinalizePairingRequest{
				SessionId: scanResp.SessionId,
				Accepted:  false,
			})
		}
		fmt.Println("Signing cancelled.")
		return
	}

	// Finalize via backend (session-based flow).
	if scanResp.SessionId == "" {
		fmt.Println("Error: backend did not return a scan session id")
		return
	}

	finalizeResp, err := client.FinalizePairing(ctx, &pb.FinalizePairingRequest{
		SessionId: scanResp.SessionId,
		Accepted:  true,
	})
	if err != nil {
		fmt.Printf("Error completing offline pairing: %v\n", err)
		return
	}
	if !finalizeResp.Success {
		errMsg := strings.TrimSpace(finalizeResp.Error)
		if errMsg == "" {
			errMsg = "unknown error"
		}
		fmt.Printf("Error completing offline pairing: %s\n", errMsg)
		return
	}

	fmt.Println()
	fmt.Println("Certificate signed! Show this response data to the node:")
	fmt.Println()
	fmt.Println(string(finalizeResp.QrData))

	if finalizeResp.Node != nil {
		fmt.Printf("\nNode registered: %s\n", finalizeResp.Node.NodeId)
	}

	fmt.Println()
	fmt.Println("Pairing complete! The node can now use this data.")
}

func truncateStr(s string, maxLen int) string {
	if len(s) <= maxLen {
		return s
	}
	return s[:maxLen-3] + "..."
}
