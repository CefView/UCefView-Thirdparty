#!/bin/bash

#===================================================================
#region Read Config Values
source ThirdParty-Config.txt
#endregion

#===================================================================
#region Set Directories
ROOT_DIR="$(pwd)"
echo "ROOT_DIR: $ROOT_DIR"

WORK_DIR=$ROOT_DIR/Work

INSTALL_DIR=$WORK_DIR/install
echo "INSTALL_DIR: $INSTALL_DIR"echo "WORK_DIR: $WORK_DIR"

SOURCE_DIR=$WORK_DIR/src
echo "SOURCE_DIR: $SOURCE_DIR"
mkdir -p $SOURCE_DIR

SOURCE_THIRDPARTY_DIR=$ROOT_DIR/../output/CefViewCore
echo "SOURCE_THIRDPARTY_DIR: $SOURCE_THIRDPARTY_DIR"
#endregion

#===================================================================
#region Update Source Repository
cd $SOURCE_DIR

# Get source repo
git init
git remote remove origin
git remote add origin $CORE_REPO
git fetch
git -c advice.detachedHead=false checkout --force $CORE_VERSION
#endregion

#===================================================================
# Build Linux x86_64
echo "Building Linux x86_64..."
mkdir -p $INSTALL_DIR
cd $SOURCE_DIR
# Build and install
cmake -G "Unix Makefiles" \
      -DCMAKE_C_COMPILER=clang \
      -DCMAKE_CXX_COMPILER=clang++ \
      -DCMAKE_CXX_FLAGS=-stdlib=libc++ \
      -DCMAKE_BUILD_TYPE=$CORE_BUILD_TYPE \
      -DCMAKE_INSTALL_PREFIX=$INSTALL_DIR \
      -DPROJECT_ARCH=x86_64 \
      -DTARGET_ARCH=x86_64 \
      -DUSE_SANDBOX=ON \
      -DCEF_SDK_VERSION=$CEF_VERSION \
      -DCEFVIEW_WING_NAME=$CEF_HELPER_NAME \
      -B "$SOURCE_DIR/build/linux.x86_64" \
      --fresh

cmake --build "$SOURCE_DIR/build/linux.x86_64" --config $CORE_BUILD_TYPE
cmake --install "$SOURCE_DIR/build/linux.x86_64" --config $CORE_BUILD_TYPE

cd $ROOT_DIR

echo "Updating bin files..."
cmake -E copy_directory "$INSTALL_DIR/$CORE_BUILD_TYPE/bin" "$SOURCE_THIRDPARTY_DIR/bin/Linux"

# Copy Header Files
echo "Updating header files..."
cmake -E copy_directory "$INSTALL_DIR/include" "$SOURCE_THIRDPARTY_DIR/include/Linux"

# Copy lib files
echo "Updating lib files..."
cmake -E copy_directory "$INSTALL_DIR/$CORE_BUILD_TYPE/lib" "$SOURCE_THIRDPARTY_DIR/lib/Linux"

# Strip libcef.so to reduce size
strip "$SOURCE_THIRDPARTY_DIR/bin/Linux/libcef.so"