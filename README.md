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

Finished in 0.2 seconds (0.2s async, 0.00s sync)
7 tests, 0 failures

**Warning**: Luego de ejecutar los tests, el entorno puede tener procesos con el estado sucio. No ejecutar los tests en producción.

## Ejemplo `put` y `get`

Para probar almacenar un valor y luego recuperarlo, podes usar los siguientes comandos en `iex`:

```elixir
# Almacenar valores
GenServer.cast(Orquestador1, {:put, "a", "b"})
GenServer.cast(Orquestador1, {:put, "c", 15})

# Recuperar valores
GenServer.call(Orquestador1, {:get, "a"}) # => "b"
GenServer.call(Orquestador1, {:get, "c"}) # => 15

# Almacenar múltiples valores
GenServer.cast(Orquestador1, {:put, "a", "b"})
GenServer.cast(Orquestador1, {:put, "j", "f"})
GenServer.cast(Orquestador1, {:put, "adsa", 158})

# Ver distribución de claves
GenServer.call(Orquestador1, :keys_distribution)
```