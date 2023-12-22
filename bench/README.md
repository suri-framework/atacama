# Bench

A small benchamrk of the throughput of echo TCP servers in OCaml+Atacama, OCaml+Eio, Go, Elixir, Erlang, and Rust.


| name | 100conn/10s | 100conn/60s |
|------|-------------|--------------|
| Atacama | 95.6 Mbps | 104.1 Mbps |
| Eio | 40.5 Mbps | 42.5 Mbps |
| Erlang | 74.7 Mbps | 72.5 Mbps |
| Elixir | 73.6 Mbps | 67.8 Mbps |
| Go | 44.6 Mbps | 50.3 Mbps |
| Rust | 103.1 Mbps | 130.5 Mbps |

**Atacama**
```
; tcpkali 0.0.0.0:2112 -m 'hello world' -c 100 -T 10s
Destination: [0.0.0.0]:2112
Interface lo0 address [127.0.0.1]:0
Using interface lo0 to connect to [0.0.0.0]:2112
Ramped up to 100 connections.
Total data sent:     5712.5 MiB (5990000216 bytes)
Total data received: 5698.0 MiB (5974823936 bytes)
Bandwidth per channel: 95.693⇅ Mbps (11961.6 kBps)
Aggregate bandwidth: 4778.572↓, 4790.710↑ Mbps
Packet rate estimate: 421254.6↓, 421441.7↑ (6↓, 12↑ TCP MSS/op)
Test duration: 10.0027 s.

; tcpkali 0.0.0.0:2112 -m 'hello world' -c 100 -T 60s
Destination: [0.0.0.0]:2112
Interface lo0 address [127.0.0.1]:0
Using interface lo0 to connect to [0.0.0.0]:2112
Ramped up to 100 connections.
Total data sent:     37277.4 MiB (39088165316 bytes)
Total data received: 37251.8 MiB (39061298176 bytes)
Bandwidth per channel: 104.198⇅ Mbps (13024.8 kBps)
Aggregate bandwidth: 5208.130↓, 5211.713↑ Mbps
Packet rate estimate: 492843.8↓, 454687.3↑ (7↓, 12↑ TCP MSS/op)
Test duration: 60.0005 s.
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
Total data sent:     4444.1 MiB (4659995790 bytes)
Total data received: 4477.6 MiB (4695095779 bytes)
Bandwidth per channel: 74.761⇅ Mbps (9345.2 kBps)
Aggregate bandwidth: 3752.097↓, 3724.047↑ Mbps
Packet rate estimate: 381463.0↓, 331027.1↑ (6↓, 18↑ TCP MSS/op)
Test duration: 10.0106 s.

; tcpkali 0.0.0.0:2112 -m 'hello world' -c 100 -T 60s
Destination: [0.0.0.0]:2112
Interface lo0 address [127.0.0.1]:0
Using interface lo0 to connect to [0.0.0.0]:2112
Ramped up to 100 connections.
Total data sent:     25931.0 MiB (27190657312 bytes)
Total data received: 25942.1 MiB (27202303090 bytes)
Bandwidth per channel: 72.521⇅ Mbps (9065.2 kBps)
Aggregate bandwidth: 3626.845↓, 3625.293↑ Mbps
Packet rate estimate: 338609.5↓, 326606.6↑ (5↓, 17↑ TCP MSS/op)
Test duration: 60.0021 s.
```

**Elixir** (using `Thousand_island`)
```
; tcpkali 0.0.0.0:2112 -m 'hello world' -c 100 -T 10s
Destination: [0.0.0.0]:2112
Interface lo0 address [127.0.0.1]:0
Using interface lo0 to connect to [0.0.0.0]:2112
Ramped up to 100 connections.
Total data sent:     4389.6 MiB (4602877945 bytes)
Total data received: 4397.2 MiB (4610848155 bytes)
Bandwidth per channel: 73.676⇅ Mbps (9209.6 kBps)
Aggregate bandwidth: 3687.009↓, 3680.635↑ Mbps
Packet rate estimate: 339618.2↓, 335003.5↑ (5↓, 16↑ TCP MSS/op)
Test duration: 10.0045 s.

; tcpkali 0.0.0.0:2112 -m 'hello world' -c 100 -T 60s
Destination: [0.0.0.0]:2112
Interface lo0 address [127.0.0.1]:0
Using interface lo0 to connect to [0.0.0.0]:2112
Ramped up to 100 connections.
Total data sent:     24291.9 MiB (25471859342 bytes)
Total data received: 24270.7 MiB (25449718756 bytes)
Bandwidth per channel: 67.892⇅ Mbps (8486.5 kBps)
Aggregate bandwidth: 3393.107↓, 3396.059↑ Mbps
Packet rate estimate: 306464.0↓, 311297.8↑ (4↓, 13↑ TCP MSS/op)
Test duration: 60.0033 s.
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

; tcpkali 0.0.0.0:2112 -m 'hello world' -c 100 -T 60s
Destination: [0.0.0.0]:2112
Interface lo0 address [127.0.0.1]:0
Using interface lo0 to connect to [0.0.0.0]:2112
Ramped up to 100 connections.
Total data sent:     46686.5 MiB (48954318189 bytes)
Total data received: 46682.0 MiB (48949595790 bytes)
Bandwidth per channel: 130.530⇅ Mbps (16316.3 kBps)
Aggregate bandwidth: 6526.202↓, 6526.831↑ Mbps
Packet rate estimate: 595847.4↓, 591284.0↑ (9↓, 15↑ TCP MSS/op)
Test duration: 60.0038 s.
```

**Go**
```
; tcpkali 0.0.0.0:2112 -m 'hello world' -c 100 -T 10s
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

; tcpkali 0.0.0.0:2112 -m 'hello world' -c 100 -T 60s
Destination: [0.0.0.0]:2112
Interface lo0 address [127.0.0.1]:0
Using interface lo0 to connect to [0.0.0.0]:2112
Ramped up to 100 connections.
Total data sent:     18006.7 MiB (18881387017 bytes)
Total data received: 18012.1 MiB (18887009423 bytes)
Bandwidth per channel: 50.355⇅ Mbps (6294.4 kBps)
Aggregate bandwidth: 2518.145↓, 2517.396↑ Mbps
Packet rate estimate: 257358.8↓, 220704.2↑ (4↓, 16↑ TCP MSS/op)
Test duration: 60.0029 s.
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
