bison -d -y simplecalc.y
echo 'Generated the parser C file as well the header file'
g++ -w -c -o y.o y.tab.c
echo 'Generated the parser object file'
flex simplecalc.l
echo 'Generated the scanner C file'
g++ -w -c -o l.o lex.yy.c
echo 'Generated the scanner object file'
g++ y.o l.o -o simplecalc.exe
echo 'All ready, running'
.\simplecalc.exe

del y.o
del lex.yy.c
del l.o
del y.tab.c
del y.tab.h