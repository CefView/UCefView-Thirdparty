#===================================================================
#region Read Config Values
Get-Content "ThirdParty-Config.txt" | ForEach-Object {
      if ($_ -match "^([^=]+)=(.*)$") {
            $name = $Matches[1].Trim()
            $value = $Matches[2].Trim()
            Write-Host "Set VAR: '$name' = '$value'"
            Set-Variable -Name $name -Value $value
      }
}
#endregion

#===================================================================
#region Set Directories
$ROOT_DIR = Get-Location
Write-Host "ROOT_DIR: '$ROOT_DIR'"

$WORK_DIR = Join-Path $ROOT_DIR "Work"
Write-Host "WORK_DIR: '$WORK_DIR'"

$SOURCE_DIR = Join-Path $WORK_DIR "src"
Write-Host "SOURCE_DIR: '$SOURCE_DIR'"

$INSTALL_DIR = Join-Path $WORK_DIR "install"
Write-Host "INSTALL_DIR: '$INSTALL_DIR'"

$SOURCE_THIRDPARTY_DIR = Join-Path $ROOT_DIR "..\output\CefViewCore"
Write-Host "SOURCE_THIRDPARTY_DIR: '$SOURCE_THIRDPARTY_DIR'"
#endregion

#===================================================================
#region Update Source Repository
if (!(Test-Path $SOURCE_DIR)) {
      New-Item -ItemType Directory -Force -Path $SOURCE_DIR
}

Set-Location $SOURCE_DIR

# Get source repo
git init
git remote remove origin
git remote add origin $CORE_REPO
git fetch
git -c advice.detachedHead=false checkout --force $CORE_VERSION
#endregion

#===================================================================
#region Build and Install
$cmakeArgs = @(
      "-DPROJECT_ARCH=x86_64",
      "-DCMAKE_BUILD_TYPE=$CORE_BUILD_TYPE",
      "-DCMAKE_INSTALL_PREFIX=$INSTALL_DIR",
      "-DUSE_SANDBOX=OFF",
      "-DUSE_GPU_OPTIMUS=ON",
      "-DCEF_SDK_VERSION=$CEF_VERSION",
      "-DCEFVIEW_WING_NAME=$CEF_HELPER_NAME",
      "-B", "$SOURCE_DIR\build\win.x64",
      "-A", "x64",
      "--fresh"
)

cmake @cmakeArgs
cmake --build "$SOURCE_DIR\build\win.x64" --config $CORE_BUILD_TYPE
cmake --install "$SOURCE_DIR\build\win.x64" --config $CORE_BUILD_TYPE
#endregion

#===================================================================
#region Copy Files
Set-Location $ROOT_DIR

Write-Host "Updating bin files..."
cmake -E copy_directory "$INSTALL_DIR\$CORE_BUILD_TYPE\bin" "$SOURCE_THIRDPARTY_DIR\bin\Win64"

Write-Host "Updating header files..."
cmake -E copy_directory "$INSTALL_DIR\include" "$SOURCE_THIRDPARTY_DIR\include\Win64"

Write-Host "Updating lib files..."
cmake -E copy_directory "$INSTALL_DIR\$CORE_BUILD_TYPE\lib" "$SOURCE_THIRDPARTY_DIR\lib\Win64"
#endregion

#===================================================================
#region Rename UCefViewHelper.exe
Write-Host "Compress UCefViewHelper.exe to UCefViewHelper.bin"
$HelperExePath = "$SOURCE_THIRDPARTY_DIR\bin\Win64\UCefViewHelper.exe"
$HelperBinPath = "$SOURCE_THIRDPARTY_DIR\bin\Win64\UCefViewHelper.bin"

Write-Host "Reading UCefViewHelper.exe content..."
$fileContent = [IO.File]::ReadAllBytes($HelperExePath)

Write-Host "Patching MZ sig..."
$fileContent[0] = 0x0;
$fileContent[1] = 0x0;

Write-Host "Writing compressed data to $HelperBinPath"
[IO.File]::WriteAllBytes($HelperBinPath, $fileContent)
#endregion

Write-Host "Removing $HelperExePath"
Remove-Item -Path $HelperExePath

Write-Host "Done!"