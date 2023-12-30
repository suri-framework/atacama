package main

import (
  "io"
	"fmt"
	"net"
	"os"
)

func main() {
	// Listen on TCP port 2112 on all interfaces.
	l, err := net.Listen("tcp", ":2112")
	if err != nil {
		fmt.Println("Error listening:", err.Error())
		os.Exit(1)
	}
	defer l.Close()
	fmt.Println("Listening on :2112")

	for {
		// Wait for a connection.
		conn, _ := l.Accept()
		go handleRequest(conn)
	}
}

func handleRequest(conn net.Conn) {
	defer conn.Close()
  io.Copy(conn, conn);
}
