// Package main provides the C-shared entry point for the mobile backend.
// This is compiled into a native library (.so for Android/Linux, .dylib/.framework for iOS)
// that the Flutter app calls via Synurang FFI.
package main

/*
#include <stdlib.h>

// Server startup arguments
struct CoreArgument {
    char* storagePath;
    char* cachePath;
    char* engineSocketPath;
    char* engineTcpPort;
    char* viewSocketPath;
    char* viewTcpPort;
    char* token;
    int enableCache;
    long long streamTimeout;
};

// FFI data structure for returning bytes
typedef struct {
    void* data;
    long long len;
} FfiData;

// Dart callback signature
typedef void (*InvokeDartCallback)(long long requestId, char* method, void* data, long long len);

static void invoke_dart_callback(InvokeDartCallback cb, long long requestId, char* method, void* data, long long len) {
    if (cb) {
        cb(requestId, method, data, len);
    }
}

// Stream callback signature (for server/bidi streaming)
typedef void (*StreamCallback)(long long streamId, char msgType, void* data, long long len);

static void invoke_stream_callback(StreamCallback cb, long long streamId, char msgType, void* data, long long len) {
    if (cb) {
        cb(streamId, msgType, data, len);
    }
}
*/
import "C"

import (
	"context"
	"fmt"
	"log"
	"os"
	"runtime"
	"strconv"
	"sync"
	"sync/atomic"
	"time"
	"unsafe"

	pb "github.com/ivere27/nitella/pkg/api/local"
	nitellaPprof "github.com/ivere27/nitella/pkg/pprof"
	"github.com/ivere27/nitella/pkg/service"
	"google.golang.org/protobuf/proto"
)

// Default timeout for all FFI calls. This prevents blocking indefinitely
// when Hub or other network operations are slow/unresponsive.
// Dart has a 30s timeout, so we use 28s to return a proper error.
const ffiTimeout = 28 * time.Second

var (
	mobileService  *service.MobileLogicService
	serviceMu      sync.RWMutex
	initialized    bool
	dartCallback   C.InvokeDartCallback
	dartCallbackMu sync.RWMutex

	// Debug monitoring
	debugEnabled     = false
	activeFFICalls   int64 // Atomic counter for in-flight FFI calls
	totalFFICalls    int64 // Total FFI calls since start
	peakGoroutines   int64 // Peak goroutine count (atomic)
	startTime        time.Time
	lastCallTime     time.Time
	lastCallTimeMu   sync.Mutex
	debugLogInterval = 100 // Log debug info every N calls
)

const (
	dartMethodOnApprovalRequest = "/nitella.local.MobileUIService/OnApprovalRequest"
	dartMethodOnNodeStatus      = "/nitella.local.MobileUIService/OnNodeStatusChange"
	dartMethodOnConnectionEvent = "/nitella.local.MobileUIService/OnConnectionEvent"
	dartMethodOnAlert           = "/nitella.local.MobileUIService/OnAlert"
	dartMethodOnToast           = "/nitella.local.MobileUIService/OnToast"
)

type dartUICallback struct{}

var invokeDartFn = InvokeDart

func invokeDartProto(method string, msg proto.Message) error {
	payload, err := proto.Marshal(msg)
	if err != nil {
		return fmt.Errorf("failed to marshal %s payload: %w", method, err)
	}
	if _, err := invokeDartFn(method, payload); err != nil {
		return fmt.Errorf("failed to invoke dart %s: %w", method, err)
	}
	return nil
}

func (d *dartUICallback) OnApprovalRequest(req *pb.ApprovalRequest) error {
	if req == nil {
		return nil
	}
	return invokeDartProto(dartMethodOnApprovalRequest, req)
}

func (d *dartUICallback) OnNodeStatusChange(change *pb.NodeStatusChange) error {
	if change == nil {
		return nil
	}
	return invokeDartProto(dartMethodOnNodeStatus, change)
}

func (d *dartUICallback) OnConnectionEvent(event *pb.ConnectionEvent) error {
	if event == nil {
		return nil
	}
	return invokeDartProto(dartMethodOnConnectionEvent, event)
}

func (d *dartUICallback) OnAlert(alert *pb.Alert) error {
	if alert == nil {
		return nil
	}
	return invokeDartProto(dartMethodOnAlert, alert)
}

func (d *dartUICallback) OnToast(msg *pb.ToastMessage) error {
	if msg == nil {
		return nil
	}
	return invokeDartProto(dartMethodOnToast, msg)
}

// =============================================================================
// Debug Monitoring
// =============================================================================

var debugLogFile *os.File

func initDebugLog() {
	if !debugEnabled {
		return
	}
	var err error
	debugLogFile, err = os.OpenFile("/tmp/nitella_debug.log", os.O_CREATE|os.O_WRONLY|os.O_TRUNC, 0644)
	if err != nil {
		log.Printf("Failed to open debug log: %v", err)
		return
	}
	debugLog("Debug logging initialized")
}

func debugLog(format string, args ...interface{}) {
	if debugLogFile == nil {
		return
	}
	msg := fmt.Sprintf("[%s] %s\n", time.Now().Format("15:04:05.000"), fmt.Sprintf(format, args...))
	debugLogFile.WriteString(msg)
	debugLogFile.Sync()
}

func logDebugStats(method string) {
	if !debugEnabled {
		return
	}

	total := atomic.LoadInt64(&totalFFICalls)
	// Log every 10 calls
	if total%10 != 0 && total > 1 {
		return
	}

	active := atomic.LoadInt64(&activeFFICalls)
	numGoroutines := runtime.NumGoroutine()

	// Track peak goroutines (atomic)
	for {
		peak := atomic.LoadInt64(&peakGoroutines)
		if int64(numGoroutines) <= peak {
			break
		}
		if atomic.CompareAndSwapInt64(&peakGoroutines, peak, int64(numGoroutines)) {
			break
		}
	}

	// Get memory stats
	var m runtime.MemStats
	runtime.ReadMemStats(&m)

	elapsed := time.Since(startTime)

	debugLog("FFI Stats after %d calls (%.1fs): goroutines=%d (peak=%d), active_ffi=%d, heap=%.1fMB, alloc=%.1fMB, sys=%.1fMB, gc=%d, method=%s",
		total,
		elapsed.Seconds(),
		numGoroutines,
		atomic.LoadInt64(&peakGoroutines),
		active,
		float64(m.HeapAlloc)/(1024*1024),
		float64(m.Alloc)/(1024*1024),
		float64(m.Sys)/(1024*1024),
		m.NumGC,
		method,
	)

	// Warn if goroutines are growing abnormally
	if numGoroutines > 100 {
		debugLog("[WARN] High goroutine count: %d", numGoroutines)
	}

	// Warn if active calls are stuck
	if active > 10 {
		debugLog("[WARN] Many active FFI calls: %d (possible blocking)", active)
	}
}

func logCallStart(method string) {
	active := atomic.AddInt64(&activeFFICalls, 1)
	total := atomic.AddInt64(&totalFFICalls, 1)

	lastCallTimeMu.Lock()
	lastCallTime = time.Now()
	lastCallTimeMu.Unlock()

	// Log every call start
	debugLog(">>> CALL START #%d: %s (active=%d)", total, method, active)
}

func logCallEnd(method string, startT time.Time) {
	active := atomic.AddInt64(&activeFFICalls, -1)
	total := atomic.LoadInt64(&totalFFICalls)
	duration := time.Since(startT)

	// Log every call end
	debugLog("<<< CALL END #%d: %s took %.3fs (active=%d)", total, method, duration.Seconds(), active)

	if duration > 5*time.Second {
		debugLog("[WARN] Slow FFI call: %s took %.2fs", method, duration.Seconds())
	}

	logDebugStats(method)
}

// =============================================================================
// FFI Exports - Server Lifecycle
// =============================================================================

//export StartGrpcServer
func StartGrpcServer(cArg C.struct_CoreArgument) C.int {
	log.Println("Nitella Mobile Backend - StartGrpcServer called")

	serviceMu.Lock()
	defer serviceMu.Unlock()

	if initialized {
		log.Println("Nitella Mobile Backend - already initialized")
		return 0
	}

	// Initialize debug timing and logging
	startTime = time.Now()
	initDebugLog()
	debugLog("Starting with debug monitoring enabled, initial goroutines: %d", runtime.NumGoroutine())

	// Start pprof if env var is set (no flag parsing in CGO/FFI binary)
	if portStr := os.Getenv("NITELLA_PPROF_PORT"); portStr != "" {
		if port, err := strconv.Atoi(portStr); err == nil {
			nitellaPprof.Start(port)
		}
	}

	// Create mobile logic service
	mobileService = service.NewMobileLogicService()
	mobileService.SetUICallback(&dartUICallback{})

	// Initialize with data directory from args
	var dataDir string
	if unsafe.Pointer(cArg.storagePath) != nil {
		dataDir = C.GoString(cArg.storagePath)
	}

	ctx := context.Background()
	resp, err := mobileService.Initialize(ctx, &pb.InitializeRequest{
		DataDir: dataDir,
	})

	if err != nil {
		log.Printf("Nitella Mobile Backend - Initialize failed: %v", err)
		return -1
	}

	if !resp.Success {
		log.Printf("Nitella Mobile Backend - Initialize failed: %s", resp.Error)
		return -1
	}

	initialized = true
	log.Printf("Nitella Mobile Backend - Initialized: dataDir=%s, identity=%v, locked=%v",
		dataDir, resp.IdentityExists, resp.IdentityLocked)

	return 0
}

//export StopGrpcServer
func StopGrpcServer() C.int {
	log.Println("Nitella Mobile Backend - StopGrpcServer called")

	serviceMu.Lock()
	defer serviceMu.Unlock()

	if !initialized || mobileService == nil {
		return 0
	}

	ctx := context.Background()
	mobileService.Shutdown(ctx, nil)
	mobileService = nil
	initialized = false

	return 0
}

// =============================================================================
// FFI Exports - Backend Invocation (Dart -> Go)
// =============================================================================

//export InvokeBackend
func InvokeBackend(method *C.char, data unsafe.Pointer, dataLen C.longlong) C.FfiData {
	goMethod := C.GoString(method)
	callStart := time.Now()
	logCallStart(goMethod)
	defer logCallEnd(goMethod, callStart)

	serviceMu.RLock()
	svc := mobileService
	serviceMu.RUnlock()

	if svc == nil {
		errStr := "Service not initialized"
		cErr := C.CBytes([]byte(errStr))
		return C.FfiData{data: cErr, len: C.longlong(-len(errStr))}
	}

	var goData []byte
	if dataLen > 0 {
		goData = C.GoBytes(data, C.int(dataLen))
	}

	// Create context with timeout to prevent indefinite blocking
	ctx, cancel := context.WithTimeout(context.Background(), ffiTimeout)
	defer cancel()

	// Use the generated FFI Invoke function
	respData, err := pb.Invoke(svc, ctx, goMethod, goData)
	if err != nil {
		errStr := err.Error()
		cErr := C.CBytes([]byte(errStr))
		return C.FfiData{data: cErr, len: C.longlong(-len(errStr))}
	}

	cResp := C.CBytes(respData)
	return C.FfiData{data: cResp, len: C.longlong(len(respData))}
}

//export InvokeBackendWithMeta
func InvokeBackendWithMeta(method *C.char, data unsafe.Pointer, dataLen C.longlong,
	metaData unsafe.Pointer, metaLen C.longlong) C.FfiData {
	// For now, just forward to InvokeBackend (metadata not used yet)
	return InvokeBackend(method, data, dataLen)
}

//export FreeFfiData
func FreeFfiData(data unsafe.Pointer) {
	if data != nil {
		C.free(data)
	}
}

// =============================================================================
// FFI Exports - Dart Callback (Go -> Dart)
// =============================================================================

var (
	pendingRequests   = make(map[int64]chan []byte)
	pendingRequestsMu sync.Mutex
	requestCounter    int64
)

//export RegisterDartCallback
func RegisterDartCallback(callback C.InvokeDartCallback) {
	log.Printf("Nitella Mobile Backend - RegisterDartCallback called")
	dartCallbackMu.Lock()
	dartCallback = callback
	dartCallbackMu.Unlock()
}

//export SendFfiResponse
func SendFfiResponse(requestId C.longlong, data unsafe.Pointer, dataLen C.longlong) {
	pendingRequestsMu.Lock()
	ch, ok := pendingRequests[int64(requestId)]
	if ok {
		delete(pendingRequests, int64(requestId))
	}
	pendingRequestsMu.Unlock()

	if ok && ch != nil {
		goData := C.GoBytes(data, C.int(dataLen))
		ch <- goData
	}
}

// InvokeDart calls a Dart method and waits for response
func InvokeDart(method string, data []byte) ([]byte, error) {
	dartCallbackMu.RLock()
	callback := dartCallback
	dartCallbackMu.RUnlock()
	if callback == nil {
		return nil, fmt.Errorf("dart callback not registered")
	}

	// Create request channel
	pendingRequestsMu.Lock()
	requestCounter++
	reqId := requestCounter
	ch := make(chan []byte, 1)
	pendingRequests[reqId] = ch
	pendingRequestsMu.Unlock()

	// Call Dart
	cMethod := C.CString(method)
	defer C.free(unsafe.Pointer(cMethod))

	var cData unsafe.Pointer
	if len(data) > 0 {
		cData = C.CBytes(data)
		defer C.free(cData)
	}

	C.invoke_dart_callback(callback, C.longlong(reqId), cMethod, cData, C.longlong(len(data)))

	// Wait for response with timeout
	select {
	case resp := <-ch:
		return resp, nil
	case <-time.After(ffiTimeout):
		pendingRequestsMu.Lock()
		delete(pendingRequests, reqId)
		pendingRequestsMu.Unlock()
		return nil, fmt.Errorf("timeout waiting for Dart response")
	}
}

// =============================================================================
// FFI Exports - Streaming Support (stub implementations)
// =============================================================================

//export RegisterStreamCallback
func RegisterStreamCallback(callback C.StreamCallback) {
	log.Println("Nitella Mobile Backend - RegisterStreamCallback called (stub)")
}

//export InvokeBackendServerStream
func InvokeBackendServerStream(method *C.char, data unsafe.Pointer, dataLen C.longlong) C.longlong {
	log.Println("Nitella Mobile Backend - InvokeBackendServerStream called (stub)")
	return -1
}

//export InvokeBackendClientStream
func InvokeBackendClientStream(method *C.char) C.longlong {
	log.Println("Nitella Mobile Backend - InvokeBackendClientStream called (stub)")
	return -1
}

//export InvokeBackendBidiStream
func InvokeBackendBidiStream(method *C.char) C.longlong {
	log.Println("Nitella Mobile Backend - InvokeBackendBidiStream called (stub)")
	return -1
}

//export SendStreamData
func SendStreamData(streamId C.longlong, data unsafe.Pointer, dataLen C.longlong) C.int {
	return -1
}

//export CloseStream
func CloseStream(streamId C.longlong) {}

//export CloseStreamInput
func CloseStreamInput(streamId C.longlong) {}

//export StreamReady
func StreamReady(streamId C.longlong) {}

// =============================================================================
// Cache FFI Exports (stub implementations)
// =============================================================================

//export CacheGet
func CacheGet(storeName *C.char, key *C.char) C.FfiData {
	return C.FfiData{data: nil, len: 0}
}

//export CachePut
func CachePut(storeName *C.char, key *C.char, data unsafe.Pointer, dataLen C.longlong, ttlSeconds C.longlong) C.int {
	return -1
}

//export CacheContains
func CacheContains(storeName *C.char, key *C.char) C.int {
	return -1
}

//export CacheDelete
func CacheDelete(storeName *C.char, key *C.char) C.int {
	return -1
}

// Required for c-shared build mode
func main() {}
