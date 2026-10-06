# Roblox-Elektryk ⚡

**Symulator Elektryka — prototyp 0.1.1 do Roblox Studio.**
Warsztat 3D i własna rozdzielnica każdego gracza: montaż aparatów, przewody,
sprawdzanie układu i wynagrodzenie za trzy kolejne zlecenia.

## Otwórz grę — bez Rojo i bez wklejania skryptów

1. Na stronie tego repozytorium wybierz **Code → Download ZIP**.
2. Rozpakuj ZIP na komputerze.
3. W Roblox Studio wybierz **File → Open from File…** i otwórz
   **`dist/Elektryk-0.1.1.rbxlx`**.
4. Naciśnij **Play / F5** (nie samo Run). Warsztat powstaje po uruchomieniu gry.
5. Podejdź do stołu z rozdzielnicą i użyj **E**, dotknij komunikatu stanowiska
   albo kliknij **OTWÓRZ STANOWISKO** będąc przy stole.

**Przed Play pusta scena jest oczekiwana:** pomieszczenie jest generowane przez skrypt serwera.
Nie musisz włączać HTTP ani API Services. Nie ma zewnętrznych modeli ani płatnych zasobów.

## Poprawka 0.1.1 — otwieranie stanowiska

- Bezpośrednia obsługa E, niezależna od wyświetlenia podpowiedzi nad stołem.
- Wspólny zasięg 18 studów dla podpowiedzi i kontroli serwera.
- Zielony przycisk otwierania w zasięgu i licznik odległości.
- Potwierdzenie połączenia z serwerem i komunikat o braku odpowiedzi.

Po pobraniu aktualizacji otwórz **nowy plik** `dist/Elektryk-0.1.1.rbxlx`.
Wciśnij Play/F5, kliknij w widok gry, podejdź do stołu i naciśnij E.
Plik `Elektryk-0.1.rbxlx` również zawiera poprawkę, dla zgodności ze starszym linkiem.

## Jak grać

1. Przeczytaj zlecenie pod rozdzielnicą. Numeracja pól znajduje się nad szyną.
2. Wybierz aparat po lewej i kliknij wolne pole. RCD zajmuje dwa pola.
3. Wybierz kolor przewodu, kliknij pierwszy zacisk, następnie drugi.
   Ponowne kliknięcie pierwszego zacisku anuluje wybór.
4. Zakładka **Plan połączeń** zawiera pomoc do bieżącej łamigłówki.
5. Naciśnij **TEST**. Zakładka **Wynik testu** pokazuje brakujące lub błędne połączenia.
6. Błędny przewód usuń z zakładki **Połączenia**. Aby wyjąć aparat,
   wybierz **Usuń aparat** i kliknij jego obudowę. Jego przewody też zostaną usunięte.
7. Po zaliczeniu otrzymujesz monety. Wybierz **NASTĘPNE**.
8. **Zamknij** lub klawisz **Q** wraca do spacerowania po warsztacie.

**WYCZYŚĆ** wymaga drugiego kliknięcia i usuwa nieukończony montaż.
Trzy zlecenia dają łącznie **720 monet**. Po trzecim prototyp jest ukończony.

## Zakres 0.1

- Warsztat 3D: stanowisko, rozdzielnica, półki, skrzynki części, oświetlenie.
- Widok pracy ze zbliżeniem kamery i graficznym panelem montażowym.
- 12 miejsc DIN; główny, RCD 2P, B10 i B16.
- Przewody: brązowy, czarny, szary, niebieski, żółto-zielony.
- Zlecenia: światło w garażu (150), gniazdo warsztatowe (220), mały warsztat (350).
- Weryfikacja montażu, połączeń i kolorów po stronie serwera.
- Blokada podwójnej nagrody, limit żądań, kontrola odległości od stołu.
- Oddzielny stan każdego gracza; wspólny warsztat.
- Obsługa kliknięć i dotyku; panel skaluje się do ekranu. Na telefonie preferowana orientacja pozioma.

## Świadome ograniczenia

To **uproszczona łamigłówka**, nie instrukcja wykonania rzeczywistej instalacji.
Nie symuluje prądów, zwarć, charakterystyk zabezpieczeń ani działania RCD.
Plan połączeń i dopuszczalne rozgałęzienia służą regułom gry.
Montaż odbywa się w panelu 2D na tle warsztatu 3D; fizyczny model na stole jest dekoracją.

**Monety i zlecenia są zachowywane tylko w bieżącej sesji serwera**, także po odrodzeniu postaci.
Wyjście i ponowne dołączenie rozpoczyna grę od nowa. Brak sklepu i trwałego zapisu w tej wersji.
Gotowy plik zawiera źródła, ale wymaga testu uruchomieniowego w Roblox Studio:
środowisko tworzenia tego repozytorium nie udostępnia silnika Roblox.

## Dalszy rozwój

- 0.2: zapis postępu, kolejne zlecenia, większe aparaty i rozdzielnice.
- 0.3: trójwymiarowe wkładanie aparatów i końcówek przewodów.
- 0.4: usterki, miernik w grze i rozbudowa warsztatu.

## Pliki i praca nad kodem

| Ścieżka | Zawartość |
|---|---|
| `dist/Elektryk-0.1.rbxlx` | Gotowy plik do otwarcia w Studio |
| `src/shared/Config.lua` | Części, kolory, zlecenia i plany |
| `src/shared/Rules.lua` | Reguły i sprawdzanie zleceń |
| `src/server/World.lua` | Generowanie warsztatu |
| `src/server/Main.server.lua` | Obsługa graczy i serwera |
| `src/client/Main.client.lua` | Interfejs i kamera |
| `tests/rules.test.lua` | Testy logiki niezależne od silnika |
| `docs/TESTY-STUDIO.md` | Lista testów do wykonania w Studio |

Po zmianie źródeł wygeneruj ponownie gotowy plik:

```sh
python3 tools/build_place.py
```

Na Windows: `py tools/build_place.py`. Skrypt wymaga wyłącznie Pythona 3.
Alternatywnie użyj projektu Rojo: `rojo build -o dist/Elektryk-0.1.rbxlx`
lub `rojo serve` i wtyczki Rojo w Studio.

Testy logiki (Lua 5.3+ albo `texlua`):

```sh
lua tests/rules.test.lua
```

Dokumentacja: [Roblox Studio](https://create.roblox.com/docs/studio),
[granica klient–serwer](https://create.roblox.com/docs/scripting/security/client-server-boundary),
[narzędzia zewnętrzne](https://create.roblox.com/docs/projects/external-tools).
