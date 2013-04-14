#include "playlist.h"

void create_pl(char *name, char *s)
{
  int size = strlen(name)+4;
  int max = strlen(name);
  char t[size];
  int fp, w;

  for(int i = 0; i <= max; i++)
    t[i]=name[i];

  char* pl = strcat(t,".m3u");

  fp = open(pl,O_RDWR|O_CREAT|O_TRUNC,0666);
  w = write(fp,s,strlen(s));w++;
  close (fp);
}

void save_biblio(char *s)
{
  int fp, w;

  fp = open("biblio",O_RDWR|O_CREAT|O_TRUNC,0666);
  w = write(fp,s,strlen(s));w++;
  close (fp);
}
