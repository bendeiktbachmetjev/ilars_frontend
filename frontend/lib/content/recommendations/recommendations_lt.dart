// Lithuanian original, from the clinical team's files (2026-10-31)
// "Mitybos rekomendacijos pacientams, patiriantiems porezekcinį sindromą.docx" and
// "Pratimų programa bei fizinio aktyvumo rekomendacijos iLARS pacientams.docx".
// Wording kept; only spelling and typography were fixed.
import '../../models/recommendations.dart';

const RecommendationsContent recommendationsLt = RecommendationsContent(
  diet: DietContent(
    title:
        'Mitybos rekomendacijos pacientams, kuriems po tiesiosios žarnos pašalinimo pasireiškia porezekcinis tiesiosios žarnos sindromas',
    intro: [
      'Po tiesiosios žarnos pašalinimo pacientai gali susidurti su dažnu tuštinimusi, skubiu noru tuštintis, išmatų nelaikymu ar dujų kontrolės sutrikimais. Tinkamai parinkti maisto produktai bei patiekalai ir individualiai pritaikyta mityba yra vienas svarbiausių įrankių, padedančių sušvelninti nemalonius simptomus.',
      'Pateikiame bendrąsias mitybos rekomendacijas, o taip pat suskirstytas pagal pagrindines maisto produktų grupes.',
    ],
    generalTitle: 'Bendrosios mitybos rekomendacijos',
    generalTips: [
      RecTip(
        id: 'general.portions',
        title: 'Valgykite dažnai, bet mažomis porcijomis.',
        detail:
            'Vietoj 3 didelių valgymų per dieną rinkitės 5–6 nedidelius valgymus. Tai padeda tolygiai paskirstyti maisto srautą per virškinamąjį traktą ir sumažina žarnyno apkrovą.',
      ),
      RecTip(
        id: 'general.chew',
        title: 'Labai gerai sukramtykite maistą.',
        detail:
            'Virškinimas prasideda burnoje. Gerai sukramtytas maistas lengviau pasisavinamas ir mažiau dirgina virškinamąjį traktą.',
      ),
      RecTip(
        id: 'general.fluids',
        title:
            'Negerkite didelių kiekių skysčių valgio metu, bet gerkite pakankamai skysčių tarp valgymų.',
        detail:
            'Skysčiai pagreitina maisto judėjimą žarnyne, todėl juos gerkite praėjus 30–60 minučių po valgio.',
      ),
      RecTip(
        id: 'general.diary',
        title: 'Veskite maisto dienoraštį.',
        detail:
            'Kiekvieno žmogaus organizmo reakcija yra individuali. Užsirašykite, kokius produktus vartojote ir kaip jautėtės – tai padės lengviau identifikuoti produktus, kurie jums tinkamiausi.',
      ),
    ],
    groupsTitle: 'Maisto produktų grupės',
    groups: [
      FoodGroup(
        id: 'meat',
        title: 'Mėsa, žuvis, kiaušiniai, paukštiena',
        subtitle: 'Visaverčių baltymų šaltinis',
        intro:
            'Baltymai yra būtini organizmo atsigavimui po operacijos, tačiau renkantis mėsą svarbu atsižvelgti į jos riebumą ir paruošimo būdą.',
        advice: [
          FoodAdvice(
            id: 'meat.rec',
            level: RecLevel.recommended,
            text:
                'Liesa mėsa – vištiena, kalakutiena, liesa jautiena, taip pat balta žuvis bei virti kiaušiniai.',
            note:
                'Maistą geriau virti, troškinti arba kepti orkaitėje be riebalų pertekliaus.',
          ),
          FoodAdvice(
            id: 'meat.limit',
            level: RecLevel.limit,
            text:
                'Riebios mėsos – kiaulienos, riebių dešros gaminių, rūkytos, sūdytos ar stipriai apdorotos mėsos.',
            note:
                'Riebus maistas skatina žarnyno peristaltiką ir gali sukelti viduriavimą.',
          ),
        ],
      ),
      FoodGroup(
        id: 'grains',
        title: 'Duona, kruopos, makaronai',
        subtitle: 'Stambiamolekulinių angliavandenių šaltinis',
        intro:
            'Angliavandeniai suteikia energijos, tačiau didelis skaidulinių medžiagų kiekis nerekomenduotinas, nes gali sustiprinti porezekcinio tiesiosios žarnos sindromo nemalonius pojūčius.',
        advice: [
          FoodAdvice(
            id: 'grains.rec',
            level: RecLevel.recommended,
            text:
                'Balti ryžiai, avižinė košė, manų kruopos, balta duona ar neriebūs sausainiai (ypatingai pirmaisiais mėnesiais po operacijos arba paūmėjimų metu).',
            note:
                'Šie produktai padeda sutirštinti išmatas ir sulėtina žarnyno peristaltiką.',
          ),
          FoodAdvice(
            id: 'grains.limit',
            level: RecLevel.limit,
            text:
                'Viso grūdo produktų, ruginės duonos, sėlenų ir nesmulkintų grūdų.',
            note:
                'Nors skaidulos sveikatai yra naudingos, netirpios skaidulos greitina žarnyno veiklą, todėl pradžioje didesnį kiekį skaidulų turinčių produktų reikėtų vengti, o vėliau riboti.',
          ),
        ],
      ),
      FoodGroup(
        id: 'produce',
        title: 'Vaisiai ir daržovės',
        intro:
            'Daržovės ir vaisiai aprūpina organizmą vitaminais, tačiau kai kurie iš jų gali sukelti dujų kaupimąsi ir pilvo pūtimą.',
        advice: [
          FoodAdvice(
            id: 'produce.rec',
            level: RecLevel.recommended,
            text:
                'Virtos, troškintos arba keptos daržovės be odelių ir sėklų (pvz., morkos, cukinijos, moliūgai). Iš vaisių tinka bananai, kepti obuoliai be odelių.',
            note: 'Bananai yra ypač naudingi, nes padeda surišti išmatas.',
          ),
          FoodAdvice(
            id: 'produce.limit',
            level: RecLevel.limit,
            text:
                'Žalių daržovių, ypač brokolių, Briuselio kopūstų, žiedinių kopūstų, šviežių ir raugintų kopūstų, taip pat svogūnų, česnakų, ankštinių kultūrų (pupelių, pupuolių, lęšių, avinžirnių, žirnių), porų, ridikėlių bei citrusinių vaisių, kurie gali dirginti žarnyno gleivinę.',
          ),
        ],
      ),
      FoodGroup(
        id: 'dairy',
        title: 'Pieno produktai',
        intro:
            'Pieno produktai gali būti sunkiai virškinami, nes po operacijų ar gydymo dažnai laikinai sumažėja laktozės toleravimas.',
        advice: [
          FoodAdvice(
            id: 'dairy.rec.fermented',
            level: RecLevel.recommended,
            text:
                'Rauginti pieno produktai (natūralus jogurtas, kefyras, pasukos) nedideliais kiekiais.',
            note:
                'Juose esančios gerosios bakterijos palaiko žarnyno mikrobiotos gyvybingumą.',
          ),
          FoodAdvice(
            id: 'dairy.rec.alternatives',
            level: RecLevel.recommended,
            text:
                'Taip pat galima rinktis laktozės neturinčius produktus arba kietuosius sūrius.',
          ),
          FoodAdvice(
            id: 'dairy.limit',
            level: RecLevel.limit,
            text: 'Didelio riebumo pieno ir saldžių grietinėlės produktų.',
          ),
        ],
      ),
      FoodGroup(
        id: 'fats',
        title: 'Riebalai ir aliejai',
        advice: [
          FoodAdvice(
            id: 'fats.rec',
            level: RecLevel.recommended,
            text: 'Alyvuogių, sėmenų aliejai.',
            note: 'Patariama juos vartoti mažais kiekiais prie patiekalų.',
          ),
          FoodAdvice(
            id: 'fats.limit',
            level: RecLevel.limit,
            text:
                'Sviestas, margarinas, taukai, riebūs padažai, majonezas, greitas maistas ir gruzdinti patiekalai.',
            note: 'Jie lėtina virškinimą arba sukelia staigų viduriavimą.',
          ),
        ],
      ),
      FoodGroup(
        id: 'drinks',
        title: 'Gėrimai ir prieskoniai',
        advice: [
          FoodAdvice(
            id: 'drinks.rec',
            level: RecLevel.recommended,
            text: 'Negazuotas vanduo, silpna juodoji ar žolelių arbata.',
            note: 'Gėrimai turi būti kambario temperatūros.',
          ),
          FoodAdvice(
            id: 'drinks.limit.caffeine',
            level: RecLevel.limit,
            text:
                'Kofeino turinčių gėrimų (stiprios kavos, juodosios arbatos, energinių gėrimų), alkoholio.',
            note:
                'Kofeinas ir angliarūgštė aktyvina žarnyno motoriką ir skatina skubų norą tuštintis.',
          ),
          FoodAdvice(
            id: 'drinks.limit.juice',
            level: RecLevel.limit,
            text: 'Vaisių sulčių (ypač citrusinių vaisių, slyvų, obuolių).',
            note: 'Dėl didelio fruktozės ir rūgščių kiekio.',
          ),
          FoodAdvice(
            id: 'drinks.limit.spices',
            level: RecLevel.limit,
            text:
                'Aštrių prieskonių, čili pipirų, aitriosios paprikos, krienų, garstyčių.',
          ),
        ],
      ),
      FoodGroup(
        id: 'sugar',
        title: 'Cukrus ir saldumynai',
        advice: [
          FoodAdvice(
            id: 'sugar.limit.sugar',
            level: RecLevel.limit,
            text: 'Cukrus, medus, uogienės.',
            note:
                'Didelis cukraus kiekis pritraukia vandenį į žarnyną ir gali sukelti viduriavimą.',
          ),
          FoodAdvice(
            id: 'sugar.limit.sweets',
            level: RecLevel.limit,
            text: 'Šokoladas, konditerijos gaminiai, pyragaičiai.',
          ),
          FoodAdvice(
            id: 'sugar.limit.sweeteners',
            level: RecLevel.limit,
            text:
                'Produktų, sudėtyje turinčių dirbtinių saldiklių (sorbitolio, ksilitolio, manitolio).',
            note:
                'Jų dažnai būna kramtomojoje gumoje, saldumynuose be cukraus – jie pasižymi stipriu laisvinamuoju poveikiu.',
          ),
        ],
      ),
      FoodGroup(
        id: 'fatty',
        title: 'Riebus ir perdirbtas maistas',
        advice: [
          FoodAdvice(
            id: 'fatty.avoid.fried',
            level: RecLevel.avoid,
            text:
                'Gruzdintas ir riebaluose keptas maistas (bulvytės fri, kepsniai tešloje ir kt.).',
          ),
          FoodAdvice(
            id: 'fatty.avoid.meats',
            level: RecLevel.avoid,
            text:
                'Riebūs mėsos gaminiai – lašiniai, riebi kiauliena, riebios dešros, rūkyti mėsos gaminiai.',
          ),
          FoodAdvice(
            id: 'fatty.avoid.sauces',
            level: RecLevel.avoid,
            text: 'Riebūs padažai – majonezas, pirktiniai padažai su priedais.',
          ),
        ],
      ),
    ],
    reintroduction: RecTip(
      id: 'reintroduction',
      title: 'Produktų grąžinimas į mitybą',
      detail:
          'Atsisakytų bei ribojamų produktų sąrašą laikui bėgant galima mėginti siaurinti: praėjus keliems mėnesiams po operacijos, po vieną produktą labai mažais kiekiais galima bandyti grąžinti į racioną. Jei per 24 valandas porezekcinio sindromo simptomai nesustiprėja, produktą galima palikti mityboje.',
    ),
  ),
  exercise: ExerciseContent(
    title:
        'Pratimų programa bei fizinio aktyvumo rekomendacijos iLARS pacientams',
    goalsTitle: 'Programos tikslai',
    goals: [
      RecTip(
        id: 'goal.activity',
        title: 'Užtikrinti fizinį aktyvumą.',
        detail:
            'Siekiamybė – pasiekti 150–300 min. savaitinio fizinio aktyvumo vaikščiojimu pagal PSO rekomendacijas.',
      ),
      RecTip(
        id: 'goal.pelvic',
        title: 'Pagerinti dubens dugno raumenų funkciją.',
      ),
    ],
    sections: [
      ExerciseSection(
        id: 'activity',
        title: 'Fizinis aktyvumas',
        exercises: [
          Exercise(
            id: 'walk',
            title: 'Terapinis ėjimas (terenkūras)',
            numbered: false,
            dose: ['Bent 20–\u206030\u00a0min. per dieną'],
            steps: [
              'Vaikščioti lauke.',
              'Svarbu, kad pasirinktas ėjimo tempas reikalautų pastangų, jo metu padažnėtų kvėpavimas.',
              'Esant galimybei renkamės lipimą laiptais, nevažiuojame liftu.',
            ],
          ),
        ],
      ),
      ExerciseSection(
        id: 'training',
        title: 'Specializuota treniruotė',
        badge: 'apie 30\u00a0min.',
        exercises: [
          Exercise(
            id: 'squat',
            title: 'Modifikuotas pritūpimas nuo kėdės',
            dose: [
              '3 serijos po 10–\u206015\u00a0kartų',
              'Poilsis tarp serijų 60–\u206090\u00a0sek.',
            ],
            steps: [
              'Naudoti tvirtą, stabilią kėdę be ratų.',
              'Sėstis ant kėdės iš lėto ir kontroliuojamai.',
              'Atsistoti nuo kėdės, keliai tiesūs.',
              'Stojantis išlaikome nugarą tiesią.',
              'Jeigu sunku – naudoti kėdę su aukštesne sėdyne arba leidžiama rankomis remtis į kėdės turėklus.',
            ],
          ),
          Exercise(
            id: 'adductor',
            title:
                'Adduktorių (vidinės šlaunies raumenų grupės) stiprinimo pratimai',
            dose: ['3 serijos po 10–\u206015\u00a0kartų'],
            steps: [
              'Atliekami su kamuoliuku arba tam skirtu treniruokliu („priemone“).',
              'Kontroliuojamai suspausti priemonę tarp kelių, išlaikyti suspaudimą 2–3 sek., tada lėtai atleisti.',
              'Galima atlikti gulint ant nugaros arba sėdint.',
              'Judesys privalo būti kontroliuojamas, vengti trūkčiojimo bei stanginimosi.',
            ],
          ),
          Exercise(
            id: 'massage',
            title: 'Vidinės kulkšnies srities savimasažas ir/arba volavimas',
            steps: [
              'Masažuojama abiejų kojų blauzdos vidinės kulkšnelės sritis, kur blauzdinis nervas yra arti odos paviršiaus.',
              'Naudojamas masažo volelis, kietas kamuoliukas arba rankos.',
              'Sukamais judesiais masažuoti vidinę kulkšnelės sritį (blauzdinis nervas čia praeina arti odos).',
              'Jei jaučiamas dilgčiojimas ar skausmas – mažiname masažo spaudimą.',
            ],
          ),
          Exercise(
            id: 'kegel',
            title: 'Kegelio pratimai',
            requiresUnlock: true,
            dose: [
              'Mažiausiai 60 kartų per parą (3\u00a0kartus\u00a0po\u00a020)',
              'Rekomenduotina 120 kartų per parą (3\u00a0kartus\u00a0po\u00a040)',
            ],
            steps: [
              'Sutraukti dubens dugno raumenis iki 50 % maksimalaus raumenų sutraukimo ir išlaikyti 10 sekundžių. Jei neišlaikoma 10 s, laikyti trumpiau, bet tikslas – išlaikyti 10 s.',
              'Atliekame gulint ant nugaros arba sėdint.',
              'Po kiekvienos Kegelio pratimų sesijos 2–3 minutes atliekami diafragminio kvėpavimo pratimai.',
            ],
          ),
        ],
      ),
    ],
  ),
);
