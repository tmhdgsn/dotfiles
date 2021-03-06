-------------------------------------------------------------------------------
--                  __  ____  __                       _                     --
--                  \ \/ /  \/  | ___  _ __   __ _  __| |                    --
--                   \  /| |\/| |/ _ \| '_ \ / _` |/ _` |                    --
--                   /  \| |  | | (_) | | | | (_| | (_| |                    --
--                  /_/\_\_|  |_|\___/|_| |_|\__,_|\__,_|                    --
--                                                                           --
-------------------------------------------------------------------------------
--          written by Shotaro Fujimoto (https://github.com/ssh0)            --
--          modified and repaired by Ogis (https://github.com/Minda1975)     --
--          modified very slightly by tmhdgsn (https://github.com/tmhdgsn)
-------------------------------------------------------------------------------
-- Import modules                                                           {{{
-------------------------------------------------------------------------------
import qualified Data.Map as M
import Control.Monad (liftM2)          -- myManageHookShift
import Data.Monoid
import System.IO                       -- for xmobar

import XMonad
import qualified XMonad.StackSet as W  -- myManageHookShift

import XMonad.Actions.CopyWindow
import XMonad.Actions.CycleWS
import qualified XMonad.Actions.FlexibleResize as Flex -- flexible resize
import XMonad.Actions.FloatKeys
import XMonad.Actions.UpdatePointer
import XMonad.Actions.WindowGo
import XMonad.Actions.DwmPromote       -- zoom swap dwm style

import XMonad.Hooks.DynamicLog         -- for xmobar
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.ManageDocks        -- avoid xmobar area
import XMonad.Hooks.ManageHelpers

import XMonad.Layout
import XMonad.Layout.DragPane          -- see only two window
import XMonad.Layout.Gaps
import XMonad.Layout.LayoutScreens
import XMonad.Layout.NoBorders         -- In Full mode, border is no use
import XMonad.Layout.PerWorkspace      -- Configure layouts on a per-workspace
import XMonad.Layout.ResizableTile     -- Resizable Horizontal border
import XMonad.Layout.Simplest
import XMonad.Layout.SimplestFloat
import XMonad.Layout.Spacing           -- this makes smart space around windows
import XMonad.Layout.ToggleLayouts     -- Full window at any time
import XMonad.Layout.TwoPane
import XMonad.Layout.Renamed
import XMonad.Layout.ThreeColumns
import XMonad.Layout.Grid

import XMonad.Prompt
import XMonad.Prompt.Window            -- pops up a prompt with window names
import XMonad.Util.EZConfig            -- removeKeys, additionalKeys
import XMonad.Util.Run
import XMonad.Util.Run(spawnPipe)      -- spawnPipe, hPutStrLn
import XMonad.Util.SpawnOnce

import Graphics.X11.ExtraTypes.XF86
import qualified XMonad.Layout.IndependentScreens
--------------------------------------------------------------------------- }}}
-- local variables                                                          {{{
-------------------------------------------------------------------------------

myWorkspaces = ["1", "2", "3", "4", "5"]
modm = mod4Mask

-- Soft Color Setting
colorBlue       = "#477ab3"
colorGreen      = "#52ad91"
colorRed        = "#84a0c6"
colorGray       = "#4d4d4d"
colorWhite      = "#ffffff"
colorNormalbg   = "#1b1b1b"
colorfg         = "#ffffff"


-- Border width
borderwidth = 3

-- Border color
mynormalBorderColor  = "#333333"
myfocusedBorderColor = "#cca8c9"

-- Float window control width
moveWD = borderwidth
resizeWD = 2*borderwidth

-- gapwidth
gapwidth  = 9
gwU = 1
gwD = 0
gwL = 42
gwR = 42

--------------------------------------------------------------------------- }}}
-- main                                                                     {{{
-------------------------------------------------------------------------------

main :: IO ()

main = do
    wsbar <- spawnPipe myWsBar
    xmonad $ ewmh def
       { borderWidth        = borderwidth
       , terminal           = "urxvt"
       , focusFollowsMouse  = True
       , normalBorderColor  = mynormalBorderColor
       , focusedBorderColor = myfocusedBorderColor
       , manageHook         = myManageHookShift <+>
                              myManageHookFloat <+>
                              manageDocks
       , layoutHook         = avoidStruts $ ( toggleLayouts (noBorders Full)
                                            -- $ onWorkspace "3" simplestFloat
                                            $ myLayout
                                            )
        -- xmobar setting
       , logHook = myLogHook wsbar >> updatePointer (0.5,0.5) (0,0)
       , handleEventHook    = fullscreenEventHook <+> docksEventHook
       , workspaces         = myWorkspaces
       , modMask            = modm
       , mouseBindings      = newMouse
       }	
		
       -------------------------------------------------------------------- }}}
       -- Define keys to remove                                             {{{
       ------------------------------------------------------------------------

       `removeKeysP`
       [
       -- Unused gmrun binding
       "M-S-p",
       -- Unused close window binding
       "M-S-c",
       "M-S-<Return>"
       ]

       -------------------------------------------------------------------- }}}
       -- Keymap: window operations                                         {{{
       ------------------------------------------------------------------------

       `additionalKeysP`
       [
       -- Shrink / Expand the focused window
         ("M-,"    , sendMessage Shrink)
       , ("M-."    , sendMessage Expand)
       , ("M-z"    , sendMessage MirrorShrink)
       , ("M-a"    , sendMessage MirrorExpand)
       -- Close the focused window
       , ("M-S-c"    , kill1)
       -- Toggle layout (Fullscreen mode)
       , ("M-f"    , sendMessage ToggleLayout)
       --, ("M-S-f"  , withFocused (keysMoveWindow (-borderwidth,-borderwidth)))
       -- toggle layout (simplest float)
       , ("M-u"    , sendMessage (Toggle "Simplest"))
       -- Move the focused window
       , ("M-C-<R>", withFocused (keysMoveWindow (moveWD, 0)))
       , ("M-C-<L>", withFocused (keysMoveWindow (-moveWD, 0)))
       , ("M-C-<U>", withFocused (keysMoveWindow (0, -moveWD)))
       , ("M-C-<D>", withFocused (keysMoveWindow (0, moveWD)))
       -- Resize the focused window
       , ("M-s"    , withFocused (keysResizeWindow (-resizeWD, -resizeWD) (0.5, 0.5)))
       , ("M-i"    , withFocused (keysResizeWindow (resizeWD, resizeWD) (0.5, 0.5)))
       -- Increase / Decrese the number of master pane
       , ("M-S-;"  , sendMessage $ IncMasterN 1)
       , ("M--"    , sendMessage $ IncMasterN (-1))
       -- Go to the next / previous workspace
       , ("M-<R>"  , nextWS )
       , ("M-<L>"  , prevWS )
       , ("M-l"    , nextWS )
       , ("M-h"    , prevWS )
       -- Shift the focused window to the next / previous workspace
       , ("M-S-<R>", shiftToNext)
       , ("M-S-<L>", shiftToPrev)
       , ("M-S-l"  , shiftToNext)
       , ("M-S-h"  , shiftToPrev)
       -- CopyWindow
       , ("M-v"    , windows copyToAll)
       , ("M-S-v"  , killAllOtherCopies)
       -- Move the focus down / up
       , ("M-<D>"  , windows W.focusDown)
       , ("M-<U>"  , windows W.focusUp)
       , ("M-j"    , windows W.focusDown)
       , ("M-k"    , windows W.focusUp)
       -- Swap the focused window down / up
       , ("M-S-j"  , windows W.swapDown)
       , ("M-S-k"  , windows W.swapUp)
       , ("M-S-<D>"  , windows W.swapDown)
       , ("M-S-<U>"  , windows W.swapUp)
       -- Shift the focused window to the master window
       , ("M-S-m"  , windows W.shiftMaster)
       -- Search a window and focus into the window
       , ("M-g"    , windowPromptGoto myXPConfig)
       -- Search a window and bring to the current workspace
       , ("M-b"    , windowPromptBring myXPConfig)
       -- Move the focus to next screen (multi screen)
       , ("M-<Tab>", nextScreen)
       -- Now we have more than one screen by dividing a single screen
       , ("M-C-<Space>", layoutScreens 2 (TwoPane 0.5 0.5))
       , ("M-C-S-<Space>", rescreen)
       ]

       -------------------------------------------------------------------- }}}
       -- Keymap: moving workspace by number                                {{{
       ------------------------------------------------------------------------

       `additionalKeys`
       [ ((modm .|. m, k), windows $ f i)
         | (i, k) <- zip myWorkspaces
                     [ xK_exclam, xK_at, xK_numbersign
                     , xK_dollar, xK_percent, xK_asciicircum
                     , xK_ampersand, xK_asterisk, xK_parenleft
                     , xK_parenright
                     ]
         , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]
         ]

       -------------------------------------------------------------------- }}}
       -- Keymap: custom commands                                           {{{
       ------------------------------------------------------------------------

       `additionalKeysP`
       [
       -- Zoomswap dwm like
         ("M-<Return>", dwmpromote) 
       -- Launch terminal
       , ("M-S-<Return>", spawn "urxvt")
		-- Lock Screen
	   , ("M-S-l", spawn "slock")
       -- Launch file manager
       , ("M-S-f", spawn "pcmanfm")
       -- Launch web browser
       , ("M-S-w", spawn "chromium")
       -- Launch dmenu for launching applicatiton
       , ("M-p", spawn "/home/t/.scripts/emenu_run")
       , ("M-r", spawn "/home/t/.scripts/emenu_run")
       -- Toggle workspace
       , ("M-<Tab>", toggleWS)
       -- Play / Pause media keys
       --, ("<XF86AudioPlay>"  , spawn "ncmpcpp toggle")
       --, ("<XF86HomePage>"   , spawn "ncmpcpp toggle")
       --, ("S-<F6>"           , spawn "ncmpcpp toggle")
       --, ("S-<XF86AudioPlay>", spawn "streamradio pause")
       --, ("S-<XF86HomePage>" , spawn "streamradio pause")
       -- Volume setting media keys
       --, ("<XF86AudioRaiseVolume>", spawn "sound_volume_change_wrapper.sh +")
       --, ("<XF86AudioLowerVolume>", spawn "sound_volume_change_wrapper.sh -")
       --, ("<XF86AudioMute>"       , spawn "sound_volume_change_wrapper.sh m")
        -- Brightness Keys
       , ("<XF86MonBrightnessUp>"  , spawn "xbacklight + 5 -time 100 -steps 1")
       , ("<XF86MonBrightnessDown>", spawn "xbacklight - 5 -time 100 -steps 1")
       -- Take a screenshot (whole window)
       , ("<Print>", spawn "scrot")
       ]

--------------------------------------------------------------------------- }}}
-- myLayout:          Handle Window behaveior                               {{{
-------------------------------------------------------------------------------

--myLayout = spacing gapwidth $ gaps [(U, gwU),(D, gwD),(L, gwL),(R, gwR)]
--           $ (ResizableTall 1 (1/204) (119/204) [])
--             ||| (TwoPane (1/204) (119/204))
--             ||| Simplest

myLayout =  tiled ||| mtiled ||| full ||| threecol ||| grid
	where
    nmaster  = 1     -- Default number of windows in master pane
    delta    = 2/100 -- Percentage of the screen to increment when resizing
    ratio    = 5/8   -- Defaul proportion of the screen taken up by main pane
    rt       = spacing 5 $ ResizableTall nmaster delta ratio []
    tiled    = renamed [Replace "T"] $ smartBorders rt
    mtiled   = renamed [Replace "Bs"] $ smartBorders $ Mirror rt
    full     = renamed [Replace "M"] $ noBorders Full
    threecol = renamed [Replace "3c"] $ ThreeColMid 1 (3/100) (1/2)
    grid     = renamed [Replace "G"] $ GridRatio (3/3)
--------------------------------------------------------------------------- }}}
-- myManageHookShift: some window must created there                        {{{
-------------------------------------------------------------------------------

myManageHookShift = composeAll
            -- if you want to know className, type "$ xprop|grep CLASS" on shell
            [ className =? "Gimp"       --> mydoShift "3"
            ]
             where mydoShift = doF . liftM2 (.) W.greedyView W.shift

--------------------------------------------------------------------------- }}}
-- myManageHookFloat: new window will created in Float mode                 {{{
-------------------------------------------------------------------------------

myManageHookFloat = composeAll
	[
      className =? "feh"              --> doCenterFloat
    --, className =? "Thunar"           --> doCenterFloat
    , title     =? "urxvt_float"      --> doSideFloat SC
    , isFullscreen                    --> doFullFloat
    , isDialog                        --> doCenterFloat
    , stringProperty "WM_NAME" =? "LINE" --> (doRectFloat $ W.RationalRect 0.60 0.1 0.39 0.82)
    , stringProperty "WM_NAME" =? "Google Keep" --> (doRectFloat $ W.RationalRect 0.3 0.1 0.4 0.82)
    , stringProperty "WM_NAME" =? "tmptex.pdf - 1/1 (96 dpi)" --> (doRectFloat $ W.RationalRect 0.29 0.25 0.42 0.5)
    , stringProperty "WM_NAME" =? "Figure 1" --> doCenterFloat
    ]

--------------------------------------------------------------------------- }}}
-- myLogHook:         loghock settings                                      {{{
-------------------------------------------------------------------------------

myLogHook h = dynamicLogWithPP $ wsPP { ppOutput = hPutStrLn h }

--------------------------------------------------------------------------- }}}
-- myWsBar:           xmobar setting                                        {{{
-------------------------------------------------------------------------------

myWsBar = "xmobar $HOME/.xmonad/xmobarrc"

wsPP = xmobarPP { ppOrder           = \(ws:l:t:_)  -> [ws,l,t]
                , ppCurrent         = xmobarColor colorRed     colorNormalbg . \s -> "●"
                , ppUrgent          = xmobarColor colorGray    colorNormalbg . \s -> "●"
                , ppVisible         = xmobarColor colorRed     colorNormalbg . \s -> "|"
                , ppHidden          = xmobarColor colorGray    colorNormalbg . \s -> "●"
                , ppHiddenNoWindows = xmobarColor colorGray    colorNormalbg . \s -> "○"
                , ppTitle           = xmobarColor colorRed     colorNormalbg
                , ppOutput          = putStrLn
                , ppWsSep           = " "
                , ppSep             = "  "
                }

--------------------------------------------------------------------------- }}}
-- myXPConfig:        XPConfig                                            {{{

myXPConfig = def
                { font              = "xft:Iosevka Slab:size=10:antialias=true"
                , fgColor           = colorfg
                , bgColor           = colorNormalbg
                , borderColor       = colorNormalbg
                , height            = 35
                , promptBorderWidth = 0
                , autoComplete      = Just 100000
                , bgHLight          = colorNormalbg
                , fgHLight          = colorRed
                , position          = Bottom
                }

--------------------------------------------------------------------------- }}}
-- newMouse:          Right click is used for resizing window               {{{
-------------------------------------------------------------------------------

myMouse x = [ ((modm, button3), (\w -> focus w >> Flex.mouseResizeWindow w)) ]
newMouse x = M.union (mouseBindings def x) (M.fromList (myMouse x))

--------------------------------------------------------------------------- }}}


-- vim: ft=haskell
