@echo off
set conf="C:\Users\%USERNAME%\Programs\gnucobol\config\default.conf"
set program="snowball"

cobc -conf=%conf% -x -o %program% -static %program%.cob input.c
pause