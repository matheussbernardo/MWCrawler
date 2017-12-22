use Mix.Config

# NOTE: Use $PORT environment variable if specified, otherwise fallback to port 80
port =
  case System.get_env("PORT") do
    port when is_binary(port) -> String.to_integer(port)
    nil -> 80 # default port
  end

config :softiparse, port: port