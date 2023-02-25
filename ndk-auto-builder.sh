#!/bin/bash


# Exit after error
set -e -o pipefail -u


# Global Variables

# NDK path(manual)
NDK_PATH=""

# Toolchain(automatic)
TOOLCHAIN="/toolchains/llvm/prebuilt/linux-x86_64"

# Project name(automatic)
PROJECT_NAME=""

# Project version(automatic)
PROJECT_VERSION=""

# Project root path(automatic)
PROJECT_ROOT_PATH=""

# Build path(manual)
BUILD_PATH=""

# Build install path(manual)
BUILD_PREFIX_PATH=""

# Build system(automatic)
BUILD_SYSTEM=""

# Build architecture(manual arg: aarch64, arm, i686, x86_64 or all)
ARCH="aarch64"

# Android API level(manual)
API="24"

# Pkg config binary path(manual)
PKG_CONFIG_PATH="/usr/bin/pkg-config"

# Pkg config library path(manual)
PKG_CONFIG_LIBPATH=""


BUILD_SYSTEM=""
TARGET=""
NDK_ABI=""
ABI=""
CPU_FAMILY=""
CPU=""
BUILD_ARCH=""

BUILD_SYSTEMS=""

AR=""
CC=""
AS=""
CXX=""
LD=""
RANLIB=""
STRIP=""
OBJCOPY=""
OBJDUMP=""
READELF=""
NM=""
CXXFILT=""



# Functions

# Print
puts ()
{
    echo -e "$1"
}

# Check projecf info
check_project_info ()
{
    puts "\nProject Name: ${PROJECT_NAME}"
    puts "Project Version: ${PROJECT_VERSION}"
    puts "Project Path: ${PROJECT_ROOT_PATH}"
    puts "Build System: ${BUILD_SYSTEMS}"
}

# Meson cross
meson_cross ()
{
cat <<EOF > ${PROJECT_ROOT_PATH}/meson-android-cross.ini
[binaries]
c         = '${NDK_PATH}${TOOLCHAIN}/bin/${i}${API}-clang'
cpp       = '${NDK_PATH}${TOOLCHAIN}/bin/${i}${API}-clang++'
ar        = '${NDK_PATH}${TOOLCHAIN}/bin/llvm-ar'
as        = '${NDK_PATH}${TOOLCHAIN}/bin/llvm-as'
ranlib    = '${NDK_PATH}${TOOLCHAIN}/bin/llvm-ranlib'
ld        = '${NDK_PATH}${TOOLCHAIN}/bin/ld'
strip     = '${NDK_PATH}${TOOLCHAIN}/bin/llvm-strip'
cmake     = 'cmake'
pkgconfig = ['env', 'PKG_CONFIG_LIBDIR=${PKG_CONFIG_LIBPATH}', '${PKG_CONFIG_PATH}']

[host_machine]
system = 'android'
cpu_family = '${CPU_FAMILY}'
cpu = '${CPU}'
endian = 'little'
EOF
}

# Create meson config
create_meson_config ()
{
# Create config file
puts "\nCreate config file to project root path"
puts "Create build-config-var.sh"
cat <<EOF > ${PROJECT_ROOT_PATH}/build-config-var.sh
#!/bin/bash


# NDK path(manual)
NDK_PATH="${NDK_PATH}"

# Toolchain(automatic)
TOOLCHAIN="${TOOLCHAIN}"

# Project name(automatic)
PROJECT_NAME="${PROJECT_NAME}"

# Project version(automatic)
PROJECT_VERSION="${PROJECT_VERSION}"

# Project root path(automatic)
PROJECT_ROOT_PATH="${PROJECT_ROOT_PATH}"

# Build install path(manual)
BUILD_PREFIX="${BUILD_PREFIX}"

# Build System(automatic)
BUILD_SYSTEM="${BUILD_SYSTEM}"

# Build Architecture(manual arg: aarch64, arm, i686, x86_64 or all)
ARCH="${ARCH}"

# Android API Level(manual)
API="${API}"

# Pkg config binary path(manual)
PKG_CONFIG_PATH="${PKG_CONFIG_PATH}"
EOF

puts "Create build-config.sh"
cat <<"EOF" > ${PROJECT_ROOT_PATH}/build-config.sh
#!/bin/bash


# Start build
puts "\nStart build"
puts "Build System: ${BUILD_SYSTEM}"


cd ${PROJECT_ROOT_PATH}

for i in ${TARGET[@]}
do
    case ${i} in
        aarch64-linux-android)
            BUILD_ARCH="aarch64"
            NDK_ABI="aarch64-linux-android"
            CPU_FAMILY="aarch64"
            CPU="aarch64"
        ;;
        armv7a-linux-androideabi)
            BUILD_ARCH="arm"
            NDK_ABI="arm-linux-androideabi"
            CPU_FAMILY="arm"
            CPU="armv7"
        ;;
        i686-linux-android)
            BUILD_ARCH="i686"
            NDK_ABI="i686-linux-android"
            CPU_FAMILY="x86"
            CPU="i686"
        ;;
        x86_64-linux-android)
            BUILD_ARCH="x86_64"
            NDK_ABI="x86_64-linux-android"
            CPU_FAMILY="x86_64"
            CPU="x86_64"
        ;;
    esac

    puts "\nTarget arch: ${BUILD_ARCH}"

    source "${HOME}/.config/ndkautobuilder/config.sh"

    # Build path(manual)
    BUILD_PATH="${PROJECT_ROOT_PATH}/build-android-${BUILD_ARCH}"

    # Build install path(manual)
    BUILD_PREFIX_PATH="${BUILD_PREFIX}/${BUILD_ARCH}"

    # Pkg config library path(manual)
    PKG_CONFIG_LIBPATH="${PKG_CONFIG_LIBPATH}"

    meson_cross

    # Config
    puts "\nConfigure build...\n"
    if [[ -d ${BUILD_PATH} ]]
    then
        rm -rf ${BUILD_PATH}
    fi
    meson ${BUILD_PATH} \
        --cross-file ${PROJECT_ROOT_PATH}/meson-android-cross.ini \
        -D prefix="${BUILD_PREFIX_PATH}" \
        -D c_args="-I${BUILD_PREFIX_PATH}/include" \
        -D cpp_args="-I${BUILD_PREFIX_PATH}/include" \
        -D c_link_args="-L${BUILD_PREFIX_PATH}/lib" \
        -D cpp_link_args="-L${BUILD_PREFIX_PATH}/lib"

    # Make
    puts "\nBuild...\n"
    ninja -C ${BUILD_PATH} -j$(nproc)

    # Install
    puts "\nInstall...\n"
    ninja -C ${BUILD_PATH} install -j$(nproc)
done

puts "\nBuild finished"
EOF
}

# Create cmake config
create_cmake_config ()
{
# Create config file
puts "\nCreate config file to project root path"
puts "Create build-config-var.sh"
cat <<EOF > ${PROJECT_ROOT_PATH}/build-config-var.sh
#!/bin/bash


# NDK path(manual)
NDK_PATH="${NDK_PATH}"

# Toolchain(automatic)
TOOLCHAIN="${TOOLCHAIN}"

# Project name(automatic)
PROJECT_NAME="${PROJECT_NAME}"

# Project version(automatic)
PROJECT_VERSION="${PROJECT_VERSION}"

# Project root path(automatic)
PROJECT_ROOT_PATH="${PROJECT_ROOT_PATH}"

# Build install path(manual)
BUILD_PREFIX="${BUILD_PREFIX}"

# Build System(automatic)
BUILD_SYSTEM="${BUILD_SYSTEM}"

# Build Architecture(manual arg: aarch64, arm, i686, x86_64 or all)
ARCH="${ARCH}"

# Android API Level(manual)
API="${API}"

# Pkg config binary path(manual)
PKG_CONFIG_PATH="${PKG_CONFIG_PATH}"
EOF

puts "Create build-config.sh"
cat <<"EOF" > ${PROJECT_ROOT_PATH}/build-config.sh
#!/bin/bash


# Start build
puts "\nStart build"
puts "Build System: ${BUILD_SYSTEM}"


cd ${PROJECT_ROOT_PATH}

for i in ${ABI[@]}
do
    case ${i} in
        arm64-v8a)
            BUILD_ARCH="aarch64"
            NDK_ABI="aarch64-linux-android"
        ;;
        armeabi-v7a)
            BUILD_ARCH="arm"
            NDK_ABI="arm-linux-androideabi"
        ;;
        x86)
            BUILD_ARCH="i686"
            NDK_ABI="i686-linux-android"
        ;;
        x86_64)
            BUILD_ARCH="x86_64"
            NDK_ABI="x86_64-linux-android"
        ;;
    esac

    puts "\nTarget arch: ${BUILD_ARCH}"

    # Build path(manual)
    BUILD_PATH="${PROJECT_ROOT_PATH}/build-android-${BUILD_ARCH}"

    # Build install path(manual)
    BUILD_PREFIX_PATH="${BUILD_PREFIX}/${BUILD_ARCH}"

    # Config
    puts "\nConfigure build...\n"
    if [[ -d ${BUILD_PATH} ]]
    then
        rm -rf ${BUILD_PATH}
    fi
    cmake \
        -B ${BUILD_PATH} \
        -DCMAKE_TOOLCHAIN_FILE=${NDK_PATH}/build/cmake/android.toolchain.cmake \
        -DANDROID_ABI=${i} \
        -DANDROID_ARM_MODE=thumb \
        -DANDROID_ARM_NEON=TRUE \
        -DANDROID_STL=c++_shared \
        -DANDROID_NDK=${NDK_PATH} \
        -DANDROID_PLATFORM=android-${API} \
        -DCMAKE_ANDROID_ARCH_ABI=${i} \
        -DCMAKE_ANDROID_NDK=${NDK_PATH} \
        -DCMAKE_SYSTEM_NAME=Android \
        -DCMAKE_SYSTEM_VERSION=${API} \
        -DCMAKE_FIND_ROOT_PATH=${BUILD_PREFIX_PATH} \
        -DCMAKE_INSTALL_PREFIX=${BUILD_PREFIX_PATH}

    if [[ -f ${BUILD_PATH}/build.ninja ]]
    then
        # Make
        puts "\nBuild...\n"
        ninja -C ${BUILD_PATH} -j$(nproc)

        # Install
        puts "\nInstall...\n"
        ninja -C ${BUILD_PATH} install -j$(nproc)
    else
        # Make
        puts "\nBuild...\n"
        cd ${BUILD_PATH}
        make -j$(nproc)

        # Install
        puts "\nInstall...\n"
        make install -j$(nproc)
    fi

    cd ${PROJECT_ROOT_PATH}
done

puts "\nBuild finished"

# ANDROID_ABI
# arm64-v8a armeabi-v7a x86_64 x86

# ANDROID_ARM_MODE
# thumb arm

# ANDROID_ARM_NEON
# TRUE FALSE

# ANDROID_STL
# c++_shared c++_static
EOF
}

# Create autotools config
create_autotools_config ()
{
# Create config file
puts "\nCreate config file to project root path"
puts "Create build-config-var.sh"
cat <<EOF > ${PROJECT_ROOT_PATH}/build-config-var.sh
#!/bin/bash


# NDK path(manual)
NDK_PATH="${NDK_PATH}"

# Toolchain(automatic)
TOOLCHAIN="${TOOLCHAIN}"

# Project name(automatic)
PROJECT_NAME="${PROJECT_NAME}"

# Project version(automatic)
PROJECT_VERSION="${PROJECT_VERSION}"

# Project root path(automatic)
PROJECT_ROOT_PATH="${PROJECT_ROOT_PATH}"

# Build install path(manual)
BUILD_PREFIX="${BUILD_PREFIX}"

# Build System(automatic)
BUILD_SYSTEM="${BUILD_SYSTEM}"

# Build Architecture(manual arg: aarch64, arm, i686, x86_64 or all)
ARCH="${ARCH}"

# Android API Level(manual)
API="${API}"

# Pkg config binary path(manual)
PKG_CONFIG_PATH="${PKG_CONFIG_PATH}"
EOF

puts "Create build-config.sh"
cat <<"EOF" > ${PROJECT_ROOT_PATH}/build-config.sh
#!/bin/bash


# Start build
puts "\nStart build"
puts "Build System: ${BUILD_SYSTEM}"


cd ${PROJECT_ROOT_PATH}

for i in ${TARGET[@]}
do
    case ${i} in
        aarch64-linux-android)
            BUILD_ARCH="aarch64"
            NDK_ABI="aarch64-linux-android"
        ;;
        armv7a-linux-androideabi)
            BUILD_ARCH="arm"
            NDK_ABI="arm-linux-androideabi"
        ;;
        i686-linux-android)
            BUILD_ARCH="i686"
            NDK_ABI="i686-linux-android"
        ;;
        x86_64-linux-android)
            BUILD_ARCH="x86_64"
            NDK_ABI="x86_64-linux-android"
        ;;
    esac

    puts "\nTarget arch: ${BUILD_ARCH}"

    source "${HOME}/.config/ndkautobuilder/config.sh"

    # Build path(manual)
    BUILD_PATH="${PROJECT_ROOT_PATH}/build-android-${BUILD_ARCH}"

    # Build install path(manual)
    BUILD_PREFIX_PATH="${BUILD_PREFIX}/${BUILD_ARCH}"

    # Pkg config library path(manual)
    PKG_CONFIG_LIBPATH="${PKG_CONFIG_LIBPATH}"

    # Config
    puts "\nConfigure build...\n"
    if [[ -d ${BUILD_PATH} ]]
    then
        rm -rf ${BUILD_PATH}
    fi
    mkdir ${BUILD_PATH}
    cd ${BUILD_PATH}
    libgcc="$(${NDK_PATH}${TOOLCHAIN}/bin/${i}${API}-clang -print-libgcc-file-name)"
    ldlibgcc="-L$(dirname $libgcc) -l:$(basename $libgcc)"
    env PKG_CONFIG_LIBDIR=${PKG_CONFIG_LIBPATH} \
    CFLAGS="-I${BUILD_PREFIX_PATH}/include" \
    CXXFLAGS="-I${BUILD_PREFIX_PATH}/include" \
    LDFLAGS="-L${BUILD_PREFIX_PATH}/lib -L${NDK_PATH}${TOOLCHAIN}/sysroot/usr/lib/${NDK_ABI}/${API} -Wl, --no-undefined" \
    AR=${NDK_PATH}${TOOLCHAIN}/bin/llvm-ar \
    CC=${NDK_PATH}${TOOLCHAIN}/bin/${i}${API}-clang \
    AS=${NDK_PATH}${TOOLCHAIN}/bin/llvm-as \
    CXX=${NDK_PATH}${TOOLCHAIN}/bin/${i}${API}-clang++ \
    LD=${NDK_PATH}${TOOLCHAIN}/bin/ld \
    RANLIB=${NDK_PATH}${TOOLCHAIN}/bin/llvm-ranlib \
    STRIP=${NDK_PATH}${TOOLCHAIN}/bin/llvm-strip \
    OBJCOPY=${NDK_PATH}${TOOLCHAIN}/bin/llvm-objcopy \
    OBJDUMP=${NDK_PATH}${TOOLCHAIN}/bin/llvm-objdump \
    READELF=${NDK_PATH}${TOOLCHAIN}/bin/llvm-readelf \
    NM=${NDK_PATH}${TOOLCHAIN}/bin/llvm-nm \
    CXXFILT=${NDK_PATH}${TOOLCHAIN}/bin/llvm-cxxfilt \
    ../configure --host ${i} \
        --prefix=${BUILD_PREFIX_PATH}

    # Make
    puts "\nBuild...\n"
    make -j$(nproc)

    # Install
    puts "\nInstall...\n"
    make install -j$(nproc)

    cd ${PROJECT_ROOT_PATH}
done

puts "\nBuild finished"
EOF
}

# Create make config
create_make_config ()
{
# Create config file
puts "\nCreate config file to project root path"
puts "Create build-config-var.sh"
cat <<EOF > ${PROJECT_ROOT_PATH}/build-config-var.sh
#!/bin/bash


# NDK path(manual)
NDK_PATH="${NDK_PATH}"

# Toolchain(automatic)
TOOLCHAIN="${TOOLCHAIN}"

# Project name(automatic)
PROJECT_NAME="${PROJECT_NAME}"

# Project version(automatic)
PROJECT_VERSION="${PROJECT_VERSION}"

# Project root path(automatic)
PROJECT_ROOT_PATH="${PROJECT_ROOT_PATH}"

# Build install path(manual)
BUILD_PREFIX="${BUILD_PREFIX}"

# Build System(automatic)
BUILD_SYSTEM="${BUILD_SYSTEM}"

# Build Architecture(manual arg: aarch64, arm, i686, x86_64 or all)
ARCH="${ARCH}"

# Android API Level(manual)
API="${API}"

# Pkg config binary path(manual)
PKG_CONFIG_PATH="${PKG_CONFIG_PATH}"
EOF

puts "Create build-config.sh"
cat <<"EOF" > ${PROJECT_ROOT_PATH}/build-config.sh
#!/bin/bash


# Start build
puts "\nStart build"
puts "Build System: ${BUILD_SYSTEM}"


cd ${PROJECT_ROOT_PATH}

for i in ${TARGET[@]}
do
    case ${i} in
        aarch64-linux-android)
            BUILD_ARCH="aarch64"
            NDK_ABI="aarch64-linux-android"
        ;;
        armv7a-linux-androideabi)
            BUILD_ARCH="arm"
            NDK_ABI="arm-linux-androideabi"
        ;;
        i686-linux-android)
            BUILD_ARCH="i686"
            NDK_ABI="i686-linux-android"
        ;;
        x86_64-linux-android)
            BUILD_ARCH="x86_64"
            NDK_ABI="x86_64-linux-android"
        ;;
    esac

    puts "\nTarget arch: ${BUILD_ARCH}"

    source "${HOME}/.config/ndkautobuilder/config.sh"

    # Build path(manual)
    BUILD_PATH="${PROJECT_ROOT_PATH}/build-android-${BUILD_ARCH}"

    # Build install path(manual)
    BUILD_PREFIX_PATH="${BUILD_PREFIX}/${BUILD_ARCH}"

    # Make
    puts "\nBuild...\n"
    make -j$(nproc) \
        CFLAGS="-I${BUILD_PREFIX_PATH}/include" \
        CXXFLAGS="-I${BUILD_PREFIX_PATH}/include" \
        LDFLAGS="-L${BUILD_PREFIX_PATH}/lib" \
        CC="${NDK_PATH}${TOOLCHAIN}/bin/${i}${API}-clang" \
        AR="${NDK_PATH}${TOOLCHAIN}/bin/llvm-ar" \
        RANLIB="${NDK_PATH}${TOOLCHAIN}/bin/llvm-ranlib"

    # Install
    puts "\nInstall...\n"
    make install -j$(nproc)
done

puts "\nBuild finished"
EOF
}



# Script Start

# Show script info
puts "NDK Auto Builder v0.1"

# Create script config file
if [[ ! -f ${HOME}/.config/ndkautobuilder/config.sh ]]
then
    puts "Create script config file"
    puts "Edit ${HOME}/.config/ndkautobuilder/config.sh to configure NDK"
    mkdir -p ${HOME}/.config/ndkautobuilder
    cat <<EOF > ${HOME}/.config/ndkautobuilder/config.sh
#!/bin/bash


# NDK path
NDK_PATH=""

# Build prefix
BUILD_PREFIX=""

# Architecture(arg: aarch64, arm, i686, x86_64 or all)
ARCH=""

# Pkg config library path
PKG_CONFIG_LIBPATH=""
EOF
exit
fi

# Check project root path
LIST_FILES=$(ls ./)
if [[ ! ${LIST_FILES} == *"meson.build"* ]] && [[ ! ${LIST_FILES} == *"CMakeLists.txt"* ]] && [[ ! ${LIST_FILES} == *"configure.ac"* ]] && [[ ! ${LIST_FILES} == *"configure.in"* ]] && [[ ! ${LIST_FILES} == *"Makefile"* ]]
then
    puts "Build system configuration file not found"
    exit
fi

PROJECT_ROOT_PATH=$(pwd)
PROJECT_NAME=$(echo ${PROJECT_ROOT_PATH} | sed "s/^.*\///g" | sed "s/-.*$//g")
if [[ $(echo ${PROJECT_ROOT_PATH} | sed "s/^.*\///g") == *"-"* ]]
then
    PROJECT_VERSION=$(echo ${PROJECT_ROOT_PATH} | sed "s/^.*\///g" | sed "s/^.*-//g")
else
    PROJECT_VERSION="none"
fi

# Check config file
if [[ ! -f ${PROJECT_ROOT_PATH}/build-config-var.sh ]]
then
    # Check build system

    BUILD_SYSTEM=()

    # Meson build system
    if [[ -f ${PROJECT_ROOT_PATH}/meson.build ]]
    then
        BUILD_SYSTEM+=("Meson")
    fi

    # Cmake build system
    if [[ -f ${PROJECT_ROOT_PATH}/CMakeLists.txt ]]
    then
        BUILD_SYSTEM+=("Cmake")
    fi

    # Autotools build sytem
    if [[ -f ${PROJECT_ROOT_PATH}/configure.ac ]] || [[ -f ${PROJECT_ROOT_PATH}/configure.in ]]
    then
        BUILD_SYSTEM+=("Autotools")
    fi

    # Make build system
    if [[ -f ${PROJECT_ROOT_PATH}/Makefile ]] && [[ ${BUILD_SYSTEM} == "" ]]
    then
        BUILD_SYSTEM+=("Make")
    fi

    BUILD_SYSTEMS="${BUILD_SYSTEM[@]}"

    if [[ ${#BUILD_SYSTEM[@]} > 1 ]]
    then
        puts "Multiple build systems detected"
        select value in "${BUILD_SYSTEM[@]}"
        do
            puts "Choose: ${value}"
            BUILD_SYSTEM=${value}
            break
        done
    else
        BUILD_SYSTEM="${BUILD_SYSTEM[@]}"
    fi

    # Check script config
    source "${HOME}/.config/ndkautobuilder/config.sh"

    case ${BUILD_SYSTEM} in
        Meson)
            # For Meson build system
            create_meson_config
        ;;
        Cmake)
            # For Cmake build system
            create_cmake_config
        ;;
        Autotools)
            # For Autotools build system
            create_autotools_config
        ;;
        Make)
            # For Make build system
            create_make_config
        ;;
    esac

    # Show project info
    check_project_info

    if [[ ! ${BUILD_SYSTEM} == "" ]]
    then
        puts "\nPlease edit the build-config-var.sh and build-config.sh files to complete the build configuration"
    fi
    exit
fi

# Check config
source "${PROJECT_ROOT_PATH}/build-config-var.sh"

TARGET=()
ABI=()

# Check build architecture
if [[ ${ARCH} == *"aarch64"* ]]
then
    TARGET+=("aarch64-linux-android")
    ABI+=("arm64-v8a")
fi

if [[ ${ARCH} == *"arm"* ]]
then
    TARGET+=("armv7a-linux-androideabi")
    ABI+=("armeabi-v7a")
fi

if [[ ${ARCH} == *"i686"* ]]
then
    TARGET+=("i686-linux-android")
    ABI+=("x86")
fi

if [[ ${ARCH} == *"x86_64"* ]]
then
    TARGET+=("x86_64-linux-android")
    ABI+=("x86_64")
fi

if [[ ${ARCH} == *"all"* ]]
then
    TARGET=("aarch64-linux-android" "armv7a-linux-androideabi" "i686-linux-android" "x86_64-linux-android")
    ABI=("arm64-v8a" "armeabi-v7a" "x86" "x86_64")
fi

# Run build
source "${PROJECT_ROOT_PATH}/build-config.sh"

# Script End
