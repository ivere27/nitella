package main

import (
	"flag"
	"fmt"
	"net"
	"os"
	"os/signal"
	"sync/atomic"
	"syscall"

	"github.com/ivere27/nitella/pkg/log"
	"github.com/ivere27/nitella/pkg/mockproto"
)

func main() {
	port := flag.Int("port", 8080, "Port to listen on")
	protocol := flag.String("protocol", "http", "Protocol to emulate (http, ssh, mysql, mssql, rdp, telnet, redis, smtp)")
	delay := flag.Int("delay", 0, "Delay in milliseconds before sending response")
	payloadStr := flag.String("payload", "", "Custom payload to send (overrides default)")
	tarpit := flag.Bool("tarpit", false, "Enable tarpit mode - waste attacker time with slow/endless responses")
	dripInterval := flag.Int("drip", 0, "Drip interval in ms (bytes sent one at a time with this delay)")
	maxConns := flag.Int("max-conns", 128, "Maximum concurrent connections (prevents resource exhaustion)")
	flag.Parse()

	addr := fmt.Sprintf("0.0.0.0:%d", *port)
	listener, err := net.Listen("tcp", addr)
	if err != nil {
		log.Fatalf("Failed to bind to %s: %v", addr, err)
	}

	log.Printf("Nitella Mock Server listening on %s", addr)
	log.Printf("Emulating Protocol: %s", *protocol)
	log.Printf("Max concurrent connections: %d", *maxConns)
	if *tarpit {
		log.Printf("TARPIT MODE ENABLED - connections will be held as long as possible")
	}

	payload := []byte(*payloadStr)

	// Connection limiter to prevent resource exhaustion
	connSem := make(chan struct{}, *maxConns)
	var activeConns atomic.Int64

	// Graceful shutdown
	go func() {
		sigCh := make(chan os.Signal, 1)
		signal.Notify(sigCh, os.Interrupt, syscall.SIGTERM)
		<-sigCh
		log.Printf("Shutting down Mock server... (active connections: %d)", activeConns.Load())
		listener.Close()
		os.Exit(0)
	}()

	for {
		conn, err := listener.Accept()
		if err != nil {
			log.Printf("Accept error: %v", err)
			continue
		}

		// Try to acquire connection slot (non-blocking)
		select {
		case connSem <- struct{}{}:
			// Got a slot, proceed
		default:
			// At capacity, reject connection
			log.Printf("Connection limit reached, rejecting %s", conn.RemoteAddr())
			conn.Close()
			continue
		}

		activeConns.Add(1)

		go func(c net.Conn) {
			defer func() {
				c.Close()
				<-connSem // Release slot
				activeConns.Add(-1)
			}()
			log.Printf("Connection from %s (active: %d)", c.RemoteAddr(), activeConns.Load())

			config := mockproto.MockConfig{
				Protocol:       *protocol,
				DelayMs:        *delay,
				Payload:        payload,
				Tarpit:         *tarpit,
				DripIntervalMs: *dripInterval,
				DripBanner:     *dripInterval > 0,
			}
			if err := mockproto.HandleConnection(c, config); err != nil {
				log.Printf("Error handling connection: %v", err)
			}
			log.Printf("Connection closed: %s", c.RemoteAddr())
		}(conn)
	}
}
