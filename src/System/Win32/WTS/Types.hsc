module System.Win32.WTS.Types where

#include <windows.h>
#include <wtsapi32.h>
#include <Win32Wts.h>

import Control.Applicative
import Foreign
import Foreign.C
import Foreign.C.String
import Foreign.Storable ()
import System.Win32.Types

wTS_CURRENT_SERVER :: HANDLE
wTS_CURRENT_SERVER = nullHANDLE

wTS_CURRENT_SERVER_HANDLE :: HANDLE
wTS_CURRENT_SERVER_HANDLE = nullHANDLE

newtype WTS_CONNECTSTATE_CLASS = WTS_CONNECTSTATE_CLASS { connStateClass :: #{type WTS_CONNECTSTATE_CLASS} }
  deriving (Eq)

instance Storable WTS_CONNECTSTATE_CLASS where
  sizeOf _ = #{size WTS_CONNECTSTATE_CLASS}
  alignment _ = 4
  peek p = fmap WTS_CONNECTSTATE_CLASS (peek $ castPtr p)
  poke p (WTS_CONNECTSTATE_CLASS v) = poke (castPtr p) v

#{enum WTS_CONNECTSTATE_CLASS, WTS_CONNECTSTATE_CLASS
 , csActive = WTSActive
 , csConnected = WTSConnected
 , csConnectQuery = WTSConnectQuery
 , csShadow = WTSShadow
 , csDisconnected = WTSDisconnected
 , csIdle = WTSIdle
 , csListen = WTSListen
 , csReset = WTSReset
 , csDown = WTSDown
 , csInit  = WTSInit
}

-- | Specifies the connection state of a Remote Desktop Services session.
data WtsConnectState
  = WTSActive
  | WTSConnected
  | WTSConnectQuery
  | WTSShadow
  | WTSDisconnected
  | WTSIdle
  | WTSListen
  | WTSReset
  | WTSDown
  | WTSInit
  deriving (Enum, Eq, Show)

-- | Specifies information about the protocol type for the session.
data WtsProtocolType
  -- | The console session.
  = WtsConsole
  -- | This value is retained for legacy purposes.
  | WtsICA
  -- | The RDP protocol.
  | WtsRDP
  deriving (Enum, Eq, Show)

type SID = DWORD

-- | Contains information about a client session on a Remote Desktop Session
-- Host (RD Session Host) server.
data WtsSessionInfo = WtsSessionInfo
  { wsiSessionId      :: DWORD
  -- ^ Session identifier of the session.
  , wsiWinStationName :: String
  -- ^ WinStation name of this session. The WinStation name is a name
  -- that Windows associates with the session, for example, "services",
  -- "console", or "RDP-Tcp#0".
  , wsiState          :: WtsConnectState
  -- ^ A value indicates the session's current connection state.
  } deriving (Eq, Show)

convertWtsSessionInfo :: WTS_SESSION_INFO -> IO WtsSessionInfo
convertWtsSessionInfo (WTS_SESSION_INFO sid wsName st) = WtsSessionInfo
    <$> pure sid
    <*> peekCWString wsName
    <*> pure (convertContentState $ connStateClass st)
  where convertContentState = toEnum . fromIntegral

data WTS_SESSION_INFO = WTS_SESSION_INFO
  { sessionId      :: DWORD
  , winStationName :: LPWSTR
  , state          :: WTS_CONNECTSTATE_CLASS
  }

instance Storable WTS_SESSION_INFO where
  sizeOf _ = #{size WTS_SESSION_INFOW}
  alignment _ = alignment (undefined :: CInt)
  peek p = WTS_SESSION_INFO
    <$> #{peek WTS_SESSION_INFO, SessionId} p
    <*> #{peek WTS_SESSION_INFO, pWinStationName} p
    <*> #{peek WTS_SESSION_INFO, State} p
  poke p x = do
    #{poke WTS_SESSION_INFO, SessionId} p $ sessionId x
    #{poke WTS_SESSION_INFO, pWinStationName} p $ winStationName x
    #{poke WTS_SESSION_INFO, State} p $ state x

type LPWTS_SESSION_INFO = Ptr WTS_SESSION_INFO

-- WTS_INFO_CLASS
-- | Contains values that indicate the type of session information
-- to retrieve in a call to the WTSQuerySessionInformation function.
newtype WTS_INFO_CLASS = WTS_INFO_CLASS { infoClass :: #{type WTS_INFO_CLASS} }
  deriving (Eq)

instance Storable WTS_INFO_CLASS where
  sizeOf _ = #{size WTS_INFO_CLASS}
  alignment _ = 4
  peek p = fmap WTS_INFO_CLASS (peek $ castPtr p)
  poke p (WTS_INFO_CLASS x) = poke (castPtr p) x

#{enum WTS_INFO_CLASS, WTS_INFO_CLASS
  , icWTSInitialProgram = WTSInitialProgram
  , icWTSApplicationName = WTSApplicationName
  , icWTSWorkingDirectory = WTSWorkingDirectory
  , icWTSOEMId = WTSOEMId
  , icWTSSessionId = WTSSessionId
  , icWTSUserName = WTSUserName
  , icWTSWinStationName = WTSWinStationName
  , icWTSDomainName = WTSDomainName
  , icWTSConnectState = WTSConnectState
  , icWTSClientBuildNumber = WTSClientBuildNumber
  , icWTSClientName = WTSClientName
  , icWTSClientDirectory = WTSClientDirectory
  , icWTSClientProductId = WTSClientProductId
  , icWTSClientHardwareId = WTSClientHardwareId
  , icWTSClientAddress = WTSClientAddress
  , icWTSClientDisplay = WTSClientDisplay
  , icWTSClientProtocolType = WTSClientProtocolType
  , icWTSIdleTime = WTSIdleTime
  , icWTSLogonTime = WTSLogonTime
  , icWTSIncomingBytes = WTSIncomingBytes
  , icWTSOutgoingBytes = WTSOutgoingBytes
  , icWTSIncomingFrames = WTSIncomingFrames
  , icWTSOutgoingFrames = WTSOutgoingFrames
  , icWTSClientInfo = WTSClientInfo
  , icWTSSessionInfo = WTSSessionInfo
}
-- , icWTSSessionInfoEx = WTSSessionInfoEx
-- , icWTSConfigInfo = WTSConfigInfo
-- , icWTSValidationInfo = WTSValidationInfo
-- , icWTSSessionAddressV4 = WTSSessionAddressV4
-- , icWTSIsRemoteSession = WTSIsRemoteSession

data WtsInfoClass
  = WTSInitialProgram
  | WTSApplicationName
  | WTSWorkingDirectory
  | WTSOEMId
  | WTSSessionId
  | WTSUserName
  | WTSWinStationName
  | WTSDomainName
  | WTSConnectState
  | WTSClientBuildNumber
  | WTSClientName
  | WTSClientDirectory
  | WTSClientProductId
  | WTSClientHardwareId
  | WTSClientAddress
  | WTSClientDisplay
  | WTSClientProtocolType
  | WTSIdleTime
  | WTSLogonTime
  | WTSIncomingBytes
  | WTSOutgoingBytes
  | WTSIncomingFrames
  | WTSOutgoingFrames
  | WTSClientInfo
  | WTSSessionInfo
  -- | WTSSessionInfoEx
  -- | WTSConfigInfo
  -- | WTSValidationInfo
  -- | WTSSessionAddressV4
  -- | WTSIsRemoteSession
  deriving (Enum, Eq, Show)