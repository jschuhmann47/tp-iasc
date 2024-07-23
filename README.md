# TpIasc

[Link al enunciado](https://docs.google.com/document/d/e/2PACX-1vSuUzfNwg4y3ALbddo0cPrjyabWRvfd3I43fYas2eQFPiqtiWsWOLDHpsxdUKcHUVpH73erhkAmoyV8/pub)



### Resumen de la Arquitectura de la Base de Datos Distribuida en Elixir:

#### Entidades Principales

##### Orchestrators.Orchestrator
* Es un GenServer que actúa como punto de entrada para las acciones de lectura y escritura en la base de datos.
* Cada nodo físico en la red tiene una instancia única de Orchestrators.Orchestrator.

##### Block.Listener
* Son múltiples GenServers que se conocen por todos los Orchestrators.Orchestrator.
* Cuando se realiza una acción de lectura o escritura, el Orchestrators.Orchestrator decide a cuál Block.Listener enviar la petición utilizando una lógica de hash basada en la clave (key).
* La cantidad de Block.Listener está definida por una configuración denominada dictionary_count.
* Cada nodo físico tiene sus propias instancias de Block.Listener, ya que son GenServers sin estado y no necesitan ser distribuidos usando Horde.

##### Block.Dictionary
* Es un Agent que contiene un diccionario para almacenar los valores.
* Se crean tantos Block.Dictionary como el resultado de dictionary_count * replication_factor.
* Cada Block.Listener tiene una relación de paridad definida con Block.Dictionary, basada en un factor de replicación configurable (replication_factor).
        Por ejemplo, si dictionary_count = 40, replication_factor = 2 y node_quantity = 3, habrá:
            40 Block.Listener ejecutándose localmente en cada nodo sin usar Horde.
            80 Block.Dictionary distribuidos en la red entre los 3 nodos.
        Los Block.Dictionary que son réplicas de otros no pueden estar en el mismo nodo.

#### Ejemplo de Configuración

Supongamos que tenemos la siguiente configuración:

```
dictionary_count = 40
replication_factor = 2
node_quantity = 3
```
Esto implica:
* Cada nodo tendrá 40 Block.Listener locales.
* Habrá un total de 80 Block.Dictionary distribuidos entre los 3 nodos, asegurando que las réplicas no residan en el mismo nodo.

Resumen del Proceso

Lectura/Escritura
    Una solicitud de lectura/escritura llega a Orchestrators.Orchestrator.
    Este usa una lógica de hash para determinar el Block.Listener apropiado.
    El Block.Listener luego interactúa con el Block.Dictionary correspondiente para procesar la solicitud.
Distribución y Replicación
    La replicación asegura que cada valor almacenado en un Block.Dictionary tenga copias redundantes en diferentes nodos, proporcionando tolerancia a fallos.
    La lógica de distribución y replicación se maneja de manera que las réplicas no se encuentren en el mismo nodo físico.

Esta arquitectura permite una distribución eficiente de datos y proporciona redundancia para asegurar la disponibilidad y tolerancia a fallos en la red de nodos.



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
TpIasc.Helpers.log_replication_status()

GenServer.cast(Orchestrators.Orchestrator.via_tuple(:"Orchestrator_node1@127.0.0.1"), {:put, "key1", "value1"})
GenServer.cast(Orchestrators.Orchestrator.via_tuple(:"Orchestrator_node1@127.0.0.1"), {:put, "key2", "value2"})
GenServer.call(Orchestrators.Orchestrator.via_tuple(:"Orchestrator_node1@127.0.0.1"), {:get, "key1"})

# Desde el nodo 2

TpIasc.Helpers.log_all()
GenServer.call(Orchestrators.Orchestrator.via_tuple(:"Orchestrator_node2@127.0.0.1"), {:get, "key1"})

# Ver distribución de claves
GenServer.call(Orquestador1, :keys_distribution)
```
