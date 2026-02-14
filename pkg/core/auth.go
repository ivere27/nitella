package core

import (
	"context"
	"fmt"

	pbHub "github.com/ivere27/nitella/pkg/api/hub"
)

// RegisterUser registers the user with the Hub's AuthService.
func (c *Controller) RegisterUser(ctx context.Context, req *pbHub.RegisterUserRequest) (*pbHub.RegisterUserResponse, error) {
	c.mu.RLock()
	client := c.authClient
	c.mu.RUnlock()

	if client == nil {
		return nil, fmt.Errorf("not connected to Hub")
	}

	return client.RegisterUser(ctx, req)
}
