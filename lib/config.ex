defmodule Fibril.Config do
  defmacro __using__(_opts) do
    quote do
      @before_compile unquote(__MODULE__)
    end
  end

  defmacro __before_compile__(_env) do
    repo = Application.get_env(:fibril, :repo, Fibril.Repo)
    module_prefix = Application.get_env(:fibril, :module_prefix, "Fibril.Resource")
    url_prefix = Application.get_env(:fibril, :url_prefix, "/admin")

    quote do
      def repo() do
        unquote(repo)
      end

      def module_prefix() do
        unquote(module_prefix)
      end

      def url_prefix do
        unquote(url_prefix)
      end
    end
  end
end
