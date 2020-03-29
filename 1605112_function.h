#include <bits/stdc++.h>
using namespace std;

class Function
        {
        string return_type;
        int number_of_parameter;
        vector<string> parameter_list;
        vector<string> parameter_type;
        vector<string> var_list;
        bool isdefined;
        int scopeid;

        public:
            Function(){
                number_of_parameter=0;
                isdefined=false;
                parameter_list.clear();
                parameter_type.clear();
                return_type="";
                scopeid=0;
                var_list.clear();

            }
            void set_return_type(string type){
                this->return_type=type;
            }
            string get_return_type(){
                return return_type;
            }
            void set_number_of_parameter(){
                number_of_parameter=parameter_list.size();
            }
            int get_number_of_parameter(){
              return  number_of_parameter;
            }
            void add_number_of_parameter(string newpara,string type){
                parameter_list.push_back(newpara);
                parameter_type.push_back(type);
              //  cout<<newpara<<endl;
                set_number_of_parameter();
            }
            void add_var(string s){

                var_list.push_back(s);
            }
            vector<string>get_var(){
               // cout<<var_list.size()<<endl;
                return var_list;
            }
            vector<string> get_paralist(){
                return parameter_list;
            }
            vector<string> get_paratype(){
                return parameter_type;
            }
            void set_isdefined(){
                this->isdefined=true;
            }
            bool get_isdefined(){
                return isdefined;
            }
            void set_scopeid(int n){
                scopeid=n;
            }
            int get_scopeid(){
                return scopeid;
            }
            void getclear(){
                parameter_list.clear();
                parameter_type.clear();
                set_number_of_parameter();
            }


        };
