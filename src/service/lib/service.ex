defmodule Service do
  use GenServer

  require Logger

  @impl true
  def init(name) when is_atom(name) do
    :global.register_name(name, self())
    Logger.info("Sevice de pé em #{inspect(Node.self())}")
    Process.send_after(self(), {:ping, name}, 1000)
    {:ok, nil}
  end

  def init(_), do: {:error, :invalid_service_name}

  def start_link(_) do
    name = System.get_env("SERVICE_NAME") |> String.to_atom()
    GenServer.start_link(__MODULE__, name)
  end

  @impl true
  def handle_call(request, from, _) do
    Logger.info(
      "Mensagem recebida no nó #{Node.self()} com corpo #{inspect(request)} envaida por #{inspect(from)}"
    )

    {:reply, nil, nil}
  end

  @impl true
  def handle_info({:ping, my_service_name}, _) do
    Logger.info("Ping: #{Node.self()}")

    :global.registered_names()
    |> List.delete(my_service_name)
    |> Enum.each(fn name ->
      name
      |> :global.whereis_name()
      |> GenServer.call("Envaindo mensagem de #{Node.self()} - #{inspect(DateTime.utc_now())}")
    end)

    Process.send_after(self(), {:ping, my_service_name}, 1000)
    {:noreply, nil}
  end
end
