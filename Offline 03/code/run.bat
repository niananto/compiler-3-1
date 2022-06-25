bison -d -y -v 1805093.y
@REM echo 'Generated the parser C file as well the header file'
g++ -w -c -o y.o y.tab.c
@REM echo 'Generated the parser object file'
flex 1805093.l
@REM echo 'Generated the scanner C file'
g++ -w -c -o l.o lex.yy.c
@REM echo 'Generated the scanner object file'
g++ y.o l.o -o a.exe
@REM echo 'All ready, running'
a.exe ..\SampleIO\input1.txt

del y.o
del lex.yy.c
del l.o
del y.tab.c
del y.tab.h
del a.exe