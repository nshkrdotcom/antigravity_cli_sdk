defmodule AntigravityCliSdk.ArgBuilder do
  @moduledoc "Converts `%AntigravityCliSdk.Options{}` into `agy` argv."

  alias AntigravityCliSdk.Options

  @spec build_args(Options.t(), String.t()) :: [String.t()]
  def build_args(%Options{} = opts, prompt) when is_binary(prompt) do
    ["--print", prompt]
    |> add_model(opts.model)
    |> add_effort(opts.effort, opts.model_payload)
    |> add_flag("--sandbox", opts.sandbox)
    |> add_flag("--dangerously-skip-permissions", opts.dangerously_skip_permissions)
    |> add_pair("--conversation", opts.conversation)
    |> add_flag("--continue", opts.continue)
    |> add_repeat("--add-dir", opts.add_dirs)
    |> add_pair("--print-timeout", opts.print_timeout)
    |> add_pair("--log-file", opts.log_file)
  end

  defp add_model(args, nil), do: args
  defp add_model(args, ""), do: args
  defp add_model(args, "default"), do: args

  defp add_model(args, model) when is_binary(model) do
    case String.trim(model) do
      "" -> args
      "default" -> args
      normalized -> args ++ ["--model", normalized]
    end
  end

  defp add_model(args, _other), do: args

  defp add_effort(args, effort, model_payload) do
    resolved_effort =
      effort
      |> blank_to_nil()
      |> Kernel.||(model_payload_effort(model_payload))

    case resolved_effort do
      nil ->
        args

      "" ->
        args

      val when is_atom(val) ->
        args ++ ["--effort", Atom.to_string(val)]

      val when is_binary(val) ->
        case String.trim(val) do
          "" -> args
          trimmed -> args ++ ["--effort", trimmed]
        end

      _other ->
        args
    end
  end

  defp model_payload_effort(%{reasoning: reasoning})
       when is_binary(reasoning) or is_atom(reasoning),
       do: reasoning

  defp model_payload_effort(payload) when is_map(payload),
    do: Map.get(payload, :reasoning) || Map.get(payload, "reasoning")

  defp model_payload_effort(_), do: nil

  defp blank_to_nil(value) when value in [nil, ""], do: nil
  defp blank_to_nil(value), do: value

  defp add_flag(args, _flag, false), do: args
  defp add_flag(args, _flag, nil), do: args
  defp add_flag(args, flag, true), do: args ++ [flag]
  defp add_flag(args, _flag, _other), do: args

  defp add_pair(args, _flag, value) when value in [nil, ""], do: args

  defp add_pair(args, flag, value) when is_binary(value) do
    case String.trim(value) do
      "" -> args
      normalized -> args ++ [flag, normalized]
    end
  end

  defp add_pair(args, flag, value), do: args ++ [flag, to_string(value)]

  defp add_repeat(args, _flag, []), do: args

  defp add_repeat(args, flag, values) when is_list(values) do
    Enum.reduce(values, args, fn
      value, acc when is_binary(value) ->
        case String.trim(value) do
          "" -> acc
          normalized -> acc ++ [flag, normalized]
        end

      _value, acc ->
        acc
    end)
  end

  defp add_repeat(args, _flag, _values), do: args
end
