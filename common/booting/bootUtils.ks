Declare Global ALTERNATE_BOOT_INDICATOR_FILE to "1:boot.txt".
Declare Global BOOT_PARAMS_FILENAME to "1:params.json".

Function CleanUpBootMetaFiles { 
    DeletePath(ALTERNATE_BOOT_INDICATOR_FILE).
    DeletePath(BOOT_PARAMS_FILENAME).
    Create(ALTERNATE_BOOT_INDICATOR_FILE).
}

Global Function SetAlternateBootFile {     
    Parameter metaBootFile.    

    CleanUpBootMetaFiles(). 

    Local indicatorFileContent to metaBootFile.
    Open(ALTERNATE_BOOT_INDICATOR_FILE):Write(indicatorFileContent).    
}

Global Function SetAlternateBootFileWithParams { 
    Parameter metaBootFile.
    Parameter paramsObject.

    CleanUpBootMetaFiles().

    Local indicatorFileContent to metaBootFile.
    Open(ALTERNATE_BOOT_INDICATOR_FILE):Write(indicatorFileContent).    
    WriteJson(paramsObject, BOOT_PARAMS_FILENAME).
}

Global Function RunBootFile { 
    Parameter defaultBootFilename. 

    If Exists(ALTERNATE_BOOT_INDICATOR_FILE) { 
        Local indicatorFileContent to Open(ALTERNATE_BOOT_INDICATOR_FILE):ReadAll():String.                
        Local altBootFilename to indicatorFileContent.

        If Exists(BOOT_PARAMS_FILENAME) { 
            Local paramsObject to ReadJson(BOOT_PARAMS_FILENAME).            
            RunPath(altBootFilename, paramsObject).
        }
        Else { 
            RUNPATH(altBootFilename).
        }        
    }
    Else { 
        Print defaultBootFilename.
        If Exists(BOOT_PARAMS_FILENAME) { 
            Local paramsObject to ReadJson(BOOT_PARAMS_FILENAME).            
            RUNPATH(defaultBootFilename, paramsObject).
        }
        Else { 
            RUNPATH(defaultBootFilename).
        }
    }
}
