#include "ScopeTable.h"

class SymbolTable
{
private:
    ScopeTable* CurrentScopeTable;
    int num;
    //int globalCount;
public:
    SymbolTable(int n)
    {
        //cout<<"This is constructor";
        CurrentScopeTable=nullptr;
        this->num=n;
        
        EnterScope();
    }

    ~SymbolTable()
    {
        //Destructor

        
        
    }
     void EnterScope()
     {
         ScopeTable * sct= new ScopeTable(num);

        if(CurrentScopeTable==nullptr)
        {
            CurrentScopeTable=sct;
            CurrentScopeTable->setParentScope(nullptr);
            CurrentScopeTable->SetId(1);
           // cout<<"Enter scope kaz kore"<<endl;

        }
        else
        {
            
            sct->setParentScope(CurrentScopeTable);
            CurrentScopeTable= sct;
            CurrentScopeTable->getParentScope()->SetCountScope();
            CurrentScopeTable->SetId();
          //  cout << "New ScopeTable with id " << CurrentScopeTable->getID()<< " created\n";


        }

     }

    ScopeTable * getCurrentScopeTable()
    {
        return this->CurrentScopeTable;
    }

     void ExitScope()
     {
         if(CurrentScopeTable==nullptr)
             return;
         //   cout<<"No scope currently"<<endl;
         ScopeTable* parent= CurrentScopeTable->getParentScope();
        // cout<<"ScopeTable with id "<< CurrentScopeTable->getID() <<" is removed "<<endl;
         delete CurrentScopeTable;
         if(parent != nullptr) CurrentScopeTable= parent;
     }


     bool Insert(string name, string type)
     {
        // cout<<"Insert e dhukse"<<endl;
         bool succeeded= false;
         succeeded= CurrentScopeTable->Insert(name,type);
        // cout<<"Insert e dhukse 2"<<endl;
         return succeeded;

     }

     bool Remove(string name)
    {
        bool succeeded= CurrentScopeTable->Delete(name);
        return succeeded;
    }

     SymbolInfo* Lookup(string name)
     {
         ScopeTable *cur= CurrentScopeTable;
          SymbolInfo * node;
         while(cur!=nullptr)
         {
            
            node= cur->LookUp(name);
            //cout<<"Lookup kaz kore bairer";
            if(node!=nullptr){
               // cout<<"Found it"<<endl;
                return node;
            }
            cur= cur->getParentScope();    
         }

       //  cout<<name<<" not found"<<endl;
         return nullptr;

     }
     void printCurrentScopeTable()
     {
         CurrentScopeTable->print();
     }
     
     string printAllScopeTable()
     {
        // cout<<"Print scope"<<endl;
         string printAll="";
         ScopeTable *cur= CurrentScopeTable;
         while(cur!=nullptr)
            {    
                printAll+=cur->printOnlyBooked();
                printAll+='\n';
                cur= cur->getParentScope();   
     }
     return printAll;
     }
};
