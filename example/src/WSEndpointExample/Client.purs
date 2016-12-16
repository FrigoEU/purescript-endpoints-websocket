module WSEndpointExample.Client where

import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Timer (setInterval)
import Network.WebSocket (connect, listenTo, sendTo)
import Prelude (Unit, pure, show, unit, (*>), (<>), bind)
import WSEndpointExample.Model (echochamber)

foreign import data DOM :: !
foreign import appendToBody :: forall eff. String -> Eff (dom :: DOM | eff) Unit

-- main :: forall eff. Eff ( dom :: DOM , ajax :: AJAX | eff ) Unit
-- main = runAff (\e -> appendToBody $ "Error: " <> message e) (\_ -> appendToBody ("Done!")) do
--   ordersForOne <- execEndpoint getOrdersEndpoint 1 unit
--   ordersForTwo <- execEndpoint getOrdersEndpoint 2 unit
--   liftEff $ appendToBody $ "OrdersForOne: " <> show ordersForOne
--   liftEff $ appendToBody $ "OrdersForTwo: " <> show ordersForTwo
--   return unit

main = do
  connect (\err -> appendToBody ("Error connecting: " <> show err))
          (\ws -> do
              setInterval 2000 (sendTo ws echochamber "sending stuff") *> pure unit
              listenTo ws echochamber \mess -> appendToBody mess)
          "ws://localhost:8008"
