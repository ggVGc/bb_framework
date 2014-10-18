NDK=$HOME/stuff/work/android/android-ndk-r10
NDKABI=9


#NDKVER=$NDK/toolchains/x86-4.6
#NDKP=$NDKVER/prebuilt/linux-x86_64/bin/i686-linux-android-
#NDKF="--sysroot $NDK/platforms/android-$NDKABI/arch-x86"
#make HOST_CC="gcc -m32" CROSS=$NDKP TARGET_FLAGS="$NDKF"

NDKVER=$NDK/toolchains/arm-linux-androideabi-4.6
NDKP=$NDKVER/prebuilt/linux-x86_64/bin/arm-linux-androideabi-
NDKF="--sysroot $NDK/platforms/android-$NDKABI/arch-arm"
NDKARCH="-march=armv7-a -mfloat-abi=softfp -Wl,--fix-cortex-a8"
make HOST_CC="gcc -m32" CROSS=$NDKP TARGET_FLAGS="$NDKF $NDKARCH"
