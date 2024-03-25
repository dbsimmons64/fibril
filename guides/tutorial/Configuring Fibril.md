There are two pieces of configuration required by Fibril. 

## config.exs

Firstly, we need to tell Fibril which repo to use and what the endpoint is for this application.
In `config.exs` add the following:

```
config :fibril,
  repo: Vet.Repo,
  endpoint: VetWeb.Endpoint
```
## router.ex

Secondly we need to add routes to access the resources:

```
    fibril_admin(:browser)
```

Don't forget to `import FibrilWeb.Router` at the top of `router.ex`


