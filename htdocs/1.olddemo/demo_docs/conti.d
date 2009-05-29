

/* Chip's random ooze continent generation program */

/* for documentation, follow this link... */

/* for output, follow this link... */

#include <stdio.h>

#define elif else if

char string[] = " \177";
int screen[60][80];

main (ac, av)
  int ac;
  char *av[];
{
  int showevery;
  int times;
  int i;

        if (ac > 3)
                srand (atoi (av[3]));
        else
                srand (getpid());
        if (ac > 2)
                times = atoi (av[2]);
        else
                times = 1;
        if (ac > 1)
                showevery = atoi (av[1]);
        else
                showevery = rand();
        init();
        for (i = 0; i < times; i++) {
                drift (showevery);
                printthepattern ();
        }
}

init()
{
  int i, j;

        for (i = 0; i < 60; i++) {
                for (j = 0; j < 80; j++)
                        screen[i][j] = rand()%2 * 1;
        }
}

drift (times)
  int times;
{
  int i;
  int x;
  int y;
  int pixel;

        for (i = 0; i < times; i++) {
                x = rand () % 80;
                y = rand () % 59;
                pixel = screen[y][x];
                if (x<79) screen[y][x+1] = pixel;
                if (x>0)  screen[y][x-1] = pixel;
                if (y<58) screen[y+1][x] = pixel;
                if (y>0)  screen[y-1][x] = pixel;
        }
}

printthepattern ()
{
  int i, j;

        gotoxy (0, 0);
        for (i = 0; i < 59; i++) {
                for (j = 0; j < 79; j++) {
                        printf ("%c", string[screen[i][j]]);
                }
                eraseol ();
                printf ("\n");
        }
}

gotoxy (x, y)
  int x, y;
{
        printf ("\33[%d;%df", y+1, x+1);
}

eraseol ()
{
        printf ("\33[K");
}
