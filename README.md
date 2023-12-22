```elixir
:logger.update_handler_config(:default, :formatter, {LoggerJSONFormatter, _config = %{}})

require Logger

Logger.info("hello")
# {"level":"info","time":1703227199210502,"msg":"hello","meta":{"pid":"#PID<0.356.0>","domain":["elixir"]}}
Logger.info(hello: "world")
# {"level":"info","time":1703227211400618,"msg":{"hello":"world"},"meta":{"pid":"#PID<0.356.0>","domain":["elixir"]}}
```
