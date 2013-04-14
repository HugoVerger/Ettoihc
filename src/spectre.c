#include "spectre.h"
#include "lecture.h"

int tempsActuel = 0, tempsPrecedent = 0;
SDL_Surface *ecran = NULL;


void checkTime()
{
  tempsActuel = SDL_GetTicks();
  if (tempsActuel - tempsPrecedent < DELAI_RAFRAICHISSEMENT)
  {
    SDL_Delay(DELAI_RAFRAICHISSEMENT - (tempsActuel - tempsPrecedent));
  }
  tempsPrecedent = SDL_GetTicks();
}

void initSDL()
{
  SDL_Init(SDL_INIT_VIDEO);
  ecran = SDL_SetVideoMode(LARGEUR_FENETRE, HAUTEUR_FENETRE, 32,
                           SDL_SWSURFACE | SDL_DOUBLEBUF);
}

int quit()
{
  SDL_Event event;
  SDL_PollEvent(&event);
  switch(event.type){
    case SDL_QUIT: return 0; break;}
  return 1;
}

void draw()
{
  float spectre[TAILLE_SPECTRE];
  int hauteurBarre = 0, i = 0, j = 0;

  while(quit())
  {
    SDL_FillRect(ecran, NULL, SDL_MapRGB(ecran->format, 0, 0, 0));

    checkTime();
 
    FMOD_Channel_GetSpectrum(channel, spectre, TAILLE_SPECTRE,
                             0, FMOD_DSP_FFT_WINDOW_RECT);

    SDL_LockSurface(ecran);

    for (i = 0 ; i < LARGEUR_FENETRE ; i++)
    {
      hauteurBarre = spectre[i] * 20 * HAUTEUR_FENETRE;

      if (hauteurBarre > HAUTEUR_FENETRE)
        hauteurBarre = HAUTEUR_FENETRE;

      for (j = HAUTEUR_FENETRE - hauteurBarre ; j < HAUTEUR_FENETRE ; j++)
        setPixel(ecran, i, j, 
                SDL_MapRGB(ecran->format, 255 - (j / RATIO), j / RATIO, 0));
    }

    SDL_UnlockSurface(ecran);
	SDL_Flip(ecran);
  }
}

void destroySDL()
{
    SDL_Quit();
}

/* La fonction setPixel permet de dessiner pixel par pixel dans une surface */
void setPixel(SDL_Surface *surface, int x, int y, Uint32 pixel)
{
  int bpp = surface->format->BytesPerPixel;

  Uint8 *p = (Uint8 *)surface->pixels + y * surface->pitch + x * bpp;

  switch(bpp)
  {
    case 1:
      *p = pixel;
      break;

    case 2:
      *(Uint16 *)p = pixel;
      break;
 
    case 3:
      if(SDL_BYTEORDER == SDL_BIG_ENDIAN)
      {
        p[0] = (pixel >> 16) & 0xff;
        p[1] = (pixel >> 8) & 0xff;
        p[2] = pixel & 0xff;
      }
      else
      {
        p[0] = pixel & 0xff;
        p[1] = (pixel >> 8) & 0xff;
        p[2] = (pixel >> 16) & 0xff;
      }
      break;
 
    case 4:
      *(Uint32 *)p = pixel;
      break;
  }
}
