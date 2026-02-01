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
# Build macOS x86_64
echo "Building macOS x86_64..."
mkdir -p $INSTALL_DIR/x86_64
cd $SOURCE_DIR
# Build and install
cmake -G "Xcode" \
      -DCMAKE_BUILD_TYPE=$CORE_BUILD_TYPE \
      -DCMAKE_INSTALL_PREFIX=$INSTALL_DIR/x86_64 \
      -DPROJECT_ARCH=x86_64 \
      -DTARGET_ARCH=x86_64 \
      -DUSE_SANDBOX=ON \
      -DCEF_SDK_VERSION=$CEF_VERSION \
      -DCEFVIEW_WING_NAME=$CEF_HELPER_NAME \
      -B "$SOURCE_DIR/build/mac.x86_64" \
      --fresh

cmake --build "$SOURCE_DIR/build/mac.x86_64" --config $CORE_BUILD_TYPE
cmake --install "$SOURCE_DIR/build/mac.x86_64" --config $CORE_BUILD_TYPE

# Copy runtime binary files
cd $ROOT_DIR
echo "Updating bin files..."
cmake -E copy_directory "$INSTALL_DIR/x86_64/$CORE_BUILD_TYPE/bin" "$SOURCE_THIRDPARTY_DIR/bin/Mac/x86_64"


#===================================================================
# Build macOS arm64
echo "Building macOS arm64..."
mkdir -p $INSTALL_DIR/arm64
cd $SOURCE_DIR
# Build and install
cmake -G "Xcode" \
      -DCMAKE_BUILD_TYPE=$CORE_BUILD_TYPE \
      -DCMAKE_INSTALL_PREFIX=$INSTALL_DIR/arm64 \
      -DPROJECT_ARCH=arm64 \
      -DTARGET_ARCH=arm64 \
      -DUSE_SANDBOX=ON \
      -DCEF_SDK_VERSION=$CEF_VERSION \
      -DCEFVIEW_WING_NAME=$CEF_HELPER_NAME \
      -B "$SOURCE_DIR/build/mac.arm64" \
      --fresh

cmake --build "$SOURCE_DIR/build/mac.arm64" --config $CORE_BUILD_TYPE
cmake --install "$SOURCE_DIR/build/mac.arm64" --config $CORE_BUILD_TYPE

# Copy runtime binary files
cd $ROOT_DIR
echo "Updating bin files..."
cmake -E copy_directory "$INSTALL_DIR/arm64/$CORE_BUILD_TYPE/bin" "$SOURCE_THIRDPARTY_DIR/bin/Mac/arm64"

#===================================================================
# Copy Header Files for both architectures
cd $ROOT_DIR
echo "Updating header files..."
cmake -E copy_directory "$INSTALL_DIR/arm64/include" "$SOURCE_THIRDPARTY_DIR/include/Mac"

#===================================================================
# Create universal binary for macOS
mkdir -p "$SOURCE_THIRDPARTY_DIR/lib/Mac"
echo "Creating universal libcef_dll_wrapper.a for macOS..."
rm -f "$SOURCE_THIRDPARTY_DIR/lib/Mac/libcef_dll_wrapper.a"
lipo -create \
  "$INSTALL_DIR/arm64/$CORE_BUILD_TYPE/lib/libcef_dll_wrapper.a" \
  "$INSTALL_DIR/x86_64/$CORE_BUILD_TYPE/lib/libcef_dll_wrapper.a" \
  -output "$SOURCE_THIRDPARTY_DIR/lib/Mac/libcef_dll_wrapper.a"

lipo -info "$SOURCE_THIRDPARTY_DIR/lib/Mac/libcef_dll_wrapper.a"

echo "Creating universal CefViewCore.framework for macOS..."
rm -rf "$SOURCE_THIRDPARTY_DIR/lib/Mac/CefViewCore.framework"
mkdir -p "$SOURCE_THIRDPARTY_DIR/lib/Mac/CefViewCore.framework"
lipo -create \
  "$INSTALL_DIR/arm64/$CORE_BUILD_TYPE/lib/CefViewCore.framework/CefViewCore" \
  "$INSTALL_DIR/x86_64/$CORE_BUILD_TYPE/lib/CefViewCore.framework/CefViewCore" \
  -output "$SOURCE_THIRDPARTY_DIR/lib/Mac/CefViewCore.framework/CefViewCore"

cp -R "$INSTALL_DIR/arm64/$CORE_BUILD_TYPE/lib/CefViewCore.framework/Versions/A/Headers" \
  "$SOURCE_THIRDPARTY_DIR/lib/Mac/CefViewCore.framework/"
cp -R "$INSTALL_DIR/arm64/$CORE_BUILD_TYPE/lib/CefViewCore.framework/Versions/A/Resources" \
  "$SOURCE_THIRDPARTY_DIR/lib/Mac/CefViewCore.framework/"

lipo -info "$SOURCE_THIRDPARTY_DIR/lib/Mac/CefViewCore.framework/CefViewCore"
