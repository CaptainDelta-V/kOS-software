Declare Global ALTERNATE_BOOT_INDICATOR_FILE to "1:boot.txt".
Declare Global BOOT_PARAMS_FILENAME to "1:params.json".
Declare Global GLOB_BOOT_LOG TO "0:logs/global_boot_log.txt".

Function CleanUpBootMetaFiles { 
    DeletePath(ALTERNATE_BOOT_INDICATOR_FILE).
    DeletePath(BOOT_PARAMS_FILENAME).
    Create(ALTERNATE_BOOT_INDICATOR_FILE).
}

Global Function SetAlternateBootFile {     
    Parameter metaBootFile.    

    CleanUpBootMetaFiles(). 

    Log Core:Tag + " boot file set to " + metaBootFile to GLOB_BOOT_LOG.

    Local indicatorFileContent to metaBootFile.
    Open(ALTERNATE_BOOT_INDICATOR_FILE):Write(indicatorFileContent).    
}

Global Function SetAlternateBootFileWithParams { 
    Parameter metaBootFile.
    Parameter paramsObject.

    CleanUpBootMetaFiles().

    Log Core:Tag + " boot file set to " + metaBootFile + " params: " + paramsObject to GLOB_BOOT_LOG.

    Local indicatorFileContent to metaBootFile.
    Open(ALTERNATE_BOOT_INDICATOR_FILE):Write(indicatorFileContent).    
    WriteJson(paramsObject, BOOT_PARAMS_FILENAME).
}

Global Function RunBootFile { 
    Parameter defaultBootFilename. 
    Parameter bootLogFileName.

    Log "Default boot filename: " + defaultBootFilename to bootLogFileName.

    If Exists(ALTERNATE_BOOT_INDICATOR_FILE) { 
        Log "Found alternate boot file." to bootLogFileName.
        Local indicatorFileContent to Open(ALTERNATE_BOOT_INDICATOR_FILE):ReadAll():String.                
        Local altBootFilename to indicatorFileContent.
        Log "Alternate boot file is: " + altBootFilename to bootLogFileName.

        If Exists(BOOT_PARAMS_FILENAME) { 
            Log "Found boot params." to bootLogFileName.
            Local paramsObject to ReadJson(BOOT_PARAMS_FILENAME).            
            Log "Running alternate boot file with params: " + paramsObject to bootLogFileName.
            RUNPATH(altBootFilename, paramsObject).
        }
        Else { 
            Log "Running alternate boot file with no params" to bootLogFileName.
            RUNPATH(altBootFilename).
        }        
    }
    Else { 
        Log "Using default boot file: " + defaultBootFilename to bootLogFileName.
        Log "Checking for boot params. . ." to bootLogFileName.
        If Exists(BOOT_PARAMS_FILENAME) {             
            Log "Found boot params." to bootLogFileName.
            Local paramsObject to ReadJson(BOOT_PARAMS_FILENAME).            
            Log "Running default boot file with params: " + paramsObject to bootLogFileName.
            RUNPATH(defaultBootFilename, paramsObject).
        }
        Else { 
            Log "Did not find any boot params. Running default boot file with no params." to bootLogFileName.
            RUNPATH(defaultBootFilename).
        }
    }
}
