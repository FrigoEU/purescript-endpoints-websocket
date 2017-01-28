module Node.WebSocket where

import Control.Monad.Eff (Eff)
import Network.WebSocket (WebSocket, WrappedWS, wrapWS)
import Node.HTTP (Server)
import Prelude (Unit, (<<<))

foreign import data WSServer :: !
foreign import data WebSocketServer :: *
foreign import webSocketServer ::
  forall e. {server :: Server} -> Eff (wsserver :: WSServer | e) WebSocketServer

foreign import onConnectionImpl ::
  forall e.
  WebSocketServer ->
  (WebSocket -> Eff (wsserver :: WSServer | e) Unit) ->
  Eff (wsserver :: WSServer | e) Unit

onConnection :: forall t3.
  WebSocketServer
  -> (WrappedWS -> Eff ( wsserver :: WSServer | t3) Unit)
  -> Eff ( wsserver :: WSServer | t3) Unit
onConnection wss cb = onConnectionImpl wss (cb <<< wrapWS)
