%{
#include <string>
%}

%option noyywrap

ESPACO [ \t]
DIGITO [0-9]
VAR [_a-zA-Z][_a-zA-Z0-9]*

DELIM {ESPACO}+
NUM {DIGITO}+

%%

"\r\n"      { linha++; return '\n'; }
"\n"        { linha++; return '\n'; }
"\r"        { linha++; return '\n'; }

{DELIM} 	{}

[+-]			{ return *yytext; }
[*]             { return *yytext; }

{NUM}		{ yylval.label = yytext; return TK_NUM; }
"int"        {return TK_INT;}
"float"      {return TK_FLOAT;}
"="          {return '=';}
{VAR}       { yylval.label = yytext; return TK_ID; }


.			{ fprintf(stderr, "Caractere nao reconhecido na linha %d: %s\n", linha, yytext); }

%%
