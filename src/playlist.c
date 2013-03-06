#define _XOPEN_SOURCE 500
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <fcntl.h>
#include <unistd.h>


void create_pl(char s[])
{
  int size = strlen(s)+4;
  int i =0;
  char t[size];
  for(i;i<=strlen(s);i++)
	t[i]=s[i];
  char ext[4] =".m3u";
  char* pl = strcat(t,ext);
  int fp;
  fp = open(pl,O_RDWR|O_CREAT|O_APPEND,0666);
}

void del_pl(char* pathname)
{
  remove(pathname);
}

void add_song(char* playlist_name, char* song_path)
{
  int fp;  
  fp = open(playlist_name,O_WRONLY|O_CREAT|O_APPEND,0666);// on creer la playlist si elle existe pas
  int w = write(fp,song_path,strlen(song_path));
  int z = write(fp,"\n",strlen("\n"));
  close(fp);
}


void del_song(char* playlist_name, char* song_path)
{  
  FILE* fin=NULL;
  fin=fopen(playlist_name, "r");
  char* temp= "temp";//playlist temporaire
  create_pl(temp);
  temp="temp.m3u";
  char line[255];//ligne de la playlist
  char csong[255]; //chaine tempo pour ne pas reecrire le '\n'
  int i= 0;

  while(fgets(line,255,fin)!=NULL)
  {
   //reinitionalisation de csong a vide
        for(i;i<255;i++)
            csong[i]=0;
        i=0;
   //comparaison des carateres pour definir si c'est la bonne chanson
	for(i;i<strlen(song_path);i++)
	{
	  if(song_path[i]!=line[i])
            i=256;
	}
   //conservation de la chanson
        if(i>256 && line[0]!='\n')
	{
	  i=0;
	  for(i;i<strlen(line)-1;i++)
	  {
	    csong[i]=line[i];
	  }
	  add_song(temp,csong);
	}
   i=0;
  }	
  fclose(fin);
//on remplace la playlist originale par sa mise a jour
  rename(temp,playlist_name);

}


char* get_song(char* playlist_name,char* song_name)
{
  FILE* fin =NULL;
  fin = fopen(playlist_name, "r");
  char tpath[255];
  char path[255];
  char* found= NULL;
  int i =0;
//initialisation du chemin
  for(i;i<255;i++)
            path[i]=0;
  i=0;
//recherche du chemin de la chanson(sans le'\n') 
  while(fgets(tpath,255,fin)!=NULL)
  {	
	found=strstr(tpath,song_name);
	if(found!=NULL)
	{
	  for(i;i<strlen(tpath)-1;i++)
	  {
	    path[i]=tpath[i];
	  }
	  return(path);
	}
  }
  return("chanson non trouvee");
}
