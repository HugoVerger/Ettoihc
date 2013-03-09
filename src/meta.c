#include <caml/mlvalues.h>
#include <stdio.h>
#include <stdlib.h>
#include "meta.h"

tag T;

void takeData(char *entree)
{
	FILE* fichier = NULL;

	fichier = fopen(entree, "rb");

	fseek(fichier, -128, SEEK_END);
	fread(&T, sizeof(T), 1, fichier);
	fclose(fichier);
}

value ocaml_titre (value v)
{
  takeData(String_val(v));
  return (v);
}
