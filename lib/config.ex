defmodule Fibril.Config do
  defmacro __using__(_opts) do
    quote do
      @before_compile unquote(__MODULE__)
    end
  end

  defmacro __before_compile__(_env) do
    repo = Application.get_env(:fibril, :repo, Fibril.Repo)

    quote do
      def repo() do
        unquote(repo)
      end
    end
  end
end
