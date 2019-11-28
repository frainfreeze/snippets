::---License---
::This is free and unencumbered software released into the public domain.

::Anyone is free to copy, modify, publish, use, compile, sell, or
::distribute this software, either in source code form or as a compiled
::binary, for any purpose, commercial or non-commercial, and by any
::means.

::by frainfreeze

::---Description---
::Tiny batch script that makes use of wget.

::---code---
title tinyGet
@echo off
echo image scrap/file dl (img/dl)
set /p option=
IF /i "%option%"=="img" goto imgScrap
IF /i "%option%"=="dl" goto dlFile
echo Not found.
goto commonexit

:imgScrap
set /p ImgLink=Copy the website URL and right click in this window. Scraps jpeg,jpg,bmp,gif,png:
echo Scraping all images from "%ImgLink%"
wget -r -P download -A jpeg,jpg,bmp,gif,png "%ImgLink%"
goto commonexit

:dlFile
set /p FileLink=Copy the direct link to file and right click in this window to download it:
wget download --no-check-certificate "%FileLink%"
goto commonexit

:commonexit
pause