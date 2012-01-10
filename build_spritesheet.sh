# !sh


#rm jumpz/assets/data/sheet.png
#rm jumpz/assets/data/sheet.txt
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
p=$1
rm $p/data/sheet.png
rm $p/data/sheet.txt
cd $p/data
mono $DIR/tools/sprite_packer/sspack/bin/Debug/sspack.exe /image:sheet.png /map:sheet.txt *.png
cd $DIR
