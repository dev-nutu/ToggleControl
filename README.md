# Toggle Control UDF

This UDF provides functions to create customizable toggle controls for GUIs.

![An example of horizontal and vertical toggles.](/assets/toggle-control.png)

Available functions in this UDF:
* GUICtrlCreateToggle
* GUICtrlDeleteToggle
* ToggleState
* GUICtrlToggle_State
* GUICtrlToggle_CtrlID
* GUICtrlToggle_BackgroundColor
* GUICtrlToggle_SwitchColor
* GUICtrlToggle_RingColor
* GUICtrlToggle_SwitchSize
* GUICtrlToggle_RingSize
* GUICtrlToggle_Position
* GUICtrlToggle_CreateTheme
* GUICtrlToggle_SetTheme

> [!NOTE]
> Each function from ToggleControl.au3 have a comment header where parameters and return codes are described.

> [!IMPORTANT]
> Call _GDIPlus_Startup() before using any function from this UDF and _GDIPlus_Shutdown() after you properly deleted all controls created with this UDF and there is no further need of any function from this UDF.

> [!TIP]
> If you have questions or if you need support for this UDF please visit AutoIt forum and post your questions [in this thread](https://www.autoitscript.com/forum/topic/211024-toggle-control-udf/).
