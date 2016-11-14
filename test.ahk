DllCall("captdll.dll\CaptureScreen", "str", "D:\Users\Simon\Documents\Loeh-Upload Source\" "test" ".JPG", "int", 75)

test := A_ScriptDir "\" "test" ".JPG"
msgbox %test%