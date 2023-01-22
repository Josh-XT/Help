REM ########################################
REM File: WindowsUpdateFix.bat
REM ########################################
REM Usage:
REM - Updates registry entry "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU\UseWUServer" to 0
REM ########################################
@echo off
REGEDIT.EXE  /S  "%~dp0\reg\WindowsUpdateFix.reg"