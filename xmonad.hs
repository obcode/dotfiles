{-# LANGUAGE TypeSynonymInstances #-}
{-# LANGUAGE DeriveDataTypeable #-}
{-# LANGUAGE MultiParamTypeClasses #-}
import qualified Data.Map as M (union, fromList)
import Control.Concurrent (threadDelay)
import qualified XMonad.StackSet as W (shift, greedyView, view)
import XMonad
import XMonad.Actions.SpawnOn
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.EwmhDesktops
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
import XMonad.Layout.WindowNavigation
import XMonad.Prompt
import XMonad.Prompt.Window
import XMonad.Util.Run

main :: IO ()
main = do
  h <- spawnPipe "xmobar ~/.xmonad/xmobar.config"
  xmonad $ defaultConfig
    { logHook = dynamicLogWithPP obPP
                    { ppOutput = hPutStrLn h }
    , keys = \c -> mykeys c `M.union` keys defaultConfig c
    , layoutHook =
                   avoidStruts $
                   smartBorders $
                   maximize $
                   windowNavigation $
                   mkToggle (FULL ?? SHOWCONKY ?? SHOWALL ?? EOT)
                      (    Mirror tiled
                       ||| tiled
                       ||| noBorders Full)
                   ||| tabbed shrinkText myTabConfig
    , terminal = "xterm"
    , focusedBorderColor = "cyan"
    , modMask = mod4Mask
    , startupHook = setWMName "LG3D"
    , focusFollowsMouse = False
    , manageHook    = manageSpawn <+> myManageHook
    , handleEventHook    = fullscreenEventHook -- Only in darcs xmonad-contrib
    }
 where
    obPP :: PP
    obPP = defaultPP
      { ppCurrent         = xmobarColor "red" "black"
      , ppVisible         = xmobarColor "orange" "black"
      , ppHidden          = xmobarColor "yellow" "black"
      , ppHiddenNoWindows = xmobarColor "green" "black"
      , ppLayout          = (>> "")
      , ppTitle           = xmobarColor "magenta" "black"
      , ppSep             = " "
      }
    myTabConfig :: Theme
    myTabConfig = defaultTheme
      { inactiveBorderColor = "#708090"
      , activeBorderColor   = "#5f9ea0"
      , activeColor         = "#000000"
      , inactiveColor       = "#333333"
      , inactiveTextColor   = "#888888"
      , activeTextColor     = "#87cefa"
      , fontName            = "-xos4-terminus-*-*-*-*-12-*-*-*-*-*-*-*"
      , decoHeight          = 15
      }
    tiled   = ResizableTall 2 (3/100) 0.618034 []
    mykeys conf@(XConfig {modMask = modm}) = M.fromList $
      [ ((modm, xK_x), sendMessage MirrorShrink)
      , ((modm, xK_s), sendMessage MirrorExpand)
      , ((modm, xK_b), sendMessage ToggleStruts)
      , ((modm, xK_c), sendMessage $ Toggle SHOWCONKY)
      , ((modm, xK_v), sendMessage $ Toggle SHOWALL)
      , ((modm, xK_f), sendMessage $ Toggle FULL)
      , ((modm, xK_n), spawn "nautilus")
      , ((modm, xK_o), spawn "xclip -o | xargs google-chrome")
      , ((modm, xK_r), do spawn "xrandr --output LVDS1 --auto"
                          spawn "xrandr --output VGA1 --auto --right-of LVDS1"
                          io $ threadDelay (10^6)
                          screenWorkspace 1 >>= flip whenJust (windows . W.view)
                          windows $ W.greedyView "5")
      , ((modm .|. shiftMask, xK_f), withFocused (sendMessage . maximizeRestore))
      , ((modm .|. shiftMask, xK_g), windowPromptGoto  defaultXPConfig)
      , ((modm .|. shiftMask, xK_b), windowPromptBring defaultXPConfig)
      , ((0, 0x1008ff11), spawn "amixer -q set Master 1-")
      , ((0, 0x1008ff13), spawn "amixer -q set Master 1+")
      , ((0, 0x1008ff12), spawn "amixer -q set Master toggle")
      , ((0, 0x1008ff81), spawn "audacious -t")
      , ((0, 0x1008ff17), spawn "audacious -f")
      , ((0, 0x1008ff16), spawn "audacious -r")
      , ((0, 0x1008ff14), spawn "audacious -t")
      , ((0, 0x1008ff15), spawn "audacious -s")
      , ((modm,                 xK_Right), sendMessage $ Go R)
      , ((modm,                 xK_Left ), sendMessage $ Go L)
      , ((modm,                 xK_Up   ), sendMessage $ Go U)
      , ((modm,                 xK_Down ), sendMessage $ Go D)
      , ((modm .|. controlMask, xK_Right), sendMessage $ Swap R)
      , ((modm .|. controlMask, xK_Left ), sendMessage $ Swap L)
      , ((modm .|. controlMask, xK_Up   ), sendMessage $ Swap U)
      , ((modm .|. controlMask, xK_Down ), sendMessage $ Swap D)
      ]
      ++
      [( (modm .|. controlMask, k)
       , do screenWorkspace 1 >>= flip whenJust (windows . W.view)
            windows $ W.greedyView i)
      | (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_9]]
    myManageHook :: ManageHook
    myManageHook = composeAll . concat $
        [ [ title     =? t --> doFloat | t <- myTitleFloats    ]
        , [ className =? c --> doFloat | c <- myClassFloats    ]
        , [ resource  =? c --> doFloat | c <- myResourceFloats ]
        , [ composeOne [isFullscreen -?> doFullFloat] ]
        , [ className   =? "stalonetray"       --> doIgnore
          , className   =? "Chromium-browser"  --> doF (W.shift "2")
          , className   =? "Google-chrome"     --> doF (W.shift "2")
          , className   =? "Eclipse"           --> doF (W.shift "7")
          , className   =? "SeaMonkey"         --> doF (W.shift "9")
          ]
        ]
        where
            myTitleFloats    = ["pqiv","gxmessage","MPlayer"]
            myClassFloats    = ["Pinentry","Gimp"]
            myResourceFloats = ["sun-awt-X11-XFramePeer"]

data Showconky = SHOWCONKY deriving (Read, Show, Eq, Typeable)

instance Transformer Showconky Window where
    transform _ x k = k (resizeHorizontal 400 x) (const x)

data ShowAll = SHOWALL deriving (Read, Show, Eq, Typeable)

instance Transformer ShowAll Window where
    transform _ x k = k (resizeVertical 750 x) (const x)
