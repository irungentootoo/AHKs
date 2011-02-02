#include FcnLib.ahk
#include ThirdParty/json.ahk

DeleteTraceFile()

if ForceWinFocusIfExist("out1.*OpenOffice.org", "RegEx")
{
   Sleep, 200
   WinClose
}

A_Quote="
date := currenttime("hyphendate")
path=C:\My Dropbox\AHKs\REFP\
currentMonth=01
currentMonthNoZero=1
currentYear=2011

infile=C:\My Dropbox\AHKs\gitExempt\usaa_export\%date%-checking.csv
expectedTransFile=%path%expectedTransactions.txt
projectionCsv=%path%financialProjection.csv
;projectionCsv=%path%out1.txt

if NOT FileExist(infile)
   fatalErrord("the infile for creating the financial projection doesn't exist, cannot continue", A_ScriptName)

;Read in all of the expected transactions
Loop, Read, %expectedTransFile%
{
   i=%A_Index%
   if InStr(A_LoopReadLine, "#debug")
      break
   reTransCount++
   Loop, parse, A_LoopReadLine, CSV
   {
      if (A_Index == 1)
         reTrans%i%=^\"(%currentMonth%|%currentMonthNoZero%)%A_LoopField%
      else if (A_Index == 2)
         reTrans%i%title=%A_LoopField%
      else if (A_Index == 3)
         reTrans%i%amount=%A_LoopField%
      else if (A_Index == 4)
         reTrans%i%date=%A_LoopField%
      else if (A_Index == 5)
         reTrans%i%isCredit := A_LoopField == "true" ? 1 : 0
   }
}

;Loop, %reTransCount%
      ;debug("here", reTrans%A_Index%)

;Go through the history file
;(check each history against each expected--ij loop)
Loop, Read, %infile%
{
   historyLine=%A_LoopReadLine%
      AddToTrace(historyLine)
   Loop, %reTransCount%
   {
      i=%A_Index%
      if RegExMatch(historyLine, reTrans%i%)
      {
         ;debug("found it", historyLine)
         ;TODO mark it as found, mark historyTrans as expected?
         reTrans%i%found:=true
      }
   }
}

;get the current balance of the checking account
Loop, Read, gitExempt/DailyFinancial.csv
{
   Loop, parse, A_LoopReadLine, CSV
   {
      if (A_Index == 3)
         currentCheckingBalance=%A_LoopField%
   }
}

;start the financial projection file
csvLine := concatWithSep(",", "Date", "Credit", "Debit", "Description", "Balance")
FileDelete(projectionCsv)
FileAppendLine(csvline, projectionCsv)
FileAppendLine("12/12/1999,,,," . currentCheckingBalance, projectionCsv)
linecount=1

;TODO get current balance
;concatWithSep(",",
;FileAppend, %csvline%, %projectionCsv%

;lets show which transactions we are still expecting (didn't see it yet)
Loop, %reTransCount%
{
   i=%A_Index%
   if (NOT reTrans%i%found)
   {
      ;debug("didn't find", reTrans%i%)
      ;TODO write to projection csv

      date := concatWithSep("/", currentMonth, reTrans%i%date, currentYear)
      creditCell :=     reTrans%i%isCredit ? reTrans%i%amount : ""
      debitCell  := NOT reTrans%i%isCredit ? reTrans%i%amount : ""
      reasonCell := a_quote . reTrans%i%title . a_quote
      plusone:=linecount+1
      plustwo:=plusone+1
      balanceCell==E%plusone%-C%plustwo%+B%plustwo%
      csvLine := concatWithSep(",", date, creditCell, debitCell, reasonCell, balanceCell)
      FileAppendLine(csvline, projectionCsv)
      linecount++
   }
}

;lets add two more months on there
Loop 3
{
   currentMonth++
   Loop, %reTransCount%
   {
      i=%A_Index%
      date := concatWithSep("/", currentMonth, reTrans%i%date, currentYear)
      creditCell :=     reTrans%i%isCredit ? reTrans%i%amount : ""
      debitCell  := NOT reTrans%i%isCredit ? reTrans%i%amount : ""
      reasonCell := a_quote . reTrans%i%title . a_quote
      plusone:=linecount+1
      plustwo:=plusone+1
      balanceCell==E%plusone%-C%plustwo%+B%plustwo%
      csvLine := concatWithSep(",", date, creditCell, debitCell, reasonCell, balanceCell)
      FileAppendLine(csvline, projectionCsv)
      linecount++
   }
}

ExitApp

Run, scalc.exe "%projectionCsv%"
ForceWinFocus("Text Import")
;Sleep, 2000
Sleep, 200
;Send, {TAB 2}c
Send, {ENTER}
ForceWinFocus("OpenOffice")

ExitApp
`:: ExitApp

;myJson(var, key, value="EMPTY")
;{
   ;if (value == "EMPTY")
      ;return json(var, key)
   ;json(var, key, value)
   ;;sucks! there seems to be no nice way to set the element (only change existing elements)
;}