$ErrorActionPreference = "Stop"

Get-PSDrive

# Android SDK の削除
if (($Env:ANDROID_HOME -ne $null) -and (Test-Path $Env:ANDROID_HOME)) {
  (Get-Item $Env:ANDROID_HOME).Delete()
}
if (($Env:ANDROID_NDK_HOME -ne $null) -and (Test-Path $Env:ANDROID_NDK_HOME)) {
  (Get-Item $Env:ANDROID_NDK_HOME).Delete()
}

# JVM の削除
if (($Env:JAVA_HOME_11_X64 -ne $null) -and (Test-Path $Env:JAVA_HOME_11_X64)) {
  Remove-Item -Recurse -Force $Env:JAVA_HOME_11_X64
}
if (($Env:JAVA_HOME_8_X64 -ne $null) -and (Test-Path $Env:JAVA_HOME_8_X64)) {
  Remove-Item -Recurse -Force $Env:JAVA_HOME_8_X64
}
if (($Env:JAVA_HOME_7_X64 -ne $null) -and (Test-Path $Env:JAVA_HOME_7_X64)) {
  Remove-Item -Recurse -Force $Env:JAVA_HOME_7_X64
}

Get-PSDrive
