flex 1805087.l
echo "lex.yy.c created."
bison -d -t 1805087.y
echo "parser.tab.h and parser.tab.c created."
g++ -fpermissive lex.yy.c 1805087.tab.c -lfl -o parser.out
echo "compilation completed. parser.out is ready to execute."
echo "parser.out executed."
./parser.out input.c