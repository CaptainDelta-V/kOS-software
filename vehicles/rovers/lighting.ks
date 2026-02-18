@LAZYGLOBAL OFF.
Wait Until Ship:Unpacked. 
RUNONCEPATH("../../common/infos").

Local lightBarLights to Ship:PartsTagged("LIGHTBAR").
Local l1 to lightBarLights[0].
Local lightModule to l1:GetModule("ModuleLight").

// DESCRIBE_MODULE_TO_FILE(LIGHT_MODULE).

lightModule:SETFIELD("light color", "#ffffff").
// DESCRIBE_SUFFIXNAMES_TO_FILE(LIGHT_MODULE).

// DESCRIBE_PART_ITEM_TO_FILE(L1:GetModule("ModuleLight"):GETFIELD("light color")).