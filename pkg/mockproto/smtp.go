package mockproto

import (
	"fmt"
	"net"
	"strings"
	"time"
)

// sanitizeSMTPResponse removes CR/LF and other control characters from input
// to prevent SMTP response injection attacks
func sanitizeSMTPResponse(s string) string {
	var result strings.Builder
	result.Grow(len(s))
	for _, r := range s {
		// Only allow printable ASCII characters (space through tilde)
		if r >= 0x20 && r <= 0x7E {
			result.WriteRune(r)
		}
	}
	// Limit length to prevent excessively long error messages
	out := result.String()
	if len(out) > 32 {
		out = out[:32]
	}
	return out
}

// MockSMTP emulates an SMTP server.
// In tarpit mode, it pretends to accept everything but processes nothing.
func MockSMTP(conn net.Conn, config MockConfig) error {
	// Send banner (slow drip in tarpit mode)
	banner := "220 mail.example.com ESMTP Postfix (Ubuntu)\r\n"
	if config.Tarpit || config.DripBanner {
		interval := config.DripIntervalMs
		if interval == 0 {
			interval = 100
		}
		if err := DripWrite(conn, []byte(banner), interval); err != nil {
			return err
		}
	} else {
		conn.Write([]byte(banner))
	}

	if config.Tarpit {
		return smtpTarpit(conn)
	}

	// Normal mode
	var t *Tarpit
	buf := make([]byte, 1024)

	for {
		if config.RandomDelay {
			if t == nil {
				t = NewTarpit(200, 500, 10000)
			}
			t.Sleep()
		} else if config.DelayMs > 0 {
			time.Sleep(time.Duration(config.DelayMs) * time.Millisecond)
		}

		conn.SetReadDeadline(time.Now().Add(60 * time.Second))
		n, err := conn.Read(buf)
		if err != nil {
			return nil
		}

		cmdLine := string(buf[:n])
		cmd := strings.ToUpper(strings.TrimSpace(cmdLine))

		if strings.HasPrefix(cmd, "HELO") || strings.HasPrefix(cmd, "EHLO") {
			conn.Write([]byte("250-mail.example.com\r\n250-PIPELINING\r\n250-SIZE 10240000\r\n250-VRFY\r\n250-ETRN\r\n250-AUTH PLAIN LOGIN\r\n250-ENHANCEDSTATUSCODES\r\n250-8BITMIME\r\n250 DSN\r\n"))
		} else if strings.HasPrefix(cmd, "QUIT") {
			conn.Write([]byte("221 2.0.0 Bye\r\n"))
			return nil
		} else if strings.HasPrefix(cmd, "AUTH") {
			conn.Write([]byte("535 5.7.8 Error: authentication failed\r\n"))
		} else {
			conn.Write([]byte("502 5.5.2 Error: command not recognized\r\n"))
		}
	}
}

// smtpTarpit pretends to be a working mail server but never actually sends anything
func smtpTarpit(conn net.Conn) error {
	t := NewTarpit(300, 400, 15000)
	buf := make([]byte, 4096)

	inData := false
	authAttempts := 0

	for {
		conn.SetReadDeadline(time.Now().Add(300 * time.Second)) // Long timeout
		n, err := conn.Read(buf)
		if err != nil {
			return nil
		}

		t.Sleep()

		cmdLine := string(buf[:n])
		cmd := strings.ToUpper(strings.TrimSpace(cmdLine))

		// If we're in DATA mode, accept everything
		if inData {
			if strings.HasSuffix(strings.TrimSpace(cmdLine), "\r\n.\r\n") || cmdLine == ".\r\n" {
				inData = false
				// Pretend to queue, but with a fake error after delay
				time.Sleep(2 * time.Second)
				conn.Write([]byte("451 4.3.0 Mail server temporarily rejected message\r\n"))
			}
			continue
		}

		switch {
		case strings.HasPrefix(cmd, "EHLO"), strings.HasPrefix(cmd, "HELO"):
			// Advertise lots of capabilities to encourage engagement
			conn.Write([]byte("250-mail.example.com Hello\r\n"))
			conn.Write([]byte("250-SIZE 52428800\r\n"))
			conn.Write([]byte("250-8BITMIME\r\n"))
			conn.Write([]byte("250-PIPELINING\r\n"))
			conn.Write([]byte("250-AUTH PLAIN LOGIN CRAM-MD5\r\n"))
			conn.Write([]byte("250-STARTTLS\r\n"))
			conn.Write([]byte("250 SMTPUTF8\r\n"))

		case strings.HasPrefix(cmd, "AUTH"):
			authAttempts++
			// Rotate through auth failures
			failures := []string{
				"535 5.7.8 Error: authentication failed\r\n",
				"454 4.7.0 Temporary authentication failure\r\n",
				"535 5.7.1 Credentials Rejected\r\n",
				"454 4.7.1 Relay access denied\r\n",
			}
			conn.Write([]byte(failures[authAttempts%len(failures)]))

		case strings.HasPrefix(cmd, "STARTTLS"):
			// Pretend TLS is available but fail
			conn.Write([]byte("220 2.0.0 Ready to start TLS\r\n"))
			// They'll try to negotiate TLS and fail

		case strings.HasPrefix(cmd, "MAIL FROM"):
			conn.Write([]byte("250 2.1.0 Ok\r\n"))

		case strings.HasPrefix(cmd, "RCPT TO"):
			conn.Write([]byte("250 2.1.5 Ok\r\n"))

		case strings.HasPrefix(cmd, "DATA"):
			conn.Write([]byte("354 End data with <CR><LF>.<CR><LF>\r\n"))
			inData = true

		case strings.HasPrefix(cmd, "RSET"):
			conn.Write([]byte("250 2.0.0 Ok\r\n"))

		case strings.HasPrefix(cmd, "NOOP"):
			conn.Write([]byte("250 2.0.0 Ok\r\n"))

		case strings.HasPrefix(cmd, "VRFY"):
			// Pretend to verify but be slow
			time.Sleep(1 * time.Second)
			conn.Write([]byte("252 2.1.5 Cannot VRFY user, but will accept message\r\n"))

		case strings.HasPrefix(cmd, "QUIT"):
			// In tarpit mode, be slow to say goodbye
			time.Sleep(2 * time.Second)
			conn.Write([]byte("221 2.0.0 Bye\r\n"))
			return nil

		default:
			// Sanitize command before echoing to prevent SMTP response injection
			cmdWord := strings.Split(cmd, " ")[0]
			cmdWord = sanitizeSMTPResponse(cmdWord)
			conn.Write([]byte(fmt.Sprintf("500 5.5.1 Error: unknown command '%s'\r\n", cmdWord)))
		}
	}
}
