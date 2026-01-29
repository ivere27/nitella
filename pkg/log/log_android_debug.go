//go:build android && !release

package log

import (
	"C"
	"fmt"
	"log"
	"unsafe"
)

/*
#include <android/log.h>
#include <stdlib.h>

static void log_print(int prio, const char* tag, const char* msg) {
    __android_log_print(prio, tag, "%s", msg);
}
*/
import "C"

import "io"

const (
	tag = "Nitella"
)

const (
	Ldate = 1 << iota
	Ltime
	Lmicroseconds
	Llongfile
	Lshortfile
	LUTC
)

func SetOutput(w io.Writer) {
	// not supported on android
}

func SetFlags(flag int) {
	// not supported on android
}

func printLog(prio C.int, msg string) {
	tag_c := C.CString(tag)
	defer C.free(unsafe.Pointer(tag_c))

	// Android log limit is ~4096 bytes. We use 4000 to be safe.
	const maxLen = 4000

	for len(msg) > 0 {
		limit := maxLen
		if len(msg) <= limit {
			limit = len(msg)
		} else {
			// Ensure we don't split a rune (continuation byte check: 10xxxxxx)
			for limit > 0 && (msg[limit-1]&0xc0 == 0x80) {
				limit--
			}
		}

		chunk := msg[:limit]
		cMsg := C.CString(chunk)
		C.log_print(prio, tag_c, cMsg)
		C.free(unsafe.Pointer(cMsg))

		msg = msg[limit:]
	}
}

func Printf(format string, v ...interface{}) {
	printLog(C.ANDROID_LOG_DEBUG, fmt.Sprintf(format, v...))
}

func Println(v ...interface{}) {
	printLog(C.ANDROID_LOG_DEBUG, fmt.Sprintln(v...))
}

func Infof(format string, v ...interface{}) {
	printLog(C.ANDROID_LOG_INFO, fmt.Sprintf(format, v...))
}

func Warnf(format string, v ...interface{}) {
	printLog(C.ANDROID_LOG_WARN, fmt.Sprintf(format, v...))
}

func Errorf(format string, v ...interface{}) {
	printLog(C.ANDROID_LOG_ERROR, fmt.Sprintf(format, v...))
}

func Fatalf(format string, v ...interface{}) {
	msg := fmt.Sprintf(format, v...)
	printLog(C.ANDROID_LOG_FATAL, msg)
	log.Fatalf(msg)
}

func Debugf(format string, v ...interface{}) {
	printLog(C.ANDROID_LOG_DEBUG, fmt.Sprintf(format, v...))
}

func Fatal(v ...interface{}) {
	msg := fmt.Sprint(v...)
	printLog(C.ANDROID_LOG_FATAL, msg)
	log.Fatal(msg)
}

func Panicf(format string, v ...interface{}) {
	msg := fmt.Sprintf(format, v...)
	printLog(C.ANDROID_LOG_FATAL, msg)
	log.Panicf(msg)
}

// Tracef logs trace-level messages (no-op on Android release builds)
func Tracef(format string, v ...interface{}) {
	printLog(C.ANDROID_LOG_VERBOSE, fmt.Sprintf(format, v...))
}
