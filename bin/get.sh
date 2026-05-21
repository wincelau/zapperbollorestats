curl https://docs.google.com/document/d/1sh-xkEMkNLGw7U8GacAPe4p6828jnDVApuIVeYb8VnI/mobilebasic | tr -d "\n" | sed 's|</p>|#|g' | sed -r 's|</?[a-z]+[^<>]*>||g' | sed -r 's/^.*zapperbollore@proton\.me//' | tr '#' "\n" | grep "," | sed 's/^39;//' | sed -r 's/[ \t]+$//' | grep -v window.set | sort > liste_complete.txt

git add liste_complete.txt
git commit liste_complete.txt -m "Mise à jour de la liste"
