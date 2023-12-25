# Bench

A small benchamrk of the throughput of echo TCP servers in OCaml+Atacama, OCaml+Eio, Go, Elixir, Erlang, and Rust.


| name | 100conn/10s | 100conn/60s |
|------|-------------|--------------|
| Atacama | 422.3 Mbps | 403.7 Mbps |
| Eio | 40.5 Mbps | 42.5 Mbps |
| Erlang | 512.3 Mbps | 509.2 Mbps |
| Elixir | 516.5 Mbps | 522.6 Mbps |
| Go | 191.8 Mbps | 215.0 Mbps |
| Rust | 226.5 Mbps | 230.8 Mbps |

**Atacama**
```
; tcpkali 0.0.0.0:2112 -m 'hello world' -c 100 -T 10s
Destination: [0.0.0.0]:2112
Interface lo0 address [127.0.0.1]:0
Using interface lo0 to connect to [0.0.0.0]:2112
Ramped up to 100 connections.
Total data sent:     25513.4 MiB (26752753101 bytes)
Total data received: 24847.8 MiB (26054801677 bytes)
Bandwidth per channel: 422.389⇅ Mbps (52798.6 kBps)
Aggregate bandwidth: 20840.315↓, 21398.581↑ Mbps
Packet rate estimate: 1878102.7↓, 1866407.3↑ (11↓, 32↑ TCP MSS/op)
Test duration: 10.0017 s.

; tcpkali 0.0.0.0:2112 -m 'hello world' -c 100 -T 60s
Destination: [0.0.0.0]:2112
Interface lo0 address [127.0.0.1]:0
Using interface lo0 to connect to [0.0.0.0]:2112
Ramped up to 100 connections.
Total data sent:     148813.4 MiB (156042115329 bytes)
Total data received: 139995.0 MiB (146795369411 bytes)
Bandwidth per channel: 403.758⇅ Mbps (50469.8 kBps)
Aggregate bandwidth: 19571.504↓, 20804.327↑ Mbps
Packet rate estimate: 1773350.3↓, 1827960.7↑ (11↓, 29↑ TCP MSS/op)
Test duration: 60.0037 s.
```

**Eio**
```
; tcpkali 0.0.0.0:2112 -m 'hello world' -c 100 -T 10s
Destination: [0.0.0.0]:2112
Interface lo0 address [127.0.0.1]:0
Using interface lo0 to connect to [0.0.0.0]:2112
Ramped up to 100 connections.
Total data sent:     2419.0 MiB (2536503252 bytes)
Total data received: 2414.3 MiB (2531559424 bytes)
Bandwidth per channel: 40.525⇅ Mbps (5065.7 kBps)
Aggregate bandwidth: 2024.294↓, 2028.247↑ Mbps
Packet rate estimate: 321717.3↓, 178558.7↑ (2↓, 9↑ TCP MSS/op)
Test duration: 10.0047 s.

; tcpkali 0.0.0.0:2112 -m 'hello world' -c 100 -T 60s
Destination: [0.0.0.0]:2112
Interface lo0 address [127.0.0.1]:0
Using interface lo0 to connect to [0.0.0.0]:2112
Ramped up to 100 connections.
Total data sent:     15236.8 MiB (15976934476 bytes)
Total data received: 15233.2 MiB (15973169152 bytes)
Bandwidth per channel: 42.595⇅ Mbps (5324.4 kBps)
Aggregate bandwidth: 2129.498↓, 2130.000↑ Mbps
Packet rate estimate: 292793.5↓, 189698.2↑ (2↓, 9↑ TCP MSS/op)
Test duration: 60.0073 s.
```

**Erlang** (using `ranch`)
```
; tcpkali 0.0.0.0:2112 -m 'hello world' -c 100 -T 10s
Destination: [0.0.0.0]:2112
Interface lo0 address [127.0.0.1]:0
Using interface lo0 to connect to [0.0.0.0]:2112
Ramped up to 100 connections.
Total data sent:     30570.8 MiB (32055855196 bytes)
Total data received: 30567.9 MiB (32052792122 bytes)
Bandwidth per channel: 512.354⇅ Mbps (64044.3 kBps)
Aggregate bandwidth: 25616.486↓, 25618.934↑ Mbps
Packet rate estimate: 2358452.8↓, 2236264.3↑ (11↓, 32↑ TCP MSS/op)
Test duration: 10.0101 s.

; tcpkali 0.0.0.0:2112 -m 'hello world' -c 100 -T 60s
Destination: [0.0.0.0]:2112
Interface lo0 address [127.0.0.1]:0
Using interface lo0 to connect to [0.0.0.0]:2112
Ramped up to 100 connections.
Total data sent:     182150.6 MiB (190998718780 bytes)
Total data received: 182147.4 MiB (190995389066 bytes)
Bandwidth per channel: 509.271⇅ Mbps (63658.9 kBps)
Aggregate bandwidth: 25463.339↓, 25463.783↑ Mbps
Packet rate estimate: 2344498.8↓, 2229571.5↑ (11↓, 32↑ TCP MSS/op)
Test duration: 60.0064 s.

```

**Elixir** (using `Thousand_island`)
```
; tcpkali 0.0.0.0:2112 -m 'hello world' -c 100 -T 10s
Destination: [0.0.0.0]:2112
Interface lo0 address [127.0.0.1]:0
Using interface lo0 to connect to [0.0.0.0]:2112
Ramped up to 100 connections.
Total data sent:     30816.3 MiB (32313268797 bytes)
Total data received: 30810.2 MiB (32306869965 bytes)
Bandwidth per channel: 516.500⇅ Mbps (64562.5 kBps)
Aggregate bandwidth: 25822.432↓, 25827.546↑ Mbps
Packet rate estimate: 2362854.3↓, 2264300.8↑ (11↓, 32↑ TCP MSS/op)
Test duration: 10.0089 s.

; tcpkali 0.0.0.0:2112 -m 'hello world' -c 100 -T 60s
Destination: [0.0.0.0]:2112
Interface lo0 address [127.0.0.1]:0
Using interface lo0 to connect to [0.0.0.0]:2112
Ramped up to 100 connections.
Total data sent:     186935.8 MiB (196016391062 bytes)
Total data received: 186933.5 MiB (196013961896 bytes)
Bandwidth per channel: 522.645⇅ Mbps (65330.6 kBps)
Aggregate bandwidth: 26132.093↓, 26132.417↑ Mbps
Packet rate estimate: 2397917.3↓, 2283473.0↑ (11↓, 32↑ TCP MSS/op)
Test duration: 60.0071 s.

```

**Rust**
```
; tcpkali 0.0.0.0:2112 -m 'hello world' -c 100
Destination: [0.0.0.0]:2112
Interface lo0 address [127.0.0.1]:0
Using interface lo0 to connect to [0.0.0.0]:2112
Ramped up to 100 connections.
Total data sent:     13491.3 MiB (14146638341 bytes)
Total data received: 13502.8 MiB (14158743871 bytes)
Bandwidth per channel: 226.252⇅ Mbps (28281.5 kBps)
Aggregate bandwidth: 11317.453↓, 11307.777↑ Mbps
Packet rate estimate: 1030238.4↓, 989473.3↑ (11↓, 25↑ TCP MSS/op)
Test duration: 10.0084 s.

; tcpkali 0.0.0.0:2112 -m 'hello world' -c 100 -T 60s
Destination: [0.0.0.0]:2112
Interface lo0 address [127.0.0.1]:0
Using interface lo0 to connect to [0.0.0.0]:2112
Ramped up to 100 connections.
Total data sent:     82578.7 MiB (86590063452 bytes)
Total data received: 82568.5 MiB (86579363443 bytes)
Bandwidth per channel: 230.888⇅ Mbps (28860.9 kBps)
Aggregate bandwidth: 11543.666↓, 11545.092↑ Mbps
Packet rate estimate: 1079342.5↓, 1024215.4↑ (11↓, 23↑ TCP MSS/op)
Test duration: 60.0013 s.

```

**Go**
```
; tcpkali 0.0.0.0:2112 -m 'hello world' -c 100 -T 10s
Destination: [0.0.0.0]:2112
Interface lo0 address [127.0.0.1]:0
Using interface lo0 to connect to [0.0.0.0]:2112
Ramped up to 100 connections.
Total data sent:     11437.1 MiB (11992702112 bytes)
Total data received: 11451.3 MiB (12007586255 bytes)
Bandwidth per channel: 191.817⇅ Mbps (23977.1 kBps)
Aggregate bandwidth: 9596.798↓, 9584.903↑ Mbps
Packet rate estimate: 839743.8↓, 854059.8↑ (10↓, 21↑ TCP MSS/op)
Test duration: 10.0097 s.

; tcpkali 0.0.0.0:2112 -m 'hello world' -c 100 -T 60s
Destination: [0.0.0.0]:2112
Interface lo0 address [127.0.0.1]:0
Using interface lo0 to connect to [0.0.0.0]:2112
Ramped up to 100 connections.
Total data sent:     76921.7 MiB (80658251610 bytes)
Total data received: 76927.7 MiB (80664542074 bytes)
Bandwidth per channel: 215.085⇅ Mbps (26885.6 kBps)
Aggregate bandwidth: 10754.664↓, 10753.826↑ Mbps
Packet rate estimate: 925180.2↓, 938571.3↑ (10↓, 21↑ TCP MSS/op)
Test duration: 60.0034 s.

```

#### Older Atacama Measurements

```
// small buffer, mixed io schedulers
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

// bigger buffer, mixed io schedulers
Destination: [0.0.0.0]:2112
Interface lo0 address [127.0.0.1]:0
Using interface lo0 to connect to [0.0.0.0]:2112
Ramped up to 100 connections.
Total data sent:     2613.2 MiB (2740126788 bytes)
Total data received: 2605.0 MiB (2731517952 bytes)
Bandwidth per channel: 43.759⇅ Mbps (5469.8 kBps)
Aggregate bandwidth: 2184.491↓, 2191.376↑ Mbps
Packet rate estimate: 208817.1↓, 201971.3↑ (7↓, 13↑ TCP MSS/op)
Test duration: 10.0033 s.

// io_thread + kqueue + reusable bigger buffer
Destination: [0.0.0.0]:2112
Interface lo0 address [127.0.0.1]:0
Using interface lo0 to connect to [0.0.0.0]:2112
Ramped up to 100 connections.
Total data sent:     6488.9 MiB (6804124972 bytes)
Total data received: 6470.6 MiB (6784936960 bytes)
Bandwidth per channel: 108.683⇅ Mbps (13585.4 kBps)
Aggregate bandwidth: 5426.477↓, 5441.823↑ Mbps
Packet rate estimate: 494592.1↓, 481333.4↑ (7↓, 13↑ TCP MSS/op)
Test duration: 10.0027 s.
```
