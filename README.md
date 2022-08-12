# compiler-3-1

Assignment 2 was fun
In the submitted file there is no file for both console and file output
I deleted that
Now those just uses console

Nonetheless, the token files are a 100% match
Log files are matching but as the sample uses previous batch's hash func,
not ours one, sdbm, that's why the symbol tables aren't matching
I have tried with previous hash and then it matches.

Assignment 2 done

Assignment 3 is pain

what I am doing
01 symbolinfo has a vector called params
02 return types are stored in the 0th position of that param vector
03 other params are stored after that
04 I am using this params for other purposes like - parameter_list and argument_list and declaration_list
05 arrays has size, others have this defaulted to -1
06 not considering char and string for the moment

idk why my looked up function from symboltable when that function got called, giving weird params
solved it fuckkkkkkkk

to-do
- is the function double defined [done]
- is it declared already when being declared [done]
- double declaration is a problem only when they don't match [done]
- what happens when we call a function which is declared not defined and then never really define it [done]
- assignop type check [done]
- array index not integer (both call and declaration) [well declaration is done by default][done]
- both operands of mod should be int [done]
- TYPE CONVERSION (details in spec pdf) [done]
- variable double decalartion in the same scope [done]
- array used as variables and vice versa [haven't I done it already?][done]
- functions used as variables/arrays and vice versa [done]
- functions declared in scopes other than global scope -> {error recovery}[done]

have to deal with all the UNDEFINED"s - not done

I will be give this a little bit of modularity
getting the code blocks out of .y file for better error recovery
