{-# LANGUAGE TypeSynonymInstances #-}
{-# LANGUAGE DeriveDataTypeable #-}
{-# LANGUAGE MultiParamTypeClasses #-}
import qualified Data.Map as M (union, fromList)
import qualified XMonad.StackSet as W (shift)
import System.Posix.Unistd (nodeName, getSystemID)
import XMonad
import XMonad.Actions.SpawnOn
import XMonad.Actions.WindowBringer
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.SetWMName
import XMonad.Layout.Maximize
import XMonad.Layout.MultiToggle
import XMonad.Layout.MultiToggle.Instances
import XMonad.Layout.NoBorders
import XMonad.Layout.ResizableTile
import XMonad.Layout.ResizeScreen
import XMonad.Layout.Tabbed
import XMonad.Util.Run

main :: IO ()
main = do
   host <- fmap nodeName getSystemID
   myDzen host xmonad

myDzen host f = do
  h <- spawnPipe ("dzen2" ++ " " ++ flags)
  sp <- mkSpawner
  f $ defaultConfig
           { logHook = dynamicLogWithPP obPP
                           { ppOutput = hPutStrLn h }
           , keys = \c -> mykeys sp c `M.union` keys defaultConfig c
           , layoutHook = smartBorders $
                          maximize $
                          avoidStruts $
                          mkToggle (FULL ?? SHOWCONKY ?? SHOWALL ?? EOT) (
                                  Mirror tiled
                              ||| tiled
                              ||| noBorders Full)
                          ||| tabbed shrinkText myTabConfig
           , terminal = "xterm"
           , focusedBorderColor = "#00ff00"
           , modMask = mod4Mask
           , startupHook = setWMName "LG3D"
           , focusFollowsMouse = False
           , manageHook    = manageSpawn sp <+> myManageHook
           }
 where
    w       = if host == "mammut" then 800 else
              if host == "foldl" then 700
              else 900 :: Integer
    fg      = "'#000000'"
    bg      = "'#b0c4de'"
    flags   = "-e '' -w " ++ show w ++ " -ta l -fg "
              ++ fg ++ " -bg " ++ bg ++ " -fn "
              ++ if host == "foldl"
                 then "-*-*-*-*-*-*-12-*-*-*-*-*-*-*"
                 else "-xos4-terminus-*-*-*-*-12-*-*-*-*-*-*-*"
    tiled   = ResizableTall 2 (3/100) 0.618034 []
    mykeys _ (XConfig {modMask = modm}) = M.fromList $
      [ ((modm, xK_x), sendMessage MirrorShrink)
      , ((modm, xK_s), sendMessage MirrorExpand)
      , ((modm, xK_b), sendMessage ToggleStruts)
      , ((modm, xK_c), sendMessage $ Toggle SHOWCONKY)
      , ((modm, xK_v), sendMessage $ Toggle SHOWALL)
      , ((modm, xK_f), sendMessage $ Toggle FULL)
      , ((modm, xK_a), spawn "audacious2")
      , ((modm, xK_n), spawn "nautilus /home/obraun")
      , ((modm, xK_r), spawn "/home/obraun/bin/thinkpad-fn-f7")
      , ((modm, xK_z), spawn "/usr/bin/xscreensaver-command -lock")
      , ((modm .|. shiftMask, xK_t), spawn "gnome-terminal")
      , ((modm .|. shiftMask, xK_f)
        , withFocused (sendMessage . maximizeRestore))
      , ((modm, xK_g     ), gotoMenu)
      , ((modm .|. shiftMask, xK_g     ), bringMenu)
      , ((0, 0x1008ff11), spawn "amixer -q set Master 1-")
      , ((0, 0x1008ff13), spawn "amixer -q set Master 1+")
      , ((0, 0x1008ff12), spawn "amixer -q set Master toggle")
      , ((0, 0x1008ff17), spawn "audacious2 -f")
      , ((0, 0x1008ff16), spawn "audacious2 -r")
      , ((0, 0x1008ff14), spawn "audacious2 -t")
      , ((0, 0x1008ff15), spawn "audacious2 -s")
      ]
    myManageHook :: ManageHook
    myManageHook = composeAll . concat $
        [ [ title =? t --> doFloat | t <- myTitleFloats]
        , [ className =? c --> doFloat | c <- myClassFloats ]
        , [ resource =? c --> doFloat | c <- myResourceFloats ]
        , [ composeOne [isFullscreen -?> doFullFloat] ]
        , [ className   =? "stalonetray"   --> doIgnore
          , className   =? "Chromium-browser"        --> doF(W.shift "2")
          , className   =? "Eclipse"       --> doF(W.shift "7")
          , className   =? "SeaMonkey" --> doF(W.shift "9")
          ]
        ]
        where
            myTitleFloats = ["pqiv","gxmessage","MPlayer"]
            myClassFloats = ["Pinentry"]
            myResourceFloats = ["sun-awt-X11-XFramePeer"]

data Showconky = SHOWCONKY deriving (Read, Show, Eq, Typeable)

instance Transformer Showconky Window where
    transform _ x k = k (resizeHorizontal 400 x)

data ShowAll = SHOWALL deriving (Read, Show, Eq, Typeable)

instance Transformer ShowAll Window where
    transform _ x k = k (resizeVertical 750 x)

obPP :: PP
obPP = defaultPP
  { ppCurrent  = dzenColor "green" "red" . wrap "[" "]"
  , ppVisible  = dzenColor "black" "orange" . pad
  , ppHidden   = dzenColor "black" "yellow" . wrap "^ " " "
  , ppHiddenNoWindows = dzenColor "black" "green" . pad
  , ppLayout   = (>> "")
  , ppSep     = " ^fg(grey60)^r(3x3)^fg() "
  }

myTabConfig :: Theme
myTabConfig = defaultTheme
  { inactiveBorderColor = "#708090"
  , activeBorderColor = "#5f9ea0"
  , activeColor = "#000000"
  , inactiveColor = "#333333"
  , inactiveTextColor = "#888888"
  , activeTextColor = "#87cefa"
  , fontName = "-xos4-terminus-*-*-*-*-12-*-*-*-*-*-*-*"
  , decoHeight = 15
  }

