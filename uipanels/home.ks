@LAZYGLOBAL OFF.
Wait Until Ship:Unpacked.

RUNONCEPATH("utilities").
RUNONCEPATH("../common/infos").

ClearScreen.

Local DoExit to false.

Local IDLE_BTN_IDX to 7.
Local BURN_BTN_IDX to 9.

Local SelectedOptionIdx to 0.
Local BEEPER is GETVOICE(1).

Local OPTION_DESC_IDX to 0.
Local OptionFuncIdx to 1.
Local OptionsList to List().

Local OptionsListPageIdx to 0.

// OptionsList:ADD(List("REACTOR", PrintHome@)).
// OptionsList:ADD(List("RADIATORS", PrintHome@)).
// OptionsList:ADD(List("ENGINES", PrintHome@)).
// OptionsList:ADD(List("LIGHTING", PrintHome@)).
// OptionsList:ADD(List("WEAPON SYSTEMS", PrintHome@)).
// OptionsList:ADD(List("COUNTERMEASURES", PrintHome@)).
// OptionsList:ADD(List("SELF DESTRUCT", PrintHome@)).

Function DoShuttleLaunch { 
  switch to 0.
  cd("vehicles/rockets/shuttle").
  // runpath("shuttlelaunch").
  run shuttlelaunch.
}

OptionsList:Add(List("SHUTTLE LAUNCH", DoShuttleLaunch@)).


// TODO: need a meta monitor setup screen to designate programs on each, have to identify indiv instead. 
// the monitors are currently getting set up by the last one that was loaded, gets the buttons.

// BEEPER:PLAY( NOTE(650, 0.10) ).
PrintHome().
SetDefaultButtons().
SetupHomeButtons().

Function PrintHome { 
  ClearScreen. 
  
  UiPrint("VESSEL CONTROL PANEL", 1, UI_ALIGN_HOR_CTR).
  PrintUiOptions().    
    
  UiPrint("      [#FFFFFF] NOMINAL [#FFF700] WARNING [#FF0029] CRITICAL ", 13, UI_ALIGN_HOR_CTR).
  UiPrint(" CURRENT MONITOR: " + LastPressedButtonMonitor, 14, UI_ALIGN_HOR_CTR).
  UiPrint(" LAST BUTTON NUM: [#FFFFFF]" + LastPressedBtnNum, 15, UI_ALIGN_HOR_CTR).
}

Function PrintUiOptions { 
  Local startLineIdx to 3.  
  FROM {Local optionIdx is 0.} Until optionIdx = OptionsList:Length 
    STEP {Set optionIdx to optionIdx+1.} DO {
      Local line to startLineIdx + optionIdx.
      Local option to OptionsList[optionIdx].      
      Local selectionIndicator to " ".
      If optionIdx = SelectedOptionIdx { 
        Set selectionIndicator to "X".
      }
      UiPrint(" [[" + selectionIndicator + "] " + option[OPTION_DESC_IDX]:PadRight(18),
       line, UI_ALIGN_HOR_CTR).
  }
}

Function SelectOption {
  OptionsList[SelectedOptionIdx][OptionFuncIdx]:Call().  
}

Function NextOption { 
  Set SelectedOptionIdx to Min(SelectedOptionIdx + 1, OptionsList:Length).  
  PrintHome().
}

Function PreviousOption { 
  Set SelectedOptionIdx to Max(SelectedOptionIdx - 1, 0).
  PrintHome().
}

Function SetupHomeButtons { 
    FROM {Local X is 0.} Until X = Monitors STEP {Set X to X+1.} DO {
      Set Buttons:CurrentMonitor to X. 
      Set Labels:CurrentMonitor to X.      

      SetIvaButton(DownBtnIdx, "", NextOption@).
      SetIvaButton(UpBtnIdx, "", PreviousOption@).
      SetIvaButton(ConfirmBtnIdx, "", SelectOption@).
  }
}

Function Exit { 
  Set DoExit to true.
}

Until DoExit {
  Wait 0. 
}.