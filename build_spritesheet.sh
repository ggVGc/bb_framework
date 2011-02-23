rm jumpz/assets/data/sheet.png
rm jumpz/assets/data/sheet.txt
cd jumpz/assets/data/
mono ../../../tools/sprite_packer/sspack/bin/Debug/sspack.exe /image:sheet.png /map:sheet.txt *.png
cd ../../..
