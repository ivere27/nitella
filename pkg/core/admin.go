package core

import (
	"context"
	"fmt"

	pbHub "github.com/ivere27/nitella/pkg/api/hub"
)

// GetLogsStats returns logs storage statistics from the Hub.
func (c *Controller) GetLogsStats(ctx context.Context, req *pbHub.GetLogsStatsRequest) (*pbHub.LogsStats, error) {
	c.mu.RLock()
	client := c.adminClient
	c.mu.RUnlock()

	if client == nil {
		return nil, fmt.Errorf("not connected to Hub")
	}

	return client.GetLogsStats(ctx, req)
}

// ListLogs lists logs for a routing token from the Hub.
func (c *Controller) ListLogs(ctx context.Context, req *pbHub.ListLogsRequest) (*pbHub.ListLogsResponse, error) {
	c.mu.RLock()
	client := c.adminClient
	c.mu.RUnlock()

	if client == nil {
		return nil, fmt.Errorf("not connected to Hub")
	}

	return client.ListLogs(ctx, req)
}

// DeleteLogs deletes logs for a routing token from the Hub.
func (c *Controller) DeleteLogs(ctx context.Context, req *pbHub.DeleteLogsRequest) (*pbHub.DeleteLogsResponse, error) {
	c.mu.RLock()
	client := c.adminClient
	c.mu.RUnlock()

	if client == nil {
		return nil, fmt.Errorf("not connected to Hub")
	}

	return client.DeleteLogs(ctx, req)
}

// CleanupOldLogs removes logs older than the specified number of days.
func (c *Controller) CleanupOldLogs(ctx context.Context, req *pbHub.CleanupOldLogsRequest) (*pbHub.CleanupOldLogsResponse, error) {
	c.mu.RLock()
	client := c.adminClient
	c.mu.RUnlock()

	if client == nil {
		return nil, fmt.Errorf("not connected to Hub")
	}

	return client.CleanupOldLogs(ctx, req)
}
