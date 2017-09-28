defmodule Parlance do

  @moduledoc """
  Documentation for Parlance.
  """

  defmacro __using__(_options) do
    quote do
      Module.register_attribute __MODULE__, :endpoints, accumulate: true,
        persist: false
      import unquote(__MODULE__), only: [
        defendpoint: 1,
      ]

      @before_compile unquote(__MODULE__)

      defp filter_query_params(params, query_params_list) do
        Enum.filter(params, fn {key, _value} ->
          key in query_params_list
        end)
      end

      defp construct_url(dir) when is_binary(dir) do
        "/" <> dir
      end

      defp construct_url(dirs) when is_list(dirs) do
        "/" <> Enum.join(dirs, "/")
      end

      defp construct_url(dirs, params) when is_list(dirs) do
        reduce_path(dirs, params)
      end

      defp reduce_path(dirs, params) when is_binary(params) do
        Enum.reduce(dirs, "", fn (dir, acc) ->
          cond do
            is_atom(dir) ->
              acc <> "/" <> params
            is_binary(dir) ->
              acc <> "/" <> dir
          end
        end)
      end

      defp reduce_path(dirs, params) when is_list(params) do
        Enum.reduce(dirs, "", fn (dir, acc) ->
          cond do
            is_atom(dir) ->
              acc <> params.(dir) <> "/"
            is_binary(dir) ->
              acc <> dir <> "/"
          end
        end)
      end

      defp construct_url(dirs, [], []) do
        construct_url(dirs)
      end

      defp construct_url(dirs, params) when is_binary(params) do
        construct_url(dirs)
      end

      defp construct_url(dirs, params, query) do
        construct_url(dirs) <> "?" <> URI.encode_query(query)
      end

      defoverridable Module.definitions_in(__MODULE__)

    end
  end


  @doc false
  defmacro __before_compile__(env) do
    compile(Module.get_attribute(env.module, :endpoints))
  end

  @doc """
  The route macro provides a way to define the endpoints with which your HTTP
  client knows how to interact. Each call to `route` will add a method to the
  module with appropriate guards and validation.

  ## Example
  iex(1)> defmodule HttpClient do
  iex(1)>   use Parlance
  iex(1)>   defendpoint {:get,
  iex(1)>     path: "path"}
  iex(1)> end
  iex(2)> HttpClient.get()
  "/path"

  ## Example
  iex(1)> defmodule Github do
  iex(1)>   use Parlance
  iex(1)>   defendpoint {:get_issues,
  iex(1)>     path: ["issues"],
  iex(1)>     query: ["filter"]}
  iex(1)> end
  iex(2)> Github.get_issues([filter: "assigned"])
  "/issues?filter=assigned"

  ## Example
  iex(1)> defmodule Github do
  iex(1)>   use Parlance
  iex(1)>   defendpoint {:get_issues,
  iex(1)>     path: ["orgs", :org, "issues"],
  iex(1)>     params: [:org],
  iex(1)>     query: ["filter"]}
  iex(1)> end
  iex(2)> Github.get_issues("elixir-lang", [])
  "/orgs/elixir-lang/issues"
  """
  defmacro defendpoint({name, config} = _endpoint) when is_atom(name) do
    quote bind_quoted: [
      name: name,
      config: config,
    ] do
      @endpoints { name, config }
    end
  end

  @doc false
  def compile(endpoints) do
    route_ast = for {name, config} <- endpoints do
      compile_endpoint(name, config)
    end

    route_ast
  end

  @doc false
  defp compile_endpoint(name, [path: path] = _config) do
    quote do
      def unquote(name)() do
        construct_url(unquote(path))
      end
    end
  end

  @doc false
  defp compile_endpoint(name, [path: path, query: _query_config] = _config) do
    quote do
      def unquote(name)(query) do
        # params = filter_params(params, unquote(query_param_list))
        construct_url(unquote(path), [], query)
      end
    end
  end

  @doc false
  defp compile_endpoint(name, [path: path, params: _params_config, query: _query_config] = _config) do
    quote do
      def unquote(name)(params, query) when is_binary(params) do
        construct_url(unquote(path), params)
      end
    end
  end

end
