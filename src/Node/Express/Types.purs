module Node.Express.Types where

import Data.Foreign
import Data.Foreign.Class
import Data.Either
import Data.Foreign.EasyFFI
import Data.String.Regex
import Data.Default
import Control.Monad.Eff
import Control.Monad.Eff.Unsafe
import Control.Monad.Eff.Class


foreign import data Express :: !

--| General monad, indicates that we're dealing with
--  express.js related functions.
--  Applications should use HandlerM and AppM primarily
--  and ExpressM in rare cases.
type ExpressM a = forall e. Eff (express :: Express | e) a

instance monadEffExpressM :: MonadEff (Eff e) where
    liftEff = unsafeInterleaveEff


foreign import data Application :: *
foreign import data Event :: *
foreign import data Response :: *
foreign import data Request :: *

data Protocol = Http | Https

instance isForeignProtocol :: IsForeign Protocol where
    read value = case readString value of
        Right "http"  -> Right Http
        Right "https" -> Right Https
        _ -> Left $ JSONError "Unknown protocol"


data Method = ALL | GET | POST | PUT | DELETE

instance showMethod :: Show Method where
    show ALL    = "all"
    show GET    = "get"
    show POST   = "post"
    show PUT    = "put"
    show DELETE = "delete"

instance isForeignMethod :: IsForeign Method where
    read value = case readString value of
        Right "GET"    -> Right GET
        Right "POST"   -> Right POST
        Right "PUT"    -> Right PUT
        Right "DELETE" -> Right DELETE
        _ -> Left $ JSONError "Unknown HTTP method"

type Port = Number
type Path = String

class RoutePattern a
instance routePath  :: RoutePattern String
instance routeRegex :: RoutePattern Regex

class RequestParam a
instance requestParamString :: RequestParam String
instance requestParamNumber :: RequestParam Number

--| Cookie options
--  - maxAge -- time in msecs
--  - signed -- use secret to sign if true
--  - path   -- cookie path
newtype CookieOptions = CookieOptions { maxAge :: Number, signed :: Boolean, path :: String }

instance defaultCookieOptions :: Default CookieOptions where
    def = CookieOptions { maxAge: oneYear, signed: false, path: "/" }
      where oneYear = 365 * 24 * 60 * 60 * 1000
