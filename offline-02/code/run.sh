#!/bin/bash

flex sample.l
g++ lex.yy.c
./a.out