echo -n > README.md

echo "<a name='haut'></a>" >> README.md

echo "# Statistiques des signataires de la tribune Zapper Bolloré" >> README.md
echo >> README.md


echo "Cette page est générée automatiquement par un robot, elle s'occupe seulement de faire des statistiques à partir de [la liste des signataires à la tribune Zapper Bolloré](https://docs.google.com/document/d/1sh-xkEMkNLGw7U8GacAPe4p6828jnDVApuIVeYb8VnI/mobilebasic)" >> README.md

echo >> README.md

rm /tmp/zapperbollore_*

cat liste_complete.txt | sort | uniq > /tmp/zapperbollore

git cat-file -p 42c7f118af896be237575b4e30ce0766b424892 | sed -r 's/[ \t]+$//' | sed -r 's/[ ]+/ /g' | sort | uniq > /tmp/previouszapperbollore

join -t ";" -j 1 /tmp/zapperbollore /tmp/previouszapperbollore -v 1 > /tmp/newsignataires

cat bin/filtres | while read ligne; do
  TITRE=$(echo -n $ligne | cut -d ";" -f 1);
  REGEXP=$(echo -n $ligne | cut -d ";" -f 2);
  REGEXPEXCLUDE=$(echo -n $ligne | cut -d ";" -f 3);
  cat /tmp/zapperbollore | grep -Ei "$REGEXP" | grep -Eiv "$REGEXPEXCLUDE" | sort | uniq > "/tmp/zapperbollore_$TITRE"
done
cat /tmp/zapperbollore_* | sort > /tmp/zapperbollore_tous
join -t ";" -v 1 /tmp/zapperbollore /tmp/zapperbollore_tous > /tmp/zapperbollore_ZZZZAutres

echo "## Regroument des signataires par catégorie de métier" >> README.md

echo >> README.md

echo "Ce regroupement par catégorie s'appuie sur des [règles de filtres](bin/filtres) par rapport aux professions déclarées par les signataires. Il est loin d'être parfait et il se peut que le choix de ces catégories ne soit pas judicieux et qu'il y ai des erreurs n'hésitez pas à le signaler." >> README.md

echo >> README.md

echo "|**Nombre de signataires total**|**$(cat /tmp/zapperbollore | sort | uniq | wc -l)**|" >> README.md
echo "|:-|-:|" >> README.md
ls /tmp/zapperbollore_* | grep -v _tous | while read file; do
  echo "|$(echo -n $file | sed 's|/tmp/zapperbollore_||' | sed 's|ZZZZ||' )|[$(cat "$file" | sort | uniq | wc -l)](#$(echo -n $file | sed 's|/tmp/zapperbollore_||' | sed 's|ZZZZ||' | tr '[:upper:]' '[:lower:]' | sed 's/ /-/g' | sed 's/[\.,.]//g' ))|" >> README.md
done

echo "## Derniers signataires" >> README.md

echo >> README.md
echo '```diff' >> README.md
echo "# $(cat /tmp/newsignataires | wc -l) nouveau(x) signataire(s)" >> README.md
echo >> README.md
cat /tmp/newsignataires | sed 's/^/+ /' >> README.md
echo '```' >> README.md
echo >> README.md

ls /tmp/zapperbollore_* | grep -v _tous | while read file; do
  echo >> README.md
  echo "## $file" | sed 's|/tmp/zapperbollore_||' | sed 's|ZZZZ||' >> README.md
  echo >> README.md
  echo '```diff' >> README.md
  echo "# $(join -t ";" -j 1 "$file" /tmp/newsignataires | wc -l) nouveau(x) signataire(s)" >> README.md
  echo >> README.md
  join -t ";" -j 1 "$file" /tmp/newsignataires | sed 's/^/+ /' >> README.md
  echo '```' >> README.md
  echo >> README.md
  echo '```' >> README.md
  cat "$file" | sed 's/^//' >> README.md
  echo '```' >> README.md
  echo >> README.md
  echo "[Retourner au début de la page](#haut)" >> README.md
done
