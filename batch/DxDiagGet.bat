::---License---
::This is free and unencumbered software released into the public domain.

::Anyone is free to copy, modify, publish, use, compile, sell, or
::distribute this software, either in source code form or as a compiled
::binary, for any purpose, commercial or non-commercial, and by any
::means.

::by frainfreeze

::---Description---
::Generates dxDiag report and saves it as text file on your desktop.

::---code---
@echo off
title DxDiagGet
echo DxDiagGet

:: Check for dxdiag.exe, in case not found go to Dxdiag_Not_Found.
if not exist %systemroot%\system32\dxdiag.exe GOTO Dxdiag_Not_Found
echo Dxdiag.exe found.

:: Execute dxdiag.exe, pass the path to the file.
%systemroot%\system32\dxdiag.exe /t %USERPROFILE%\Desktop\dxdiag.txt
pause

:: Open the newly created file.
%USERPROFILE%\Desktop\dxdiag.txt

exit


:Dxdiag_Not_Found
echo Dxdiag.exe was not found.
pause
exit