python zip_assets.py
python do_build.py only_exe
rc=$?
if test $rc -eq 0 

then
  cd bin
  ./framework
  cd ..
else
  echo "\nCOMPILE ERRORS"
fi
