%{
#include <string>
%}

%option noyywrap

ESPACO [ \t]
DIGITO [0-9]
MIN[a-z]
MAIU[A-Z]
VAR [_a-zA-Z][_a-zA-Z0-9]*

DELIM {ESPACO}+
FLOAT ({DIGITO}+"."{DIGITO}*)|({DIGITO}*"."{DIGITO}+)
NUM {DIGITO}+


%%

"\r\n"      { linha++; return '\n'; }
"\n"        { linha++; return '\n'; }
"\r"        { linha++; return '\n'; }

{DELIM} 	{}

[+-]			{ return *yytext; }
[*]             { return *yytext; }

{NUM}		{ yylval.label = yytext; return TK_NUM; }
"int"       {return TK_INT; }
{FLOAT}     { yylval.label = yytext; return TK_FLOAT_LIT; }
"float"     {  return TK_FLOAT; }
"char"      { return TK_CHAR; }
"bool"      { return TK_BOOL; }
"false"     { yylval.label = "0"; return TK_FALSE;}
"true"     { yylval.label = "1"; return TK_TRUE;}
\'[a-zA-Z]\' { yylval.label = yytext; return TK_LETTER; }
"="          {return '=';}

{VAR}       { yylval.label = yytext; return TK_ID; }


.			{ fprintf(stderr, "Caractere nao reconhecido na linha %d: %s\n", linha, yytext); }

%%
