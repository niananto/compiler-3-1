#!/bin/bash

yacc -d -y 1805093.y
# yacc -d -y --warnings=none 1805093.y
# echo 'Generated the parser C file as well the header file'
g++ -w -c -o y.o y.tab.c
# echo 'Generated the parser object file'
flex 1805093.l
# echo 'Generated the scanner C file'
g++ -w -c -o l.o lex.yy.c
# if the above command doesn't work try g++ -fpermissive -w -c -o l.o lex.yy.c
# echo 'Generated the scanner object file'
g++ y.o l.o -lfl -o a
# echo 'All ready, running'
./a ../SampleIO/input1.txt
# ./a input.c


rm y.o lex.yy.c l.o a y.tab.c y.tab.h