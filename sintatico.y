%{
#include <iostream>
#include <string>
#include <map>
#include <utility>

#define YYSTYPE atributos

using namespace std;

int var_temp_qnt;
int var_chave_qnt;
int linha = 1;
string codigo_gerado;
string variaveis;

struct variavel
{
	string nome_interno;
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
string get_chave_temp();
void addVar(string nome, string tipo, bool interno = true, string nome_interno = "");
pair<bool, bool> existsVar(string nome, string tipo);
bool atribuicaoCompativel(string t1, string t2);
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
%token TK_RELACIONAL
%token TK_LOGICO

%start S

%left TK_LOGICO
%left TK_NOT
%left TK_RELACIONAL
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
E 			: E '+' E
			{
				bool operacaoCompativel = atribuicaoCompativel($1.tipo, $3.tipo);
				if(!operacaoCompativel) {
					yyerror("Voce nao pode somar um " + $1.tipo + " com um " + $3.tipo);
					exit(1);
				}
				string tipo_resultado;
				if($1.tipo == "float" || $3.tipo == "float") {
					tipo_resultado = "float";
				}
				else {
					tipo_resultado = "int";
				}

				string traducao = $1.traducao + $3.traducao;
				string op1 = $1.label;
				string op3 = $3.label;

				if($1.tipo == "int" && tipo_resultado == "float") {
					string temp_cast = gentempcode();
					addVar(temp_cast, "float");
					traducao += "\t" + temp_cast + " = (float) " + $1.label + ";\n";
					op1 = temp_cast;
				}

				if($3.tipo == "int" && tipo_resultado == "float") {
					string temp_cast = gentempcode();
					addVar(temp_cast, "float");
					traducao += "\t" + temp_cast + " = (float) " + $3.label + ";\n";
					op3 = temp_cast;
				}
				$$.label = gentempcode();


				addVar($$.label, tipo_resultado);
				$$.tipo = tipo_resultado;

				$$.traducao = traducao + "\t" + $$.label +	
					" = " + op1 + " + " + op3 + ";\n";
			}
			|
			E '-' E
			{
				bool operacaoCompativel = atribuicaoCompativel($1.tipo, $3.tipo);
				if(!operacaoCompativel) {
					yyerror("Voce nao pode subtrair um " + $3.tipo + " de um " + $1.tipo);
					exit(1);
				}
				string tipo_resultado;
				if($1.tipo == "float" || $3.tipo == "float") {
					tipo_resultado = "float";
				}
				else {
					tipo_resultado = "int";
				}

				string traducao = $1.traducao + $3.traducao;
				string op1 = $1.label;
				string op3 = $3.label;

				if($1.tipo == "int" && tipo_resultado == "float") {
					string temp_cast = gentempcode();
					addVar(temp_cast, "float");
					traducao += "\t" + temp_cast + " = (float) " + $1.label + ";\n"; 
					op1 = temp_cast;
				}
				if($3.tipo == "int" && tipo_resultado == "float") {
					string temp_cast = gentempcode();
					addVar(temp_cast, "float");
					traducao += "\t" + temp_cast + " = (float) " + $3.label + ";\n"; 
					op3 = temp_cast;
				}

				$$.label = gentempcode();

				addVar($$.label, tipo_resultado);
				$$.tipo = tipo_resultado;

				$$.traducao = traducao + "\t" + $$.label +
					" = " + op1 + " - " + op3 + ";\n";
			}
			|
   			 E '*' E
			{
				bool operacaoCompativel = atribuicaoCompativel($1.tipo, $3.tipo);
				if(!operacaoCompativel) {
					yyerror("Voce nao pode multiplicar um " + $1.tipo + " por um " + $3.tipo);
					exit(1);
				}
				string tipo_resultado;
				if($1.tipo == "float" || $3.tipo == "float") {
					tipo_resultado = "float";
				}
				else {
					tipo_resultado = "int";
				}

				string traducao = $1.traducao + $3.traducao;
				string op1 = $1.label;
				string op3 = $3.label;

				if($1.tipo == "int" && tipo_resultado == "float") {
					string temp_cast = gentempcode();
					addVar(temp_cast, "float");
					traducao += "\t" + temp_cast + " = (float) " + $1.label + ";\n";
					op1 = temp_cast; 
				}

				if($3.tipo == "int" && tipo_resultado == "float") {
					string temp_cast = gentempcode();
					addVar(temp_cast, "float");
					traducao += "\t" + temp_cast + " = (float) " + $3.label + ";\n";
					op3 = temp_cast; 
				} 
				$$.label = gentempcode();
				addVar($$.label, tipo_resultado);
				$$.tipo = tipo_resultado;


				$$.traducao = traducao + "\t" + $$.label +
					" = " + op1 + " * " + op3 + ";\n";
			}
			|
			 E '/' E
			{
				bool operacaoCompativel = atribuicaoCompativel($1.tipo, $3.tipo);
				if(!operacaoCompativel) {
					yyerror("Voce nao pode dividir um " + $1.tipo + " por um " + $3.tipo);
					exit(1);
				}
				string tipo_resultado;
				if($1.tipo == "float" || $3.tipo == "float") {
					tipo_resultado = "float";
				}
				else {
					tipo_resultado = "int";
				}

				string traducao = $1.traducao + $3.traducao;
				string op1 = $1.label;
				string op3 = $3.label;

				if($1.tipo == "int" && tipo_resultado == "float") {
					string temp_cast = gentempcode();
					addVar(temp_cast, "float");
					traducao += "\t" + temp_cast + " = (float) " + $1.label + ";\n";
					op1 = temp_cast;
				}

				if($3.tipo == "int" && tipo_resultado == "float") {
					string temp_cast = gentempcode();
					addVar(temp_cast, "float");
					traducao += "\t" + temp_cast + " = (float) " + $3.label + ";\n";
					op3 = temp_cast;
				}

				$$.label = gentempcode();

				addVar($$.label, tipo_resultado);
				$$.tipo = tipo_resultado;
				$$.traducao = traducao + "\t" + $$.label +
					" = " + op1 + " / " + op3 + ";\n";
			}
			 | '(' E ')'
    		{
       			$$ = $2; 
    		}
			| '(' TIPO ')' E
			{
				if(!atribuicaoCompativel($2.tipo, $4.tipo)) {
					yyerror("Conversão invalida de " + $4.tipo + " para " + $2.tipo);
					exit(1);
				}

				$$.label = gentempcode();
				addVar($$.label, $2.tipo);
				$$.tipo = $2.tipo;

				$$.traducao = $4.traducao + "\t" + $$.label + " = (" + $2.tipo + ") " + $4.label + ";\n";
			}
			| E TK_RELACIONAL E
			{
				$$.label = gentempcode();
				addVar($$.label, "bool");
				$$.tipo = "bool";
				$$.traducao = $1.traducao + $3.traducao + "\t" + $$.label + " = " + $1.label + " " + $2.label + " " + $3.label + ";\n";
			}
			| E TK_LOGICO E
			{
				$$.label = gentempcode();
				addVar($$.label, "bool");
				$$.tipo = "bool";
				$$.traducao = $1.traducao + $3.traducao + "\t" + $$.label + " = " + $1.label + " " + $2.label + " " + $3.label + ";\n";

			}
			| TK_NOT E
			{
				$$.label = gentempcode();
				addVar($$.label, "bool");
				$$.tipo = "bool";
				$$.traducao = $2.traducao + "\t" + $$.label + " = " + $1.label + $2.label + ";\n";
			}
			| TK_ID
			{
				if(!existsVar($1.label, "any").first) {
					yyerror("Variavel " + $1.label + " nao foi declarada anteriormente");
					exit(1);
				}
				variavel var = tabela[$1.label];
				string tipo = var.tipo;
				$$.label = gentempcode();
				addVar($$.label, tipo);
				$$.tipo = tipo;
				$$.traducao = "\t" + $$.label + " = " + var.nome_interno + ";\n";
			}
			| VALOR
			{
				$$.label = gentempcode();
				addVar($$.label, $1.tipo);
				$$.tipo = $1.tipo;
				$$.traducao = "\t" + $$.label + " = " + $1.label + ";\n";
			}

			;
D			: TIPO TK_ID
			{
				pair<bool, bool> ex = existsVar($2.label, "any");
				string var = gentempcode();
				if(ex.first) {
					yyerror("Variavel " + $2.label + " já foi declarada anteriormente");
					exit(1);
				}
				addVar($2.label, $1.tipo, false, var);
			}
			| TK_ID '=' E
			{
				pair<bool, bool> ex = existsVar($1.label, $3.tipo);
				variavel var = tabela[$1.label];

				if(!ex.first) {
					yyerror("Variavel nao declarada");
					exit(1);
				}
				

				else if(!atribuicaoCompativel(var.tipo, $3.tipo)) {
					yyerror("A variavel " + $1.label + " eh do tipo " + var.tipo + " e vc tentou associar ela com um valor do tipo " + $3.tipo);
					exit(1);
				}

				string traducao = $3.traducao;
				string origem = $3.label;
				if(var.tipo != $3.tipo) {
					string temp_cast = gentempcode();
					addVar(temp_cast, var.tipo);
					traducao += "\t" + temp_cast + " = (" + var.tipo + ") " + $3.label + ";\n";
					origem = temp_cast;
				}

				var.valor = origem;
				tabela[$1.label] = var;

				codigo_gerado += traducao;
				codigo_gerado += "\t" + var.nome_interno + " = " + origem + ";\n";
			}
			|
			TIPO TK_ID '=' E
			{
				pair<bool, bool> ex = existsVar($2.label, "any");
				if(ex.first) {
					yyerror("Variavel " + $2.label + " já foi declarada anteriormente");
					exit(1);
				}
				if(!atribuicaoCompativel($1.tipo, $4.tipo)) { // aqui depois posso colocar a funcao que verifica se tipos sao compativeis
					yyerror("Tipos incompativeis de atribuição (" + $1.tipo + ", " + $4.tipo + ")");
					exit(1);
				}
				string var = gentempcode();
				addVar($2.label, $1.tipo, false, var);
				codigo_gerado += $4.traducao;
				codigo_gerado += "\t" + var + " = " + $4.label + ";\n";
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

void addVar(string nome, string tipo, bool interno, string nome_interno) {

	if(!interno) {
		if(tabela.find(nome) != tabela.end()) {
			yyerror("Ja existe uma variavel com esse nome");
			exit(1);
		};

		variavel v;
		v.nome_interno = nome_interno;
		v.tipo = tipo;
		v.valor = "";
		tabela[nome] = v;
		if(tipo == "bool") {
			variaveis += "\tint " + nome_interno + ";" + "\n";
			return;
		}
		variaveis += "\t" + tipo + " " + nome_interno + ";" + "\n";

		return;
	}
	
	variavel var;
	var.tipo = tipo;
	var.nome_interno = nome;

	string nome_temp = get_chave_temp(); 

	tabela[nome_temp] = var;
	if(tipo == "bool") {
		variaveis += "\tint " + nome + ";" + "\n";
		return;
	}
	variaveis += "\t" + tipo + " " + nome + ";" + "\n";
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
	return "t" + to_string(var_temp_qnt);
}

string get_chave_temp()
{
	var_chave_qnt++;
	return "@!" + to_string(var_chave_qnt);
}

int main(int argc, char* argv[])
{
	var_temp_qnt = 0;
	var_chave_qnt = 0;

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
