# TpIasc

[Link al enunciado](https://docs.google.com/document/d/e/2PACX-1vSuUzfNwg4y3ALbddo0cPrjyabWRvfd3I43fYas2eQFPiqtiWsWOLDHpsxdUKcHUVpH73erhkAmoyV8/pub)

## Ejecutar en Windows

Para iniciar la aplicación:

```sh
iex.bat -S mix
```

## Ejecutar en Windows (con tests)

Para iniciar la aplicación y ejecutar los tests:

```sh
iex.bat -S mix test
```

**Warning**: Luego de ejecutar los tests, el entorno puede tener procesos con el estado sucio. No ejecutar los tests en producción.

## Ejecutar en Linux

Descargar dependencias:

```bash
mix deps.get
```

Ejecutar:

```bash
iex --name node1@127.0.0.1 -S mix
iex --name node2@127.0.0.1 -S mix
```

Correr tests:

```bash
iex -S mix test
```

## Ejemplo `put` y `get`

Para probar almacenar un valor y luego recuperarlo, podes usar los siguientes comandos en `iex`:

```elixir
# Desde el nodo 1

TpIasc.Helpers.log_all()
GenServer.cast(Orchestrators.Orchestrator.via_tuple(:"Orchestrator_node1@127.0.0.1"), {:put, "key1", "value1"})
GenServer.call(Orchestrators.Orchestrator.via_tuple(:"Orchestrator_node1@127.0.0.1"), {:get, "key1"})

# Desde el nodo 2

TpIasc.Helpers.log_all()
GenServer.call(Orchestrators.Orchestrator.via_tuple(:"Orchestrator_node2@127.0.0.1"), {:get, "key1"})

# Ver distribución de claves
GenServer.call(Orquestador1, :keys_distribution)
```
