[`libwebrtc`] binaries
======================

[![CocoaPods](https://img.shields.io/cocoapods/v/instrumentisto-libwebrtc-bin "CocoaPods")](https://cocoapods.org/pods/instrumentisto-libwebrtc-bin)
[![CI](https://github.com/instrumentisto/libwebrtc-bin/actions/workflows/ci.yml/badge.svg?branch=main "CI")](https://github.com/instrumentisto/libwebrtc-bin/actions?query=workflow%3ACI+branch%3Amain)

Build scripts for statically linked [`libwebrtc`] binaries, used by [Medea Flutter-WebRTC].




## Build matrix

|         |          x64           |         arm64          |
|--------:|:----------------------:|:----------------------:| 
| Android | `.aar` (`.a` + `.jar`) | `.aar` (`.a` + `.jar`) | 
|     iOS |     `.xcframework`     |     `.xcframework`     | 
|   Linux |          `.a`          |          `.a`          | 
|   macOS |          `.a`          |          `.a`          | 
| Windows |         `.lib`         |                        | 




## References 

- https://webrtc.googlesource.com/src
- https://github.com/crow-misia/libwebrtc-bin
- https://github.com/aisouard/libwebrtc
- https://github.com/shiguredo/shiguredo-webrtc-windows




## License

Copyright © 2022-2025  Instrumentisto Team <https://github.com/instrumentisto>

This repository is subject to the terms of the [Blue Oak Model License 1.0.0](https://github.com/instrumentisto/libwebrtc-bin/blob/main/LICENSE.md). If a copy of the [BlueOak-1.0.0](https://spdx.org/licenses/BlueOak-1.0.0.html) license was not distributed with this file, You can obtain one at <https://blueoakcouncil.org/license/1.0.0>.

Forked from [`crow-misia/libwebrtc-bin`](https://github.com/crow-misia/libwebrtc-bin), which is licensed under the [Apache License 2.0](https://github.com/crow-misia/libwebrtc-bin/blob/main/LICENSE).

[`libwebrtc`] itself is licensed under the [BSD 3-Clause "New" or "Revised" License](https://webrtc.googlesource.com/src/+/refs/heads/main).




[`crow-misia/libwebrtc-bin`]: https://github.com/crow-misia/libwebrtc-bin
[`libwebrtc`]: https://webrtc.googlesource.com/src
[Medea Flutter-WebRTC]: https://github.com/instrumentisto/medea-flutter-webrtc
