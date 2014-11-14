make clean

NDK=$HOME/stuff/work/android/android-ndk-r10
NDKABI=9


NDKVER=$NDK/toolchains/x86-4.6
NDKP=$NDKVER/prebuilt/linux-x86_64/bin/i686-linux-android-
NDKF="--sysroot $NDK/platforms/android-$NDKABI/arch-x86"
make HOST_CC="gcc -m32" CROSS=$NDKP TARGET_FLAGS="$NDKF"
cp src/libluajit.a ./bin/android/x86/libluajit.a
#mv src/libluajit.so ./bin/android/x86/libluajit.so

make clean

NDKVER=$NDK/toolchains/arm-linux-androideabi-4.6
NDKP=$NDKVER/prebuilt/linux-x86_64/bin/arm-linux-androideabi-
NDKF="--sysroot $NDK/platforms/android-$NDKABI/arch-arm"
make HOST_CC="gcc -m32" CROSS=$NDKP TARGET_FLAGS="$NDKF"
mv src/libluajit.a ./bin/android/armeabi/libluajit.a
#mv src/libluajit.so ./bin/android/armeabi/libluajit.so

make clean

NDKVER=$NDK/toolchains/arm-linux-androideabi-4.6
NDKP=$NDKVER/prebuilt/linux-x86_64/bin/arm-linux-androideabi-
NDKF="--sysroot $NDK/platforms/android-$NDKABI/arch-arm"
NDKARCH="-march=armv7-a -mfloat-abi=softfp -Wl,--fix-cortex-a8"
make HOST_CC="gcc -m32" CROSS=$NDKP TARGET_FLAGS="$NDKF $NDKARCH"
mv src/libluajit.a ./bin/android/armeabi-v7a/libluajit.a
#mv src/libluajit.so ./bin/android/armeabi-v7a/libluajit.so

make clean
