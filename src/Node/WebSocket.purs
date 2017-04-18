module Node.WebSocket where

import Control.Monad.Eff (Eff)
import Network.WebSocket (WebSocket, WrappedWS, wrapWS)
import Node.HTTP (Server)
import Prelude (Unit, (<<<), (+))
import Control.Monad.Eff (kind Effect)

foreign import data WSServer :: Effect
foreign import data WebSocketServer :: Type
foreign import webSocketServer ::
  forall e. {server :: Server} -> Eff (wsserver :: WSServer | e) WebSocketServer

foreign import onConnectionImpl ::
  forall e.
  WebSocketServer ->
  (WebSocket -> Eff (wsserver :: WSServer | e) Unit) ->
  Eff (wsserver :: WSServer | e) Unit

-- /// <live>
sum n = n + 5
b = sum 56
-- /// </live>

onConnection :: forall t3.
  WebSocketServer
  -> (WrappedWS -> Eff ( wsserver :: WSServer | t3) Unit)
  -> Eff ( wsserver :: WSServer | t3) Unit
onConnection wss cb = onConnectionImpl wss (cb <<< wrapWS)
