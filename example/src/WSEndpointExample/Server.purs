module WSEndpointExample.Server where

-- import Prelude (Unit, (==), bind, return, ($))

-- import Control.Monad.Eff (Eff)
-- import Control.Monad.Eff.Console (CONSOLE, log)
-- import Network.HTTP.Affjax (AJAX)

-- import Data.Array (filter)

-- import WSEndpointExample.Model (Order(Order), getOrdersEndpoint)

-- import Node.Express.Endpoint (EXPRESS, listen, hostStatic, hostEndpoint, makeApp)
import Network.WebSocket (listenTo, sendTo)
import Node.HTTP (createServer)
import Node.WebSocket (onConnection, webSocketServer)
import Prelude (bind, pure, unit, (<>))
import WSEndpointExample.Model (echochamber)

-- ----------------------------

main = do
  server <- createServer (\_ _ -> pure unit)
  wsserver <- webSocketServer {port: 8008, server}
  onConnection wsserver \ws -> do
    listenTo ws echochamber \mess -> sendTo ws echochamber ("Echoed: " <> mess)
