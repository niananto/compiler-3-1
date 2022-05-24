cmake_minimum_required(VERSION 3.21)
project(offline_01)

set(CMAKE_CXX_STANDARD 17)

add_executable(offline_01 main.cpp SymbolInfo.h ScopeTable.h SymbolTable.h)
