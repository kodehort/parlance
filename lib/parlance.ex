defmodule Parlance do

  @moduledoc """
  Documentation for Parlance.
  """

  defmacro __using__(_options) do
    quote do
      Module.register_attribute __MODULE__, :routes, accumulate: true,
        persist: false
      import unquote(__MODULE__), only: [
        route: 3,
      ]

      @before_compile unquote(__MODULE__)

      @base_url ""

      defp filter_params(params, params_list) do
        Enum.filter(params, fn {key, _value} ->
          key in params_list
        end)
      end

      defp construct_url(dir) when is_binary(dir) do
        @base_url <> "/" <> dir
      end

      defp construct_url(dirs) when is_list(dirs) do
        @base_url <> "/" <> Enum.join(dirs, "/")
      end

      defp construct_url(dirs, params) do
        construct_url(dirs) <> "?" <> URI.encode_query(params)
      end

      defoverridable Module.definitions_in(__MODULE__)

    end
  end


  defmacro __before_compile__(env) do
    compile(Module.get_attribute(env.module, :routes))
  end

  @doc """
  The route macro provides a way to define the endpoints with which your HTTP
  client knows how to interact. Each call to `route` will add a method to the
  module with appropriate guards and validation.

  ## Example
  iex(1)> defmodule Github do
  iex(1)>   use Parlance
  iex(1)>   route :get_issues,
  iex(1)>     ["issues"],
  iex(1)>     [params: %{
  iex(1)>       values: %{
  iex(1)>         filter: %{
  iex(1)>           values: ["assigned", "created", "mentioned", "subscribed", "all"]
  iex(1)>         },
  iex(1)>         state: %{
  iex(1)>         }
  iex(1)>       }
  iex(1)>     }]
  iex(1)> end
  iex(2)> Github.get_issues([filter: "assigned"])
  "/issues?filter=assigned"

  ## Example
  iex(1)> defmodule Github do
  iex(1)>   use Parlance
  iex(1)>   route :get_issues,
  iex(1)>     ["orgs", :org, "issues"],
  iex(1)>     [
  iex(1)>       org: %{
  iex(1)>       },
  iex(1)>       params: %{
  iex(1)>         values: %{
  iex(1)>           filter: %{}
  iex(1)>         }
  iex(1)>       }
  iex(1)>     ]
  iex(1)> end
  iex(2)> Github.get_issues("elixir-lang", [])
  "/orgs/elixir-lang/issues?"
  """
  defmacro route(name, path, params) when is_atom(name) do
    quote bind_quoted: [
      name: name,
      path: path,
      params: params,
    ] do
      @routes { name, path, params }
    end
  end

  def compile(routes) do
    route_ast = for {name, path, params} <- routes do
      defroute(name, path, params)
    end

    final_ast = route_ast

    final_ast
  end

  defp defroute(name, path, _params) do
    quote do
      def unquote(name)(_method_params) do
        # params = filter_params(params, unquote(query_param_list))
        construct_url(unquote(path), [])
      end
    end
  end



end
