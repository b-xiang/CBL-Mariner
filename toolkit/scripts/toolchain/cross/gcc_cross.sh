# Docs used to create this script:
# https://preshing.com/20141119/how-to-build-a-gcc-cross-compiler/
# https://mdeva2.home.blog/2019/07/08/building-gcc-as-a-cross-compiler-for-raspberry-pi/
# http://jiadongsun.cc/2019/09/03/Cross_Compile_Gcc/#6-build-glibc

installDir="/opt/cross"
buildDir="$HOME/cross"
scriptDir=$(dirname "$0")

echo ${scriptDir}

sudo rm -rf ${installDir}
sudo rm -rf ${buildDir}

mkdir ${buildDir}
cd ${buildDir}

# Download source tarballs
wget http://ftp.gnu.org/gnu/binutils/binutils-2.32.tar.xz
wget https://ftp.gnu.org/gnu/gcc/gcc-9.1.0/gcc-9.1.0.tar.xz
wget https://github.com/microsoft/WSL2-Linux-Kernel/archive/linux-msft-5.4.83.tar.gz
wget https://ftp.gnu.org/gnu/glibc/glibc-2.28.tar.xz
wget http://www.mpfr.org/mpfr-4.0.1/mpfr-4.0.1.tar.gz
wget http://ftp.gnu.org/gnu/gmp/gmp-6.1.2.tar.xz
wget https://ftp.gnu.org/gnu/mpc/mpc-1.1.0.tar.gz

# Install gawk
sudo apt-get install gawk

# Unzip source tarballs
for f in *.tar*; do tar xf $f; done

cd gcc-9.1.0
ln -s ../mpfr-4.0.1 mpfr
ln -s ../gmp-6.1.2 gmp
ln -s ../mpc-1.1.0 mpc

# Patch GCC to avoid an error where PATH_MAX isn't defined
patch -p1 < "${scriptDir}/pathmax.patch"
cd ..

sudo mkdir -p ${installDir}
sudo chown vitong ${installDir}
export PATH="${installDir}/bin":$PATH

mkdir build-binutils
cd build-binutils
../binutils-2.32/configure --prefix=${installDir} --target=aarch64-linux --disable-multilib
make -j$(nproc)
make install
cd ..

cd WSL2-Linux-Kernel-linux-msft-5.4.83
make ARCH=arm64 INSTALL_HDR_PATH="${installDir}/aarch64-linux" headers_install
cd ..

mkdir -p build-gcc
cd build-gcc
../gcc-9.1.0/configure --prefix=${installDir} --target=aarch64-linux --disable-multilib --enable-shared --enable-threads=posix --enable-__cxa_atexit --enable-clocale=gnu --enable-languages=c,c++,fortran --disable-bootstrap --enable-linker-build-id  --enable-plugin --enable-default-pie
make -j$(nproc) all-gcc
make install-gcc
cd ..

mkdir -p build-glibc
cd build-glibc
../glibc-2.28/configure --prefix="${installDir}/aarch64-linux" --build=$MACHTYPE --host=aarch64-linux --target=aarch64-linux --with-headers="${installDir}/aarch64-linux/include" --disable-multilib libc_cv_forced_unwind=yes  --disable-werror
make install-bootstrap-headers=yes install-headers
make -j$(nproc) csu/subdir_lib
install csu/crt1.o csu/crti.o csu/crtn.o "${installDir}/aarch64-linux/lib"
aarch64-linux-gcc -nostdlib -nostartfiles -shared -x c /dev/null -o "${installDir}/aarch64-linux/lib/libc.so"
touch "${installDir}/aarch64-linux/include/gnu/stubs.h"
cd ..

cd build-gcc
make -j$(nproc) all-target-libgcc
make install-target-libgcc
cd ..

cd build-glibc
make -j$(nproc)
make install
cd ..

cd build-gcc
make -j$(nproc)
make install
cd ..
