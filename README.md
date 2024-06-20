# TpIasc

[Link enunciado](https://docs.google.com/document/d/e/2PACX-1vSuUzfNwg4y3ALbddo0cPrjyabWRvfd3I43fYas2eQFPiqtiWsWOLDHpsxdUKcHUVpH73erhkAmoyV8/pub)


## Ejemplo put y get

iex(1)> GenServer.cast(Orquestador1, {:put, "a", "b"})
:ok
iex(2)> GenServer.call(Orquestador1, {:get, "a"})
"b"
iex(3)> GenServer.call(Orquestador2, {:get, "a"})
"b"