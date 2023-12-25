import Config

# Environment variables would be better, but this is fine, I guess.
# thisisfine.jpg
config =
  "../../../../../../../config.json"
  |> Path.expand(__DIR__)
  |> File.read!()
  |> Jason.decode!()

%{"port" => port, "buffer" => buffer} = config

config :echo, Echo,
  port: port,
  handler_module: Echo,
  transport_options: [recbuf: buffer]
