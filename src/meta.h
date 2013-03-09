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
