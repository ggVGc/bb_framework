cd ../../
./zip_assets.py -s && ./gen_c_resources.py
cd -
export NDK_DEBUG=1
ndk-build 2> buildoutput.txt && ./build.py



