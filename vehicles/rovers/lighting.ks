@LAZYGLOBAL OFF.
Wait Until Ship:Unpacked. 
RUNONCEPATH("../../common/infos").

Local LIGHT_BAR_LIGHTS to Ship:PartsTagged("LIGHTBAR").
Local L1 to LIGHT_BAR_LIGHTS[0].
Local LIGHT_MODULE to L1:GetModule("ModuleLight").

// DESCRIBE_MODULE_TO_FILE(LIGHT_MODULE).

LIGHT_MODULE:SETFIELD("light color", "#ffffff").
// DESCRIBE_SUFFIXNAMES_TO_FILE(LIGHT_MODULE).

// DESCRIBE_PART_ITEM_TO_FILE(L1:GetModule("ModuleLight"):GETFIELD("light color")).