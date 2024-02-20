#include <ToggleControl.au3>
#include <GUIConstantsEx.au3>

_GDIPlus_Startup()

$mAdminOn = GUICtrlToggle_CreateTheme(0xFF2C6E49, 0x30B5C99A, 0xFFB5C99A, 5, 2)
$mAdminOff = GUICtrlToggle_CreateTheme(0xFF800F2F, 0x30F45B69, 0xFFF45B69, 5, 2)

$hMain = GUICreate('Toggle Control UDF', 300, 200)
GUICtrlCreateLabel('Admin mode', 10, 10, 80, 25, 0x200) ; SS_CENTERIMAGE
GUICtrlSetFont(-1, 10, 500, 0, 'Segoe UI')
$mHToggle = GUICtrlCreateToggle($hMain, 90, 10, 50, 25)
GUICtrlSetTip(GUICtrlToggle_CtrlID($mHToggle), 'Click me')
GUICtrlToggle_SetTheme($mHToggle, $mAdminOff)
$mVToggle = GUICtrlCreateToggle($hMain, 200, 20, 40, 170, $TOGGLE_VERTICAL)
GUICtrlSetTip(GUICtrlToggle_CtrlID($mVToggle), 'Click me multiple times')
GUISetState()

While True
    Switch GUIGetMsg()
        Case $mHToggle['ID']
            ToggleState($mHToggle)
            If GUICtrlToggle_State($mHToggle) Then
                GUICtrlToggle_SetTheme($mHToggle, $mAdminOn)
            Else
                GUICtrlToggle_SetTheme($mHToggle, $mAdminOff)
            EndIf
        Case $mVToggle['ID']
            ToggleState($mVToggle)
            $iSwitchSize = GUICtrlToggle_SwitchSize($mVToggle)
            $iSwitchSize += 1
            If $iSwitchSize > 10 Then $iSwitchSize = 3
            GUICtrlToggle_SwitchSize($mVToggle, $iSwitchSize)
            GUICtrlToggle_SwitchColor($mVToggle, 0xFF000000 + Random(0, 0xFFFFFF, 1))
        Case $GUI_EVENT_CLOSE
            ExitLoop
    EndSwitch
WEnd

GUICtrlDeleteToggle($mVToggle)
GUICtrlDeleteToggle($mHToggle)
_GDIPlus_Shutdown()
