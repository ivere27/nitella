package firebase

import (
	"context"
	"fmt"
	"log"

	firebase "firebase.google.com/go/v4"
	"firebase.google.com/go/v4/messaging"
	"google.golang.org/api/option"
)

// Service wraps Firebase Cloud Messaging client
type Service struct {
	client *messaging.Client
	app    *firebase.App
}

// NewService creates a new Firebase service
// If credentialsFile is empty, push notifications will be disabled
func NewService(credentialsFile string) (*Service, error) {
	if credentialsFile == "" {
		log.Println("[Firebase] Credentials not provided. Push notifications disabled.")
		return &Service{}, nil
	}

	opt := option.WithCredentialsFile(credentialsFile)
	app, err := firebase.NewApp(context.Background(), nil, opt)
	if err != nil {
		return nil, fmt.Errorf("error initializing app: %v", err)
	}

	client, err := app.Messaging(context.Background())
	if err != nil {
		return nil, fmt.Errorf("error getting messaging client: %v", err)
	}

	log.Println("[Firebase] Push notification service initialized")
	return &Service{client: client, app: app}, nil
}

// SendPush sends a push notification to a device token
func (s *Service) SendPush(token string, title, body string, data map[string]string) error {
	if s.client == nil {
		log.Println("[Firebase] Push skipped (no client):", title)
		return nil
	}

	message := &messaging.Message{
		Token: token,
		Notification: &messaging.Notification{
			Title: title,
			Body:  body,
		},
		Data: data,
	}

	_, err := s.client.Send(context.Background(), message)
	return err
}

// SendDataPush sends a data-only push notification (silent)
func (s *Service) SendDataPush(token string, data map[string]string) error {
	if s.client == nil {
		log.Println("[Firebase] Data push skipped (no client)")
		return nil
	}

	message := &messaging.Message{
		Token: token,
		Data:  data,
	}

	_, err := s.client.Send(context.Background(), message)
	return err
}

// SendMulticast sends a push notification to multiple device tokens
func (s *Service) SendMulticast(tokens []string, title, body string, data map[string]string) (*messaging.BatchResponse, error) {
	if s.client == nil {
		log.Println("[Firebase] Multicast skipped (no client):", title)
		return nil, nil
	}

	if len(tokens) == 0 {
		return nil, nil
	}

	message := &messaging.MulticastMessage{
		Tokens: tokens,
		Notification: &messaging.Notification{
			Title: title,
			Body:  body,
		},
		Data: data,
	}

	return s.client.SendEachForMulticast(context.Background(), message)
}

// IsEnabled returns true if the Firebase service is configured
func (s *Service) IsEnabled() bool {
	return s.client != nil
}

// PushTypes for data field
const (
	PushTypeApproval       = "approval"
	PushTypeNodeOnline     = "node_online"
	PushTypeNodeOffline    = "node_offline"
	PushTypeAlert          = "alert"
	PushTypeCommandResult  = "command_result"
	PushTypeMetrics        = "metrics"
)

// SendApprovalRequest sends a push notification for connection approval
func (s *Service) SendApprovalRequest(token, reqID, nodeID, sourceIP string) error {
	return s.SendPush(token, "Connection Approval Required",
		fmt.Sprintf("New connection from %s", sourceIP),
		map[string]string{
			"type":      PushTypeApproval,
			"req_id":    reqID,
			"node_id":   nodeID,
			"source_ip": sourceIP,
		})
}

// SendNodeStatus sends a push notification for node status change
func (s *Service) SendNodeStatus(token, nodeID string, online bool) error {
	status := "offline"
	pushType := PushTypeNodeOffline
	if online {
		status = "online"
		pushType = PushTypeNodeOnline
	}

	return s.SendPush(token, "Node Status Changed",
		fmt.Sprintf("Node is now %s", status),
		map[string]string{
			"type":    pushType,
			"node_id": nodeID,
			"status":  status,
		})
}

// SendSecurityAlert sends a push notification for security alerts
func (s *Service) SendSecurityAlert(token, nodeID, alertType, message string) error {
	return s.SendPush(token, "Security Alert",
		message,
		map[string]string{
			"type":       PushTypeAlert,
			"node_id":    nodeID,
			"alert_type": alertType,
		})
}
