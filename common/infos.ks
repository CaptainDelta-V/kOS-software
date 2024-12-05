@LAZYGLOBAL OFF.

Local DEFAULT_LOG_FILENAME to "0:output/out" + Time:MINUTE + "" + Time:SECOND + ".txt".

Global Function DESCRIBE_PART_ITEM {
    Parameter PART.

    For MODULE_NAME In PART:ALLMODULES { 
        Print "Module name: " + MODULE_NAME.
        Declare Local MODULE to PART:GetModule(MODULE_NAME).
        For fieldname In MODULE:AllFieldNames {
            Print "    Field: " + fieldname.
        }
        For ACTION_NAME In MODULE:ALLACTIONNAMES { 
            Print "    Action: " + ACTION_NAME.
        }
        For EVENT_NAME In MODULE:ALLEVENTNAMES { 
            Print "    Event: " + EVENT_NAME.
        }
    }

}

Global Function DESCRIBE_PART_ITEM_TO_FILE {
    Parameter PART.
    Parameter FILENAME is DEFAULT_LOG_FILENAME.

    For MODULE_NAME In PART:ALLMODULES { 
        LOG "Module name: " + MODULE_NAME to FILENAME.
        Declare Local MODULE to PART:GetModule(MODULE_NAME).

        For fieldName In MODULE:AllFieldNames {
            LOG "    Field: " + fieldName + " " + MODULE:GETFIELD(fieldName) to FILENAME.
        }
        For ACTION_NAME In MODULE:ALLACTIONNAMES { 
            LOG "    Action: " + ACTION_NAME to FILENAME.
        }
        For EVENT_NAME In MODULE:ALLEVENTNAMES { 
            LOG  "    Event: " + EVENT_NAME to FILENAME.
        }
    }
}

Global Function DESCRIBE_MODULE_TO_FILE { 
    Parameter MODULE.
    Parameter FILENAME is DEFAULT_LOG_FILENAME. 

    For FIELD_NAME In MODULE:AllFieldNames { 
        Local FIELD to MODULE:GETFIELD(FIELD_NAME).
        LOG "    Field: " + FIELD_NAME to FILENAME.
        LOG "       Value: "  to FILENAME.
        LOG "   Suffix names: " to FILENAME.    
        For SUFFIX_NAME In FIELD:SUFFIXNAMES { 
            LOG "       Suffix: " + SUFFIX_NAME to FILENAME.
        }
    }    
}

Global Function DESCRIBE_SUFFIXNAMES_TO_FILE { 
    Parameter THING.
    Parameter FILENAME is DEFAULT_LOG_FILENAME.

    For SN In THING:SUFFIXNAMES {
        LOG SN to FILENAME.
    }
}

