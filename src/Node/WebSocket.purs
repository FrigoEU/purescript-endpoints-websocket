module Node.WebSocket where

import Control.Monad.Eff (Eff)
import Network.WebSocket (WebSocket)
import Node.HTTP (Server)
import Prelude (Unit)

foreign import data WSServer :: !
foreign import data WebSocketServer :: *
foreign import webSocketServer ::
  forall e. {port :: Int, server :: Server} -> Eff (wsserver :: WSServer | e) WebSocketServer

foreign import onConnection ::
  forall e.
  WebSocketServer ->
  (WebSocket -> Eff (wsserver :: WSServer | e) Unit) ->
  Eff (wsserver :: WSServer | e) Unit

