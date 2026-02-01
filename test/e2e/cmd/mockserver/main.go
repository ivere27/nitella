// Package main provides a mock backend server for E2E testing
package main

import (
	"fmt"
	"io"
	"net"
	"net/http"
	"os"
	"strings"
	"time"
)

func main() {
	protocol := os.Getenv("PROTOCOL")
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	switch protocol {
	case "http":
		runHTTPServer(port)
	case "ssh":
		runTCPEchoServer(port, "SSH-2.0-MockServer\r\n")
	case "mysql":
		runTCPEchoServer(port, mysqlGreeting())
	case "rdp":
		runTCPEchoServer(port, "RDP Mock Server Ready\n")
	case "smtp":
		runTCPEchoServer(port, "220 mock.smtp.local ESMTP\r\n")
	case "custom":
		runTCPEchoServer(port, "CUSTOM PROTOCOL v1.0\n")
	default:
		runHTTPServer(port)
	}
}

func runHTTPServer(port string) {
	mux := http.NewServeMux()

	// Health check
	mux.HandleFunc("/health", func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
		w.Write([]byte("OK"))
	})

	// Echo endpoint - returns request info
	mux.HandleFunc("/echo", func(w http.ResponseWriter, r *http.Request) {
		body, _ := io.ReadAll(r.Body)
		response := fmt.Sprintf("Method: %s\nPath: %s\nHeaders: %v\nBody: %s\n",
			r.Method, r.URL.Path, r.Header, string(body))
		w.Write([]byte(response))
	})

	// Delay endpoint for timeout testing
	mux.HandleFunc("/delay/", func(w http.ResponseWriter, r *http.Request) {
		parts := strings.Split(r.URL.Path, "/")
		if len(parts) >= 3 {
			var delay time.Duration
			fmt.Sscanf(parts[2], "%dms", &delay)
			time.Sleep(delay * time.Millisecond)
		}
		w.Write([]byte("Delayed response"))
	})

	// Status endpoint - returns requested status code
	mux.HandleFunc("/status/", func(w http.ResponseWriter, r *http.Request) {
		parts := strings.Split(r.URL.Path, "/")
		if len(parts) >= 3 {
			var code int
			fmt.Sscanf(parts[2], "%d", &code)
			w.WriteHeader(code)
		}
		w.Write([]byte("Status response"))
	})

	// Default handler
	mux.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		w.Write([]byte(fmt.Sprintf("Mock HTTP Server - Path: %s", r.URL.Path)))
	})

	addr := ":" + port
	fmt.Printf("Mock HTTP server listening on %s\n", addr)
	http.ListenAndServe(addr, mux)
}

func runTCPEchoServer(port, greeting string) {
	addr := ":" + port
	listener, err := net.Listen("tcp", addr)
	if err != nil {
		fmt.Printf("Failed to listen on %s: %v\n", addr, err)
		os.Exit(1)
	}
	defer listener.Close()

	fmt.Printf("Mock TCP server (%s) listening on %s\n", os.Getenv("PROTOCOL"), addr)

	for {
		conn, err := listener.Accept()
		if err != nil {
			continue
		}
		go handleTCPConnection(conn, greeting)
	}
}

func handleTCPConnection(conn net.Conn, greeting string) {
	defer conn.Close()

	// Send greeting
	conn.Write([]byte(greeting))

	// Echo loop
	buf := make([]byte, 4096)
	for {
		conn.SetReadDeadline(time.Now().Add(30 * time.Second))
		n, err := conn.Read(buf)
		if err != nil {
			return
		}
		conn.Write(buf[:n])
	}
}

func mysqlGreeting() string {
	// Simplified MySQL protocol greeting
	return string([]byte{
		0x4a, 0x00, 0x00, 0x00, 0x0a, // packet header + protocol version
		0x35, 0x2e, 0x37, 0x2e, 0x33, 0x36, 0x00, // version "5.7.36"
	})
}
