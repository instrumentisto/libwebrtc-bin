# Copyright 2019, Shiguredo Inc, melpon and enm10k
# Copyright 2019, Zenichi Amano
# Copyright 2022-2025, Instrumentisto Team, rogurotus and tyranron
# original: https://github.com/shiguredo/shiguredo-webrtc-windows/blob/master/gabuild.ps1

$ErrorActionPreference = "Stop"

# Wraps native commands to handle their errors.
# Original:
#   https://stackoverflow.com/a/48999101/1828012
#   https://stackoverflow.com/a/52784160/1828012
function Exec
{
  [CmdletBinding()]
  param(
    [Parameter(Position=0,Mandatory=1)][scriptblock]$cmd,
    [int[]]$SuccessCodes = @(0)
  )
  & $cmd
  if (($SuccessCodes -notcontains $LastExitCode) -and ($ErrorActionPreference -eq "Stop")) {
    exit $LastExitCode
  }
}

# VERSIONファイル読み込み
$lines = get-content VERSION
foreach ($line in $lines) {
  # WEBRTC_COMMITの行のみ取得する
  if ($line -match "^WEBRTC_") {
    $name, $value = $line.split("=",2)
    Invoke-Expression "`$$name='$value'"
  }
}

if (!(Test-Path vswhere.exe)) {
  Invoke-WebRequest -Uri "https://github.com/microsoft/vswhere/releases/download/2.8.4/vswhere.exe" -OutFile vswhere.exe
}

# vsdevcmd.bat の設定を入れる
# https://github.com/microsoft/vswhere/wiki/Find-VC
$path = .\vswhere.exe -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath
if ($path) {
  $batpath = Join-Path $path 'Common7\Tools\vsdevcmd.bat'
  if (Test-Path $batpath) {
    cmd /s /c """$batpath"" $args && set" | Where-Object { $_ -match '(\w+)=(.*)' } | ForEach-Object {
      $null = New-Item -Force -Path "Env:\$($Matches[1])" -Value $Matches[2]
    }
  }
  # dbghelp.dll が無いと怒られてしまうので所定の場所にコピーする (管理者権限で実行する必要がある)
  $debuggerpath = Join-Path $path "Common7\IDE\Extensions\TestPlatform\Extensions\Cpp\x64\dbghelp.dll"
  if (!(Test-Path "C:\Program Files (x86)\Windows Kits\10\Debuggers\x64")) {
    New-Item "C:\Program Files (x86)\Windows Kits\10\Debuggers\x64" -ItemType Directory -Force
    Copy-Item $debuggerpath "C:\Program Files (x86)\Windows Kits\10\Debuggers\x64\dbghelp.dll"
  }
}

$REPO_DIR = Resolve-Path "."
$WEBRTC_DIR = "C:\webrtc"
$BUILD_DIR = "C:\webrtc_build"
$DEPOT_TOOLS_DIR = Join-Path $REPO_DIR.Path "depot_tools"
$PATCH_DIR = Join-Path $REPO_DIR.Path "patch"
$PACKAGE_DIR = Join-Path $REPO_DIR.Path "package"

# WebRTC ビルドに必要な環境変数の設定
$Env:GYP_MSVS_VERSION = "2019"
$Env:DEPOT_TOOLS_WIN_TOOLCHAIN = "0"
$Env:PYTHONIOENCODING = "utf-8"

# depot_tools
if (Test-Path $DEPOT_TOOLS_DIR) {
  Push-Location $DEPOT_TOOLS_DIR
    Exec { git checkout . }
    Exec { git clean -df . }
    Exec { git pull . }
  Pop-Location
} else {
  Exec { git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git }
}

# Git設定
git config --global core.longpaths true
git config --global depot-tools.allowGlobalGitConfig true

$Env:PATH = "$DEPOT_TOOLS_DIR;$Env:PATH"
# Choco へのパスを削除
$Env:PATH = $Env:Path.Replace("C:\ProgramData\Chocolatey\bin;", "");

# WebRTC のソース取得
New-Item $WEBRTC_DIR -ItemType Directory -Force
Push-Location $WEBRTC_DIR
if (Test-Path .gclient) {
  Push-Location src
    Exec { git checkout . }
    Exec { git clean -df }
  Pop-Location

  Push-Location src\build
    Exec { git checkout . }
    Exec { git clean -xdf }
  Pop-Location

  Push-Location src\third_party
    Exec { git checkout . }
    Exec { git clean -df }
  Pop-Location
} else {
  if (Test-Path $DEPOT_TOOLS_DIR\metrics.cfg) {
    Remove-Item $DEPOT_TOOLS_DIR\metrics.cfg -Force
  }
  if (Test-Path src) {
    Remove-Item src -Recurse -Force
  }
  Exec { fetch --nohooks webrtc }
}

if (!(Test-Path $BUILD_DIR)) {
  New-Item $BUILD_DIR -ItemType Directory -Force
}

Push-Location $WEBRTC_DIR\src
  Exec { gclient sync --with_branch_heads -r $WEBRTC_COMMIT }
  Write-Output "Start to apply patches..."
  Write-Output "Applying add_licenses.patch"
  Exec { git apply -p1 --ignore-space-change --ignore-whitespace --whitespace=nowarn --reject -v $PATCH_DIR\add_licenses.patch }
  Write-Output "Applying 4k.patch"
  Exec { git apply -p1 --ignore-space-change --ignore-whitespace --whitespace=nowarn --reject -v $PATCH_DIR\4k.patch }
  Write-Output "Applying windows_fix_optional.patch"
  Exec { git apply -p1 --ignore-space-change --ignore-whitespace --whitespace=nowarn --reject -v $PATCH_DIR\windows_fix_optional.patch }
  Write-Output "Applying windows_add_deps.patch"
  Exec { git apply -p1 --ignore-space-change --ignore-whitespace --whitespace=nowarn --reject -v $PATCH_DIR\windows_add_deps.patch }
  Write-Output "Applying win_dynamic_crt.patch"
  Exec { git apply -p1 --ignore-space-change --ignore-whitespace --whitespace=nowarn --reject -v $PATCH_DIR\win_dynamic_crt.patch }
Pop-Location
Write-Output "Applying fix_disable_proxy_trace_events.patch"
Exec { git apply -p1 --ignore-space-change --ignore-whitespace --whitespace=nowarn --reject -v $PATCH_DIR\fix_disable_proxy_trace_events.patch }
Write-Output "All patches are applied"
Pop-Location

Get-PSDrive

Push-Location $WEBRTC_DIR\src
  # WebRTC Debugビルド x64
  Exec { gn gen $BUILD_DIR\debug_x64 --args="treat_warnings_as_errors=false rtc_use_h264=true rtc_include_tests=false rtc_build_tools=false rtc_build_examples=false is_component_build=false use_rtti=true use_custom_libcxx=false" }
  Exec { ninja -C "$BUILD_DIR\debug_x64" }

  # WebRTC Releaseビルド x64
  Exec { gn gen $BUILD_DIR\release_x64 --args="is_debug=false treat_warnings_as_errors=false rtc_use_h264=true rtc_include_tests=false rtc_build_tools=false rtc_build_examples=false is_component_build=false use_rtti=true strip_debug_info=true symbol_level=0 use_custom_libcxx=false" }
  Exec { ninja -C "$BUILD_DIR\release_x64" }
Pop-Location

foreach ($build in @("debug_x64", "release_x64")) {
  Exec { ninja -C "$BUILD_DIR\$build" audio_device_module_from_input_and_output }

  # このままだと webrtc.lib に含まれないファイルがあるので、いくつか追加する
  Push-Location $BUILD_DIR\$build\obj
  Exec {
    lib.exe `
      /out:$BUILD_DIR\$build\webrtc.lib webrtc.lib `
      api\task_queue\default_task_queue_factory\default_task_queue_factory_win.obj `
      rtc_base\rtc_task_queue_win\task_queue_win.obj `
      modules\audio_device\audio_device_module_from_input_and_output\audio_device_factory.obj `
      modules\audio_device\audio_device_module_from_input_and_output\audio_device_module_win.obj `
      modules\audio_device\audio_device_module_from_input_and_output\core_audio_base_win.obj `
      modules\audio_device\audio_device_module_from_input_and_output\core_audio_input_win.obj `
      modules\audio_device\audio_device_module_from_input_and_output\core_audio_output_win.obj `
      modules\audio_device\windows_core_audio_utility\core_audio_utility_win.obj `
      modules\audio_device\audio_device_name\audio_device_name.obj
  }
  Pop-Location
  Move-Item $BUILD_DIR\$build\webrtc.lib $BUILD_DIR\$build\obj\webrtc.lib -Force
}

# WebRTC のヘッダーだけをパッケージングする
if (Test-Path $BUILD_DIR\package) {
  Remove-Item -Force -Recurse -Path $BUILD_DIR\package
}
New-Item $BUILD_DIR\package\webrtc\include -ItemType Directory -Force
Exec { robocopy "$WEBRTC_DIR\src" "$BUILD_DIR\package\webrtc\include" *.h *.hpp *.inc /S /NP /NS /NC /NFL /NDL } -SuccessCodes @(1)

# ライブラリディレクトリ作成
New-Item $BUILD_DIR\package\webrtc\debug -ItemType Directory -Force
New-Item $BUILD_DIR\package\webrtc\release -ItemType Directory -Force

# バージョンファイルコピー
$WEBRTC_VERSION | Out-File $BUILD_DIR\package\webrtc\VERSION

# ライセンス生成 (x64)
Push-Location $WEBRTC_DIR\src
  Exec { vpython3 tools_webrtc\libs\generate_licenses.py --target :webrtc "$BUILD_DIR\" "$BUILD_DIR\debug_x64" "$BUILD_DIR\release_x64" }
Pop-Location
Copy-Item "$BUILD_DIR\LICENSE.md" "$BUILD_DIR\package\webrtc\NOTICE"

# x64用ライブラリコピー
Copy-Item $BUILD_DIR\debug_x64\obj\webrtc.lib $BUILD_DIR\package\webrtc\debug\
Copy-Item $BUILD_DIR\release_x64\obj\webrtc.lib $BUILD_DIR\package\webrtc\release\

# ファイルを圧縮する
if (!(Test-Path $PACKAGE_DIR)) {
  New-Item $PACKAGE_DIR -ItemType Directory -Force
}
if (Test-Path $PACKAGE_DIR\libwebrtc-windows-x64.tar.gz) {
  Remove-Item -Force -Path $PACKAGE_DIR\libwebrtc-windows-x64.tar.gz
}
Push-Location $BUILD_DIR\package\webrtc
  Exec { tar -czvf $PACKAGE_DIR\libwebrtc-windows-x64.tar.gz include debug release NOTICE VERSION }
Pop-Location
