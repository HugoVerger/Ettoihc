

#include <stdio.h>
#include <stdlib.h>

typedef struct ID3tag
{
	char TAG[3];
	char Titre[30];
	char Artiste[30];
	char Album[30];
	char Annee[4];
	char Commentaire[28];
	char Separateur[1];
	char Piste[1];
	char Genre[1];
} __attribute__ ((packed)) tag ;

int main()
{
	tag T;
	FILE* fichier = NULL;
	char entree[]= "../media/10 When the Wild Wind Blows.mp3";

	fichier = fopen(entree, "rb");

	fseek(fichier, -128, SEEK_END);
	fread(&T, sizeof(T), 1, fichier);
	fclose(fichier);

	printf("\nTAG = %.3s\n", T.TAG); 
	printf("Titre = %.30s\n", T.Titre);
	printf("Artiste = %.30s\n", T.Artiste);
	printf("Album = %.30s\n", T.Album);
	return 0;
}
