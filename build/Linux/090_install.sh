#!/bin/bash

SYSROOT=$STANDALONE_TOOLCHAIN/sysroot

SWIFT_INCLUDE=$SWIFT_INSTALL/usr/lib/swift/
SWIFT_LIB=$SWIFT_INCLUDE/android/
SWIFT_MODULE=$SWIFT_LIB/armv7/

# foundation dependencies
rsync -av $SYSROOT/usr/lib/libxml2.* $SWIFT_LIB
cp -r $SYSROOT/src/libxml2/include/libxml $SWIFT_INCLUDE

rsync -av $SYSROOT/usr/lib/libcurl.* $SWIFT_LIB
cp -r $SYSROOT/src/curl/include/curl $SWIFT_INCLUDE

rsync -av $ANDROID_NDK_HOME/sources/cxx-stl/llvm-libc++/libs/armeabi-v7a/libc++_shared.so $SWIFT_LIB

# foundation
rsync -av $SWIFT_BUILD/foundation-linux-x86_64/Foundation/libFoundation.so $SWIFT_LIB
rsync -av $SWIFT_BUILD/foundation-linux-x86_64/Foundation/usr/lib/swift/CoreFoundation $SWIFT_INCLUDE
rsync -av $SWIFT_BUILD/foundation-linux-x86_64/Foundation/Foundation.swift* $SWIFT_MODULE

# xctest
rsync -av $SWIFT_BUILD/xctest-linux-x86_64/libXCTest.so $SWIFT_LIB
rsync -av $SWIFT_BUILD/xctest-linux-x86_64/XCTest.swift* $SWIFT_MODULE

# icu
rsync -av $LIBICONV_ANDROID/armeabi-v7a/libicu{uc,i18n,data}.so $SWIFT_LIB
cp -r $LIBICONV_ANDROID/armeabi-v7a/include/unicode $SWIFT_INCLUDE

for i in $SWIFT_LIB/libicu*.so
do 
    $ANDROID_NDK_HOME/toolchains/arm-linux-androideabi-4.9/prebuilt/linux-x86_64/arm-linux-androideabi/bin/strip $i
    mv $i ${i/libicu/libscu}
done

rpl -R -e libicu libscu $SWIFT_INSTALL/usr/lib/swift/android/lib*.so &&

cp -rf ./libiconv-libicu-android/armeabi-v7a/lib/pkgconfig swift-install
sed -i -e 's@-licu@-lscu@g' swift-install/pkgconfig/*.pc
rm -f swift-install/pkgconfig/*.pc.tmp

# bundle ndk
mkdir -p $SWIFT_INSTALL/ndk-android-21/usr
rsync -av $ANDROID_NDK_HOME/platforms/android-21/arch-arm/usr/{include,lib} $SWIFT_INSTALL/ndk-android-21/usr

# copy to host
mkdir -p /vagrant/out

rsync -av $ANDROID_NDK_HOME/ /vagrant/out/ndk
rsync -av $LIBICONV_ANDROID /vagrant/out/
rsync -av $SWIFT_INSTALL /vagrant/out/
rsync -av $SWIFT_SOURCE /vagrant/out/ --exclude build