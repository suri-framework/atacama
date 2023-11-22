package main

import (
  "io"
	"fmt"
	"net"
	"os"
)

func main() {
	// Listen on TCP port 9090 on all interfaces.
	l, err := net.Listen("tcp", ":9090")
	if err != nil {
		fmt.Println("Error listening:", err.Error())
		os.Exit(1)
	}
	defer l.Close()
	fmt.Println("Listening on :9090")

	for {
		// Wait for a connection.
		conn, err := l.Accept()
		if err != nil {
			fmt.Println("Error accepting: ", err.Error())
			os.Exit(1)
		}

		// Handle the connection in a new goroutine.
		// The loop then returns to accepting, so that
		// multiple connections may be served concurrently.
		go handleRequest(conn)
	}
}

func handleRequest(conn net.Conn) {
	defer conn.Close()

	// Create a buffer to hold the received data.
	buffer := make([]byte, 1024)

	for {
		// Read the incoming data into the buffer.
		length, err := conn.Read(buffer)
		if err != nil {
			if err != io.EOF {
				fmt.Println("Error reading:", err.Error())
			}
			break
		}

		// Send the received data back to the client.
		_, err = conn.Write(buffer[:length])
		if err != nil {
			fmt.Println("Error writing:", err.Error())
			break
		}
	}
}
