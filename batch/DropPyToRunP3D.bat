::---License---
::This is free and unencumbered software released into the public domain.

::Anyone is free to copy, modify, publish, use, compile, sell, or
::distribute this software, either in source code form or as a compiled
::binary, for any purpose, commercial or non-commercial, and by any
::means.

::by frainfreeze

::---Description---
::Used to run P3D scripts with desired version of panda3d.
::change PANDAPATH to p3d build path you want to use, 
::just drop .py files onto bat and it will execute

::---code---
@echo off
setlocal
set PANDAPATH=C:\exampleFolder\newBuild
set PATH=%PANDAPATH%\bin;%PATH%
set PYTHONPATH=%PANDAPATH%\;%PYTHONPATH%
echo Running Panda3D from "%PANDAPATH%"
%PANDAPATH%\python\python.exe -B %1
pause