%{
#include <iostream>
#include <cstdlib>

#include <cmath>
#include <vector>
#include <string>
#include <limits>
#include <sstream>
#include "1605112_SymbolTable.h"
#include "optimizer.h"

using namespace std;

int yyparse(void);
int yylex(void);
extern FILE *yyin;
FILE *fp;
FILE *error=fopen("error.txt","w");
FILE *parsertext= fopen("parsertext.txt","w");
FILE *asmcode= fopen("code.asm","w");
int line_count=1;
int error_count=0;


SymbolTable *table=new SymbolTable(100,parsertext);
vector<SymbolInfo*>parameter_list;
vector<SymbolInfo*>declared_list;
vector<SymbolInfo*>argument_list;

vector<string> variable_declaration;
vector<string> func_variable_declaration;
vector<pair<string,string> >array_declaration;
string curfunction;


void yyerror(const char *s)
{	error_count++;
	fprintf(error,"Line no %d : %s\n\n",line_count,s);

}


int labelCount=0;
int tempCount=0;
string IntToString (int a)
{
    ostringstream temporary;
    temporary<<a;
    return temporary.str();
}

char *newLabel()
{
	char *lb= new char[4];
	strcpy(lb,"L");
	char b[3];
	sprintf(b,"%d", labelCount);
	labelCount++;
	strcat(lb,b);
	return lb;
}

char *newTemp()
{
	char *t= new char[4];
	strcpy(t,"t");
	char b[3];
	sprintf(b,"%d", tempCount);
	tempCount++;
	strcat(t,b);
	return t;
}

void optimization(FILE *asmcode);

string func_def_set(SymbolInfo *s,string codes,string temp){
  vector<string>parameter_list=s->get_isFunction()->get_paralist();
  vector<string>var_list=s->get_isFunction()->get_var();
  for(int i=0;i<parameter_list.size();i++){
    codes+="\tPUSH "+parameter_list[i]+"\n";
  }
  for(int i=0;i<var_list.size();i++){
    codes+="\tPUSH "+var_list[i]+"\n";
  }
  codes+=	temp+"LReturn"+curfunction+":\n";
    for(int i=var_list.size()-1;i>=0;i--){
    codes+="\tPOP "+var_list[i]+"\n";
  }
  for(int i=parameter_list.size()-1;i>=0;i--){
    codes+="\tPOP "+parameter_list[i]+"\n";
  }
}

void type_specifier_set(SymbolInfo*s,string codes,string temp){
  vector<string>parameter_list=s->get_isFunction()->get_paralist();
  vector<string>var_list=s->get_isFunction()->get_var();
  for(int i=0;i<parameter_list.size();i++){
    codes+="\tPUSH "+parameter_list[i]+"\n";
  }
  for(int i=0;i<var_list.size();i++){
    codes+="\tPUSH "+var_list[i]+"\n";
  }
  codes+=	temp+"LReturn"+curfunction+":\n";
    for(int i=var_list.size()-1;i>=0;i--){
    codes+="\tPOP "+var_list[i]+"\n";
  }
  for(int i=parameter_list.size()-1;i>=0;i--){
    codes+="\tPOP "+parameter_list[i]+"\n";
  }

}

void set_var(string codes,string idValue,string temp,string temp2,string temp3){

                                                char *label1=newLabel();
  																							char *label2=newLabel();
  																							codes+=string(label1)+":\n";
  																							codes+=temp;
  																							codes+="\tMOV AX,"+idValue+"\n";
  																							codes+="\tCMP AX,0\n";
  																							codes+="\tJE "+string(label2)+"\n";
  																							codes+=temp2;
  																							codes+=temp3;
  																							codes+="\tJMP "+string(label1)+"\n";
  																							codes+=string(label2)+":\n";

}

void if_set(string codes,string idvalue,string temp){
  char *label1=newLabel();
  codes+="\tMOV AX,"+idvalue+"\n";
  codes+="\tCMP AX,0\n";
  codes+="\tJE "+string(label1)+"\n";
  codes+=temp;
  codes+=string(label1)+":\n";
}

void else_set(string codes,string idvalue,string temp1,string temp2){
  char *label1=newLabel();
  char *label2=newLabel();
  codes+="\tMOV AX,"+idvalue+"\n";
  codes+="\tCMP AX,0\n";
  codes+="\tJE "+string(label1)+"\n";
  codes+=temp1;
  codes+="\tJMP "+string(label2)+"\n";
  codes+=string(label1)+":\n";
  codes+=temp2;
  codes+=string(label2)+":\n";
}

void while_set(string codes,string a_code3,string idvalue3,string a_code5){
  char *label1=newLabel();
  char *label2=newLabel();
  codes+=string(label1)+":\n";
  codes+=a_code3;
  codes+="\tMOV AX,"+idvalue3+"\n";
  codes+="\tCMP AX,0\n";
  codes+="\tJE "+string(label2)+"\n";
  codes+=a_code5;
  codes+="\tJMP "+string(label1)+"\n";
  codes+=string(label2)+":\n";
}

void logical_set(string codes,string symbol,string idvalue1,string idvalue3,char* temp){
  char *label1=newLabel();
  char *label2=newLabel();
  char *label3=newLabel();
//  char *temp=newTemp();

  if(symbol=="||"){
    codes+="\tMOV AX,"+idvalue1+"\n";
    codes+="\tCMP AX,0\n";
    codes+="\tJNE "+string(label2)+"\n";
    codes+="\tMOV AX,"+idvalue3+"\n";
    codes+="\tCMP AX,0\n";
    codes+="\tJNE "+string(label2)+"\n";
    codes+=string(label1)+":\n";
    codes+="\tMOV "+string(temp)+",0\n";
    codes+="\tJMP "+string(label3)+"\n";
    codes+=string(label2)+":\n";
    codes+="\tMOV "+string(temp)+",1\n";
    codes+=string(label3)+":\n";

  }

  else{
    codes+="\tMOV AX,"+idvalue1+"\n";
    codes+="\tCMP AX,0\n";
    codes+="\tJE "+string(label2)+"\n";
    codes+="\tMOV AX,"+idvalue3+"\n";
    codes+="\tCMP AX,0\n";
    codes+="\tJE "+string(label2)+"\n";
    codes+=string(label1)+":\n";
    codes+="\tMOV "+string(temp)+",1\n";
    codes+="\tJMP "+string(label3)+"\n";
    codes+=string(label2)+":\n";
    codes+="\tMOV "+string(temp)+",0\n";
    codes+=string(label3)+":\n";
  }

}

void relop_set(char *temp,char*label1,char*label2,string codes,string symbol,string idvalue1,string idvalue3){
  codes+="\tMOV AX,"+idvalue1+"\n";
  codes+="\tCMP AX,"+idvalue3+"\n";

  if(symbol=="<"){
    codes+="\tJL "+string(label1)+"\n";

  }
  else if(symbol==">"){
    codes+="\tJG "+string(label1)+"\n";

  }
  else if(symbol=="<="){
    codes+="\tJLE "+string(label1)+"\n";

  }
  else if(symbol==">="){
    codes+="\tJGE "+string(label1)+"\n";

  }
  else if(symbol=="=="){
    codes+="\tJE "+string(label1)+"\n";

  }
  else if(symbol=="!="){
    codes+="\tJNE "+string(label1)+"\n";

  }

  codes+="\tMOV "+string(temp)+",0\n";
  codes+="\tJMP "+string(label2)+"\n";
  codes+=string(label1)+":\n";
  codes+="\tMOV "+string(temp)+",1\n";
  codes+=string(label2)+":\n";
}

void addsub_set(char* temp,string symbol,string codes,string idvalue1,string idvalue3){
  codes+="\tMOV AX,"+idvalue1+"\n";
  if(symbol=="+"){
    codes+="\tADD AX,"+idvalue3+"\n";
  }
  else{
    codes+="\tSUB AX,"+idvalue3+"\n";
  }
  codes+="\tMOV "+string(temp)+",AX\n";
}

void modulo_set(char* temp,string codes,string idvalue1,string idvalue3){
  codes+="\tMOV AX,"+idvalue1+"\n";
  codes+="\tMOV BX,"+idvalue3+"\n";
  codes+="\tMOV DX,0\n";
  codes+="\tDIV BX\n";
  codes+="\tMOV "+string(temp)+", DX\n";
}

void div_set(char* temp,string codes,string idvalue1,string idvalue3){
  codes+="\tMOV AX,"+idvalue1+"\n";
  codes+="\tMOV BX,"+idvalue3+"\n";
  codes+="\tDIV BX\n";
  codes+="\tMOV "+string(temp)+", AX\n";
}

void mul_set(char* temp,string codes,string idvalue1,string idvalue3){
  codes+="\tMOV AX,"+idvalue1+"\n";
  codes+="\tMOV BX,"+idvalue3+"\n";
  codes+="\tMUL BX\n";
  codes+="\tMOV "+string(temp)+", AX\n";
}

void Inc_set(char* temp,string codes,string type,string idvalue1 ){
  if(type=="array"){
   codes+="\tMOV AX,"+idvalue1+"[BX]\n";
 }
 else
 codes+="\tMOV AX,"+idvalue1+"\n";

 codes+="\tMOV "+string(temp)+",AX\n";

 if(type=="array"){
   codes+="\tMOV AX,"+idvalue1+"[BX]\n";
   codes+="\tINC AX\n";
   codes+="\tMOV "+idvalue1+"[BX],AX\n";
 }
 else
 codes+="\tINC "+idvalue1+"\n";
}

void dec_set(char* temp,string codes,string type,string idvalue1){

  if(type=="array"){
    codes+="\tMOV AX,"+idvalue1+"[BX]\n";
  }
  else
  codes+="\tMOV AX,"+idvalue1+"\n";
  codes+="\tMOV "+string(temp)+",AX\n";
  if(type=="array"){
    codes+="\tMOV AX,"+idvalue1+"[BX]\n";
    codes+="\tDEC AX\n";
    codes+="\tMOV "+idvalue1+"[BX],AX\n";
  }
  else
  codes+="\tDEC "+idvalue1+"\n";

}

%}


//%error-verbose
%token IF ELSE FOR WHILE DO BREAK
%token INT FLOAT CHAR DOUBLE VOID
%token RETURN SWITCH CASE DEFAULT CONTINUE
%token CONST_INT CONST_FLOAT CONST_CHAR
%token ADDOP MULOP INCOP RELOP ASSIGNOP LOGICOP BITOP NOT DECOP
%token LPAREN RPAREN LCURL RCURL LTHIRD RTHIRD COMMA SEMICOLON
%token STRING ID PRINTLN

%left RELOP LOGICOP BITOP
%left ADDOP
%left MULOP

%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE

%union
{
    SymbolInfo* s_info;
		vector<string>*s;
}
%type <s>HAJIME


%%

HAJIME : program {
//	if(error_count==0){
	string codes="";
	codes+=".MODEL SMALL\n\.STACK 100H\n\.DATA \n";
	for(int i=0;i<variable_declaration.size();i++){
		codes+=variable_declaration[i]+" dw ?\n";
	}
	for(int i=0;i<array_declaration.size();i++){
		codes+=array_declaration[i].first+" dw "+array_declaration[i].second+" dup(?)\n";
	}


	$<s_info>1->set_assemblyCode(codes+".CODE\n"+$<s_info>1->get_assemblyCode());

	$<s_info>1->set_assemblyCode($<s_info>1->get_assemblyCode()+"OUTDEC PROC  \n\
    PUSH AX \n\
    PUSH BX \n\
    PUSH CX \n\
    PUSH DX  \n\
    CMP AX,0 \n\
    JGE BEGIN \n\
    PUSH AX \n\
    MOV DL,'-' \n\
    MOV AH,2 \n\
    INT 21H \n\
    POP AX \n\
    NEG AX \n\
    \n\
    BEGIN: \n\
    XOR CX,CX \n\
    MOV BX,10 \n\
    \n\
    REPEAT: \n\
    XOR DX,DX \n\
    DIV BX \n\
    PUSH DX \n\
    INC CX \n\
    OR AX,AX \n\
    JNE REPEAT \n\
    MOV AH,2 \n\
    \n\
    PRINT_LOOP: \n\
    POP DX \n\
    ADD DL,30H \n\
    INT 21H \n\
    LOOP PRINT_LOOP \n\
    \n\
    MOV AH,2\n\
    MOV DL,10\n\
    INT 21H\n\
    \n\
    MOV DL,13\n\
    INT 21H\n\
	\n\
    POP DX \n\
    POP CX \n\
    POP BX \n\
    POP AX \n\
    ret \n\
OUTDEC ENDP \n\
END MAIN\n");
//   FILE* asmcode= fopen("code.asm","w");
	 fprintf(asmcode,"%s",$<s_info>1->get_assemblyCode().c_str());
	 fclose(asmcode);
	 asmcode= fopen("code.asm","r");
	 optimization(asmcode);
//	 }

}

	  ;

program : program unit {$<s_info>$=new SymbolInfo();// fprintf(parsertext,"Line at %d : program->program unit\n\n",line_count);
					//	fprintf(parsertext,"%s %s\n\n",$<s_info>1->get_symbol_name().c_str(),$<s_info>2->get_symbol_name().c_str());
						$<s_info>$->set_symbol_name($<s_info>1->get_symbol_name()+$<s_info>2->get_symbol_name());
						$<s_info>$->set_assemblyCode($<s_info>1->get_assemblyCode()+$<s_info>2->get_assemblyCode());
						/* fprintf(asmcode,"%s",$<s_info>$->get_assemblyCode().c_str());
				 	 fclose(asmcode);
				 	 asmcode= fopen("code.asm","r");
				 	 optimization(asmcode); */
						}

	| unit {$<s_info>$=new SymbolInfo(); //fprintf(parsertext,"Line at %d : program->unit\n\n",line_count);
//	fprintf(parsertext,"%s\n\n",$<s_info>1->get_symbol_name().c_str());
	$<s_info>$->set_symbol_name($<s_info>1->get_symbol_name());
	$<s_info>$->set_assemblyCode($<s_info>1->get_assemblyCode());
//	fprintf(asmcode,"%s",$<s_info>1->get_assemblyCode().c_str());
/* fprintf(asmcode,"%s",$<s_info>1->get_assemblyCode().c_str());
fclose(asmcode);
asmcode= fopen("code.asm","r");
optimization(asmcode); */
	}
	;

unit : variable_declarationlaration {$<s_info>$=new SymbolInfo();// fprintf(parsertext,"Line at %d : unit->variable_declarationlaration\n\n",line_count);
				//		fprintf(parsertext,"%s\n\n",$<s_info>1->get_symbol_name().c_str());
						$<s_info>$->set_symbol_name($<s_info>1->get_symbol_name()+"\n");
						func_variable_declaration.clear();
						$<s_info>$->set_assemblyCode($<s_info>1->get_assemblyCode());

						}
     | func_declaration {$<s_info>$=new SymbolInfo();// fprintf(parsertext,"Line at %d : unit->func_declaration\n\n",line_count);
	 				//	fprintf(parsertext,"%s\n\n",$<s_info>1->get_symbol_name().c_str());
						 $<s_info>$->set_symbol_name($<s_info>1->get_symbol_name()+"\n");
						 	$<s_info>$->set_assemblyCode($<s_info>1->get_assemblyCode());

						}
     | func_definition { $<s_info>$=new SymbolInfo();// fprintf(parsertext,"Line at %d : unit->func_definition\n\n",line_count);
	 				///	 fprintf(parsertext,"%s\n\n",$<s_info>1->get_symbol_name().c_str());
						 $<s_info>$->set_symbol_name($<s_info>1->get_symbol_name()+"\n");
						$<s_info>$->set_assemblyCode($<s_info>1->get_assemblyCode());

						 }
     ;

func_declaration : type_specifier ID  LPAREN  parameter_list RPAREN SEMICOLON {$<s_info>$=new SymbolInfo();// fprintf(parsertext,"Line at %d : func_declaration->type_specifier ID LPAREN parameter_list RPAREN SEMICOLON\n\n",line_count);
	//	fprintf(parsertext,"%s %s(%s);\n\n",$<s_info>1->get_symbol_name().c_str(),$<s_info>2->get_symbol_name().c_str(),$<s_info>4->get_symbol_name().c_str());
		SymbolInfo *s=table->lookup($<s_info>2->get_symbol_name());
		//		if(s==0){
					table->Insert($<s_info>2->get_symbol_name(),"ID","Function");
					s=table->lookup($<s_info>2->get_symbol_name());
					s->set_isFunction();
					for(int i=0;i<parameter_list.size();i++){
						s->get_isFunction()->add_number_of_parameter(parameter_list[i]->get_symbol_name(),parameter_list[i]->get_symbol_dectype());
					//cout<<parameter_list[i]->get_symbol_dectype()<<endl;
					}
					parameter_list.clear();
					s->get_isFunction()->set_return_type($<s_info>1->get_symbol_name());
		//		}
				/* else{
					int num=s->get_isFunction()->get_number_of_parameter();
				//	cout<<line_count<<" "<<parameter_list.size()<<endl;
				//	$<s_info>$->set_symbol_dectype(s->get_isFunction()->get_return_type());
					if(num!=parameter_list.size()){
						error_count++;
				//		fprintf(error,"Error at Line No.%d:  Invalid number of parameters \n\n",line_count);

					}
					 /* else{

					vector<string>para_type=s->get_isFunction()->get_paratype();
					for(int i=0;i<parameter_list.size();i++){
					if(parameter_list[i]->get_symbol_dectype()!=para_type[i]){
								error_count++;
								fprintf(error,"Error at Line No.%d: Type Mismatch \n\n",line_count);
								break;
							}
						}
						if(s->get_isFunction()->get_return_type()!=$<s_info>1->get_symbol_name()){
								error_count++;
								fprintf(error,"Error at Line No.%d: Return Type Mismatch \n\n",line_count);
						}
						parameter_list.clear();
					} */

			//	}

		$<s_info>$->set_symbol_name($<s_info>1->get_symbol_name()+" "+$<s_info>2->get_symbol_name()+"("+$<s_info>4->get_symbol_name()+");");
		}
		|type_specifier ID LPAREN RPAREN SEMICOLON {$<s_info>$=new SymbolInfo();//// fprintf(parsertext,"Line at %d : func_declaration->type_specifier ID LPAREN RPAREN SEMICOLON\n\n",line_count);
		//		fprintf(parsertext,"%s %s();\n\n",$<s_info>1->get_symbol_name().c_str(),$<s_info>2->get_symbol_name().c_str());
				SymbolInfo *s=table->lookup($<s_info>2->get_symbol_name());
		//		if(s==0){
					table->Insert($<s_info>2->get_symbol_name(),"ID","Function");
					s=table->lookup($<s_info>2->get_symbol_name());
					s->set_isFunction();s->get_isFunction()->set_return_type($<s_info>1->get_symbol_name());
		//		}
				/* else{
					if(s->get_isFunction()->get_number_of_parameter()!=0){
						error_count++;
						fprintf(error,"Error at Line No.%d:  Invalid number of parameters \n\n",line_count);
					}
					if(s->get_isFunction()->get_return_type()!=$<s_info>1->get_symbol_name()){
						error_count++;
						fprintf(error,"Error at Line No.%d: Return Type Mismatch \n\n",line_count);
					}

				} */
				$<s_info>$->set_symbol_name($<s_info>1->get_symbol_name()+" "+$<s_info>2->get_symbol_name()+"();");
		}
		;

func_definition : type_specifier ID  LPAREN  parameter_list RPAREN {$<s_info>$=new SymbolInfo();

				SymbolInfo *s=table->lookup($<s_info>2->get_symbol_name());
				if(s!=0){
					if(s->get_isFunction()->get_isdefined()==0){
					/* int num=s->get_isFunction()->get_number_of_parameter();
				//	cout<<line_count<<" "<<parameter_list.size()<<endl;
				//	$<s_info>$->set_symbol_dectype(s->get_isFunction()->get_return_type());
					if(num!=parameter_list.size()){
						error_count++;
						fprintf(error,"Error at Line No.%d:  Invalid number of parameters \n\n",line_count);

					}
					 else{

					vector<string>para_type=s->get_isFunction()->get_paratype();
					for(int i=0;i<parameter_list.size();i++){
					if(parameter_list[i]->get_symbol_dectype()!=para_type[i]){
								error_count++;
								fprintf(error,"Error at Line No.%d: Type Mismatch \n\n",line_count);
								break;
							}
						}
						if(s->get_isFunction()->get_return_type()!=$<s_info>1->get_symbol_name()){
								error_count++;
								fprintf(error,"Error at Line No.%d: Return Type Mismatch1 \n\n",line_count);
						}
						//	parameter_list.clear();
					} */
					s->get_isFunction()->getclear();
					for(int i=0;i<parameter_list.size();i++){
							s->get_isFunction()->add_number_of_parameter(parameter_list[i]->get_symbol_name()+IntToString(table->getNextId()),parameter_list[i]->get_symbol_dectype());
					//	cout<<parameter_list[i]->get_symbol_dectype()<<parameter_list[i]->get_symbol_name()<<endl;
					}
					s->get_isFunction()->set_isdefined();
				}
					/* else{
						error_count++;
						fprintf(error,"Error at Line No.%d:  Multiple defination of function %s\n\n",line_count,$<s_info>2->get_symbol_name().c_str());

					} */
				}
				else { //cout<<parameter_list.size()<<" "<<line_count<<endl;
						table->Insert($<s_info>2->get_symbol_name(),"ID","Function");
						s=table->lookup($<s_info>2->get_symbol_name());
						s->set_isFunction();
						//cout<<s->get_isFunction()->get_number_of_parameter()<<endl;
						s->get_isFunction()->set_isdefined();
						for(int i=0;i<parameter_list.size();i++){
							s->get_isFunction()->add_number_of_parameter(parameter_list[i]->get_symbol_name()+IntToString(table->getNextId()),parameter_list[i]->get_symbol_dectype());
					//	cout<<parameter_list[i]->get_symbol_dectype()<<parameter_list[i]->get_symbol_name()<<endl;
					}
					//	parameter_list.clear();
					s->get_isFunction()->set_return_type($<s_info>1->get_symbol_name());
					//cout<<table->getNextId()<<endl;
					//cout<<line_count<<" "<<s->get_isFunction()->get_return_type()<<endl;
				}
				curfunction=$<s_info>2->get_symbol_name();
				variable_declaration.push_back(curfunction+"_return");

				} compound_statement
				{//fprintf(parsertext,"Line at %d : func_definition->type_specifier ID LPAREN parameter_list RPAREN compound_statement \n\n",line_count);
			//	fprintf(parsertext,"%s %s(%s) %s \n\n",$<s_info>1->get_symbol_name().c_str(),$<s_info>2->get_symbol_name().c_str(),$<s_info>4->get_symbol_name().c_str(),$<s_info>7->get_symbol_name().c_str());
											$<s_info>$->set_assemblyCode($<s_info>2->get_symbol_name()+" PROC\n");

											if($<s_info>2->get_symbol_name()=="main"){
												$<s_info>$->set_assemblyCode($<s_info>$->get_assemblyCode()+"    MOV AX,@DATA\n\tMOV DS,AX \n"+$<s_info>7->get_assemblyCode()+"LReturn"+curfunction+":\n\tMOV AH,4CH\n\tINT 21H\n");
											}
											else {
													SymbolInfo *s=table->lookup($<s_info>2->get_symbol_name());

											for(int i=0;i<func_variable_declaration.size();i++){
												s->get_isFunction()->add_var(func_variable_declaration[i]);
											}
											func_variable_declaration.clear();

												string codes=$<s_info>$->get_assemblyCode()+
												"\tPUSH AX\n\tPUSH BX \n\tPUSH CX \n\tPUSH DX\n";
                      string temp = $<s_info>7->get_assemblyCode();
                      func_def_set(s,codes,temp);
											/* vector<string>parameter_list=s->get_isFunction()->get_paralist();
											vector<string>var_list=s->get_isFunction()->get_var();
											for(int i=0;i<parameter_list.size();i++){
												codes+="\tPUSH "+parameter_list[i]+"\n";
											}
											for(int i=0;i<var_list.size();i++){
												codes+="\tPUSH "+var_list[i]+"\n";
											}
											codes+=	$<s_info>7->get_assemblyCode()+
												"LReturn"+curfunction+":\n";
												for(int i=var_list.size()-1;i>=0;i--){
												codes+="\tPOP "+var_list[i]+"\n";
											}
											for(int i=parameter_list.size()-1;i>=0;i--){
												codes+="\tPOP "+parameter_list[i]+"\n";
											}
 */

											codes+="\tPOP DX\n\tPOP CX\n\tPOP BX\n\tPOP AX\n\tret\n";

											$<s_info>$->set_assemblyCode(codes+$<s_info>2->get_symbol_name()+" ENDP\n");

											}

				$<s_info>$->set_symbol_name($<s_info>1->get_symbol_name()+" "+$<s_info>2->get_symbol_name()+"("+$<s_info>4->get_symbol_name()+")"+$<s_info>7->get_symbol_name());
				}
		| type_specifier ID LPAREN RPAREN { $<s_info>$=new SymbolInfo();
                      SymbolInfo *s=table->lookup($<s_info>2->get_symbol_name());
											if(s==0){
												table->Insert($<s_info>2->get_symbol_name(),"ID","Function");
												s=table->lookup($<s_info>2->get_symbol_name());
												s->set_isFunction();
												s->get_isFunction()->set_isdefined();
												s->get_isFunction()->set_return_type($<s_info>1->get_symbol_name());
										//	cout<<line_count<<" "<<s->get_isFunction()->get_return_type()<<endl;
											}
											else if(s->get_isFunction()->get_isdefined() == 0){
												/* if(s->get_isFunction()->get_number_of_parameter()!=0){
													error_count++;
													fprintf(error,"Error at Line No.%d:  Invalid number of parameters \n\n",line_count);
												}
												if(s->get_isFunction()->get_return_type()!=$<s_info>1->get_symbol_name()){
													error_count++;
													fprintf(error,"Error at Line No.%d: Return Type Mismatch \n\n",line_count);
												} */
												s->get_isFunction()->set_isdefined();
											}
											/* else{
												error_count++;
												fprintf(error,"Error at Line No.%d:  Multiple defination of function %s\n\n",line_count,$<s_info>2->get_symbol_name().c_str());
											} */
											//cout<<table->getNextId()<<endl;
											curfunction=$<s_info>2->get_symbol_name();
											variable_declaration.push_back(curfunction+"_return");
											$<s_info>1->set_symbol_name($<s_info>1->get_symbol_name()+" "+$<s_info>2->get_symbol_name()+"()");
											} compound_statement {
										//	fprintf(parsertext,"Line at %d : func_definition->type_specifier ID LPAREN RPAREN compound_statement\n\n",line_count);
										//	fprintf(parsertext,"%s %s\n\n",$<s_info>1->get_symbol_name().c_str(),$<s_info>6->get_symbol_name().c_str());
											$<s_info>$->set_assemblyCode($<s_info>2->get_symbol_name()+" PROC\n");

											if($<s_info>2->get_symbol_name()=="main"){
												$<s_info>$->set_assemblyCode($<s_info>$->get_assemblyCode()+"    MOV AX,@DATA\n\tMOV DS,AX \n"+$<s_info>6->get_assemblyCode()+"LReturn"+curfunction+":\n\tMOV AH,4CH\n\tINT 21H\n");
											}
											else {
												SymbolInfo *s=table->lookup($<s_info>2->get_symbol_name());

											for(int i=0;i<func_variable_declaration.size();i++){
												s->get_isFunction()->add_var(func_variable_declaration[i]);
											}
											func_variable_declaration.clear();

											string codes=$<s_info>$->get_assemblyCode()+
												"\tPUSH AX\n\tPUSH BX \n\tPUSH CX \n\tPUSH DX\n";

                      string temp = $<s_info>6->get_assemblyCode();
                      type_specifier_set(s,codes,temp);
											/* vector<string>parameter_list=s->get_isFunction()->get_paralist();
											vector<string>var_list=s->get_isFunction()->get_var();
											for(int i=0;i<parameter_list.size();i++){
												codes+="\tPUSH "+parameter_list[i]+"\n";
											}
											for(int i=0;i<var_list.size();i++){
												codes+="\tPUSH "+var_list[i]+"\n";
											}
											codes+=	temp+"LReturn"+curfunction+":\n";
												for(int i=var_list.size()-1;i>=0;i--){
												codes+="\tPOP "+var_list[i]+"\n";
											}
											for(int i=parameter_list.size()-1;i>=0;i--){
												codes+="\tPOP "+parameter_list[i]+"\n";
											} */

											codes+="\tPOP DX\n\tPOP CX\n\tPOP BX\n\tPOP AX\n\tret\n";

											$<s_info>$->set_assemblyCode(codes+$<s_info>2->get_symbol_name()+" ENDP\n");
											}

											$<s_info>$->set_symbol_name($<s_info>1->get_symbol_name()+$<s_info>6->get_symbol_name());

					}
 		;


parameter_list  : parameter_list COMMA type_specifier ID {$<s_info>$=new SymbolInfo(); //fprintf(parsertext,"Line at %d : parameter_list->parameter_list COMMA type_specifier ID\n\n",line_count);
														//	fprintf(parsertext,"%s,%s %s\n\n",$<s_info>1->get_symbol_name().c_str(),$<s_info>3->get_symbol_name().c_str(),$<s_info>4->get_symbol_name().c_str());
															 parameter_list.push_back(new SymbolInfo($<s_info>4->get_symbol_name(),"ID",$<s_info>3->get_symbol_name()));
															$<s_info>$->set_symbol_name($<s_info>1->get_symbol_name()+","+$<s_info>3->get_symbol_name()+" "+$<s_info>4->get_symbol_name());
															}
		| parameter_list COMMA type_specifier {$<s_info>$=new SymbolInfo(); //fprintf(parsertext,"Line at %d : parameter_list->parameter_list COMMA type_specifier\n\n",line_count);
										//	fprintf(parsertext,"%s,%s\n\n",$<s_info>1->get_symbol_name().c_str(),$<s_info>3->get_symbol_name().c_str());
											parameter_list.push_back(new SymbolInfo("","ID",$<s_info>3->get_symbol_name()));
											$<s_info>$->set_symbol_name($<s_info>1->get_symbol_name()+","+$<s_info>3->get_symbol_name());

											}
 		| type_specifier ID {$<s_info>$=new SymbolInfo();// fprintf(parsertext,"Line at %d : parameter_list->type_specifier ID\n\n",line_count);
		 				//	fprintf(parsertext,"%s %s\n\n",$<s_info>1->get_symbol_name().c_str(),$<s_info>2->get_symbol_name().c_str());
							parameter_list.push_back(new SymbolInfo($<s_info>2->get_symbol_name(),"ID",$<s_info>1->get_symbol_name()));
		 					$<s_info>$->set_symbol_name($<s_info>1->get_symbol_name()+" "+$<s_info>2->get_symbol_name());
							}
		| type_specifier {$<s_info>$=new SymbolInfo(); //fprintf(parsertext,"Line at %d : parameter_list->type_specifier\n\n",line_count);
			//fprintf(parsertext,"%s \n\n",$<s_info>1->get_symbol_name().c_str());
			parameter_list.push_back(new SymbolInfo("","ID",$<s_info>1->get_symbol_name()));
			$<s_info>$->set_symbol_name($<s_info>1->get_symbol_name()+" ");
		}
 		;


compound_statement : LCURL {table->Enter_Scope();
		//	cout<<line_count<<" "<<parameter_list.size()<<endl;
			for(int i=0;i<parameter_list.size();i++){
				table->Insert(parameter_list[i]->get_symbol_name(),"ID",parameter_list[i]->get_symbol_dectype());
				//table->printcurrent();
				variable_declaration.push_back(parameter_list[i]->get_symbol_name()+IntToString(table->getCurrentId()));}
				parameter_list.clear();
			} statements RCURL {$<s_info>$=new SymbolInfo(); //fprintf(parsertext,"Line at %d : compound_statement->LCURL statements RCURL\n\n",line_count);
										//	fprintf(parsertext,"{%s}\n\n",$<s_info>3->get_symbol_name().c_str());
											$<s_info>$->set_symbol_name("{\n"+$<s_info>3->get_symbol_name()+"\n}");
											$<s_info>$->set_assemblyCode($<s_info>3->get_assemblyCode());
											table->printall();
											table->Exit_Scope();
											}
 		    | LCURL RCURL {table->Enter_Scope();
				 for(int i=0;i<parameter_list.size();i++){
				table->Insert(parameter_list[i]->get_symbol_name(),"ID",parameter_list[i]->get_symbol_dectype());
				//table->printcurrent();
				variable_declaration.push_back(parameter_list[i]->get_symbol_name()+IntToString(table->getCurrentId()));
				}
				parameter_list.clear();
				$<s_info>$=new SymbolInfo(); //fprintf(parsertext,"Line at %d : compound_statement->LCURL RCURL\n\n",line_count);
			 				fprintf(parsertext,"{}\n\n");
			 				$<s_info>$->set_symbol_name("{}");
							table->printall();
							table->Exit_Scope();
			 }
 		    ;

variable_declarationlaration : type_specifier declaration_list SEMICOLON {$<s_info>$=new SymbolInfo(); //fprintf(parsertext,"Line at %d : variable_declarationlaration->type_specifier declaration_list SEMICOLON\n\n",line_count);
														//	fprintf(parsertext,"%s %s;\n\n",$<s_info>1->get_symbol_name().c_str(),$<s_info>2->get_symbol_name().c_str());
															/* if($<s_info>1->get_symbol_name()=="void "){
																error_count++;
																fprintf(error,"Error at Line No.%d: Type specifier can not be void \n\n",line_count);

															} */
														//	else{
															//	func_variable_declaration.clear();
															for(int i=0;i<declared_list.size();i++){

																/* if(table->lookupcurrent(declared_list[i]->get_symbol_name())){
																	error_count++;
																	fprintf(error,"Error at Line No.%d:  Multiple Declaration of %s \n\n",line_count,declared_list[i]->get_symbol_name().c_str());
																	continue;
																} */
																if(declared_list[i]->get_type().size()>2){
																	array_declaration.push_back(make_pair(declared_list[i]->get_symbol_name()+IntToString(table->getCurrentId()),declared_list[i]->get_type().substr(2,declared_list[i]->get_type().size () - 1)));

																	declared_list[i]->set_type(declared_list[i]->get_type().substr(0,declared_list[i]->get_type().size () - 1));

																	table->Insert(declared_list[i]->get_symbol_name(),declared_list[i]->get_type(),$<s_info>1->get_symbol_name()+"array");
																}
																else{
																func_variable_declaration.push_back(declared_list[i]->get_symbol_name()+IntToString(table->getCurrentId()));
																table->Insert(declared_list[i]->get_symbol_name(),declared_list[i]->get_type(),$<s_info>1->get_symbol_name());
																variable_declaration.push_back(declared_list[i]->get_symbol_name()+IntToString(table->getCurrentId()));
																}
															}
														//	}

															declared_list.clear();
															$<s_info>$->set_symbol_name($<s_info>1->get_symbol_name()+" "+$<s_info>2->get_symbol_name()+";");
															}
 		 ;

type_specifier	: INT  {$<s_info>$=new SymbolInfo();// fprintf(parsertext,"Line at %d : type_specifier	: INT\n\n",line_count);fprintf(parsertext,"int \n\n");
				$<s_info>$->set_symbol_name("int ");
				}
 		| FLOAT  {$<s_info>$=new SymbolInfo();// fprintf(parsertext,"Line at %d : type_specifier	: FLOAT\n\n",line_count);fprintf(parsertext,"float \n\n");
		 $<s_info>$->set_symbol_name("float ");
		 }
 		| VOID  {$<s_info>$=new SymbolInfo();// fprintf(parsertext,"Line at %d : type_specifier	: VOID\n\n",line_count);fprintf(parsertext,"void \n\n");
		 $<s_info>$->set_symbol_name("void ");
		 }
 		;

declaration_list : declaration_list COMMA ID {$<s_info>$=new SymbolInfo();// fprintf(parsertext,"Line at %d : declaration_list->declaration_list COMMA ID\n\n",line_count);
										//	fprintf(parsertext,"%s,%s\n\n",$<s_info>1->get_symbol_name().c_str(),$<s_info>3->get_symbol_name().c_str());
												declared_list.push_back(new SymbolInfo($<s_info>3->get_symbol_name(),"ID"));
											$<s_info>$->set_symbol_name($<s_info>1->get_symbol_name()+","+$<s_info>3->get_symbol_name());
											}
 		  | declaration_list COMMA ID LTHIRD CONST_INT RTHIRD {$<s_info>$=new SymbolInfo();// fprintf(parsertext,"Line at %d : declaration_list->declaration_list COMMA ID LTHIRD CONST_INT RTHIRD\n\n",line_count);
		   													//	fprintf(parsertext,"%s,%s[%s]\n\n",$<s_info>1->get_symbol_name().c_str(),$<s_info>3->get_symbol_name().c_str(),$<s_info>5->get_symbol_name().c_str());
																declared_list.push_back(new SymbolInfo($<s_info>3->get_symbol_name(),"ID"+$<s_info>5->get_symbol_name()));
																$<s_info>$->set_symbol_name($<s_info>1->get_symbol_name()+","+$<s_info>3->get_symbol_name()+"["+$<s_info>5->get_symbol_name()+"]");
																   }
 		  | ID {$<s_info>$=new SymbolInfo();// fprintf(parsertext,"Line at %d : declaration_list->ID\n\n",line_count);
		  // fprintf(parsertext,"%s\n\n",$<s_info>1->get_symbol_name().c_str());
		   	declared_list.push_back(new SymbolInfo($<s_info>1->get_symbol_name(),"ID"));
				$<s_info>$->set_symbol_name($<s_info>1->get_symbol_name());

		   }
 		  | ID LTHIRD CONST_INT RTHIRD {$<s_info>$=new SymbolInfo();// fprintf(parsertext,"Line at %d : declaration_list->ID LTHIRD CONST_INT RTHIRD\n\n",line_count);
		    //fprintf(parsertext,"%s[%s]\n\n",$<s_info>1->get_symbol_name().c_str(),$<s_info>3->get_symbol_name().c_str());
		   	declared_list.push_back(new SymbolInfo($<s_info>1->get_symbol_name(),"ID"+$<s_info>3->get_symbol_name()));
		   	$<s_info>$->set_symbol_name($<s_info>1->get_symbol_name()+"["+$<s_info>3->get_symbol_name()+"]");

		   }
 		  ;

statements : statement {$<s_info>$=new SymbolInfo();// fprintf(parsertext,"Line at %d : statements->statement\n\n",line_count);
						//fprintf(parsertext,"%s\n\n",$<s_info>1->get_symbol_name().c_str());
						$<s_info>$->set_symbol_name($<s_info>1->get_symbol_name());
						$<s_info>$->set_assemblyCode($<s_info>1->get_assemblyCode());
						}
	   | statements statement {$<s_info>$=new SymbolInfo();// fprintf(parsertext,"Line at %d : statements->statements statement\n\n",line_count);
	   					//	fprintf(parsertext,"%s %s\n\n",$<s_info>1->get_symbol_name().c_str(),$<s_info>2->get_symbol_name().c_str());
							$<s_info>$->set_symbol_name($<s_info>1->get_symbol_name()+"\n"+$<s_info>2->get_symbol_name());
							$<s_info>$->set_assemblyCode($<s_info>1->get_assemblyCode()+$<s_info>2->get_assemblyCode());
							   }
	   ;

statement : variable_declarationlaration { $<s_info>$=new SymbolInfo();//fprintf(parsertext,"Line at %d : statement -> variable_declarationlaration\n\n",line_count);
							//fprintf(parsertext,"%s\n\n",$<s_info>1->get_symbol_name().c_str());
							$<s_info>$->set_symbol_name($<s_info>1->get_symbol_name());

							}
	  | expression_statement {$<s_info>$=new SymbolInfo();//fprintf(parsertext,"Line at %d : statement -> expression_statement\n\n",line_count);
	  					//	fprintf(parsertext,"%s\n\n",$<s_info>1->get_symbol_name().c_str());
							$<s_info>$->set_symbol_name($<s_info>1->get_symbol_name());
							$<s_info>$->set_assemblyCode($<s_info>1->get_assemblyCode());


							  }
	  | compound_statement {$<s_info>$=new SymbolInfo();//fprintf(parsertext,"Line at %d : statement->compound_statement\n\n",line_count);
	  					//	fprintf(parsertext,"%s\n\n",$<s_info>1->get_symbol_name().c_str());
							$<s_info>$->set_symbol_name($<s_info>1->get_symbol_name());
 							$<s_info>$->set_assemblyCode($<s_info>1->get_assemblyCode());

							  }
	  | FOR LPAREN expression_statement expression_statement expression RPAREN statement {$<s_info>$=new SymbolInfo();//fprintf(parsertext,"Line at %d : statement ->FOR LPAREN expression_statement expression_statement expression RPAREN statement\n\n",line_count);
	  																				//	fprintf(parsertext,"for(%s %s %s)\n%s \n\n",$<s_info>3->get_symbol_name().c_str(),$<s_info>4->get_symbol_name().c_str(),$<s_info>5->get_symbol_name().c_str(),$<s_info>7->get_symbol_name().c_str());
																						/* if($<s_info>3->get_symbol_dectype()=="void "){
																							error_count++;
																							fprintf(error,"Error at Line No.%d:  Type Mismatch \n\n",line_count);
																							//$<s_info>$->set_symbol_dectype("int ");
																						} */
																				//		else{
																							//cout<<line_count<<" "<<$<s_info>7->get_assemblyCode()<<endl;
																							string codes=$<s_info>3->get_assemblyCode();

                                              string temp = $<s_info>4->get_assemblyCode();
                                              string temp2 = $<s_info>7->get_assemblyCode();
                                              string temp3 = $<s_info>5->get_assemblyCode();

                                              string idValue = $<s_info>4->get_IDvalue();

                                              set_var(codes,idValue,temp,temp2,temp3);

                                              /* char *label1=newLabel();
																							char *label2=newLabel();
																							codes+=string(label1)+":\n";
																							codes+=temp;
																							codes+="\tMOV AX,"+idValue+"\n";
																							codes+="\tCMP AX,0\n";
																							codes+="\tJE "+string(label2)+"\n";
																							codes+=temp2;
																							codes+=temp3;
																							codes+="\tJMP "+string(label1)+"\n";
																							codes+=string(label2)+":\n"; */

																							$<s_info>$->set_assemblyCode(codes);
																					//	}

																						$<s_info>$->set_symbol_name("for("+$<s_info>3->get_symbol_name()+$<s_info>4->get_symbol_name()+$<s_info>5->get_symbol_name()+")\n"+$<s_info>5->get_symbol_name());

																						  }
	  | IF LPAREN expression RPAREN statement %prec LOWER_THAN_ELSE {$<s_info>$=new SymbolInfo();//fprintf(parsertext,"Line at %d : statement->IF LPAREN expression RPAREN statement\n\n",line_count);
	  															//	fprintf(parsertext,"if(%s)\n%s\n\n",$<s_info>3->get_symbol_name().c_str(),$<s_info>5->get_symbol_name().c_str());
																	/* if($<s_info>3->get_symbol_dectype()=="void "){
																		error_count++;
																		fprintf(error,"Error at Line No.%d:  Type Mismatch \n\n",line_count);
																		//$<s_info>$->set_symbol_dectype("int ");
																	} */
															//		else{
																		string codes=$<s_info>3->get_assemblyCode();
                                    string idvalue = $<s_info>3->get_IDvalue();
                                    string temp = $<s_info>5->get_assemblyCode();
                                    if_set(codes,idvalue,temp);

																		/* char *label1=newLabel();
																		codes+="\tMOV AX,"+idValue+"\n";
																		codes+="\tCMP AX,0\n";
																		codes+="\tJE "+string(label1)+"\n";
																		codes+=temp;
																		codes+=string(label1)+":\n"; */

																		$<s_info>$->set_assemblyCode(codes);
															//		}

																	$<s_info>$->set_symbol_name("if("+$<s_info>3->get_symbol_name()+")\n"+$<s_info>5->get_symbol_name());

																	  }
	  | IF LPAREN expression RPAREN statement ELSE statement {$<s_info>$=new SymbolInfo();//fprintf(parsertext,"Line at %d : statement->IF LPAREN expression RPAREN statement ELSE statement\n\n",line_count);
	  													//	fprintf(parsertext,"if(%s)\n%s\n else \n %s\n\n",$<s_info>3->get_symbol_name().c_str(),$<s_info>5->get_symbol_name().c_str(),$<s_info>7->get_symbol_name().c_str());
															/* if($<s_info>3->get_symbol_dectype()=="void "){
																error_count++;
																fprintf(error,"Error at Line No.%d:  Type Mismatch \n\n",line_count);
																//$<s_info>$->set_symbol_dectype("int ");
															} */
													//		else{
																string codes=$<s_info>3->get_assemblyCode();
                                string idvalue = $<s_info>3->get_IDvalue();

                                string temp1 = $<s_info>5->get_assemblyCode();
                                string temp2 = $<s_info>7->get_assemblyCode();

                                else_set(codes,idvalue,temp1,temp2);

																/* char *label1=newLabel();
																char *label2=newLabel();
																codes+="\tMOV AX,"+idvalue+"\n";
																codes+="\tCMP AX,0\n";
																codes+="\tJE "+string(label1)+"\n";
																codes+=temp1;
																codes+="\tJMP "+string(label2)+"\n";
																codes+=string(label1)+":\n";
																codes+=temp2;
																codes+=string(label2)+":\n"; */

																$<s_info>$->set_assemblyCode(codes);
													//		}

															$<s_info>$->set_symbol_name("if("+$<s_info>3->get_symbol_name()+")\n"+$<s_info>5->get_symbol_name()+" else \n"+$<s_info>7->get_symbol_name());
															}

	  | WHILE LPAREN expression RPAREN statement {$<s_info>$=new SymbolInfo();//fprintf(parsertext,"Line at %d : statement->WHILE LPAREN expression RPAREN statement\n\n",line_count);
	  											//fprintf(parsertext,"while(%s)\n%s\n\n",$<s_info>3->get_symbol_name().c_str(),$<s_info>5->get_symbol_name().c_str());
												  /* if($<s_info>3->get_symbol_dectype()=="void "){
													error_count++;
													fprintf(error,"Error at Line No.%d:  Type Mismatch \n\n",line_count);
												//	$<s_info>$->set_symbol_dectype("int ");
												} */
											//	else{
													string codes="";

                          string a_code3 = $<s_info>3->get_assemblyCode();
                          string idvalue3 = $<s_info>3->get_IDvalue();

                          string a_code5 = $<s_info>5->get_assemblyCode();

                          while_set(codes,a_code3,idvalue3,a_code5);

													/* char *label1=newLabel();
													char *label2=newLabel();
													codes+=string(label1)+":\n";
													codes+=a_code3
													codes+="\tMOV AX,"+idvalue3+"\n";
													codes+="\tCMP AX,0\n";
													codes+="\tJE "+string(label2)+"\n";
													codes+=a_code5;
													codes+="\tJMP "+string(label1)+"\n";
													codes+=string(label2)+":\n"; */

													$<s_info>$->set_assemblyCode(codes);
											//	}
												  $<s_info>$->set_symbol_name("while("+$<s_info>3->get_symbol_name()+")\n"+$<s_info>5->get_symbol_name());
												  }
	  | PRINTLN LPAREN ID RPAREN SEMICOLON {$<s_info>$=new SymbolInfo();//fprintf(parsertext,"Line at %d : statement->PRINTLN LPAREN ID RPAREN SEMICOLON\n\n",line_count);
	  									//	fprintf(parsertext,"\n (%s);\n\n",$<s_info>3->get_symbol_name().c_str());
											string codes="";
											/* if(table->lookupscopeid($<s_info>3->get_symbol_name())==-1){
												error_count++;
												fprintf(error,"Error at Line No.%d:  Undeclared Variable: %s \n\n",line_count,$<s_info>3->get_symbol_name().c_str());
											} */
										//	else{

												codes+="\tMOV AX,"+$<s_info>3->get_symbol_name()+IntToString(table->lookupscopeid($<s_info>3->get_symbol_name()));
												codes+="\n\tCALL OUTDEC\n";
										//	}
											$<s_info>$->set_symbol_name("println("+$<s_info>3->get_symbol_name()+");");

											$<s_info>$->set_assemblyCode(codes);
											  }
	  | RETURN expression SEMICOLON {$<s_info>$=new SymbolInfo();//fprintf(parsertext,"Line at %d : statement->RETURN expression SEMICOLON\n\n",line_count);
	  							//	fprintf(parsertext,"return %s;\n\n",$<s_info>2->get_symbol_name().c_str());
									if($<s_info>2->get_symbol_dectype()=="void "){
												/* error_count++;
												fprintf(error,"Error at Line No.%d:  Type Mismatch \n\n",line_count); */
												$<s_info>$->set_symbol_dectype("int ");
									}
									else{
										string codes=$<s_info>2->get_assemblyCode();
										codes+="\tMOV AX,"+$<s_info>2->get_IDvalue()+"\n";
										codes+="\tMOV "+curfunction+"_return,AX\n";
										codes+="\tJMP LReturn"+curfunction+"\n";
										$<s_info>$->set_assemblyCode(codes);
									}
									$<s_info>$->set_symbol_name("return "+$<s_info>2->get_symbol_name()+";");
									}
	  ;

expression_statement 	: SEMICOLON	{$<s_info>$=new SymbolInfo();//fprintf(parsertext,"Line at %d : expression_statement->SEMICOLON\n\n",line_count);
									//fprintf(parsertext,";\n\n");
									$<s_info>$->set_symbol_name(";");
									}
			| expression SEMICOLON {$<s_info>$=new SymbolInfo();//fprintf(parsertext,"Line at %d : expression_statement->expression SEMICOLON\n\n",line_count);
									//fprintf(parsertext,"%s;\n\n",$<s_info>1->get_symbol_name().c_str());
									$<s_info>$->set_symbol_name($<s_info>1->get_symbol_name()+";");
									$<s_info>$->set_assemblyCode($<s_info>1->get_assemblyCode());
									$<s_info>$->set_IDvalue($<s_info>1->get_IDvalue());

									}
			;

variable : ID 		{$<s_info>$=new SymbolInfo();
					/* fprintf(parsertext,"Line at %d : variable->ID\n\n",line_count);
					fprintf(parsertext,"%s\n\n",$<s_info>1->get_symbol_name().c_str()); */
					/* if(table->lookup($<s_info>1->get_symbol_name())==0){
						 error_count++;
						fprintf(error,"Error at Line No.%d:  Undeclared Variable: %s \n\n",line_count,$<s_info>1->get_symbol_name().c_str());

					} */
					/* else if(table->lookup($<s_info>1->get_symbol_name())->get_symbol_dectype()=="int array" || table->lookup($<s_info>1->get_symbol_name())->get_symbol_dectype()=="float array"){
						error_count++;
						fprintf(error,"Error at Line No.%d:  Not an array: %s \n\n",line_count,$<s_info>1->get_symbol_name().c_str());
					} */
					if(table->lookup($<s_info>1->get_symbol_name())!=0){
						//cout<<line_count<<" "<<$<s_info>1->get_symbol_name()<<" "<<table->lookup($<s_info>1->get_symbol_name())->get_symbol_dectype()<<endl;
						$<s_info>$->set_symbol_dectype(table->lookup($<s_info>1->get_symbol_name())->get_symbol_dectype());
						$<s_info>$->set_IDvalue($<s_info>1->get_symbol_name()+IntToString(table->lookupscopeid($<s_info>1->get_symbol_name())));
					}
					$<s_info>$->set_symbol_name($<s_info>1->get_symbol_name());
					$<s_info>$->set_type("notarray");


					}
	 | ID LTHIRD expression RTHIRD  {$<s_info>$=new SymbolInfo();//fprintf(parsertext,"Line at %d : variable->ID LTHIRD expression RTHIRD\n\n",line_count);
	 								//fprintf(parsertext,"%s[%s]\n\n",$<s_info>1->get_symbol_name().c_str(),$<s_info>3->get_symbol_name().c_str());
									/* if(table->lookup($<s_info>1->get_symbol_name())==0){
										error_count++;
										fprintf(error,"Error at Line No.%d:  Undeclared Variable: %s \n\n",line_count,$<s_info>1->get_symbol_name().c_str());
									} */
									//cout<<line_count<<" "<<$<s_info>3->get_symbol_dectype()<<endl;
									if($<s_info>3->get_symbol_dectype()=="float "||$<s_info>3->get_symbol_dectype()=="void "){
									//	error_count++;
									//	fprintf(error,"Error at Line No.%d:  Non-integer Array Index  \n\n",line_count);
										$<s_info>$->set_IDvalue($<s_info>1->get_symbol_name()+IntToString(table->lookupscopeid($<s_info>1->get_symbol_name())));
									}
									else if(table->lookup($<s_info>1->get_symbol_name()) != 0) {
										//cout<<line_count<<" "<<table->lookup($<s_info>1->get_symbol_name())->get_symbol_dectype()<<endl;
										/* if(table->lookup($<s_info>1->get_symbol_name())->get_symbol_dectype()!="int array" && table->lookup($<s_info>1->get_symbol_name())->get_symbol_dectype()!="float array")
										{
											error_count++;
											fprintf(error,"Error at Line No.%d:  Type Mismatch \n\n",line_count);
										} */
									//	else{
										if(table->lookup($<s_info>1->get_symbol_name())->get_symbol_dectype()=="int array"){
											$<s_info>1->set_symbol_dectype("int ");
										}
										if(table->lookup($<s_info>1->get_symbol_name())->get_symbol_dectype()=="float array"){
											$<s_info>1->set_symbol_dectype("float ");
										}
										$<s_info>$->set_symbol_dectype($<s_info>1->get_symbol_dectype());
										string codes="";
										codes+=$<s_info>3->get_assemblyCode();
										codes+="\tMOV BX,"+$<s_info>3->get_IDvalue()+"\n";
										codes+="\tADD BX,BX\n";
										$<s_info>$->set_IDvalue($<s_info>1->get_symbol_name()+IntToString(table->lookupscopeid($<s_info>1->get_symbol_name())));
										$<s_info>$->set_assemblyCode(codes);
								//	}
								}
									$<s_info>$->set_symbol_name($<s_info>1->get_symbol_name()+"["+$<s_info>3->get_symbol_name()+"]");
									$<s_info>$->set_type("array");
									}
	 ;
expression : logic_expression	{$<s_info>$=new SymbolInfo();//fprintf(parsertext,"Line at %d : expression->logic_expression\n\n",line_count);
 								//fprintf(parsertext,"%s\n\n",$<s_info>1->get_symbol_name().c_str());
								 	$<s_info>$->set_symbol_name($<s_info>1->get_symbol_name());
									$<s_info>$->set_symbol_dectype($<s_info>1->get_symbol_dectype());
									$<s_info>$->set_assemblyCode($<s_info>1->get_assemblyCode());
									$<s_info>$->set_IDvalue($<s_info>1->get_IDvalue());
								 }
	   | variable ASSIGNOP logic_expression {$<s_info>$=new SymbolInfo();//fprintf(parsertext,"Line at %d : expression->variable ASSIGNOP logic_expression\n\n",line_count);
	   										//fprintf(parsertext,"%s=%s\n\n",$<s_info>1->get_symbol_name().c_str(),$<s_info>3->get_symbol_name().c_str());
											   if($<s_info>3->get_symbol_dectype()=="void "){
											//	error_count++;
											//	fprintf(error,"Error at Line No.%d:  Type Mismatch \n\n",line_count);
												$<s_info>$->set_symbol_dectype("int ");
											}
											else {
												//cout<<line_count<<" "<<table->lookup($<s_info>1->get_symbol_name())->get_symbol_dectype()<<""<<$<s_info>3->get_symbol_dectype()<<endl;
												/* if($<s_info>1->get_symbol_dectype()!=$<s_info>3->get_symbol_dectype()){
													 error_count++;
													fprintf(error,"Error at Line No.%d: Type Mismatch \n\n",line_count);
												} */
											//	else{
													string codes=$<s_info>1->get_assemblyCode();
													codes+=$<s_info>3->get_assemblyCode();
													codes+="\tMOV AX,"+$<s_info>3->get_IDvalue()+"\n";
													if($<s_info>1->get_type()=="notarray"){


													codes+="\tMOV "+$<s_info>1->get_IDvalue()+",AX\n";}
													else{
														codes+="\tMOV "+$<s_info>1->get_IDvalue()+"[BX],AX\n";
													}
													$<s_info>$->set_assemblyCode(codes);
													$<s_info>$->set_IDvalue($<s_info>1->get_IDvalue());
											//	}
											}
											$<s_info>$->set_symbol_dectype($<s_info>1->get_symbol_dectype());
											$<s_info>$->set_symbol_name($<s_info>1->get_symbol_name()+"="+$<s_info>3->get_symbol_name());
											}
	   ;
logic_expression : rel_expression 	{$<s_info>$=new SymbolInfo();//fprintf(parsertext,"Line at %d : logic_expression->rel_expression\n\n",line_count);
										//fprintf(parsertext,"%s\n\n",$<s_info>1->get_symbol_name().c_str());
										$<s_info>$->set_symbol_name($<s_info>1->get_symbol_name());
										$<s_info>$->set_symbol_dectype($<s_info>1->get_symbol_dectype());
										$<s_info>$->set_assemblyCode($<s_info>1->get_assemblyCode());
										$<s_info>$->set_IDvalue($<s_info>1->get_IDvalue());
										}
		 | rel_expression LOGICOP rel_expression {$<s_info>$=new SymbolInfo();//fprintf(parsertext,"Line at %d : logic_expression->rel_expression LOGICOP rel_expression\n\n",line_count);
		 											//fprintf(parsertext,"%s%s%s\n\n",$<s_info>1->get_symbol_name().c_str(),$<s_info>2->get_symbol_name().c_str(),$<s_info>3->get_symbol_name().c_str());
													 if($<s_info>1->get_symbol_dectype()=="void "||$<s_info>3->get_symbol_dectype()=="void "){
														/* error_count++;
														fprintf(error,"Error at Line No.%d:  Type Mismatch \n\n",line_count); */
														$<s_info>$->set_symbol_dectype("int ");
													}
													else{



														string codes=$<s_info>1->get_assemblyCode();
														codes+=$<s_info>3->get_assemblyCode();

                            string symbol = $<s_info>2->get_symbol_name();

                            string idvalue1 = $<s_info>1->get_IDvalue();
                            string idvalue3 = $<s_info>3->get_IDvalue();
                            char *temp=newTemp();
                            logical_set(codes,symbol,idvalue1,idvalue3,temp);

														/* char *label1=newLabel();
														char *label2=newLabel();
														char *label3=newLabel();
														char *temp=newTemp();

														if(symbol=="||"){
															codes+="\tMOV AX,"+idvalue1+"\n";
															codes+="\tCMP AX,0\n";
															codes+="\tJNE "+string(label2)+"\n";
															codes+="\tMOV AX,"+idvalue3+"\n";
															codes+="\tCMP AX,0\n";
															codes+="\tJNE "+string(label2)+"\n";
															codes+=string(label1)+":\n";
															codes+="\tMOV "+string(temp)+",0\n";
															codes+="\tJMP "+string(label3)+"\n";
															codes+=string(label2)+":\n";
															codes+="\tMOV "+string(temp)+",1\n";
															codes+=string(label3)+":\n";

														}

														else{
															codes+="\tMOV AX,"+idvalue1+"\n";
															codes+="\tCMP AX,0\n";
															codes+="\tJE "+string(label2)+"\n";
															codes+="\tMOV AX,"+idvalue3+"\n";
															codes+="\tCMP AX,0\n";
															codes+="\tJE "+string(label2)+"\n";
															codes+=string(label1)+":\n";
															codes+="\tMOV "+string(temp)+",1\n";
															codes+="\tJMP "+string(label3)+"\n";
															codes+=string(label2)+":\n";
															codes+="\tMOV "+string(temp)+",0\n";
															codes+=string(label3)+":\n";
														}
                             */
														$<s_info>$->set_assemblyCode(codes);
														$<s_info>$->set_IDvalue(temp);
														variable_declaration.push_back(temp);

													}
										 			$<s_info>$->set_symbol_dectype("int ");
		 											$<s_info>$->set_symbol_name($<s_info>1->get_symbol_name()+$<s_info>2->get_symbol_name()+$<s_info>3->get_symbol_name());

												}
		 ;

rel_expression	: simple_expression {$<s_info>$=new SymbolInfo();//fprintf(parsertext,"Line at %d : rel_expression->simple_expression\n\n",line_count);
									//fprintf(parsertext,"%s\n\n",$<s_info>1->get_symbol_name().c_str());
									$<s_info>$->set_symbol_name($<s_info>1->get_symbol_name());
									$<s_info>$->set_symbol_dectype($<s_info>1->get_symbol_dectype());
									$<s_info>$->set_assemblyCode($<s_info>1->get_assemblyCode());
									$<s_info>$->set_IDvalue($<s_info>1->get_IDvalue());
									}
		| simple_expression RELOP simple_expression	 {$<s_info>$=new SymbolInfo();//fprintf(parsertext,"Line at %d : rel_expression->simple_expression RELOP simple_expression\n\n",line_count);
													//fprintf(parsertext,"%s%s%s\n\n",$<s_info>1->get_symbol_name().c_str(),$<s_info>2->get_symbol_name().c_str(),$<s_info>3->get_symbol_name().c_str());
													if($<s_info>1->get_symbol_dectype()=="void "||$<s_info>3->get_symbol_dectype()=="void "){
														/* error_count++;
														fprintf(error,"Error at Line No.%d:  Type Mismatch \n\n",line_count); */
														$<s_info>$->set_symbol_dectype("int ");
													}
													else{
														string codes=$<s_info>1->get_assemblyCode();
														codes+=$<s_info>3->get_assemblyCode();

														char *temp=newTemp();
														char *label1=newLabel();
														char *label2=newLabel();

                            string symbol = $<s_info>2->get_symbol_name();

                            string idvalue1 = $<s_info>1->get_IDvalue();
                            string idvalue3 = $<s_info>3->get_IDvalue();

                            relop_set(temp,label1,label2,codes,symbol,idvalue1,idvalue3);

														/* codes+="\tMOV AX,"+idvalue1+"\n";
														codes+="\tCMP AX,"+idvalue3+"\n";

														if(symbol=="<"){
															codes+="\tJL "+string(label1)+"\n";

														}
														else if(symbol==">"){
															codes+="\tJG "+string(label1)+"\n";

														}
														else if(symbol=="<="){
															codes+="\tJLE "+string(label1)+"\n";

														}
														else if(symbol==">="){
															codes+="\tJGE "+string(label1)+"\n";

														}
														else if(symbol=="=="){
															codes+="\tJE "+string(label1)+"\n";

														}
														else if(symbol=="!="){
															codes+="\tJNE "+string(label1)+"\n";

														}

														codes+="\tMOV "+string(temp)+",0\n";
														codes+="\tJMP "+string(label2)+"\n";
														codes+=string(label1)+":\n";
														codes+="\tMOV "+string(temp)+",1\n";
														codes+=string(label2)+":\n"; */

														variable_declaration.push_back(temp);
														$<s_info>$->set_assemblyCode(codes);
														$<s_info>$->set_IDvalue(temp);
													}

										 			$<s_info>$->set_symbol_dectype("int ");

													$<s_info>$->set_symbol_name($<s_info>1->get_symbol_name()+$<s_info>2->get_symbol_name()+$<s_info>3->get_symbol_name());

													}
		;

simple_expression : term {$<s_info>$=new SymbolInfo();//fprintf(parsertext,"Line at %d : simple_expression->term\n\n",line_count);
							//fprintf(parsertext,"%s\n\n",$<s_info>1->get_symbol_name().c_str());
							$<s_info>$->set_symbol_dectype($<s_info>1->get_symbol_dectype());
							$<s_info>$->set_symbol_name($<s_info>1->get_symbol_name());
							$<s_info>$->set_assemblyCode($<s_info>1->get_assemblyCode());
							$<s_info>$->set_IDvalue($<s_info>1->get_IDvalue());
							}
		  | simple_expression ADDOP term {$<s_info>$=new SymbolInfo();
		  								//fprintf(parsertext,"Line at %d : simple_expression->simple_expression ADDOP term\n\n",line_count);
		  								//fprintf(parsertext,"%s%s%s\n\n",$<s_info>1->get_symbol_name().c_str(),$<s_info>2->get_symbol_name().c_str(),$<s_info>3->get_symbol_name().c_str());
										//cout<<$<s_info>3->get_symbol_dectype()<<endl;
										if($<s_info>1->get_symbol_dectype()=="void "||$<s_info>3->get_symbol_dectype()=="void "){
												/* error_count++;
												fprintf(error,"Error at Line No.%d:  Type Mismatch \n\n",line_count); */
												$<s_info>$->set_symbol_dectype("int ");
										}
										else{
											 if($<s_info>1->get_symbol_dectype()=="float " ||$<s_info>3->get_symbol_dectype()=="float ")
												$<s_info>$->set_symbol_dectype("float ");
											else  $<s_info>$->set_symbol_dectype("int ");

											string codes=$<s_info>1->get_assemblyCode()+$<s_info>3->get_assemblyCode();

                      string idvalue1=$<s_info>1->get_IDvalue();
                      string idvalue3=$<s_info>3->get_IDvalue();

                      string symbol=$<s_info>2->get_symbol_name();
                      char *temp=newTemp();

                      addsub_set(temp,symbol,codes,idvalue1,idvalue3);

											/* codes+="\tMOV AX,"+idvalue1+"\n";
											if(symbol=="+"){
												codes+="\tADD AX,"+idvalue3+"\n";
											}
											else{
												codes+="\tSUB AX,"+idvalue3+"\n";
											}
											codes+="\tMOV "+string(temp)+",AX\n"; */

											$<s_info>$->set_assemblyCode(codes);
											$<s_info>$->set_IDvalue(temp);
											variable_declaration.push_back(temp);
											}
										 	$<s_info>$->set_symbol_name($<s_info>1->get_symbol_name()+$<s_info>2->get_symbol_name()+$<s_info>3->get_symbol_name());
										  }
		  ;

term :	unary_expression  {$<s_info>$=new SymbolInfo();//fprintf(parsertext,"Line at %d : term->unary_expression\n\n",line_count);
						//	fprintf(parsertext,"%s\n\n",$<s_info>1->get_symbol_name().c_str());
							$<s_info>$->set_symbol_dectype($<s_info>1->get_symbol_dectype());

							$<s_info>$->set_symbol_name($<s_info>1->get_symbol_name());
							$<s_info>$->set_assemblyCode($<s_info>1->get_assemblyCode());
							$<s_info>$->set_IDvalue($<s_info>1->get_IDvalue());
							}
     |  term MULOP unary_expression {$<s_info>$=new SymbolInfo();//fprintf(parsertext,"Line at %d : term->term MULOP unary_expression\n\n",line_count);
	 								//fprintf(parsertext,"%s%s%s\n\n",$<s_info>1->get_symbol_name().c_str(),$<s_info>2->get_symbol_name().c_str(),$<s_info>3->get_symbol_name().c_str());
									 if($<s_info>1->get_symbol_dectype()=="void "||$<s_info>3->get_symbol_dectype()=="void "){
											/* error_count++;
											fprintf(error,"Error at Line No.%d:  Type Mismatch \n\n",line_count); */
											$<s_info>$->set_symbol_dectype("int ");
									}
									else if($<s_info>2->get_symbol_name()=="%"){
										 /* if($<s_info>1->get_symbol_dectype()!="int " ||$<s_info>3->get_symbol_dectype()!="int "){
											 error_count++;
											fprintf(error,"Error at Line No.%d:  Integer operand on modulus operator  \n\n",line_count);

										 } */
										// else{
											 $<s_info>$->set_symbol_dectype("int ");

										// }

										 string codes=$<s_info>1->get_assemblyCode()+$<s_info>3->get_assemblyCode();
										 char *temp=newTemp();

                     string idvalue1=$<s_info>1->get_IDvalue();
                     string idvalue3=$<s_info>3->get_IDvalue();

                     modulo_set(temp,codes,idvalue1,idvalue3);

										 /* codes+="\tMOV AX,"+idvalue1+"\n";
										 codes+="\tMOV BX,"+idvalue3+"\n";
										 codes+="\tMOV DX,0\n";
										 codes+="\tDIV BX\n";
										 codes+="\tMOV "+string(temp)+", DX\n"; */

										 $<s_info>$->set_assemblyCode(codes);
										 $<s_info>$->set_IDvalue(temp);
										 variable_declaration.push_back(temp);
										}
									else if($<s_info>2->get_symbol_name()=="/"){
 									if($<s_info>1->get_symbol_dectype()=="void "|| $<s_info>3->get_symbol_dectype()=="void "){
											/* error_count++;
											fprintf(error,"Error at Line No.%d:  Type Mismatch \n\n",line_count); */
											$<s_info>$->set_symbol_dectype("int ");
									}
										else {
											if($<s_info>1->get_symbol_dectype()=="int " && $<s_info>3->get_symbol_dectype()=="int ")
										 		$<s_info>$->set_symbol_dectype("int ");
										 	else $<s_info>$->set_symbol_dectype("float ");

										 string codes=$<s_info>1->get_assemblyCode()+$<s_info>3->get_assemblyCode();
										 char *temp=newTemp();

                     string idvalue1=$<s_info>1->get_IDvalue();
                     string idvalue3=$<s_info>3->get_IDvalue();

                     div_set(temp,codes,idvalue1,idvalue3);

										 /* codes+="\tMOV AX,"+idvalue1+"\n";
										 codes+="\tMOV BX,"+idvalue3+"\n";
										 codes+="\tDIV BX\n";
										 codes+="\tMOV "+string(temp)+", AX\n"; */

										 $<s_info>$->set_assemblyCode(codes);
										 $<s_info>$->set_IDvalue(temp);
										 variable_declaration.push_back(temp);
										}
									 }
									 else{
										  if($<s_info>1->get_symbol_dectype()=="void "||$<s_info>3->get_symbol_dectype()=="void "){
											/* error_count++;
											fprintf(error,"Error at Line No.%d:  Type Mismatch \n\n",line_count); */
											$<s_info>$->set_symbol_dectype("int ");
										}
										else {
											if($<s_info>1->get_symbol_dectype()=="float " || $<s_info>3->get_symbol_dectype()=="float ")
										 		$<s_info>$->set_symbol_dectype("float ");
										 	else $<s_info>$->set_symbol_dectype("int ");

										 string codes=$<s_info>1->get_assemblyCode()+$<s_info>3->get_assemblyCode();
										 char *temp=newTemp();

                     string idvalue1=$<s_info>1->get_IDvalue();
                     string idvalue3=$<s_info>3->get_IDvalue();

                     mul_set(temp,codes,idvalue1,idvalue3);

										 /* codes+="\tMOV AX,"+idvalue1+"\n";
										 codes+="\tMOV BX,"+idvalue3+"\n";
										 codes+="\tMUL BX\n";
										 codes+="\tMOV "+string(temp)+", AX\n"; */

										 $<s_info>$->set_assemblyCode(codes);
										 $<s_info>$->set_IDvalue(temp);
										 variable_declaration.push_back(temp);

										 }
									 }
									$<s_info>$->set_symbol_name($<s_info>1->get_symbol_name()+$<s_info>2->get_symbol_name()+$<s_info>3->get_symbol_name());

									 }
     ;

unary_expression : ADDOP unary_expression  {$<s_info>$=new SymbolInfo(); //fprintf(parsertext,"Line at %d : unary_expression->ADDOP unary_expression\n\n",line_count);
											//fprintf(parsertext,"%s%s\n\n",$<s_info>1->get_symbol_name().c_str(),$<s_info>2->get_symbol_name().c_str());
											if($<s_info>2->get_symbol_dectype()=="void "){
												/* error_count++;
												fprintf(error,"Error at Line No.%d:  Type Mismatch \n\n",line_count); */
												$<s_info>$->set_symbol_dectype("int ");
											}
											else {
												string codes=$<s_info>2->get_assemblyCode();
												if($<s_info>1->get_symbol_name()=="-"){

													codes+="\tMOV AX,"+$<s_info>2->get_IDvalue()+"\n";
													codes+="\tNEG AX\n";
													codes+="\tMOV "+$<s_info>2->get_IDvalue()+",AX\n";

												}
											$<s_info>$->set_assemblyCode(codes);
											$<s_info>$->set_IDvalue($<s_info>2->get_IDvalue());

											 $<s_info>$->set_symbol_dectype($<s_info>2->get_symbol_dectype());

											 }
											 $<s_info>$->set_symbol_name($<s_info>1->get_symbol_name()+$<s_info>2->get_symbol_name());

										}
		 | NOT unary_expression {$<s_info>$=new SymbolInfo();//fprintf(parsertext,"Line at %d : unary_expression->NOT unary_expression\n\n",line_count);
			//	fprintf(parsertext,"!%s\n\n",$<s_info>2->get_symbol_name().c_str());
				if($<s_info>2->get_symbol_dectype()=="void "){
					/* error_count++;
					fprintf(error,"Error at Line No.%d:  Type Mismatch \n\n",line_count); */
					$<s_info>$->set_symbol_dectype("int ");
				}
				else {
					$<s_info>$->set_symbol_dectype($<s_info>2->get_symbol_dectype());

					string codes=$<s_info>2->get_assemblyCode();
					codes+="\tMOV AX,"+$<s_info>2->get_IDvalue()+"\n";
					codes+="\tNOT AX\n";
					codes+="\tMOV "+$<s_info>2->get_IDvalue()+",AX\n";

					$<s_info>$->set_assemblyCode(codes);
					$<s_info>$->set_IDvalue($<s_info>2->get_IDvalue());


				}

		 		$<s_info>$->set_symbol_name("!"+$<s_info>2->get_symbol_name());

		 }
		 | factor {$<s_info>$=new SymbolInfo();//fprintf(parsertext,"Line at %d : unary_expression->factor\n\n",line_count);
		 		//fprintf(parsertext,"%s\n\n",$<s_info>1->get_symbol_name().c_str());
				// cout<<$<s_info>1->get_symbol_dectype()<<endl;
				$<s_info>$->set_symbol_dectype($<s_info>1->get_symbol_dectype());
				$<s_info>$->set_symbol_name($<s_info>1->get_symbol_name());
				$<s_info>$->set_assemblyCode($<s_info>1->get_assemblyCode());
				$<s_info>$->set_IDvalue($<s_info>1->get_IDvalue());


		 }
		 ;

factor	: variable { $<s_info>$=new SymbolInfo();//fprintf(parsertext,"Line at %d : factor->variable\n\n",line_count);
					//fprintf(parsertext,"%s\n\n",$<s_info>1->get_symbol_name().c_str());
					$<s_info>$->set_symbol_dectype($<s_info>1->get_symbol_dectype());
					$<s_info>$->set_symbol_name($<s_info>1->get_symbol_name());

					string codes=$<s_info>1->get_assemblyCode();
					if($<s_info>1->get_type()=="array"){

						char *temp=newTemp();
						codes+="\tMOV AX,"+$<s_info>1->get_IDvalue()+"[BX]\n";
						codes+="\tMOV "+string(temp)+",AX\n";

						variable_declaration.push_back(temp);
						$<s_info>$->set_IDvalue(temp);

					}
					else{
						$<s_info>$->set_IDvalue($<s_info>1->get_IDvalue());
					}

					$<s_info>$->set_assemblyCode(codes);

					}
	| ID LPAREN argument_list RPAREN {$<s_info>$=new SymbolInfo(); //fprintf(parsertext,"Line at %d : factor->ID LPAREN argument_list RPAREN\n\n",line_count);
									//fprintf(parsertext,"%s(%s)\n\n",$<s_info>1->get_symbol_name().c_str(),$<s_info>3->get_symbol_name().c_str());
									SymbolInfo* s=table->lookup($<s_info>1->get_symbol_name());
									if(s==0){
										/* error_count++;
										fprintf(error,"Error at Line No.%d:  Undefined Function \n\n",line_count); */
										$<s_info>$->set_symbol_dectype("int ");
									}
									else if(s->get_isFunction()==0){
										/* error_count++;
										fprintf(error,"Error at Line No.%d:  Not A Function \n\n",line_count); */
										$<s_info>$->set_symbol_dectype("int ");
									}
									else {
										/* if(s->get_isFunction()->get_isdefined()==0){
										error_count++;
										fprintf(error,"Error at Line No.%d:  Undeclared Function \n\n",line_count);
										} */

										int num=s->get_isFunction()->get_number_of_parameter();
										//cout<<line_count<<" "<<argument_list.size()<<endl;
										$<s_info>$->set_symbol_dectype(s->get_isFunction()->get_return_type());
										/* if(num!=argument_list.size()){
											error_count++;
											fprintf(error,"Error at Line No.%d:  Invalid number of arguments %s\n\n",line_count,$<s_info>1->get_symbol_name().c_str());

										} */
										//else{
											string codes=$<s_info>3->get_assemblyCode();
											//cout<<s->get_isFunction()->get_return_type()<<endl;

											vector<string>parameter_list=s->get_isFunction()->get_paralist();
											vector<string>para_type=s->get_isFunction()->get_paratype();
											vector<string>var_list=s->get_isFunction()->get_var();

											for(int i=0;i<argument_list.size();i++){

												codes+="\tMOV AX,"+argument_list[i]->get_IDvalue()+"\n";
												codes+="\tMOV "+parameter_list[i]+",AX\n";
												//cout<<parameter_list[i]<<" "<<argument_list[i]->get_symbol_name()<<" "<<argument_list[i]->get_IDvalue()<<endl;
												/* if(argument_list[i]->get_symbol_dectype()!=para_type[i]){

													error_count++;
													fprintf(error,"Error at Line No.%d: Type Mismatch \n\n",line_count);
													break;
												} */
											}

											codes+="\tCALL "+$<s_info>1->get_symbol_name()+"\n";
											codes+="\tMOV AX,"+$<s_info>1->get_symbol_name()+"_return\n";
											char *temp=newTemp();
											codes+="\tMOV "+string(temp)+",AX\n";

											$<s_info>$->set_assemblyCode(codes);
											$<s_info>$->set_IDvalue(temp);
											variable_declaration.push_back(temp);

								//		}
									}
									argument_list.clear();
									//cout<<line_count<<" "<<$<s_info>$->get_symbol_dectype()<<endl;
									$<s_info>$->set_symbol_name($<s_info>1->get_symbol_name()+"("+$<s_info>3->get_symbol_name()+")");
									}
	| LPAREN expression RPAREN {$<s_info>$=new SymbolInfo();//fprintf(parsertext,"Line at %d : factor->LPAREN expression RPAREN\n\n",line_count);
								//fprintf(parsertext,"(%s)\n\n",$<s_info>2->get_symbol_name().c_str());
								$<s_info>$->set_symbol_dectype($<s_info>2->get_symbol_dectype());
								$<s_info>$->set_symbol_name("("+$<s_info>2->get_symbol_name()+")");
								$<s_info>$->set_assemblyCode($<s_info>2->get_assemblyCode());
								$<s_info>$->set_IDvalue($<s_info>2->get_IDvalue());
								}
	| CONST_INT { $<s_info>$=new SymbolInfo();//fprintf(parsertext,"Line at %d : factor->CONST_INT\n\n",line_count);
			//	fprintf(parsertext,"%s\n\n",$<s_info>1->get_symbol_name().c_str());
				$<s_info>$->set_symbol_dectype("int ");
				$<s_info>$->set_symbol_name($<s_info>1->get_symbol_name());
				char *temp=newTemp();
				string codes="\tMOV "+string(temp)+","+$<s_info>1->get_symbol_name()+"\n";
				$<s_info>$->set_assemblyCode(codes);
				$<s_info>$->set_IDvalue(string(temp));
				//cout<<codes<<endl;
				variable_declaration.push_back(temp);
				}
	| CONST_FLOAT {$<s_info>$=new SymbolInfo();//fprintf(parsertext,"Line at %d : factor->CONST_FLOAT\n\n",line_count);
				//	fprintf(parsertext,"%s\n\n",$<s_info>1->get_symbol_name().c_str());
					$<s_info>$->set_symbol_dectype("float ");
					$<s_info>$->set_symbol_name($<s_info>1->get_symbol_name());
					char *temp=newTemp();
					string codes="\tMOV "+string(temp)+","+$<s_info>1->get_symbol_name()+"\n";
					$<s_info>$->set_assemblyCode(codes);
					$<s_info>$->set_IDvalue(string(temp));
					variable_declaration.push_back(temp);
					}
	| variable INCOP {$<s_info>$=new SymbolInfo();//fprintf(parsertext,"Line at %d : factor->variable INCOP\n\n",line_count);
				//	fprintf(parsertext,"%s++\n\n",$<s_info>1->get_symbol_name().c_str());
					$<s_info>$->set_symbol_dectype($<s_info>1->get_symbol_dectype());
					char *temp=newTemp();
					string codes="";

          string type=$<s_info>1->get_type();
          string idvalue1=$<s_info>1->get_IDvalue();
          Inc_set(temp,codes,type,idvalue1);

					 /* if(type=="array"){
						codes+="\tMOV AX,"+idvalue1+"[BX]\n";
					}
					else
					codes+="\tMOV AX,"+idvalue1+"\n";

					codes+="\tMOV "+string(temp)+",AX\n";

					if(type=="array"){
						codes+="\tMOV AX,"+idvalue1+"[BX]\n";
						codes+="\tINC AX\n";
						codes+="\tMOV "+idvalue1+"[BX],AX\n";
					}
					else
					codes+="\tINC "+idvalue1+"\n"; */

					variable_declaration.push_back(temp);

					$<s_info>$->set_symbol_name($<s_info>1->get_symbol_name()+"++");
					$<s_info>$->set_assemblyCode(codes);
					$<s_info>$->set_IDvalue(temp);

					 }
	| variable DECOP {$<s_info>$=new SymbolInfo();//fprintf(parsertext,"Line at %d : factor->variable DECOP\n\n",line_count);
					//fprintf(parsertext,"%s--\n\n",$<s_info>1->get_symbol_name().c_str());
					$<s_info>$->set_symbol_dectype($<s_info>1->get_symbol_dectype());
					char *temp=newTemp();
					string codes="";
          string type=$<s_info>1->get_type();
          string idvalue1=$<s_info>1->get_IDvalue();
          dec_set(temp,codes,type,idvalue1);
          /*
					if(type=="array"){
						codes+="\tMOV AX,"+idvalue1+"[BX]\n";
					}
					else
					codes+="\tMOV AX,"+idvalue1+"\n";
					codes+="\tMOV "+string(temp)+",AX\n";
					if(type=="array"){
						codes+="\tMOV AX,"+idvalue1+"[BX]\n";
						codes+="\tDEC AX\n";
						codes+="\tMOV "+idvalue1+"[BX],AX\n";
					}
					else
					codes+="\tDEC "+idvalue1+"\n";
           */
					variable_declaration.push_back(temp);
					$<s_info>$->set_symbol_name($<s_info>1->get_symbol_name()+"--");
					$<s_info>$->set_assemblyCode(codes);
					$<s_info>$->set_IDvalue(temp);

					 }
	;

argument_list : arguments  {$<s_info>$=new SymbolInfo(); //fprintf(parsertext,"Line at %d : argument_list->arguments\n\n",line_count);
							//fprintf(parsertext,"%s\n\n",$<s_info>1->get_symbol_name().c_str());
							 $<s_info>$->set_symbol_name($<s_info>1->get_symbol_name());
							 $<s_info>$->set_assemblyCode($<s_info>1->get_assemblyCode());
							}
				| 	{ $<s_info>$=new SymbolInfo(); //fprintf(parsertext,"Line at %d : argument_list-> \n\n",line_count);$<s_info>$->set_symbol_name("");
			}
			  ;

arguments : arguments COMMA logic_expression { $<s_info>$=new SymbolInfo();//fprintf(parsertext,"Line at %d : arguments->arguments COMMA logic_expression \n\n",line_count);
											//fprintf(parsertext,"%s,%s\n\n",$<s_info>1->get_symbol_name().c_str(),$<s_info>3->get_symbol_name().c_str());
											argument_list.push_back($<s_info>3);
											$<s_info>$->set_symbol_name($<s_info>1->get_symbol_name()+","+$<s_info>3->get_symbol_name());
											$<s_info>$->set_assemblyCode($<s_info>1->get_assemblyCode()+$<s_info>3->get_assemblyCode());
											}
	      | logic_expression {$<s_info>$=new SymbolInfo();
		  					/* fprintf(parsertext,"Line at %d : arguments->logic_expression\n\n",line_count);
		  					fprintf(parsertext,"%s\n\n",$<s_info>1->get_symbol_name().c_str()); */
							argument_list.push_back($<s_info>1);
							// cout<<$<s_info>1->get_symbol_dectype()<<endl;
		  					$<s_info>$->set_symbol_name($<s_info>1->get_symbol_name());
							$<s_info>$->set_assemblyCode($<s_info>1->get_assemblyCode());
		  }
	      ;
 %%
 bool check(string s1,string s2){

	 if(s1.size()!=s2.size() || s1.size()<11) return false;
	int j=0;
	for(;j<s1.size();j++){
		if(s1[j]=='M') break;
	}
	if(j==s1.size()) return false;

	 if(s1[j]!='M' || s1[j+1]!='O' || s1[j+2]!='V') return false;
	j=0;
	for(;j<s2.size();j++){
		if(s2[j]=='M') break;
	}
	if(j==s2.size()) return false;

	 if(s2[j]!='M' || s2[j+1]!='O' || s2[j+2]!='V') return false;

//	cout<<s1<<endl;
//	cout<<s2<<endl;

	 string source1="",dist1="";
	 string source2="",dist2="";
	 int i;
	 for(i=j+4;i<s1.size()-1;i++){
		 if(s1[i]==' ' and source1.size()==0) continue;
		 if(s1[i]==' ' || s1[i]==',') break;
		 source1.push_back(s1[i]);
	 }
	//cout<<source1<<" ";
	 for(;i<s1.size()-1;i++){
		 if((s1[i]==' '||s1[i]==',') and dist1.size()==0) continue;
		 if(s1[i]==' ') break;
		 dist1.push_back(s1[i]);
	 }
	//cout<<dist1<<" ";

	 for(i=j+4;i<s2.size()-1;i++){
		 if(s2[i]==' ' and source2.size()==0) continue;
		 if(s2[i]==' '|| s2[i]==',') break;
		 source2.push_back(s2[i]);
	 }
	//cout<<source2<<" ";
	 for(;i<s2.size()-1;i++){
		 if((s2[i]==' '||s2[i]==',') and dist2.size()==0) continue;
		 if(s2[i]==' ') break;
		 dist2.push_back(s2[i]);
	 }
	 //cout<<dist2<<endl;

	//cout<<source1<<","<<dist1<<endl<<source2<<","<<dist2<<endl;
	 if(dist1==source2 and dist2==source1) return true;


	 return false;
 }
void optimization(FILE *asmcode){
	FILE* optcode= fopen("optcode.asm","w");
	char * line = NULL;
    size_t len = 0;
    ssize_t read;
	vector<string>v;
    while ((read = getline(&line, &len, asmcode)) != -1) {
       // printf("%s", line);
	   v.push_back(string(line));
    }
	int sz=v.size();
	int mark[sz];
	for(int i=0;i<sz;i++)
		mark[i]=1;
	for(int i=0;i<sz-1;i++){
		if(check(v[i],v[i+1])){
			mark[i+1]=0;
		}
	}
	for(int i=0;i<sz;i++){
		if(mark[i])
		fprintf(optcode,"%s",v[i].c_str());
	}

	fclose(asmcode);
	fclose(optcode);
    if (line)
        free(line);

}
int main(int argc,char *argv[])
{

	if((fp=fopen(argv[1],"r"))==NULL)
	{
		printf("Cannot Open Input File.\n");
		return 0;
	}
	yyin=fp;
	table->Enter_Scope();
	yyparse();
	fprintf(parsertext," Symbol Table : \n\n");
	table->printall();
	fprintf(parsertext,"Total Lines : %d \n\n",line_count);
	fprintf(parsertext,"Total Errors : %d \n\n",error_count);
	fprintf(error,"Total Errors : %d \n\n",error_count);

	fclose(fp);
	fclose(parsertext);
	fclose(error);

	return 0;
}
