defmodule LoggerJSONFormatter do
  @moduledoc """
  Documentation for `LoggerJSONFormatter`.
  """

  defmodule LogEvent do
    defstruct [:fields]

    defimpl Jason.Encoder do
      def encode(%{fields: fields}, opts) do
        Jason.Encode.keyword(fields, opts)
      end
    end
  end

  @doc false
  def format(%{meta: meta, msg: msg, level: level}, _config) do
    msg =
      case msg do
        {:string, msg} when is_binary(msg) ->
          msg

        {:report, report} when is_list(report) ->
          %LogEvent{fields: report}
          |> Jason.encode_to_iodata!()
          |> Jason.Fragment.new()

        {:report, report} when is_map(report) ->
          report
      end

    time = Map.get(meta, :time) || System.system_time(:microsecond)

    fields =
      [
        {"level", level},
        {"time", time},
        {"msg", msg},
        {"meta",
         %LogEvent{fields: meta |> Map.to_list() |> process_meta()}
         |> Jason.encode_to_iodata!()
         |> Jason.Fragment.new()}
      ]

    [Jason.encode_to_iodata!(%LogEvent{fields: fields}), ?\n]
  end

  defp process_meta([kv | rest]) do
    if kv = process_meta_kv(kv) do
      [kv | process_meta(rest)]
    else
      process_meta(rest)
    end
  end

  defp process_meta(empty = []), do: empty

  defmacrop unsafe_fragment(data) do
    quote do
      Jason.Fragment.new([?", unquote_splicing(data), ?"])
    end
  end

  defp process_meta_kv({drop, _})
       when drop in [:time, :report_cb, :gl],
       do: nil

  defp process_meta_kv({key, pid}) when is_pid(pid) do
    {key, unsafe_fragment(["#PID", :erlang.pid_to_list(pid)])}
  end

  defp process_meta_kv({key, ref}) when is_reference(ref) do
    {key, unsafe_fragment([:erlang.ref_to_list(ref)])}
  end

  defp process_meta_kv({key, port}) when is_port(port) do
    {key, unsafe_fragment([:erlang.port_to_list(port)])}
  end

  defp process_meta_kv({key, atom}) when is_atom(atom) do
    value =
      case Atom.to_string(atom) do
        "Elixir." <> rest -> rest
        other -> other
      end

    {key, value}
  end

  defp process_meta_kv({mfa_key, {mod, fun, arity}})
       when mfa_key in [:mfa, :initial_call] and is_atom(mod) and is_atom(fun) and
              is_integer(arity) do
    {mfa_key, Exception.format_mfa(mod, fun, arity)}
  end

  defp process_meta_kv({:crash_reason = key, {%{__exception__: true} = exception, stacktrace}}) do
    {key, Exception.format(:error, exception, stacktrace)}
  end

  defp process_meta_kv({list_key, list}) when list_key in [:file, :function] and is_list(list) do
    {list_key, List.to_string(list)}
  end

  defp process_meta_kv({_k, _v} = other), do: other
end
