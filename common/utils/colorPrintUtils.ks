
Declare Global COLOR_RED to "#ff0026".
Declare Global COLOR_GREEN TO "#11ff00".
Declare Global COLOR_WHITE TO "#ffffff".

Function TextColor { 
    Parameter text.
    Parameter color.

    Return "<color=" + color + ">" + text + "</color>".
}

Function TextColorRed { 
    Parameter text.
    Return TextColor(text, COLOR_RED).
}

Function TextColorGreen { 
    Parameter text.
    Return TextColor(text, COLOR_GREEN). 
}

Function TextColorWhite { 
    Parameter text.
    Return TextColor(text, COLOR_WHITE).
}