# Inlämningsuppgift 2

**Namn:** Alexander Herder, alhe5785 (Enmansgrupp)
**Grupp:** 04
**Kurs:** Artificiell Intelligens, AIVT2026, IB582N

## Projektbeskrivning
Detta projekt är en visuell simulering av ett multi-agentsystem där två lag av autonoma stridsvagnar (tanks) möts i en kompetitiv och partiellt observerbar miljö. Syftet med simuleringen är att undersöka och mäta hur explicit kommunikation påverkar lagets förmåga till koordination och totala nytta (utility).
Simuleringen demonstrerar och jämför två olika AI-strategier för beslutsfattande:

* **Oberoende Knowledge-Based Agents** - Agenterna agerar helt isolerat utifrån sina egna sensorer och delar ingen information med sina lagkamrater.
* **Kooperativ Multi-Agent Planning** - Agenterna använder en delad datastruktur för att kommunicera fiendepositioner och utföra koordinerade anfall med hjälp av modifierad A*-sökning.

## Krav och Förutsättningar
Programmet är skrivet i Java och bygger på ramverket **Processing**. Inga externa tredjepartsbibliotek utöver Processing Core krävs.

För att köra programmet behövs **Processing IDE**, alternativt en annan IDE med Processing installerat som ramverk. Används en annan IDE kan dock instruktionerna för testkörning inte garanteras att vara samma som nedan specificerat.

Eftersom programmet körs via Processing är det plattformsoberoende och kan köras på Windows, Linux och macOS.

## Instruktioner för testkörning (Körbarhet)
För att starta och testa systemet, följ dessa steg:

1. Packa upp `.zip`-arkivfilen så att alla filer ligger i samma projektmapp.
2. Öppna huvudfilen `tanks.pde` i **Processing IDE**.
3. **VIKTIGT:** Kontrollera att undermappen `data` ligger direkt i projektets rotkatalog (samma plats som `.pde`-filerna). Inuti `data`-mappen måste bildfilen `tree01_v2.png` finnas. Om strukturen ändras kommer programmet att kasta en `NullPointerException`.
4. Klicka på **Run** (Spela-knappen) uppe till vänster i Processing.

## Styrning och Interaktion
När programmet startar är simuleringen **pausad**. Använd tangentbordet för att interagera med och styra AI-agentens logik:

* **`1`** : Starta simuleringen där lagen spelar asymmetriskt (Röda laget använder lokal kunskap, Blåa laget använder Shared Intel).
* **`2`** : Starta simuleringen där lagen spelar symmetriskt (Båda lagen använder Shared Intel).
* **`p`** : Pausa eller återuppta simuleringen manuellt.

## Övriga kommentarer
Simuleringen är inställd på att automatiskt avslutas efter 3 minuter (180 000 ms).

Vid symmetriska möten (där båda lagen använder Shared Intel) är det förväntat att systemet ibland hamnar i ett defensivt dödläge där tanksen roterar i sina baser tills tiden rinner ut. Detta diskuteras i detalj i den bifogade dokumentationen.