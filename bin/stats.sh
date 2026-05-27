echo -n > README.md

echo "<a name='haut'></a>" >> README.md

echo "# Suivi statistique de la tribune Zapper Bolloré" >> README.md
echo >> README.md

echo "[Cette page](https://wincelau.github.io/ZapperBolloreStats/) est générée automatiquement par [un script](https://github.com/wincelau/ZapperBolloreStats), elle s'occupe seulement de faire des statistiques à partir de [la liste des signataires](https://docs.google.com/document/d/1sh-xkEMkNLGw7U8GacAPe4p6828jnDVApuIVeYb8VnI/mobilebasic) de [la tribune Zapper Bolloré](https://www.liberation.fr/culture/depardon-binoche-haenel-600-professionnels-du-cinema-denoncent-lemprise-de-bollore-sur-le-septieme-art-20260511_FZW7WRBEXNDPVK5MAUTSFF6EHE)." >> README.md

echo >> README.md

echo "Dernière mis à jour : $(stat liste_complete.txt | grep Modif | cut -d " " -f 2,3 | cut -d "." -f 1
)" >> README.md

echo >> README.md

rm /tmp/zapperbollore_*

cat liste_complete.txt | sort | uniq > /tmp/zapperbollore

# Récupére les nouveaux signataires du jour

PREVIOUSCOMMIT=$(git log --oneline --until="$(date +%Y-%m-%d) 00:00:00" liste_complete.txt | head -n 1 | cut -d " " -f 1)
PREVIOUSHASH=$(git cat-file -p $(git cat-file -p $PREVIOUSCOMMIT | grep tree | cut -d " " -f 2) | grep "liste_complete.txt" | cut -d " " -f 3 | sed -r 's/^([a-z0-9]+).+$/\1/')

git cat-file -p $PREVIOUSHASH | sed -r 's/[ \t]+$//' | sed -r 's/[ ]+/ /g' | sort | uniq > /tmp/previouszapperbollore

join -t ";" -j 1 /tmp/zapperbollore /tmp/previouszapperbollore -v 1 > /tmp/newsignataires
join -t ";" -j 1 /tmp/zapperbollore /tmp/previouszapperbollore -v 2 > /tmp/oldsignataires
NBNEWSIGNATAIRE=$(echo "$(cat /tmp/newsignataires | wc -l) - $(cat /tmp/oldsignataires | wc -l)" | bc)

# Récupére les nouveaux signataires de la veille

YESTERDAYFIRSTCOMMIT=$(git log --oneline --until="$(date +%Y-%m-%d --date=yesterday) 00:00:00" liste_complete.txt | head -n 1 | cut -d " " -f 1)
YESTERDAYFIRSTHASH=$(git cat-file -p $(git cat-file -p $YESTERDAYFIRSTCOMMIT | grep tree | cut -d " " -f 2) | grep "liste_complete.txt" | cut -d " " -f 3 | sed -r 's/^([a-z0-9]+).+$/\1/')

git cat-file -p $YESTERDAYFIRSTHASH | sed -r 's/[ \t]+$//' | sed -r 's/[ ]+/ /g' | sort | uniq > /tmp/yesterdayfirstzapperbollore

YESTERDAYLASTCOMMIT=$(git log --oneline --until="$(date +%Y-%m-%d --date=yesterday) 23:59:59" liste_complete.txt | head -n 1 | cut -d " " -f 1)
YESTERDAYFLASTHASH=$(git cat-file -p $(git cat-file -p $YESTERDAYLASTCOMMIT | grep tree | cut -d " " -f 2) | grep "liste_complete.txt" | cut -d " " -f 3 | sed -r 's/^([a-z0-9]+).+$/\1/')
git cat-file -p $YESTERDAYFLASTHASH | sed -r 's/[ \t]+$//' | sed -r 's/[ ]+/ /g' | sort | uniq > /tmp/yesterdaylastzapperbollore

join -t ";" -j 1 /tmp/yesterdaylastzapperbollore /tmp/yesterdayfirstzapperbollore -v 1 > /tmp/yesterday_newsignataires
join -t ";" -j 1 /tmp/yesterdaylastzapperbollore /tmp/yesterdayfirstzapperbollore -v 2 > /tmp/yesterday_oldsignataires

YESTERDAYNBNEWSIGNATAIRE=$(echo "$(cat /tmp/yesterday_newsignataires | wc -l) - $(cat /tmp/yesterday_oldsignataires | wc -l)" | bc)

# Récupére les nouveaux signataires de l'avant veille

BEFOREYESTERDAYFIRSTCOMMIT=$(git log --oneline --until="$(date +%Y-%m-%d --date="- 2 day") 00:00:00" liste_complete.txt | head -n 1 | cut -d " " -f 1)
BEFOREYESTERDAYFIRSTHASH=$(git cat-file -p $(git cat-file -p $BEFOREYESTERDAYFIRSTCOMMIT | grep tree | cut -d " " -f 2) | grep "liste_complete.txt" | cut -d " " -f 3 | sed -r 's/^([a-z0-9]+).+$/\1/')

git cat-file -p $BEFOREYESTERDAYFIRSTHASH | sed -r 's/[ \t]+$//' | sed -r 's/[ ]+/ /g' | sort | uniq > /tmp/beforeyesterdayfirstzapperbollore

BEFOREYESTERDAYLASTCOMMIT=$(git log --oneline --until="$(date +%Y-%m-%d --date="- 2 day") 23:59:59" liste_complete.txt | head -n 1 | cut -d " " -f 1)
BEFOREYESTERDAYFLASTHASH=$(git cat-file -p $(git cat-file -p $BEFOREYESTERDAYLASTCOMMIT | grep tree | cut -d " " -f 2) | grep "liste_complete.txt" | cut -d " " -f 3 | sed -r 's/^([a-z0-9]+).+$/\1/')
git cat-file -p $BEFOREYESTERDAYFLASTHASH | sed -r 's/[ \t]+$//' | sed -r 's/[ ]+/ /g' | sort | uniq > /tmp/beforeyesterdaylastzapperbollore

join -t ";" -j 1 /tmp/beforeyesterdaylastzapperbollore /tmp/beforeyesterdayfirstzapperbollore -v 1 > /tmp/beforeyesterday_newsignataires
join -t ";" -j 1 /tmp/beforeyesterdaylastzapperbollore /tmp/beforeyesterdayfirstzapperbollore -v 2 > /tmp/beforeyesterday_oldsignataires

BEFOREYESTERDAYNBNEWSIGNATAIRE=$(echo "$(cat /tmp/beforeyesterday_newsignataires | wc -l) - $(cat /tmp/beforeyesterday_oldsignataires | wc -l)" | bc)

# Récupère les signataire par catégorie

cat bin/filtres | while read ligne; do
  TITRE=$(echo -n $ligne | cut -d ";" -f 1);
  REGEXP=$(echo -n $ligne | cut -d ";" -f 2);
  REGEXPEXCLUDE=$(echo -n $ligne | cut -d ";" -f 3);
  cat /tmp/zapperbollore | grep -Ei "$REGEXP" | grep -Eiv "$REGEXPEXCLUDE" | sort | uniq > "/tmp/zapperbollore_$TITRE"
  cat /tmp/oldsignataires | grep -Ei "$REGEXP" | grep -Eiv "$REGEXPEXCLUDE" | sort | uniq > "/tmp/oldsignataires_$TITRE"
done
cat /tmp/zapperbollore_* | sort > /tmp/zapperbollore_tous
join -t ";" -v 1 /tmp/zapperbollore /tmp/zapperbollore_tous > /tmp/zapperbollore_ZZZZAutres

echo "## Regroument des signataires par catégorie de métiers" >> README.md

echo >> README.md

echo "Ce regroupement par catégorie s'appuie sur des [règles de filtres](bin/filtres) par rapport aux professions déclarées par les signataires. Il est loin d'être parfait et il se peut que le choix de ces catégories ne soit pas judicieux et qu'il y ai des erreurs n'hésitez pas à le signaler." >> README.md

echo >> README.md

echo "||Total|Aujourd'hui|Hier|Avant-hier|" >> README.md
echo "|:-|-:|-:|-:|-:|" >> README.md
echo "|**Tous les signataires**|**$(cat /tmp/zapperbollore | sort | uniq | wc -l)**|**+$NBNEWSIGNATAIRE**|**+$YESTERDAYNBNEWSIGNATAIRE**|**+$BEFOREYESTERDAYNBNEWSIGNATAIRE**|" >> README.md
ls /tmp/zapperbollore_* | grep -v _tous | while read file; do
  echo "|$(echo -n $file | sed 's|/tmp/zapperbollore_||' | sed 's|ZZZZ||' )|[$(cat "$file" | sort | uniq | wc -l)](#$(echo -n $file | sed 's|/tmp/zapperbollore_||' | sed 's|ZZZZ||' | tr '[:upper:]' '[:lower:]' | sed 's/ /-/g' | sed 's/[\.,.]//g' )-1)|[+$(join -t ";" -j 1 "$file" /tmp/newsignataires | wc -l)](#$(echo -n $file | sed 's|/tmp/zapperbollore_||' | sed 's|ZZZZ||' | tr '[:upper:]' '[:lower:]' | sed 's/ /-/g' | sed 's/[\.,.]//g' ))|||" >> README.md
done

echo >> README.md
echo "## Derniers signataires " >> README.md
echo >> README.md
echo "$(cat /tmp/newsignataires | wc -l) nouveau(x) signataire(s) aujourd'hui" >> README.md
echo >> README.md

ls /tmp/zapperbollore_* | grep -v _tous | while read file; do
  join -t ";" -j 1 "$file" /tmp/newsignataires > /tmp/newsignatairescategorie.tmp
  OLDFILE="$(echo $file | sed 's/zapperbollore_/oldsignataires_/')"
  NBNEW=$(echo "$(cat /tmp/newsignatairescategorie.tmp | wc -l) - $(cat "$OLDFILE" | wc -l)" | bc)
  echo "### $file" | sed 's|/tmp/zapperbollore_||' | sed 's|ZZZZ||' >> README.md
  echo >> README.md
  echo '```diff' >> README.md
  echo "$NBNEW nouveau(x) signataire(s) aujourd'hui" >> README.md
  echo "# " >> README.md
  cat /tmp/newsignatairescategorie.tmp | sed 's/^/+ /' > /tmp/diffsignatairescategorie.tmp
  cat "$OLDFILE" | sed 's/^/- /' >> /tmp/diffsignatairescategorie.tmp
  cat /tmp/diffsignatairescategorie.tmp | sort >> README.md
  echo '```' >> README.md
  echo >> README.md
done

echo >> README.md
echo "## Liste complète" >> README.md
echo >> README.md

ls /tmp/zapperbollore_* | grep -v _tous | while read file; do
  echo >> README.md
  echo "### $file" | sed 's|/tmp/zapperbollore_||' | sed 's|ZZZZ||' >> README.md
  echo >> README.md
  echo '```' >> README.md
  cat "$file" | sed 's/^//' >> README.md
  echo '```' >> README.md
  echo >> README.md
  echo "[Retourner au début de la page](#haut)" >> README.md
done
