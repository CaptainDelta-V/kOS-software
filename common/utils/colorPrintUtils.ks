
Declare Global COLOR_RED to "#ff0026".
Declare Global COLOR_GREEN TO "#11ff00".
Declare Global COLOR_WHITE TO "#ffffff".

Global Function TextColor { 
    Parameter text.
    Parameter color.

    Return "<color=" + color + ">" + text + "</color>".
}

Global Function TextColorRed { 
    Parameter text.
    Return TextColor(text, COLOR_RED).
}

Global Function TextColorGreen { 
    Parameter text.
    Return TextColor(text, COLOR_GREEN). 
}

Global Function TextColorWhite { 
    Parameter text.
    Return TextColor(text, COLOR_WHITE).
}

// todo: options for the ui panel version?