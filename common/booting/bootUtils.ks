Declare Global ALTERNATE_BOOT_INDICATOR_FILE to "1:ALT_BOOT.txt".
Local BOOT_INDICATOR_FILE_PARAM_SEPARATOR to ",".

Global Function SetAlternatBootFile {     
    Parameter MetaBootFile.
    Parameter bootParam0 is "".
    Parameter bootParam1 is "".
    Parameter bootParam2 is "".

    DeletePath(ALTERNATE_BOOT_INDICATOR_FILE).
    Create(ALTERNATE_BOOT_INDICATOR_FILE).

    Local bootParamList to List(MetaBootFile, bootParam0, bootParam1, bootParam2).
    Local indicatorFileContent to bootParamList:Join(BOOT_INDICATOR_FILE_PARAM_SEPARATOR).

    Open(ALTERNATE_BOOT_INDICATOR_FILE):Write(indicatorFileContent).
}

Global Function CheckAltBootFile { 
    If EXISTS(ALTERNATE_BOOT_INDICATOR_FILE) { 
        Local indicatorFileContent to Open(ALTERNATE_BOOT_INDICATOR_FILE):ReadAll():STRING.
        
        Local bootParamList to indicatorFileContent:Split(BOOT_INDICATOR_FILE_PARAM_SEPARATOR).
        Local altBootFilename to bootParamList[0].

        If (bootParamList:Length = 4) { 
            RunWithParams(altBootFilename, bootParamList[1], bootParamList[2], bootParamList[3]).
        }
        Else If (bootParamList:Length = 3) { 
            RunWithParams(altBootFilename, bootParamList[1], bootParamList[2]).
        }
        Else If (bootParamList:Length = 2) { 
            RunWithParams(altBootFilename, bootParamList[1]).
        }
        Else { 
            RUNPATH(altBootFilename).
        }        
    }
}

Global Function RunWithParams {
    Parameter Filename. 
    Parameter P0 is "".
    Parameter P1 is "". 
    Parameter P2 is "".

    If (P2:Length > 0) { 
        RUNPATH(Filename, P0, P1, P2).
    }
    Else If (P1:Length > 0) { 
        RUNPATH(Filename, P0, P1).
    }
    Else If (P0:Length > 0) { 
        RUNPATH(Filename, P0).
    }
    Else { 
        RUNPATH(Filename).
    }
}

