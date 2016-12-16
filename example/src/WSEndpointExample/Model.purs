module WSEndpointExample.Model where

import Network.WebSocket (WSEndpoint(..))

echochamber :: WSEndpoint String
echochamber = WSEndpoint "echochamber"
