defmodule Parser do
  use Application
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(Parser.Endpoint, [])
    ]

    opts = [strategy: :one_for_one, name: HexVersion.Supervisor]
    Supervisor.start_link(children, opts)
  end

  
end
