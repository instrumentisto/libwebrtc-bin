$ErrorActionPreference = "Stop"

Get-PSDrive

# Android SDK の削除
if (Test-Path $Env:ANDROID_HOME) {
  Remove-Item $Env:ANDROID_HOME -Recurse -Force
}
Remove-Item -Recurse -Force $Env:ANDROID_NDK_HOME

# JVM の削除
Remove-Item -Recurse -Force $Env:JAVA_HOME_11_X64
Remove-Item -Recurse -Force $Env:JAVA_HOME_8_X64
Remove-Item -Recurse -Force $Env:JAVA_HOME_7_X64

Get-PSDrive
