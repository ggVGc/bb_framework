#cd ../../
#./zip_assets.py -s $1 && ./gen_c_resources.py $1
#cd -
export NDK_DEBUG=1
ndk-build 2> buildoutput.txt && ./build.py



