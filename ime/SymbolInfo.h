#include <iostream>
using namespace std;

class SymbolInfo{
    private:
        string name;
        string type;
        SymbolInfo* SymbolNextInChain;

    public:
         SymbolInfo()
        {
            //constructor
        }

        void setName(string name)
        {
            this->name=name;
        };
        string getName()
        {
            return this->name;
        };

        void setType(string type)
        {
             this->type=type;
        };
        string getType()
        {
             return this->type;
        };

        void setSymbolNextInChain(SymbolInfo* nextSymbol)
        {
            this->SymbolNextInChain= nextSymbol;
        };

        SymbolInfo* getSymbolNextInChain()
        {
            return this->SymbolNextInChain;
        };

          ~SymbolInfo()
        {
            //destructor
            delete SymbolNextInChain;
        }


};
