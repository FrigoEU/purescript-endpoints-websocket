module Network.WebSocket where

import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Console (CONSOLE, log)
import Control.Monad.Eff.Exception (EXCEPTION, Error)
import Data.Argonaut.Core (jsonEmptyObject, stringify, toObject)
import Data.Argonaut.Decode (class DecodeJson, decodeJson, getField)
import Data.Argonaut.Encode (class EncodeJson, encodeJson, (:=), (~>))
import Data.Argonaut.Parser (jsonParser)
import Data.Either (Either(..), either)
import Data.Maybe (maybe)
import Prelude (Unit, id, ($), (<#>), (<$>), (<*>), (==), (>>=))

foreign import data WS :: !
foreign import data WebSocket :: *
data WSEndpoint a = WSEndpoint String
newtype WSMessage = WSMessage {t :: String, m :: String}

foreign import connect :: forall e.
                          (Error -> Eff (ws :: WS | e) Unit) ->
                          (WebSocket -> Eff (ws :: WS | e) Unit) ->
                          String -> Eff (ws :: WS | e) Unit

instance decodeJsonWSMessage :: DecodeJson WSMessage where
  decodeJson json =
    maybe
      (Left "Expecting JSON object")
      (\obj -> WSMessage
               <$> ({t: _, m: _}
               <$>  (getField obj "t" >>= decodeJson)
               <*>  (getField obj "m" >>= decodeJson)))
      (toObject json)

instance encodeJsonWSMessage :: EncodeJson WSMessage where
  encodeJson (WSMessage {t, m}) =
    "t" := t
    ~> "m" := m
    ~> jsonEmptyObject


foreign import onMessage ::
  forall e.
  WebSocket ->
  (String -> Eff (ws :: WS, err :: EXCEPTION | e) Unit) ->
  Eff (ws :: WS, err :: EXCEPTION | e) Unit

foreign import onClose ::
  forall e.
  WebSocket ->
  (Unit -> Eff (ws :: WS | e) Unit) ->
  Eff (ws :: WS | e) Unit

foreign import send ::
  forall e. WebSocket -> String -> Eff (ws :: WS | e) Unit

listenTo :: forall a e. (DecodeJson a) =>
  WebSocket
  -> WSEndpoint a
  -> (a -> Eff (ws :: WS, console :: CONSOLE, err :: EXCEPTION | e) Unit)
  -> Eff (ws :: WS, console :: CONSOLE, err :: EXCEPTION | e) Unit
listenTo ws (WSEndpoint typ) handler =
  onMessage ws go
  where
    go mess = either log id
               $ jsonParser mess >>= decodeJson >>=
                 \(WSMessage {t, m}) ->
                   if t == typ
                     then jsonParser m >>= decodeJson <#> handler
                     else (Left "WSMessage type param incorrect")

sendTo :: forall a e. (EncodeJson a) =>
  WebSocket
  -> WSEndpoint a
  -> a
  -> Eff (ws :: WS | e) Unit
sendTo ws (WSEndpoint typ) a =
  send ws (stringify (encodeJson $ WSMessage {t: typ, m: stringify (encodeJson a)}))
