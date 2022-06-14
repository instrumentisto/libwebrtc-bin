$ErrorActionPreference = "Stop"

Get-PSDrive

# JVM の削除
if ($Env:JAVA_HOME_11_X64 -ne $null) {
  Remove-Item -Recurse -Force $Env:JAVA_HOME_11_X64
}
if ($Env:JAVA_HOME_8_X64 -ne $null) {
  Remove-Item -Recurse -Force $Env:JAVA_HOME_8_X64
}
if ($Env:JAVA_HOME_7_X64 -ne $null) {
  Remove-Item -Recurse -Force $Env:JAVA_HOME_7_X64
}

# Android SDK の削除
if ($Env:ANDROID_HOME -ne $null) {
  echo "$Env:ANDROID_HOME"
  (Get-Item $Env:ANDROID_HOME).Delete()
  #Remove-Item $Env:ANDROID_HOME -Recurse -Force
}
Remove-Item -Recurse -Force $Env:ANDROID_NDK_HOME

Get-PSDrive
