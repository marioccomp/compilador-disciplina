%{
#include <iostream>
#include <string>
#include <set>

#define YYSTYPE atributos

using namespace std;

int var_temp_qnt;
int linha = 1;
string codigo_gerado;
string variaveis;
set<string> tabela;

struct atributos
{
	string label;
	string traducao;
};

int yylex(void);
void yyerror(string);
string gentempcode();
void addVar(string variavel);
%}

%token TK_NUM
%token TK_ID
%token TK_INT
%token TK_FLOAT

%start S

%left '+','-'
%left '*'

%%


S			:  CMD '\n' S
			| '\n' S
			| '\n'
			| CMD '\n'
			| CMD
			;

CMD			: E
			{
				codigo_gerado += $1.traducao;
			}
			|
			D
			;

E 			: E '+' E
			{
				$$.label = gentempcode();
				addVar("int " + $$.label);
				$$.traducao = $1.traducao + $3.traducao + "\t" + $$.label +	
					" = " + $1.label + " + " + $3.label + ";\n";
			}
			|
			E '-' E
			{
				$$.label = gentempcode();
				addVar("int " + $$.label);

				$$.traducao = $1.traducao + $3.traducao + "\t" + $$.label +
					" = " + $1.label + " - " + $3.label + ";\n";
			}
			|
   			 E '*' E
			{
				$$.label = gentempcode();
				addVar("int " + $$.label);

				$$.traducao = $1.traducao + $3.traducao + "\t" + $$.label +
					" = " + $1.label + " * " + $3.label + ";\n";
			}
			| TK_NUM
			{
				$$.label = gentempcode();
				addVar("int " + $$.label);
				$$.traducao = "\t" + $$.label + " = " + $1.label + ";\n";
			}
			;
D			: TK_INT TK_ID
			{
				addVar("int " + $2.label);
			}
			|
			TK_INT TK_ID '=' E
			{
				addVar("int " + $2.label);
				codigo_gerado += $4.traducao;
				codigo_gerado += "\t" + $2.label + " = " + $4.label + ";\n";
			}
			|
			TK_FLOAT TK_ID
			{
				addVar("float " + $2.label);
			}
			;

%%

#include "lex.yy.c"

int yyparse();

string cabecalho() {
	string codigo = "/*Compilador FOCA*/\n"
					"#include <stdio.h>\n"
					"int main(void) {\n";
	return codigo;
}

void addVar(string variavel) {
	string nome = variavel.substr(variavel.find(' ') + 1);
	if(tabela.find(nome) != tabela.end()) {
		yyerror("Ja existe uma variavel com esse nome");
		exit(1);
	};
	tabela.insert(nome);
	variaveis += "\t" + variavel + ";" + "\n";
}


string footer() {
	string codigo = "\treturn 0;\n}\n";

	return codigo;
}

string gentempcode()
{
	var_temp_qnt++;
	return "t" + to_string(var_temp_qnt);
}

int main(int argc, char* argv[])
{
	var_temp_qnt = 0;

	if (yyparse() == 0) {
		cout << cabecalho();
		cout << variaveis;
		cout << codigo_gerado;
		cout << footer();
	}

	return 0;
}

void yyerror(string MSG)
{
	cerr << "Erro na linha " << linha << ": " << MSG << endl;
}
