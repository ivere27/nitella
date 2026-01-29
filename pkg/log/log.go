//go:build !android

package log

import (
	"fmt"
	"io"
	"log"
	"os"
)

const (
	Ldate         = 1 << iota // the date in the local time zone: 2009/01/23
	Ltime                     // the time in the local time zone: 01:23:23
	Lmicroseconds             // microsecond resolution: 01:23:23.123123.  assumes Ltime.
	Llongfile                 // full file name and line number: /a/b/c/d.go:23
	Lshortfile                // final file name element and line number: d.go:23. overrides Llongfile
	LUTC                      // if Ldate or Ltime is set, use UTC rather than the local time zone
)

func SetOutput(w io.Writer) {
	log.SetOutput(w)
}

func SetFlags(flag int) {
	log.SetFlags(flag)
}

func Infof(format string, v ...interface{}) {
	log.Printf("INFO: "+format, v...)
}

func Warnf(format string, v ...interface{}) {
	log.Printf("WARN: "+format, v...)
}

func Errorf(format string, v ...interface{}) {
	log.Printf("ERROR: "+format, v...)
}

func Fatalf(format string, v ...interface{}) {
	log.Fatalf("FATAL: "+format, v...)
}

func Fatal(v ...interface{}) {
	log.Fatal("FATAL: ", fmt.Sprint(v...))
}

func Panicf(format string, v ...interface{}) {
	msg := fmt.Sprintf(format, v...)
	log.Panic("PANIC: " + msg)
}

func Println(v ...interface{}) {
	log.Println(v...)
}

func Printf(format string, v ...interface{}) {
	log.Printf(format, v...)
}

func Debugf(format string, v ...interface{}) {
	log.Printf("DEBUG: "+format, v...)
}

// traceEnabled controls verbose trace logging (set NITELLA_TRACE=1 to enable)
var traceEnabled = os.Getenv("NITELLA_TRACE") == "1"

// Tracef logs trace-level messages only when NITELLA_TRACE=1 is set.
// Use for development debugging that should be silent in production.
func Tracef(format string, v ...interface{}) {
	if traceEnabled {
		log.Printf("TRACE: "+format, v...)
	}
}
