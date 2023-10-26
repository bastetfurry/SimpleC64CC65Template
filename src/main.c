#include <c64.h>
#include <conio.h>
#include <stdint.h>
#include <stdlib.h>

#include "irq.h"
#include "helper.h"

uint8_t gameticks=0;

// Dinge Initialisieren, laden, etc...
void GameInit()
{
	POKE(0xd018, 0x15); // Uppercase mit Grafik, cc65 hat die Eigenart das die Initialisierungsroutine erst mal auf Upper/Lowercase schaltet.
	VIC.addr = 24;		// Wechsle auf Charset
}

// Wird 50 mal die Sekunde aufgerufen, ist auf PAL Maschinen geeicht.
void GameRun()
{
	uint8_t lastkey = 0;
	gameticks++;

	// POKE(0xd020,PEEK(0xd020)+1); // <-- Achtung! 
	if(gameticks >= 50)
	{
		// Hintergrundfarbe eins hoch damit man was sieht
		POKE(0xd021,PEEK(0xd021)+1);
		gameticks = 0;
	}
	
	if(kbhit())lastkey = cgetc();
	
	if(lastkey!=0)
	{
		stopirq(); // IRQ abmelden
		exit(0); 
	}
}

void main()
{
	clrscr();
	
	GameInit();

	// Unseren IRQ anmelden damit wir mitbekommen wann ein Frame durch war.
	// Grobes Timing darüber, für diese Art Spiele gut genug.
	startirq();

	// Hier könnte das Titelbild angezeigt werden

	// Hier könnte das Hauptmenu angezeigt werden
	gotoxy(0,0);
	cprintf("simple c64 cc65 template");

	// (Einfacher) Hauptloop
	while(1)
	{
		while(!irqhappend);
		irqhappend = 0;
		GameRun();
	}
}
