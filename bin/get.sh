export LC_ALL=fr_FR.UTF-8

curl https://docs.google.com/document/d/1sh-xkEMkNLGw7U8GacAPe4p6828jnDVApuIVeYb8VnI/mobilebasic > liste_complete.html

cat liste_complete.html | grep -v "DOCTYPE" | tr -d "\n" | sed 's|</p>|#|g' | sed -r 's|<style>.*</style>||g' | sed -r 's|<javascript>.*</javascript>||g'  | sed -r 's|</?[a-z]+[^<>]*>||g' | sed -r 's/^.*zapperbollore@proton\.me//' | tr '#' "\n" | grep -v "Pour signer la tribune" | grep "," | grep -v window.set | grep -v function | sed 's/^39;//' | sed -r 's/[ \t]+$//' | sed -r 's/[ ]+/ /g' | sort > /tmp/liste_complete.txt.tmp

if [ "$(md5sum /tmp/liste_complete.txt.tmp | cut -d " " -f 1)" != "$(md5sum liste_complete.txt | cut -d " " -f 1)" ]
then
  mv /tmp/liste_complete.txt.tmp liste_complete.txt
  bash bin/stats.sh
  git add liste_complete.html liste_complete.txt README.md
  git commit liste_complete.html liste_complete.txt README.md -m "Mise à jour de la liste"
else
  rm /tmp/liste_complete.txt.tmp;
fi
