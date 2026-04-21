# Inlämningsuppgift 1

**Namn:** Alexander Herder, alhe5785 (Enmansgrupp)
**Grupp:** 04
**Kurs:** Artificiell Intelligens, AIVT2026, IB582N

## Projektbeskrivning
Detta projekt är en visuell simulering av en autonom agent (en tank) som patrullerar en 2D-spelvärld. När agenten upptäcker en fiende med sina kamerasensorer, måste den räkna ut den kortaste och säkraste vägen (vägen med lägst antal hinder) tillbaka till sin hembas för att rapportera händelsen. 

Simuleringen demonstrerar och jämför två olika heuristiska vägvalsagoritmer (pathfinding) för att hantera statiska hinder (träd):

* **A\* (A-Star)**
* **Greedy Best-First Search (GBFS)**

## Krav och Förutsättningar
Programmet är skrivet i Java och bygger på ramverket **Processing**. Inga externa tredjepartsbibliotek utöver Processing Core krävs.

För att köra programmet behövs **Processing IDE**, alternativt en annan IDE med Processing installerat som ramverk. Används en annan IDE kan dock instruktionerna för testkörning inte garanteras att vara samma som nedan specificerat.

Eftersom programmet körs via Processing är det plattformsoberoende och kan köras på Windows, Linux och Mac.

## Instruktioner för testkörning (Körbarhet)
För att starta och testa systemet, följ dessa steg:

1. Packa upp `.zip`-arkivfilen så att alla filer ligger i samma projektmapp.
2. Öppna huvudfilen `tanks.pde` i **Processing IDE**.
3. **VIKTIGT:** Kontrollera att undermappen `data` ligger direkt i projektets rotkatalog (samma plats som `.pde`-filerna). Inuti `data`-mappen måste bildfilen `tree01_v2.png` finnas. Om strukturen ändras kommer programmet att kasta en `NullPointerException`.
4. Klicka på **Run** (Spela-knappen) uppe till vänster i Processing.

## Styrning och Interaktion
När programmet startar är simuleringen **pausad**. Använd tangentbordet för att interagera med och styra AI-agentens logik:

* **`1`** : Välj och starta sökning med **A\* (A-Star)**. Algoritmen tar hänsyn till både sträckans kostnad hittills ($g(n)$) och uppskattat avstånd till mål ($h(n)$). (Startar automatiskt simuleringen).
* **`2`** : Välj och starta sökning med **Greedy Best-First Search (GBFS)**. Algoritmen navigerar enbart utifrån uppskattat avstånd till mål ($h(n)$). (Startar automatiskt simuleringen).
* **`p`** : Pausa eller återuppta simuleringen manuellt.

## Övriga kommentarer
Systemet exekverar och slutför sin uppgift utan krascher. När hela världen är upptäckt så övergår agenten till ett "idle-läge" där den roterar på plats tills användaren avslutar programmet.