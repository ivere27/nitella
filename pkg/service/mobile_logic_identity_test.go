package service

import (
	"context"
	"testing"

	pb "github.com/ivere27/nitella/pkg/api/local"
)

func TestEvaluatePassphrase(t *testing.T) {
	svc := NewMobileLogicService()

	weak, err := svc.EvaluatePassphrase(context.Background(), &pb.EvaluatePassphraseRequest{
		Passphrase: "password",
	})
	if err != nil {
		t.Fatalf("EvaluatePassphrase(weak) error = %v", err)
	}
	if weak.GetStrength() != pb.PassphraseStrength_PASSPHRASE_STRENGTH_WEAK {
		t.Fatalf("weak strength = %v, want %v", weak.GetStrength(), pb.PassphraseStrength_PASSPHRASE_STRENGTH_WEAK)
	}
	if !weak.GetShouldWarn() {
		t.Fatalf("weak passphrase should warn")
	}

	strong, err := svc.EvaluatePassphrase(context.Background(), &pb.EvaluatePassphraseRequest{
		Passphrase: "correct horse battery staple!",
	})
	if err != nil {
		t.Fatalf("EvaluatePassphrase(strong) error = %v", err)
	}
	if strong.GetStrength() != pb.PassphraseStrength_PASSPHRASE_STRENGTH_STRONG {
		t.Fatalf("strong strength = %v, want %v", strong.GetStrength(), pb.PassphraseStrength_PASSPHRASE_STRENGTH_STRONG)
	}
	if strong.GetShouldWarn() {
		t.Fatalf("strong passphrase should not warn")
	}
}

func TestValidatePassphrasePolicy(t *testing.T) {
	if err := validatePassphrasePolicy("", false); err != nil {
		t.Fatalf("empty passphrase should be allowed: %v", err)
	}

	if err := validatePassphrasePolicy("password", false); err == nil {
		t.Fatalf("weak passphrase without override should be rejected")
	}

	if err := validatePassphrasePolicy("password", true); err != nil {
		t.Fatalf("weak passphrase with override should be allowed: %v", err)
	}

	if err := validatePassphrasePolicy("correct horse battery staple!", false); err != nil {
		t.Fatalf("strong passphrase should be allowed: %v", err)
	}
}
