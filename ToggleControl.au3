#include-once
#include <GDIPlus.au3>

; ============================================================================================================================================================================================================
; Title: Toggle Control  UDF
; AutoIt Version : 3.3.16.1
; Description: Toggle control.
; Author: Andreik
; Dependencies: GDI+
; Call _GDIPlus_Startup() before using any other function from this UDF and _GDIPlus_Shutdown() after you properly deleted all controls created with this UDF
; and there is no further need of any function from this UDF.
; ============================================================================================================================================================================================================

; #CONSTANTS# ================================================================================================================================================================================================
Global Enum $TOGGLE_HORIZONTAL, $TOGGLE_VERTICAL
; ============================================================================================================================================================================================================

; #CURRENT# ==================================================================================================================================================================================================
; GUICtrlCreateToggle
; GUICtrlDeleteToggle
; ToggleState
; GUICtrlToggle_State
; GUICtrlToggle_CtrlID
; GUICtrlToggle_BackgroundColor
; GUICtrlToggle_SwitchColor
; GUICtrlToggle_RingColor
; GUICtrlToggle_SwitchSize
; GUICtrlToggle_RingSize
; GUICtrlToggle_Position
; GUICtrlToggle_CreateTheme
; GUICtrlToggle_SetTheme
; ============================================================================================================================================================================================================

; #FUNCTION# =================================================================================================================================================================================================
; Name:            GUICtrlCreateToggle
; Description:     Creates a toggle control.
; Syntax:          GUICtrlCreateToggle($hGUI, $iX, $iY, $iW, $iH, [, $iStyle = Default [, $iBkColor = Default]])
; Parameters:      $hGUI - The handle of the parent window.
;                  $iX - Position of the left side of the control.
;                  $iY - Position of the top side of the control.
;                  $iW - The width of the control.
;                  $iH - The height of the control.
;                  $iStyle - [Optional] - Defines the style of the control. Available styles: $TOGGLE_HORIZONTAL, $TOGGLE_VERTICAL. Default value is $TOGGLE_HORIZONTAL.
;                  $iBkColor - [Optional] - Background color of the parent window in AARRGGBB format. If this parameter is not provided then COLOR_3DFACE  will be used as background color.
; Return value:    Success - Returns a map with all information about the toggle control.
;                  Failure - Returns Null.
;                      @error = 1 - The width of the control  must be greater than the height of the control when the control has $TOGGLE_HORIZONTAL style.
;                      @error = 2 - The height of the control  must be greater than the width of the control when the control has $TOGGLE_VERTICAL style.
; Author:          Andreik
; Remarks:         This function returns a map with different properties of the control but it's highly recommended to avoid any direct modification of these properties. Instead you can
;                  use the specialized functions of this UDF to get/set some of these properties.
; ============================================================================================================================================================================================================
Func GUICtrlCreateToggle($hGUI, $iX, $iY, $iW, $iH, $iStyle = Default, $iBkColor = Default)
  Local $mToggleCtrl[]
  Local Const $COLOR_3DFACE = 15

  ; Set default values
  If $iStyle = Default Then $iStyle = $TOGGLE_HORIZONTAL
  If $iBkColor = Default Then
    Local $aCall = DllCall('user32.dll', 'dword', 'GetSysColor', 'int', $COLOR_3DFACE)
    If @error Then    ; If the color cannot be retrieved using GetSysColor then use a default value
      $mToggleCtrl['GUIBackground'] = 0xFFF0F0F0
    Else
      $mToggleCtrl['GUIBackground'] =  BitOR($aCall[0], 0xFF000000)
    EndIf
  EndIf
  $mToggleCtrl['GUI'] = $hGUI
  $mToggleCtrl['Style'] = $iStyle
  $mToggleCtrl['State'] = False
  $mToggleCtrl['SwitchSize'] = 5
  $mToggleCtrl['RingSize'] = 2
  $mToggleCtrl['BackgroundColor'] = 0xFF212529
  $mToggleCtrl['SwitchColor'] = 0xFFCED4DA
  $mToggleCtrl['RingColor'] = 0xFF6C757D
  $mToggleCtrl['Top'] = $iX
  $mToggleCtrl['Left'] = $iY
  $mToggleCtrl['Width'] = $iW
  $mToggleCtrl['Height'] = $iH

  ; Check W/H ratio with respect to style
  If $mToggleCtrl['Style'] = $TOGGLE_HORIZONTAL And $iW < $iH Then Return SetError(1, 0, Null)
  If $mToggleCtrl['Style'] = $TOGGLE_VERTICAL And $iH < $iW Then Return SetError(2, 0, Null)

  ; Create the control
  $mToggleCtrl['ID'] = GUICtrlCreatePic('', $iX, $iY, $iW, $iH)
  $mToggleCtrl['Bitmap'] = _GDIPlus_BitmapCreateFromScan0($iW, $iH)
  __DrawToggle($mToggleCtrl)
  GUICtrlSetCursor($mToggleCtrl['ID'], 0)

  ; Return the control as a map
  Return $mToggleCtrl
EndFunc

; #FUNCTION# =================================================================================================================================================================================================
; Name:            GUICtrlDeleteToggle
; Description:     Deletes a toggle control.
; Syntax:          GUICtrlDeleteToggle($mToggleCtrl)
; Parameters:      $mToggleCtrl - A map that represent the toggle control returned by GUICtrlCreateToggle().
; Return value:    Success - True
;                  Failure - False
;                      @error = 1 - $mToggleCtrl is not a valid toggle control.
; Author:          Andreik
; Remarks:         Even if the visible control can be technically deleted with GUICtrlDelete($mToggleCtrl['ID']) this should be avoided as there is
;                  a bitmap associated with the control that will produce a memory leak.
; ============================================================================================================================================================================================================
Func GUICtrlDeleteToggle(ByRef $mToggleCtrl)
  ; Check if the control is actually a map
  If Not IsMap($mToggleCtrl) Then Return SetError(1, 0, False)

  ; Dispose the bitmap associated with the control and delete the control
  _GDIPlus_BitmapDispose($mToggleCtrl['Bitmap'])
  GUICtrlDelete($mToggleCtrl['ID'])
  $mToggleCtrl = Null
  Return True
EndFunc

; #FUNCTION# =================================================================================================================================================================================================
; Name:            ToggleState
; Description:     Toggles the current state of the toggle control.
; Syntax:          ToggleState($mToggleCtrl)
; Parameters:      $mToggleCtrl - A map that represent the toggle control returned by GUICtrlCreateToggle().
; Return value:    Success - True
;                  Failure - False
;                      @error = 1 - $mToggleCtrl is not a valid toggle control.
; Author:          Andreik
; Remarks:         This function should be called each time when the toggle control is clicked. In order to set a specific status of the toggle control use GUICtrlToggle_State().
; ============================================================================================================================================================================================================
Func ToggleState(ByRef $mToggleCtrl)
  ; Check if the control is actually a map
  If Not IsMap($mToggleCtrl) Then Return SetError(1, 0, False)

  ; Change toggle state and redraw control
  $mToggleCtrl['State'] = Not $mToggleCtrl['State']
  __DrawToggle($mToggleCtrl, True)
  Return True
EndFunc

; #FUNCTION# =================================================================================================================================================================================================
; Name:            GUICtrlToggle_State
; Description:     Get or set the current state of the toggle control.
; Syntax:          GUICtrlToggle_State($mToggleCtrl [, $iState = Null])
; Parameters:      $mToggleCtrl - A map that represent the toggle control returned by GUICtrlCreateToggle().
;                  $iState - [Optional] - A new state of the toggle control.  Available states: True (or 1) and False (or 0).
; Return value:    Success - True   - if the function is used to set the state of the toggle control.
;                          - A boolean value that represent the current state of the toggle control - if the function is used to get the state of the toggle control.
;                  Failure - False
;                      @error = 1 - $mToggleCtrl is not a valid toggle control.
;                      @error = 2 - $iState is not a valid state.
; Author:          Andreik
; Remarks:         This function can be used to get the current state of the control but also to set a new state if the $iState parameter is provided.
; ============================================================================================================================================================================================================
Func GUICtrlToggle_State(ByRef $mToggleCtrl, $iState = Null)
  ; Check if the control is actually a map
  If Not IsMap($mToggleCtrl) Then Return SetError(1, 0, False)

  ; Check if get or set is requested
  If @NumParams = 1 Then Return $mToggleCtrl['State']

  ; Check the provided state
  If $iState <> 0 And $iState <> 1 Then Return SetError(2, 0, False)

  ; Set toggle state and redraw the control
  $mToggleCtrl['State'] = $iState
  __DrawToggle($mToggleCtrl, True)
  Return True
EndFunc

; #FUNCTION# =================================================================================================================================================================================================
; Name:            GUICtrlToggle_CtrlID
; Description:     Returns the control ID of the picture control where the toggle control is drawn. This control ID can be used with native AutoIt functions.
; Syntax:          GUICtrlToggle_CtrlID($mToggleCtrl)
; Parameters:      $mToggleCtrl - A map that represent the toggle control returned by GUICtrlCreateToggle().
; Return value:    Success - Returns the control ID of the picture control where the toggle control is drawn.
;                  Failure - False
;                      @error = 1 - $mToggleCtrl is not a valid toggle control.
; Author:          Andreik
; Remarks:         Technically this function is equivalent with $mToggleCtrl['ID'] but there is a validation to ensure that
;                  GUICtrlCreateToggle() returned a valid map that represent the toggle control.
; ============================================================================================================================================================================================================
Func GUICtrlToggle_CtrlID($mToggleCtrl)
  ; Check if the control is actually a map
  If Not IsMap($mToggleCtrl) Then Return SetError(1, 0, False)

  Return $mToggleCtrl['ID']
EndFunc

; #FUNCTION# =================================================================================================================================================================================================
; Name:            GUICtrlToggle_BackgroundColor
; Description:     Get or set the background color of the toggle control.
; Syntax:          GUICtrlToggle_BackgroundColor($mToggleCtrl [, $iBackgroundColor = Null])
; Parameters:      $mToggleCtrl - A map that represent the toggle control returned by GUICtrlCreateToggle().
;                  $iBackgroundColor - [Optional] - Background color of the toggle control in AARRGGBB format.
; Return value:    Success - True   - if the function is used to set the background color of the toggle control.
;                          - The background color of the toggle control in AARRGGBB format - if the function is used to get the background color.
;                  Failure - False
;                      @error = 1 - $mToggleCtrl is not a valid toggle control.
; Author:          Andreik
; Remarks:         This function can be used to get the background color of the control but also to set a new background color if the $iBackgroundColor parameter is provided.
; ============================================================================================================================================================================================================
Func GUICtrlToggle_BackgroundColor(ByRef $mToggleCtrl, $iBackgroundColor = Null)
  ; Check if the control is actually a map
  If Not IsMap($mToggleCtrl) Then Return SetError(1, 0, False)

  ; Check if get or set is requested
  If @NumParams = 1 Then Return '0x' & Hex($mToggleCtrl['BackgroundColor'], 8)

  ; Set background color and redraw the control
  $mToggleCtrl['BackgroundColor'] = $iBackgroundColor
  __DrawToggle($mToggleCtrl)
  Return True
EndFunc

; #FUNCTION# =================================================================================================================================================================================================
; Name:            GUICtrlToggle_SwitchColor
; Description:     Get or set the color of the switch.
; Syntax:          GUICtrlToggle_SwitchColor($mToggleCtrl [, $iSwitchColor = Null])
; Parameters:      $mToggleCtrl - A map that represent the toggle control returned by GUICtrlCreateToggle().
;                  $iSwitchColor - [Optional] - The color of the switch in AARRGGBB format.
; Return value:    Success - True   - if the function is used to set a new color for the switch.
;                          - The color of the switch in AARRGGBB format - if the function is used to get the color of the switch.
;                  Failure - False
;                      @error = 1 - $mToggleCtrl is not a valid toggle control.
; Author:          Andreik
; Remarks:         This function can be used to get the color of the switch but also to set a new color for the switch if the $iSwitchColor parameter is provided.
; ============================================================================================================================================================================================================
Func GUICtrlToggle_SwitchColor(ByRef $mToggleCtrl, $iSwitchColor = Null)
  ; Check if the control is actually a map
  If Not IsMap($mToggleCtrl) Then Return SetError(1, 0, False)

  ; Check if get or set is requested
  If @NumParams = 1 Then Return '0x' & Hex($mToggleCtrl['SwitchColor'], 8)

  ; Set switch color and redraw the control
  $mToggleCtrl['SwitchColor'] = $iSwitchColor
  __DrawToggle($mToggleCtrl)
  Return True
EndFunc

; #FUNCTION# =================================================================================================================================================================================================
; Name:            GUICtrlToggle_RingColor
; Description:     Get or set the color of the ring that is around the switch.
; Syntax:          GUICtrlToggle_RingColor($mToggleCtrl [, $iRingColor = Null])
; Parameters:      $mToggleCtrl - A map that represent the toggle control returned by GUICtrlCreateToggle().
;                  $iRingColor - [Optional] - The color of the ring in AARRGGBB format.
; Return value:    Success - True   - if the function is used to set a new color for the ring.
;                          - The color of the ring in AARRGGBB format - if the function is used to get the color of the ring.
;                  Failure - False
;                      @error = 1 - $mToggleCtrl is not a valid toggle control.
; Author:          Andreik
; Remarks:         This function can be used to get the color of the ring but also to set a new color for the ring if the $iRingColor parameter is provided.
; ============================================================================================================================================================================================================
Func GUICtrlToggle_RingColor(ByRef $mToggleCtrl, $iRingColor = Null)
  ; Check if the control is actually a map
  If Not IsMap($mToggleCtrl) Then Return SetError(1, 0, False)

  ; Check if get or set is requested
  If @NumParams = 1 Then Return '0x' & Hex($mToggleCtrl['RingColor'], 8)

  ; Set ring color and redraw the control
  $mToggleCtrl['RingColor'] = $iRingColor
  __DrawToggle($mToggleCtrl)
  Return True
EndFunc

; #FUNCTION# =================================================================================================================================================================================================
; Name:            GUICtrlToggle_SwitchSize
; Description:     Get or set the size of the switch.
; Syntax:          GUICtrlToggle_SwitchSize($mToggleCtrl [, $iSwitchSize = Null])
; Parameters:      $mToggleCtrl - A map that represent the toggle control returned by GUICtrlCreateToggle().
;                  $iSwitchSize - [Optional] - The size of the switch. The size can be any value between 2 and 10.
; Return value:    Success - True   - if the function is used to set the size of the switch.
;                          - An integer between 2 and 10 - if the function is used to get the size of the switch.
;                  Failure - False
;                      @error = 1 - $mToggleCtrl is not a valid toggle control.
; Author:          Andreik
; Remarks:         This function can be used to get the size of the switch but also to set a new size for the switch if the $iSwitchSize parameter is provided.
; ============================================================================================================================================================================================================
Func GUICtrlToggle_SwitchSize(ByRef $mToggleCtrl, $iSwitchSize = Null)
  ; Check if the control is actually a map
  If Not IsMap($mToggleCtrl) Then Return SetError(1, 0, False)

  ; Check if get or set is requested
  If @NumParams = 1 Then Return $mToggleCtrl['SwitchSize']

  ; Check the min/max switch size
  If $iSwitchSize < 2 Then $iSwitchSize = 2
  If $iSwitchSize > 10 Then $iSwitchSize = 10

  ; Set switch size and redraw the control
  $mToggleCtrl['SwitchSize'] = $iSwitchSize
  __DrawToggle($mToggleCtrl)
  Return True
EndFunc

; #FUNCTION# =================================================================================================================================================================================================
; Name:            GUICtrlToggle_RingSize
; Description:     Get or set the size of the ring.
; Syntax:          GUICtrlToggle_RingSize($mToggleCtrl [, $iRingSize = Null])
; Parameters:      $mToggleCtrl - A map that represent the toggle control returned by GUICtrlCreateToggle().
;                  $iRingSize - [Optional] - The size of the ring The size can be any value between 0 and 10.
; Return value:    Success - True   - if the function is used to set the size of the ring.
;                          - An integer between 0 and 10 - if the function is used to get the size of the ring.
;                  Failure - False
;                      @error = 1 - $mToggleCtrl is not a valid toggle control.
; Author:          Andreik
; Remarks:         This function can be used to get the size of the ring but also to set a new size for the ring if the $iRingSize parameter is provided.
; ============================================================================================================================================================================================================
Func GUICtrlToggle_RingSize(ByRef $mToggleCtrl, $iRingSize = Null)
  ; Check if the control is actually a map
  If Not IsMap($mToggleCtrl) Then Return SetError(1, 0, False)

  ; Check if get or set is requested
  If @NumParams = 1 Then Return $mToggleCtrl['RingSize']

  ; Check the min/max ring size
  If $iRingSize < 0 Then $iRingSize = 0
  If $iRingSize > 10 Then $iRingSize = 10

  ; Set ring size and redraw the control
  $mToggleCtrl['RingSize'] = $iRingSize
  __DrawToggle($mToggleCtrl)
  Return True
EndFunc

; #FUNCTION# =================================================================================================================================================================================================
; Name:            GUICtrlToggle_Position
; Description:     Get or set the position and size of the toggle control.
; Syntax:          GUICtrlToggle_Position($mToggleCtrl [, $iX = Null [,$iY = Null [,$iW = Null [,$iH = Null]]]])
; Parameters:      $mToggleCtrl - A map that represent the toggle control returned by GUICtrlCreateToggle().
;                  $iX  - [Optional] - Position of the left side of the control.
;                  $iY  - [Optional] - Position of the top side of the control.
;                  $iW  - [Optional] - The width of the control.
;                  $iH  - [Optional] - The height of the control.
; Return value:    Success - True   - if the function is used to set a new position and size.
;                          - Returns a four-element array containing the Top, Left, Width and Height of the control - if the function is used to get the position and size of the control.
;                  Failure - False
;                      @error = 1 - $mToggleCtrl is not a valid toggle control.
;                      @error = 2 - Some parameters are missing. If the function is used to set a new position and size then all parameters are required.
;                      @error = 3 - The size provided is not compatible with the control style. If the control has the style $TOGGLE_HORIZONTAL then width cannot be less than height.
;                      @error = 4 - The size provided is not compatible with the control style. If the control has the style $TOGGLE_VERTICAL then height cannot be less than width.
; Author:          Andreik
; Remarks:         This function can be used to get the position and size of the toggle control
;                  but also to set a new position and size for the toggle control if the $iX, $iY, $iW and $iH parameters are provided.
; ============================================================================================================================================================================================================
Func GUICtrlToggle_Position(ByRef $mToggleCtrl, $iX = Null, $iY = Null, $iW = Null, $iH = Null)
  ; Check if the control is actually a map
  If Not IsMap($mToggleCtrl) Then Return SetError(1, 0, False)

  ; Check if get or set is requested
  If @NumParams = 1 Then
    Local $aPos[4] = [$mToggleCtrl['Top'], $mToggleCtrl['Left'], $mToggleCtrl['Width'], $mToggleCtrl['Height']]
    Return $aPos
  EndIf

  If @NumParams <> 5 Then  Return SetError(2, 0, False)

  ; Check W/H ratio with respect to style
  If $mToggleCtrl['Style'] = $TOGGLE_HORIZONTAL And $iW < $iH Then Return SetError(3, 0, False)
  If $mToggleCtrl['Style'] = $TOGGLE_VERTICAL And $iH < $iW Then Return SetError(4, 0, False)

  ; Set position and redraw the control
  $mToggleCtrl['Top'] = $iX
  $mToggleCtrl['Left'] = $iY
  $mToggleCtrl['Width'] = $iW
  $mToggleCtrl['Height'] = $iH
  __DrawToggle($mToggleCtrl)
  Return True
EndFunc

; #FUNCTION# =================================================================================================================================================================================================
; Name:            GUICtrlToggle_CreateTheme
; Description:     Create a compatible theme for toggle controls.
; Syntax:          GUICtrlToggle_CreateTheme($iBackgroundColor, $iSwitchColor, $iRingColor, $iSwitchSize, $iRingSize)
; Parameters:      $iBackgroundColor - Background color of the toggle switch in AARRGGBB format.
;                  $iSwitchColor - The color of the switch in AARRGGBB format.
;                  $iRingColor - The color of the ring in AARRGGBB format.
;                  $iSwitchSize - The size of the switch. The size can be any value between 2 and 10.
;                  $iRingSize - The size of the ring The size can be any value between 0 and 10.
; Return value:    Success - Returns a map that defines the theme.
; Author:          Andreik
; ============================================================================================================================================================================================================
Func GUICtrlToggle_CreateTheme($iBackgroundColor, $iSwitchColor, $iRingColor, $iSwitchSize, $iRingSize)
  If $iSwitchSize < 2 Then $iSwitchSize = 2
  If $iSwitchSize > 10 Then $iSwitchSize = 10
  If $iRingSize < 0 Then $iRingSize = 0
  If $iRingSize > 10 Then $iRingSize = 10
  Local $mTheme[]
  $mTheme['BackgroundColor'] = $iBackgroundColor
  $mTheme['SwitchColor'] = $iSwitchColor
  $mTheme['RingColor'] = $iRingColor
  $mTheme['SwitchSize'] = $iSwitchSize
  $mTheme['RingSize'] = $iRingSize
  Return $mTheme
EndFunc

; #FUNCTION# =================================================================================================================================================================================================
; Name:            GUICtrlToggle_SetTheme
; Description:     Set a theme to a toggle control.
; Syntax:          GUICtrlToggle_SetTheme($mToggleCtrl, $mTheme)
; Parameters:      $mToggleCtrl - A map that represent the toggle control returned by GUICtrlCreateToggle().
;                  $mTheme - A map that represent the theme returned by GUICtrlToggle_CreateTheme().
; Return value:    Success - True
;                  Failure - False
;                      @error = 1 - $mToggleCtrl is not a valid toggle control.
;                      @error = 2 - $mTheme is not a valid theme.
; Author:          Andreik
; ============================================================================================================================================================================================================
Func GUICtrlToggle_SetTheme(ByRef $mToggleCtrl, $mTheme)
  ; Check if the control is actually a map
  If Not IsMap($mToggleCtrl) Then Return SetError(1, 0, False)

  ; Check if the theme is actually a map
  If Not IsMap($mTheme) Then Return SetError(2, 0, False)

  ; Set the theme
  GUICtrlToggle_BackgroundColor($mToggleCtrl, $mTheme['BackgroundColor'])
  GUICtrlToggle_SwitchColor($mToggleCtrl, $mTheme['SwitchColor'])
  GUICtrlToggle_RingColor($mToggleCtrl, $mTheme['RingColor'])
  GUICtrlToggle_SwitchSize($mToggleCtrl, $mTheme['SwitchSize'])
  GUICtrlToggle_RingSize($mToggleCtrl, $mTheme['RingSize'])
  Return True
EndFunc

; #INTERNAL_USE_ONLY# ========================================================================================================================================================================================
; This function is for internal use only and it's used to draw the control. Don't call this function unless you understand how it works!!!
; ============================================================================================================================================================================================================
Func __DrawToggle(ByRef $mToggleCtrl, $bAnimate = False)
  Local $hHBITMAP, $iStart, $iStop, $iStep, $hDC, $iOffsetX, $iOffsetY, $iStepAmp = 1
  Local Const $STM_SETIMAGE = 0x0172, $IMAGE_BITMAP = 0, $GDIP_SmoothingMode_HighQuality = 2, $ANIMATION_UNIT = 150
  Local $iSwitchSizePercent = ($mToggleCtrl['Style'] = $TOGGLE_HORIZONTAL ? $mToggleCtrl['Height'] / $mToggleCtrl['SwitchSize'] : $mToggleCtrl['Width']  / $mToggleCtrl['SwitchSize'])
  Local $iDiameter = ($mToggleCtrl['Width'] < $mToggleCtrl['Height'] ? $mToggleCtrl['Width'] : $mToggleCtrl['Height'])
  Local $iBitmapWidth = _GDIPlus_ImageGetWidth($mToggleCtrl['Bitmap'])
  Local $iBitmapHeigt= _GDIPlus_ImageGetHeight($mToggleCtrl['Bitmap'])
  If $iBitmapWidth <> $mToggleCtrl['Width'] Or $iBitmapHeigt <> $mToggleCtrl['Height'] Then
    GUICtrlSetPos($mToggleCtrl['ID'], $mToggleCtrl['Top'], $mToggleCtrl['Left'], $mToggleCtrl['Width'], $mToggleCtrl['Height'])
    _GDIPlus_BitmapDispose($mToggleCtrl['Bitmap'])
    $mToggleCtrl['Bitmap'] = _GDIPlus_BitmapCreateFromScan0($mToggleCtrl['Width'], $mToggleCtrl['Height'])
  EndIf
  Local $hGraphics = _GDIPlus_ImageGetGraphicsContext($mToggleCtrl['Bitmap'])
  Local $hBrush = _GDIPlus_BrushCreateSolid($mToggleCtrl['BackgroundColor'])
  Local $hPen = _GDIPlus_PenCreate($mToggleCtrl['RingColor'], $mToggleCtrl['RingSize'])
  Local $hPath = _GDIPlus_PathCreate()
  _GDIPlus_GraphicsSetSmoothingMode($hGraphics, $GDIP_SmoothingMode_HighQuality)
  _GDIPlus_GraphicsSetCompositingQuality($hGraphics, $GDIP_COMPOSITINGQUALITY_HIGHQUALITY)
  _GDIPlus_GraphicsSetPixelOffsetMode($hGraphics, 2)
  _GDIPlus_PathReset($hPath)
  _GDIPlus_PathAddArc($hPath, 0, 0, $iDiameter, $iDiameter, 180, 90)
  _GDIPlus_PathAddArc($hPath, $mToggleCtrl['Width'] - $iDiameter - 1, 0, $iDiameter, $iDiameter, 270, 90)
  _GDIPlus_PathAddArc($hPath, $mToggleCtrl['Width'] - $iDiameter - 1, $mToggleCtrl['Height'] - $iDiameter - 1, $iDiameter, $iDiameter, 0, 90)
  _GDIPlus_PathAddArc($hPath, 0, $mToggleCtrl['Height'] - $iDiameter - 1, $iDiameter, $iDiameter, 90, 90)
  _GDIPlus_PathCloseFigure($hPath)
  Local $iDelta = Abs($mToggleCtrl['Width'] - $mToggleCtrl['Height'])
  If $bAnimate Then
    $iStart = $mToggleCtrl['State'] ? 0 : $iDelta
    $iStop = $mToggleCtrl['State'] ? $iDelta : 0
    $iStepAmp = Int(($mToggleCtrl['Style'] = $TOGGLE_HORIZONTAL ? $mToggleCtrl['Width'] :  $mToggleCtrl['Height']) / $ANIMATION_UNIT)
    $iStepAmp = ($iStepAmp < 1 ? 1 : $iStepAmp)
    $iStep =  $mToggleCtrl['State'] ? ( $iStepAmp) : (-$iStepAmp)
  Else
    $iStart = $mToggleCtrl['State'] ? $iDelta : 0
    $iStop = $iStart
    $iStep = 1
  EndIf
  Local $iSwitchRadius = ($mToggleCtrl['Style'] = $TOGGLE_HORIZONTAL ? $mToggleCtrl['Height'] : $mToggleCtrl['Width']) - $iSwitchSizePercent * 2
  For $iOffset = $iStart To $iStop Step $iStep
    $iOffsetX = ($mToggleCtrl['Style'] = $TOGGLE_HORIZONTAL ? $iOffset : 0)
    $iOffsetY = ($mToggleCtrl['Style'] = $TOGGLE_VERTICAL ? $iOffset : 0)
    _GDIPlus_GraphicsClear($hGraphics, $mToggleCtrl['GUIBackground'])
    _GDIPlus_BrushSetSolidColor($hBrush, $mToggleCtrl['BackgroundColor'])
    _GDIPlus_GraphicsFillPath($hGraphics, $hPath, $hBrush)
    _GDIPlus_BrushSetSolidColor($hBrush, $mToggleCtrl['SwitchColor'])
    _GDIPlus_GraphicsFillEllipse($hGraphics, $iOffsetX + $iSwitchSizePercent, $iOffsetY + $iSwitchSizePercent, $iSwitchRadius, $iSwitchRadius, $hBrush)
    _GDIPlus_GraphicsDrawEllipse($hGraphics, $iOffsetX + $iSwitchSizePercent, $iOffsetY + $iSwitchSizePercent, $iSwitchRadius, $iSwitchRadius, $hPen)
    $hHBITMAP = _GDIPlus_BitmapCreateHBITMAPFromBitmap($mToggleCtrl['Bitmap'])
    _WinAPI_DeleteObject(GUICtrlSendMsg($mToggleCtrl['ID'], $STM_SETIMAGE, $IMAGE_BITMAP, $hHBITMAP))
    _WinAPI_DeleteObject($hHBITMAP)
  Next
  _GDIPlus_PathDispose($hPath)
  _GDIPlus_PenDispose($hPen)
  _GDIPlus_BrushDispose($hBrush)
  _GDIPlus_GraphicsDispose($hGraphics)
EndFunc
