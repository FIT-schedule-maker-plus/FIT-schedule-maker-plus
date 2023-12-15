#let project(title: "", year: "", author: (), logo: none, team: "", extensions: (), body) = {
  // Set the document's basic properties.
  set document(author: author.name, title: title)
  set text(font: "New Computer Modern", lang: "en")
  show math.equation: set text(weight: 400)
  set heading(numbering: "1.1.")

  v(0.6fr)
  if logo != none {
    align(center, image(logo, width: 100%))
  }

  v(1fr)

  align(center)[
      #text(2em, weight: 700, title) \
      #v(0.1fr)
      #text(1.5em, year)
      // Author information.
      #pad(
        top: 0.7em,
        right: 20%,
        left: 20%,
        grid(
          columns: (1fr,) * calc.min(2, 1),
          gutter: 3em,
          [
            #author.name \
            #author.xlogin \
          ],
        ),
      )

      #v(0.4fr)
      #text(1.2em, team)

  ]

  v(2.4fr)
  pagebreak()
  set page(numbering: "1", number-align: center)


  // Main body.
  set par(
    justify: true,
    first-line-indent: 2em,
  )

  body
}

#show: project.with(
  title: "ITU - Technická zpráva",
  year: "2023/24",
  author: (
    name: "Jakub Kloub",
    xlogin: "xkloub03",
  ),
  team: "Tým xkloub03",
)

= Téma projektu
Náš tým se zabýval webovou aplikací, která dovoluje uživateli vytvořit rozvrh na další (nebo stávající) semestr.

== Části programu
Aplikace se skládá ze čtyř hlavních částí:
- Boční menu pro vybrání předmětů
- Interakticní vytváření rozvrhu
- Zobrazení výsledného rozvrhu
- Správa různých verzí rozvrhu

= Moje část
Já jsem se hlavně věnoval _správě variant rozvrhů_, _zobrazení výsledného rozvrhu_, _export/import_ rozvrhů. Také jsem navrhul jak bude reprezentován model rozvrhu společně s variantami.

Narozdíl od návrhu, kde varianta obsahovala pouze jeden konkrétní rozvrh, obsahuje jedna varianta rozvrhy dva. Jeden pro letní semestr a druhý pro zimní. Důvodem k této změně bylo, že na základě diskuze s více studenty jsme se rozhodli mít pouze jeden exportovaný rozvrh pro celý rok.

Jedna varianta je reprezentováná přímo strukturou _Timetable_, která ukládá vybrané předměty pro oba semstry a také jméno varianty. Vytvoření samostatného modelu pro varianty jsme vyzkoušeli a po diskuzi jsme se shodli na tom že je tento model redundantní, protože jediné co k rozvrhu přidával bylo jméno. Rozhodli jsme se tedy je sjednotit.

V imlpementaci se starám o zobrazování variant rozvrhů, jejich správě, načtení z disku a export do formátu JSON nebo PNG. Také jsem implementoval obrazovku s kompletním rozvrhem a hlavní _bar_ pro navigaci aplikace (zde jsem musel spolupracovat s Matúšem pro schovální bočního menu při přepínání).

== Soubory
V rámci projektu jsem autorem těchto souborů ve složce _src/lib_:
#table(
    columns: 2,
    stroke: none,
    [*Soubor*], [*Funkcionalita*],
    [models/timetable.dart], [Reprezentace varianty rozvrhu a rozvrhu jako takového, také implementuje potřebné funkce pro export do formátu JSON.],
    [models/export_timetable.dart], [Struktura která se při exportu do JSONu použije jako nosič všech informací. Obsahuje _Timetable_ a seznam všech identifikátorů programů, které jsou v rozvrhu použity.],
    [viewmodels/timetable.dart], [Má roli viewmodelu mezi interakcí s čímkoliv co pořebuje přístup k _Timetable_ modelu a stará se o předání informací mezi nimy. Také vykonává potřebné akce, které vznikli vstupem od uživatele při interakci s rozvrhem. Ukládá a spravuje instance rozvrhů.],
    [views/complete_timetable.dart], [Jedná se o pohled, který reprezentuje již hotový rozvrh. V tomto rozvrhu se zobrazují pouze předměty, které si uživatel vybral. Také je používán jako podklad pro export do obrázkového formátu PNG při exportu. Dále si zde uživatel může zvolit jaký semestr právě upravuje v editoru rozvrhu.],
    [views/offscreen_timetable.dart], [Souží jako dočasný pohled pro uložení kompletního rozvrhu ve formátu PNG.],
    [views/tab_app_bar.dart], [Pohled zobrazující tři velká tlačítka, která přepínají mezi: _Rozpracovaným rozvrhem_, _kompletním rozvrhem_ a _správou variant_],
    [views/timetable_variants.dart], [Pohled který zobrazuje obrazovku se správou variant rozvrhů. Uživatel si zde může přidat, odebrat, přejmenovat, exportovat do PNG/JSON, importovat rozvrhy. Také si zde navolí jaká varianta je aktivní pro úpravu a jakých semestr se upravuje.],
    [disp_timetable_gen.dart], [Obsahuje algoritmus (a struktury s ním spojené) pro vygenerování speciálního druhu rozvrhu. Tento rozvrh obsahuje všechny (i nevybrané) hodiny, které se mají zorazit a přidává k nim informace o tom _jak_ se mají zobrazit. Například když je více hodin ve stejný čas, tak se mají zobrazit podsebou a mají být seskupeny u sebe podle předmětu.],
    [utils.dart], [Obsahuje funkce, které dovolují programátorovi vyvolat uložení souboru s daným obsahem (text nebo PNG).],
)
