use std::net::TcpStream;
use tokio::io::BufReader;
use tokio::net::TcpListener;
use tokio::spawn;

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    let listener = TcpListener::bind("127.0.0.1:2112").await?;

    loop {
        let (socket, _) = listener.accept().await?;
        let std_stream = socket.into_std().unwrap();
        let socket = socket2::Socket::from(std_stream);
        socket.set_recv_buffer_size(1024 * 50).unwrap();
        let std_stream: TcpStream = socket.into();
        let mut socket = tokio::net::TcpStream::from_std(std_stream).unwrap();

        spawn(async move {
            let (r, mut w) = socket.split();
            let mut r = BufReader::with_capacity(1024 * 50, r);
            tokio::io::copy_buf(&mut r, &mut w).await?;
            Ok::<_, std::io::Error>(())
        });
    }
}
