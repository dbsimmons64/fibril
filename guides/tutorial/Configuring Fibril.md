There are two pieces of configuration required by Fibril. 

## Config.exs

In `config.exs` add the following:

```
config :fibril,
  repo: Vet.Repo,
  endpoint: VetWeb.Endpoint
```
We need to tell Fibril which repo to use and what the endpoint is for this application.

