# Display image with tput
function image() {
convert $1 -resize 40 txt:-|sed -E 's/://;s/\( ? ?//;s/, ? ?/,/g;s/\)//;s/([0-9]+,[0-9]+,[0-9]+),[0-9]+/\1/g;s/255/254/g;/mage/d'|awk '{print $1,$2}'|sed -E 's/^0,[0-9]+ /print "echo;tput setaf "\;/;s/^[0-9]+,[0-9]+ /print "tput setaf ";/;s/(.+),(.+),(.+)/\1\/42.5*36+\2\/42.5*6+\3\/42.5+16/'|bc|sed 's/$/;echo -n "  ";/'|tr '\n' ' '|sed 's/^/tput rev;/;s/; /;/g;s/$/tput sgr0;echo/'|bash
}

# Display image with escape codes
function fastimage() {
echo -e "$(convert $1 -resize $2 txt:- | sed -E 's/://;s/\( ? ?//;s/, ? ?/,/g;s/\)//;s/([0-9]+,[0-9]+,[0-9]+),[0-9]+/\1/g;s/255/254/g;/mage/d' | awk '{print $1,$2}' | sed -E 's/^0,[0-9]+ /print "#"\;/;s/^[0-9]+,[0-9]+ //;s/(.+),(.+),(.+)/\1\/42.5*36+\2\/42.5*6+\3\/42.5+16/' | bc | sed -E '/[0-9]/s/^/\\b\\e[48;5;/;s/([0-9])$/\1m\  \\e[0m/' | tr '\n' ' '|tr '#' '\n')"
}

# Play GIFs
function playgif(){
  f=$(convert $1 -resize $2 -coalesce txt:-|sed -E 's/ //g;s/#.+:([0-9]+).+/_\1/g;s/.+://;s/\(//;s/\)//;s/#.*//;s/255/254/g;s/([0-9]+,[0-9]+,[0-9]+),[0-9]+/\1/;s/_/ /'|tr '\n' 'z');
  w=$(echo ${f::3}|sed -E 's/([0-9]+).*/\1/');
  clear;
  tput civis;
  while true;
    do for i in ${f[@]}; 
      do j=($(echo $i|tr 'z' '\n'|sed -E '/^[0-9]*$/d;s/(.+),(.+),(.+)/\1\/42.5*36+\2\/42.5*6+\3\/42.5+16/'|bc)); 
        for r in $(seq 0 $w $((${#j[@]}-$w)));
          do p=($(for c in $(seq 0 $(($w-1)));
            do echo " ${j[$(($r+$c))]} ";done));
          IFS='%';
          k=$(echo ${p[@]}|sed -E 's/^/\\e[0m\\e[48;5;/;s/\ /m\ \ \\e[0m\\e[48;5;/g;s/$/m\ \ \\e[0m/');
          echo -e $k;
          unset IFS;done;tput cup 0 0;done;done
}

# Party time
function party() {
  n=16;for r in $(seq 0 $n 255); do echo "$(for c in $(seq $n); do tput setaf $(($r + $c - 1)) && echo -ne '\xE2\x98\x85 '; done)"; done
}