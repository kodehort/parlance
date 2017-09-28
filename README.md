# Parlance

[![Build Status](https://travis-ci.org/kodehort/parlance.svg?branch=master)](https://travis-ci.org/kodehort/parlance)
```
/ˈpɑːl(ə)ns/
```

noun: parlance

a particular way of speaking or using words, especially a way common to those with a particular job or interest.

**"dated terms that were once in common parlance"**

Parlance provides a set of marcos that can be used to define HTTP clients for APIs. It is intended to greatly reduce the
boilerplate code while providing a consistent and well documented developer API for interacting with an API.

## Principles

* Simple DSL that supports common API design.
* Robust developer API that provides guards for correct parameters.
* Support common API authentication methods.
* Provide stub implementation of the API so that tests are decoupled from the external dependency.

## DSL

```elixir
  route :route_name, # Route name will be used to define the method name within the client
    ["path", "parts", :variables], # A list of path parts as strings and atoms to be replaced by a method parameter
    [params: %{}]
```

## Example

```elixir
defmodule Github do

  use Parlance

  route :get_issues,
    ["issues"]
    [params: %{
      filter: %{
        type: String.t,
        values: ["assigned", "created", "mentioned", "subscribed", "all"]
      },
      state: %{
        type: String.t
        values: []
      }
    }]
  route :get_user_issues
    ["user", "issues"]
    %{}
  route :get_orgs_issues
    ["orgs", :org, "issues"]
    %{}

end
```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `parlance` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:parlance, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/parlance](https://hexdocs.pm/parlance).
