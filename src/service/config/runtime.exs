import Config

config :opentelemetry,
  resource: %{service: %{name: System.get_env("SERVICE_NAME")}},
  span_processor: :batch,
  traces_exporter: :otlp

config :opentelemetry_exporter,
  otlp_protocol: :http_protobuf,
  otlp_endpoint: "http://otel:4318"
