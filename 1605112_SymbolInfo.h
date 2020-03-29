#include <bits/stdc++.h>
#include "1605112_function.h"
using namespace std;

class SymbolInfo
        {
        string name,type,dectype;
        string assembly_code;
        string idvalue;
        SymbolInfo * next;
        Function* isFunction;
        public:
        SymbolInfo()
        {
            this->isFunction=0;
            this->next=0;

        }

        SymbolInfo(string name,string type,string dec=""){
            this->name=name;
            this->type=type;
            this->dectype=dec;
            this->assembly_code="";
            this->idvalue="";
            this->next=0;
        }

        string get_symbol_name()
        {
            return this->name;
        }

        string get_type()
        {
            return this->type;
        }
        string get_symbol_dectype()
        {
            return this->dectype;
        }
        string get_assemblyCode(){
            return this->assembly_code;
        }
        string get_IDvalue(){
            return this->idvalue;
        }

        SymbolInfo *get_next()
        {
            return this->next;
        }


        string set_symbol_name(string new_name)
        {
            this->name=new_name;
            return this->name;
        }

        string set_type(string new_type)
        {
            this->type=new_type;
            return this->type;
        }
        string set_symbol_dectype(string new_type)
        {
            this->dectype=new_type;
            return this->dectype;
        }
        string set_assemblyCode(string s){
            this->assembly_code=s;
            return this->assembly_code;
        }
        string set_IDvalue(string s){
            this->idvalue=s;
            return this->idvalue;
        }

        SymbolInfo *set_next(SymbolInfo * new_next)
        {
            this->next=new_next;
            return this->next;
        }
        void set_isFunction(){
            isFunction=new Function();
        }
        Function* get_isFunction(){
           return isFunction;
        }
        };


        // #include <bits/stdc++.h>
        // #include "1505069_function.h"
        // using namespace std;
        //
        // class SymbolInfo
        //         {
        //         string name,type,dectype;
        //         string assembly_code;
        //         string idvalue;
        //         SymbolInfo * next;
        //         Function* isFunction;
        //         public:
        //         SymbolInfo()
        //         {
        //             this->isFunction=0;
        //             this->next=0;
        //
        //         }
        //
        //         SymbolInfo(string name,string type,string dec=""){
        //             this->name=name;
        //             this->type=type;
        //             this->dectype=dec;
        //             this->assembly_code="";
        //             this->idvalue="";
        //             this->next=0;
        //         }
        //
        //         string get_symbol_name()
        //         {
        //             return this->name;
        //         }
        //
        //         string get_type()
        //         {
        //             return this->type;
        //         }
        //         string get_symbol_dectype()
        //         {
        //             return this->dectype;
        //         }
        //         string get_assemblyCode(){
        //             return this->assembly_code;
        //         }
        //         string get_IDvalue(){
        //             return this->idvalue;
        //         }
        //
        //         SymbolInfo *get_next()
        //         {
        //             return this->next;
        //         }
        //
        //
        //         string set_name(string new_name)
        //         {
        //             this->name=new_name;
        //             return this->name;
        //         }
        //
        //         string set_type(string new_type)
        //         {
        //             this->type=new_type;
        //             return this->type;
        //         }
        //         string set_symbol_dectype(string new_type)
        //         {
        //             this->dectype=new_type;
        //             return this->dectype;
        //         }
        //         string set_assemblyCode(string s){
        //             this->assembly_code=s;
        //             return this->assembly_code;
        //         }
        //         string set_IDvalue(string s){
        //             this->idvalue=s;
        //             return this->idvalue;
        //         }
        //
        //         SymbolInfo *set_next(SymbolInfo * new_next)
        //         {
        //             this->next=new_next;
        //             return this->next;
        //         }
        //         void set_isFunction(){
        //             isFunction=new Function();
        //         }
        //         Function* get_isFunction(){
        //            return isFunction;
        //         }
        //         };
