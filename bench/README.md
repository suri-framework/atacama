# Bench

A small benchamrk of the throughput of echo TCP servers in
OCaml+Atacama, OCaml+Eio, Go, Elixir, Erlang, and Rust.

We're basically trying to saturate the network stack.

This is *NOT* a scientific benchmark, I run these for my own
benefit a few times every time I do big changes to make sure I
haven't broken something terribly. PRs very welcome to improve things!

I'm also not running them on an dedicated machine, they run on my macbook pro.

Some day we'll submit proper to techempower or sit down and do a real
benchmark, for now, we have this:

| name | 100conn/10s | 100conn/60s |
|------|-------------|--------------|
| OCaml (Atacama) | 422.3 Mbps | 403.7 Mbps |
| OCaml (Eio) | 157.0 Mbps | 173.3 Mbps |
| Erlang (ranch) | 512.3 Mbps | 509.2 Mbps |
| Elixir (thousand_island) | 516.5 Mbps | 522.6 Mbps |
| Go (stdlib) | 199.8 Mbps | 219.0 Mbps |
| Rust (tokio) | 538.9 Mbps | 538.8 Mbps |

**Atacama**
```
; tcpkali 0.0.0.0:2112 -m 'hello world' -c 100 -T 10s
Destination: [0.0.0.0]:2112
Interface lo0 address [127.0.0.1]:0
Using interface lo0 to connect to [0.0.0.0]:2112
Ramped up to 100 connections.
Total data sent:     9444.1 MiB (9902865586 bytes)
Total data received: 9433.3 MiB (9891581952 bytes)
Bandwidth per channel: 158.235⇅ Mbps (19779.3 kBps)
Aggregate bandwidth: 7907.221↓, 7916.241↑ Mbps
Packet rate estimate: 724672.1↓, 679765.2↑ (10↓, 18↑ TCP MSS/op)
Test duration: 10.0076 s.


; tcpkali 0.0.0.0:2112 -m 'hello world' -c 100 -T 60s
Destination: [0.0.0.0]:2112
Interface lo0 address [127.0.0.1]:0
Using interface lo0 to connect to [0.0.0.0]:2112
Ramped up to 100 connections.
Total data sent:     52023.7 MiB (54550806178 bytes)
Total data received: 51969.3 MiB (54493712384 bytes)
Bandwidth per channel: 145.370⇅ Mbps (18171.2 kBps)
Aggregate bandwidth: 7264.674↓, 7272.286↑ Mbps
Packet rate estimate: 692980.0↓, 624650.5↑ (5↓, 10↑ TCP MSS/op)
Test duration: 60.0095 s.

```

**Eio**
```
; tcpkali 0.0.0.0:2112 -m 'hello world' -c 100 -T 10s
Destination: [0.0.0.0]:2112
Interface lo0 address [127.0.0.1]:0
Using interface lo0 to connect to [0.0.0.0]:2112
Ramped up to 100 connections.
Total data sent:     9357.9 MiB (9812417099 bytes)
Total data received: 9370.8 MiB (9825945677 bytes)
Bandwidth per channel: 157.041⇅ Mbps (19630.1 kBps)
Aggregate bandwidth: 7857.443↓, 7846.624↑ Mbps
Packet rate estimate: 699968.8↓, 711393.1↑ (10↓, 17↑ TCP MSS/op)
Test duration: 10.0042 s.

; tcpkali 0.0.0.0:2112 -m 'hello world' -c 100 -T 60s
Destination: [0.0.0.0]:2112
Interface lo0 address [127.0.0.1]:0
Using interface lo0 to connect to [0.0.0.0]:2112
Ramped up to 100 connections.
Total data sent:     61980.1 MiB (64990858491 bytes)
Total data received: 61998.3 MiB (65009927828 bytes)
Bandwidth per channel: 173.308⇅ Mbps (21663.6 kBps)
Aggregate bandwidth: 8666.695↓, 8664.152↑ Mbps
Packet rate estimate: 770648.6↓, 783658.6↑ (10↓, 18↑ TCP MSS/op)
Test duration: 60.009 s.

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
Total data sent:     12572.4 MiB (13183163320 bytes)
Total data received: 12591.5 MiB (13203186173 bytes)
Bandwidth per channel: 211.068⇅ Mbps (26383.5 kBps)
Aggregate bandwidth: 10561.408↓, 10545.391↑ Mbps
Packet rate estimate: 992567.9↓, 932650.8↑ (11↓, 22↑ TCP MSS/op)
Test duration: 10.0011 s.

; tcpkali 0.0.0.0:2112 -m 'hello world' -c 100 -T 60s
Destination: [0.0.0.0]:2112
Interface lo0 address [127.0.0.1]:0
Using interface lo0 to connect to [0.0.0.0]:2112
Ramped up to 100 connections.
Total data sent:     78332.3 MiB (82137369297 bytes)
Total data received: 78379.2 MiB (82186570690 bytes)
Bandwidth per channel: 219.067⇅ Mbps (27383.4 kBps)
Aggregate bandwidth: 10956.620↓, 10950.061↑ Mbps
Packet rate estimate: 988206.8↓, 974395.3↑ (10↓, 20↑ TCP MSS/op)
Test duration: 60.0087 s.

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
