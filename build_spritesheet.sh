# !sh


#rm jumpz/assets/data/sheet.png
#rm jumpz/assets/data/sheet.txt
rm ../bounce/data/sheet.png
rm ../bounce/data/sheet.txt
cd ../bounce/data
mono ../../framework/tools/sprite_packer/sspack/bin/Debug/sspack.exe /image:sheet.png /map:sheet.txt *.png
cd ../../framework
