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
import Prelude (Unit, id, ($), (<#>), (<$>), (<*>), (<<<), (==), (>>=))

foreign import data WS :: !
foreign import data WebSocket :: *
type RemoveListener = forall e. Unit -> Eff (ws :: WS | e) Unit

newtype WSMessage = WSMessage {t :: String, m :: String}
data WSEndpoint a = WSEndpoint String

newtype WrappedWS =
  WrappedWS
  { onMessage :: forall e. (String -> Eff (ws :: WS, err :: EXCEPTION | e) Unit)
                           -> Eff (ws :: WS, err :: EXCEPTION | e) RemoveListener,
    onClose :: forall e. (Unit -> Eff (ws :: WS | e) Unit)
                         -> Eff (ws :: WS | e) RemoveListener,
    send :: forall e. String -> Eff (ws :: WS | e) Unit,
    ws :: WebSocket
  }

foreign import wrapWS :: WebSocket -> WrappedWS

foreign import connectImpl :: forall e.
                          (Error -> Eff (ws :: WS | e) Unit) ->
                          (WebSocket -> Eff (ws :: WS | e) Unit) ->
                          String -> Eff (ws :: WS | e) Unit
connect:: forall e.
          (Error -> Eff (ws :: WS | e) Unit)
          -> (WrappedWS -> Eff (ws :: WS | e) Unit)
          -> String -> Eff (ws :: WS | e) Unit
connect errcb successcb url = connectImpl errcb (successcb <<< wrapWS) url

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


listenTo :: forall a e. (DecodeJson a) =>
  WrappedWS
  -> WSEndpoint a
  -> (a -> Eff (ws :: WS, console :: CONSOLE, err :: EXCEPTION | e) Unit)
  -> Eff (ws :: WS, console :: CONSOLE, err :: EXCEPTION | e) RemoveListener
listenTo (WrappedWS ws) (WSEndpoint typ) handler =
  ws.onMessage go
  where
    go mess = either log id
               $ jsonParser mess >>= decodeJson >>=
                 \(WSMessage {t, m}) ->
                   if t == typ
                     then jsonParser m >>= decodeJson <#> handler
                     else (Left "WSMessage type param incorrect")

sendTo :: forall a e. (EncodeJson a) =>
  WrappedWS
  -> WSEndpoint a
  -> a
  -> Eff (ws :: WS | e) Unit
sendTo (WrappedWS ws) (WSEndpoint typ) a =
  ws.send (stringify (encodeJson $ WSMessage {t: typ, m: stringify (encodeJson a)}))
