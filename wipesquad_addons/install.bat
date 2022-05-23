cd %~dp0
for %%i in (Banana, BigWigs, CthunWarner, Decursive, KLHThreatMeter) do (
  rmdir /s /q "../Interface/test2/%%~i"
REM  robocopy "%%~i" "..\Interface\test2\%%~i"
)
pause