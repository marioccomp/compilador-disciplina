%{
#include <iostream>
#include <string>
#include <map>
#include <utility>

#define YYSTYPE atributos

using namespace std;

int var_temp_qnt;
int linha = 1;
string codigo_gerado;
string variaveis;

struct variavel
{
	string tipo;
	string valor;
};

map<string, variavel> tabela;


struct atributos
{
	string label;
	string traducao;
	string tipo;
};

int yylex(void);
void yyerror(string);
string gentempcode();
void addVar(string nome, string tipo);
pair<bool, bool> existsVar(string nome, string tipo);
bool atribuicaoCompativel(string t1, string t2);
void nomeReservado(const string& nome);
%}

%token TK_NUM
%token TK_ID
%token TK_INT
%token TK_FLOAT
%token TK_CHAR
%token TK_LETTER
%token TK_TRUE
%token TK_FALSE
%token TK_BOOL
%token TK_FLOAT_LIT

%start S

%left '+' '-'
%left '*' '/'

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
VALOR		: TK_TRUE
			{
				$$.tipo = "bool";
			}
			| TK_FALSE
			{
				$$.tipo = "bool";
			}
			| TK_LETTER
			{
				$$.tipo = "char";	
			} 
			| TK_NUM
			{
				$$.tipo = "int";
			}
			| TK_FLOAT_LIT
			{
				$$.tipo = "float";
			}
			;

TIPO		: TK_INT
			{
				$$.tipo = "int";
			}
			| TK_BOOL
			{
				$$.tipo = "bool";
			}
			| TK_FLOAT
			{
				$$.tipo = "float";
			}
			| TK_CHAR
			{
				$$.tipo = "char";
			}
			;
E 			: E '+' E
			{
				$$.label = gentempcode();
				string tipo;
				if($1.tipo == "float" || $3.tipo == "float") {
					tipo = "float";
				}
				else {
					tipo = "int";
				}
				addVar($$.label, tipo);
				$$.tipo = tipo;
				$$.traducao = $1.traducao + $3.traducao + "\t" + $$.label +	
					" = " + $1.label + " + " + $3.label + ";\n";
			}
			|
			E '-' E
			{
				$$.label = gentempcode();
				string tipo;
				if($1.tipo == "float" || $3.tipo == "float") {
					tipo = "float";
				}
				else {
					tipo = "int";
				}
				addVar($$.label, tipo);
				$$.tipo = tipo;

				$$.traducao = $1.traducao + $3.traducao + "\t" + $$.label +
					" = " + $1.label + " - " + $3.label + ";\n";
			}
			|
   			 E '*' E
			{
				$$.label = gentempcode();
				string tipo;
				if($1.tipo == "float" || $3.tipo == "float") {
					tipo = "float";
				}
				else {
					tipo = "int";
				}
				addVar($$.label, tipo);
				$$.tipo = tipo;


				$$.traducao = $1.traducao + $3.traducao + "\t" + $$.label +
					" = " + $1.label + " * " + $3.label + ";\n";
			}
			|
			 E '/' E
			{
				$$.label = gentempcode();
				string tipo;
				if($1.tipo == "float" || $3.tipo == "float") {
					tipo = "float";
				}
				else {
					tipo = "int";
				}
				addVar($$.label, tipo);
				$$.tipo = tipo;
				$$.traducao = $1.traducao + $3.traducao + "\t" + $$.label +
					" = " + $1.label + " / " + $3.label + ";\n";
			}
			 | '(' E ')'
    		{
       			$$ = $2;
    		}
			| TK_NUM
			{
				$$.label = gentempcode();
				addVar($$.label, "int");
				$$.tipo = "int";
				$$.traducao = "\t" + $$.label + " = " + $1.label + ";\n";
			}
			| TK_FLOAT_LIT
			{
				$$.label = gentempcode();
				addVar($$.label, "float");
				$$.tipo = "float";
				$$.traducao = "\t" + $$.label + " = " + $1.label + ";\n";
			}
			| TK_ID
			{
				nomeReservado($1.label);
				if(!existsVar($1.label, "any").first) {
					yyerror("Variavel " + $1.label + " nao foi declarada anteriormente");
					exit(1);
				}
				string tipo = tabela[$1.label].tipo;
				$$.label = gentempcode();
				addVar($$.label, tipo);
				$$.tipo = tipo;
				$$.traducao = "\t" + $$.label + " = " + $1.label + ";\n";
			}
			;
D			: TIPO TK_ID
			{
				nomeReservado($2.label);
				pair<bool, bool> ex = existsVar($2.label, "any");
				if(ex.first) {
					yyerror("Variavel " + $2.label + " já foi declarada anteriormente");
					exit(1);
				}
				addVar($2.label, $1.tipo);
			}
			| TK_ID '=' E
			{
				pair<bool, bool> ex = existsVar($1.label, $3.tipo);
				if(!ex.first) {
					yyerror("Variavel nao declarada");
					exit(1);
				}
				else if(!atribuicaoCompativel(tabela[$1.label].tipo, $3.tipo)) {
					yyerror("A variavel " + $1.label + " eh do tipo " + tabela[$1.label].tipo + " e vc tentou associar ela com um valor do tipo " + $3.tipo);
					exit(1);
				}
				variavel var = tabela[$1.label];
				var.valor = $3.label;
				tabela[$1.label] = var;
				codigo_gerado += $3.traducao;
				codigo_gerado += "\t" + $1.label + " = " + $3.label + ";\n";
			}
			|
			TIPO TK_ID '=' E
			{
				nomeReservado($2.label);
				pair<bool, bool> ex = existsVar($2.label, "any");
				if(ex.first) {
					yyerror("Variavel " + $2.label + " já foi declarada anteriormente");
					exit(1);
				}
				if(!atribuicaoCompativel($1.tipo, $4.tipo)) { // aqui depois posso colocar a funcao que verifica se tipos sao compativeis
					yyerror("Tipos incompativeis de atribuição (" + $1.tipo + ", " + $4.tipo + ")");
					exit(1);
				}
				addVar($2.label, $1.tipo);
				codigo_gerado += $4.traducao;
				codigo_gerado += "\t" + $2.label + " = " + $4.label + ";\n";
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

void addVar(string nome, string tipo) {

	if(tabela.find(nome) != tabela.end()) {
		yyerror("Ja existe uma variavel com esse nome");
		exit(1);
	};
	variavel var;
	var.tipo = tipo;
	tabela[nome] = var;
	if(tipo == "bool") {
		variaveis += "\tint " + nome + ";" + "\n";
		return;
	}
	variaveis += "\t" + tipo + " " + nome + ";" + "\n";
}

void nomeReservado(const string& nome) {
    if(nome.rfind("___t", 0) == 0) {
		yyerror("Variaveis que iniciam com ___t são exclusivas do compilador");
		exit(1);
	}
}

bool isNumerico(string t) {
	return t == "int" || t == "float";
}

bool atribuicaoCompativel(string t1, string t2) {
	if(t1 == t2) return true;

	if(isNumerico(t1) && isNumerico(t2)) return true;

	return false;
}

pair<bool, bool> existsVar(string nome, string tipo) {
	bool exists = tabela.find(nome) != tabela.end();
	if(!exists) {
		return {false, false};
	}
	else {
		return {true, tabela[nome].tipo == tipo};
	}
}


string footer() {
	string codigo = "\treturn 0;\n}\n";

	return codigo;
}

string gentempcode()
{
	var_temp_qnt++;
	return "___t" + to_string(var_temp_qnt);
}

int main(int argc, char* argv[])
{
	var_temp_qnt = 0;

	if (yyparse() == 0) {
		cout << cabecalho();
		cout << variaveis << endl;
		cout << codigo_gerado;
		cout << footer();
	}

	return 0;
}

void yyerror(string MSG)
{
	cerr << "Erro na linha " << linha << ": " << MSG << endl;
}
