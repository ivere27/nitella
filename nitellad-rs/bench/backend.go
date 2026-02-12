package main

import (
	"flag"
	"fmt"
	"log"
	"net/http"
)

func main() {
	port := flag.Int("port", 9090, "Port to listen on")
	flag.Parse()

	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "text/plain")
		w.Write([]byte("Hello from backend"))
	})

	addr := fmt.Sprintf(":%d", *port)
	log.Printf("Backend server listening on %s", addr)
	log.Fatal(http.ListenAndServe(addr, nil))
}
