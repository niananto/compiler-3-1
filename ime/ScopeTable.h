#include"SymbolInfo.h"

class ScopeTable
{
private:
    SymbolInfo** ArrayOfSymbolTable;
    ScopeTable* ParentScope;
    int numOfBuckets;
    string ID;
    int countScope;
public:
    ScopeTable(int n)
    {
        int i;
        this->numOfBuckets= n;
        ArrayOfSymbolTable= new SymbolInfo*[numOfBuckets];

        for(i=0; i<numOfBuckets; i++)
        {
            ArrayOfSymbolTable[i]= nullptr;
        }
        ParentScope =nullptr;
        countScope=0;



    }

    void setParentScope(ScopeTable* Pscope)
    {
        if(Pscope== nullptr)
            this->ParentScope= nullptr;
        else
            this-> ParentScope= Pscope;
    }

    ScopeTable* getParentScope()
    {
        return this->ParentScope;
    }

    void SetNumOfBuckets(int n)
    {
        this->numOfBuckets= n;
    }

    int GetNumOfBuckets()
    {
        return this->numOfBuckets;
    }

    void SetId(int ID)
    {
        this->ID= to_string(ID);
    }


 string getID(){
    if(this->ParentScope == nullptr)
        return to_string(1);
    return this->ID;
}

void SetId(){
    this->ID = ParentScope->getID()+"."+ to_string(ParentScope->GetCountScope());
}


    void SetCountScope()
    {
        this->countScope++;
    }

    int GetCountScope()
    {
        return this->countScope;
    }


   static unsigned int SDBMHash(string str) {
	unsigned int hash = 0;
	unsigned int i = 0;
	unsigned int len = str.length();

	for (i = 0; i < len; i++)
	{
		hash = (str[i]) + (hash << 6) + (hash << 16) - hash;
	}

	return hash;
}


    bool Insert(string name,string type)
    {
       // cout<<"vitorer insert e dhukse"<<endl;
        SymbolInfo* node= LookUp(name);
        //ei line e atkaise
        if(node!=nullptr)
        {
            //cout << "< " << name << "," << type <<" > already exist in the currentScopeTable"<<endl;
            return false;
        }

        else
        {
            // cout<<"vitorer else e dhukse"<<endl;
            SymbolInfo* temp = new SymbolInfo ;
            int index= SDBMHash(name) % numOfBuckets;
            SymbolInfo * cur= ArrayOfSymbolTable[index];
            temp->setName(name);
            temp->setType(type);
            temp->setSymbolNextInChain(nullptr);
            // cout<<"Else kaz kore"<<endl;
           
            if(cur==nullptr)
            {
                ArrayOfSymbolTable[index]= temp;
                //cout<<"Inserted in ScopeTable# "<< getID()<< " at position " << index <<", 0"<<endl;
                //cout<<"Eta kaz kore"<<endl;
                return true;
            }
            else 
            {
                SymbolInfo* next= cur->getSymbolNextInChain();
                int pos=1;
                while(next!=nullptr)
                {
                    cur=next;
                    next= next->getSymbolNextInChain();
                    pos++;
                }
                next= temp;
                cur->setSymbolNextInChain(next);
                // cout<<"Inserted in ScopeTable#"<< getID()<< " at position " << index << ", " << pos<<endl;
                 return true;

                


            }

            
        }
        return false;


    };

    SymbolInfo* LookUp(string name)
    {
        // unsigned char* char_arr;
        // string str_obj(name);
        // char_arr = &str_obj[0];
        // int index= sdbm(char_arr);

        int index= SDBMHash(name) % numOfBuckets;
       // cout<<index<<endl;
        int pos=0;
      // cout<<"Vitorer lookup kaz kore"<<endl;
        SymbolInfo* item = ArrayOfSymbolTable[index];
        //cout<<item<<endl;

        //etar por jhamela kore


        if(item==nullptr)
        {
            //cout<<"Vitorer item==nullptr kaz kore"<<endl;
           // cout<<"Not found"<<endl;
            return nullptr;
        }
        if(item->getName()==name)
         {
           cout<<"Found in ScopeTable# "<< getID()<<" at position " << index << "," << pos<<endl;
            return item;
         }
        else
        {
           // int pos=0;
            SymbolInfo * nextNode= item->getSymbolNextInChain();
            while(nextNode!=nullptr)
            {
                pos++;
                if(nextNode->getName()==name){
                   // cout<<"Found in ScopeTable# "<< getID()<<" at position " << index << "," << pos<<endl;
                    return nextNode;
                }
                nextNode = nextNode->getSymbolNextInChain();
                pos++;
            }
        }
        //cout<<"Not found"<<endl;
        return nullptr;
       
    }


      int LookUpIndex(string name)
    {
    
        int index= SDBMHash(name)% numOfBuckets;
        int pos=0;
       // cout<<"Vitorer lookup kaz kore"<<endl;
        SymbolInfo* item = this->ArrayOfSymbolTable[index];
        if(item==nullptr)
        {
       
            return -1;
        }
      
        else
        {
           // int pos=0;
            SymbolInfo * nextNode= item;
            while(nextNode!=nullptr)
            {
                
                if(nextNode->getName()==name){
                  //  cout<<"Found in ScopeTable# "<< getID()<<" at position " << index << "," << pos;
                   // break;
                   return pos;
                }
                nextNode = nextNode->getSymbolNextInChain();
                pos++;
            }
        }
        return pos;
       
    };

  


    bool Delete(string name)
    {
        int index= SDBMHash(name)%numOfBuckets;
        int position=0;
        SymbolInfo* foundNode= LookUp(name);
        int pos= LookUpIndex(name);

        if(foundNode!=nullptr)
        {
            

             if(ArrayOfSymbolTable[index]->getSymbolNextInChain() != nullptr){
                    ArrayOfSymbolTable[index] = ArrayOfSymbolTable[index]->getSymbolNextInChain();
                }

            else{
                    ArrayOfSymbolTable[index] = nullptr;
                }
                cout << "Found in ScopeTable# " << getID() << " at position " << index << ", " << position<< endl;
                cout << "Deleted Entry at " << index << ", " << position <<  " in the current ScopeTable"<<endl;
                return true;
        }
        cout<<name<<" is not found"<<endl;
        return false;

    }
    void print()
    {

        SymbolInfo* listPrint = nullptr;
       cout<<"ScopeTable# "<< " "<< getID()<<endl;

       int i;
       for ( i = 0; i < numOfBuckets; i++)
       {
           /* code */
           cout<<i<<" --> ";
           listPrint= ArrayOfSymbolTable[i];
           while(listPrint!=nullptr)
           {
               cout<<" < " <<listPrint->getName()<< " , "<<listPrint->getType()<<" >";
               listPrint=listPrint->getSymbolNextInChain();
           }
           cout<<endl;
       }
       

    }

       string printOnlyBooked()
    {

        string printTable="";
        SymbolInfo* listPrint = nullptr;
       //cout<<"ScopeTable# "<< " "<< getID()<<endl;
        printTable.append("ScopeTable# ");
        printTable+=getID();
        printTable+='\n';
       int i;
       for ( i = 0; i < numOfBuckets; i++)
       {
           /* code */

           if(ArrayOfSymbolTable[i]!=NULL)
           {

           //cout<<i<<" --> ";

            printTable.append(to_string(i));
            printTable.append(" --> ");

           listPrint= ArrayOfSymbolTable[i];
           while(listPrint!=nullptr)
           {
               //cout<<" < " <<listPrint->getName()<< " , "<<listPrint->getType()<<" >";
               printTable.append(" <");
               printTable.append(listPrint->getName());
               printTable.append(" : ");
               printTable.append(listPrint->getType());
               printTable.append("> ");

               listPrint=listPrint->getSymbolNextInChain();
           }
           //cout<<endl;
           printTable+='\n';
       }
       }
       return printTable;


    }

    ~ScopeTable()
    {
        //destructor
        

        for (int i = 0; i < numOfBuckets; i++)
        {
            /* code */
            SymbolInfo* current = ArrayOfSymbolTable[i];
            while (current!=nullptr) {
                SymbolInfo* temp = current->getSymbolNextInChain();
                delete current;
                current = temp;
        }
        delete[] ArrayOfSymbolTable;
       // cout<<"Destroying scope "<<getID()<<endl;
        
    }



    }
};
