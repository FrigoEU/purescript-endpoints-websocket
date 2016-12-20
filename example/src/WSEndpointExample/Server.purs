module WSEndpointExample.Server where

import Network.WebSocket (listenTo, sendTo)
import Node.HTTP (createServer)
import Node.WebSocket (onConnection, webSocketServer)
import Prelude (bind, pure, unit, (<>))
import WSEndpointExample.Model (echochamber)

-------------------------------

main = do
  server <- createServer (\_ _ -> pure unit)
  wsserver <- webSocketServer {port: 8008, server}
  onConnection wsserver \ws -> do
    listenTo ws echochamber
      \mess -> sendTo ws echochamber ("Echoed: " <> mess)
    pure unit
