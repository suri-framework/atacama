# Bench

A small benchamrk of echo TCP servers in Atacama, Go, and Rust.

**Atacama**
```
; tcpkali 0.0.0.0:2112 -m 'hello world' -c 100
Destination: [0.0.0.0]:2112
Interface lo0 address [127.0.0.1]:0
Using interface lo0 to connect to [0.0.0.0]:2112
Ramped up to 100 connections.
Total data sent:     842.9 MiB (883803360 bytes)
Total data received: 837.2 MiB (877893888 bytes)
Bandwidth per channel: 14.091⇅ Mbps (1761.3 kBps)
Aggregate bandwidth: 702.173↓, 706.900↑ Mbps
Packet rate estimate: 83958.5↓, 62348.4↑ (1↓, 10↑ TCP MSS/op)
Test duration: 10.002 s.
```

**Rust**
```
; tcpkali 0.0.0.0:2112 -m 'hello world' -c 100
Destination: [0.0.0.0]:2112
Interface lo0 address [127.0.0.1]:0
Using interface lo0 to connect to [0.0.0.0]:2112
Ramped up to 100 connections.
Total data sent:     6150.2 MiB (6448986808 bytes)
Total data received: 6151.4 MiB (6450161806 bytes)
Bandwidth per channel: 103.173⇅ Mbps (12896.6 kBps)
Aggregate bandwidth: 5159.115↓, 5158.175↑ Mbps
Packet rate estimate: 483614.0↓, 442147.2↑ (7↓, 11↑ TCP MSS/op)
Test duration: 10.002 s.
```

**Go**
```
; tcpkali 0.0.0.0:2112 -m 'hello world' -c 100
Destination: [0.0.0.0]:2112
Interface lo0 address [127.0.0.1]:0
Using interface lo0 to connect to [0.0.0.0]:2112
Ramped up to 100 connections.
Total data sent:     2650.8 MiB (2779579020 bytes)
Total data received: 2674.6 MiB (2804550044 bytes)
Bandwidth per channel: 44.639⇅ Mbps (5579.8 kBps)
Aggregate bandwidth: 2241.906↓, 2221.945↑ Mbps
Packet rate estimate: 192248.3↓, 201218.1↑ (2↓, 11↑ TCP MSS/op)
Test duration: 10.0077 s.
```
