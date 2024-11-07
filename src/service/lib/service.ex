defmodule Service do
  use GenServer

  require Logger
  require OpenTelemetry.Tracer, as: Tracer

  @impl true
  def init(name) when is_atom(name) do
    Tracer.with_span :init do
      :global.register_name(name, self())
      Logger.info("Sevice de pé em #{inspect(Node.self())}")
      Process.send_after(self(), {:ping, name}, 1000)
      {:ok, nil}
    end
  end

  def init(_), do: {:error, :invalid_service_name}

  def start_link(_) do
    name = System.get_env("SERVICE_NAME") |> String.to_atom()
    GenServer.start_link(__MODULE__, name)
  end

  @impl true
  def handle_call(request, _from, _) do
    links = if request[:context] != nil, do: [OpenTelemetry.link(request.context)], else: []

    IO.inspect(links)

    Tracer.with_span :receive_message, %{links: links} do
      Tracer.set_attributes([{:request, inspect(request)}])

      {:reply, nil, nil}
    end
  end

  @impl true
  def handle_info({:ping, my_service_name}, _) do
    Logger.info("Ping: #{Node.self()}")

    Tracer.with_span :send_messages do
      :global.registered_names()
      |> List.delete(my_service_name)
      |> Enum.each(fn name ->
        name
        |> :global.whereis_name()
        |> GenServer.call(%{
          context: Tracer.current_span_ctx(),
          control: Enum.random(1111..9999)
        })
      end)

      Process.send_after(self(), {:ping, my_service_name}, 1000)
    end

    {:noreply, nil}
  end
end
