# ChromiumOS Board Notes

This repository collects notes, links, and experiments around ChromiumOS-like
systems on common PCs and ARM development boards.

The initial focus is:

- What ChromiumOS is and how it relates to ChromeOS.
- Which installation route fits normal PCs, Raspberry Pi boards, RK3566 boards,
  and RK3576 boards.
- Which projects are worth tracking for future board images and ports.

## Quick Summary

ChromiumOS is the open-source base of Google's ChromeOS. It is not a universal
installer that can be flashed to every device. In practice, the correct route
depends heavily on the device class:

| Device class | Practical route | Current status |
| --- | --- | --- |
| Official Chromebook / Chromebox / Chromebase | ChromeOS | Vendor-supported |
| Old Intel/AMD PC or Mac | ChromeOS Flex | Official Google route, certified-model dependent |
| Raspberry Pi 4 / 5 / 400 / 500 | FydeOS for SBC, openFyde, or Chromium OS for Raspberry Pi | Usable community/vendor images exist |
| RK3566 / RK3568 boards | Community openFyde rk356x builds | Experimental, board-specific |
| RK3576 boards | Debian/Android first; ChromiumOS-like system requires porting | No mature public image found yet |

## Terminology

### Chromium

Chromium is the open-source browser project. Google Chrome is built from
Chromium plus Google-specific services, branding, media components, auto-update
integration, and other proprietary pieces.

Official project:

- <https://www.chromium.org/Home>
- <https://opensource.google/projects/chromium/>

### ChromiumOS

ChromiumOS is the open-source operating system project that forms the base of
ChromeOS. It is mainly useful for developers, hardware vendors, and people who
want to build or port a ChromeOS-like system.

Official project:

- <https://www.chromium.org/chromium-os/>
- <https://www.chromium.org/chromium-os/chromium-os-faq/>
- <https://opensource.google/projects/chromiumos/>

### ChromeOS

ChromeOS is Google's product OS shipped on Chromebook, Chromebox, and related
official ChromeOS devices. Compared with ChromiumOS, it includes Google's
release infrastructure, verified boot integration, device certification,
firmware/recovery flow, and product-level services.

### ChromeOS Flex

ChromeOS Flex is Google's official installable ChromeOS-like system for many old
Intel/AMD PCs and Macs. It is the most realistic path for normal laptop/desktop
reuse, but it is not for ARM boards such as Raspberry Pi or Rockchip SBCs.

Official pages:

- <https://chromeos.google/products/chromeos-flex/>
- <https://support.google.com/chromeosflex/answer/11552529>
- <https://support.google.com/chromeosflex/answer/11513094>
- <https://support.google.com/chromeosflex/answer/11542901>

Important limits:

- Requires Intel or AMD x86-64 hardware.
- Requires at least 4 GB RAM and 16 GB storage.
- Requires USB boot support and BIOS/UEFI admin access.
- Certified models are the only models Google treats as supported.
- ARM boards are not supported.
- Some hardware features can be missing even on machines that boot.

## What ChromiumOS-like Systems Are Good For

The core idea is a browser-first, cloud-first operating system. Common use cases:

- Web browsing and web applications.
- Google Workspace and other SaaS workflows.
- Education devices.
- Enterprise managed terminals.
- Kiosk and digital-signage devices.
- Lightweight shared machines.
- Reusing old PCs as web terminals.
- Hardware-vendor bring-up for ChromeOS-like devices.

It is not a drop-in replacement for every Linux desktop use case. Hardware
enablement, GPU acceleration, Wi-Fi, Bluetooth, touch, camera, suspend/resume,
Android support, and Linux container support are all board- and build-specific.

## Raspberry Pi Route

For Raspberry Pi, the usable options are not official Google ChromeOS images.
They are community or vendor-maintained ChromiumOS/openFyde/FydeOS builds.

### FydeOS for SBC - Raspberry Pi

Best fit when the goal is to flash an image and use the system with the least
build work.

Links:

- <https://fydeos.io/download/device/rpi5-fydeos/>
- <https://fydeos.com/help/knowledge-base/installation-guides/fydeos-for-sbc/raspberry-pi/>

Practical notes:

- Targets Raspberry Pi 4, Raspberry Pi 5, Pi 400, and related newer Pi boards.
- 2 GB or lower memory boards are not suitable according to FydeOS notes.
- Use 4 GB or 8 GB boards where possible.

### openFyde for Raspberry Pi

Best fit when the goal is a more open ChromiumOS-like system and the user is
willing to tolerate more rough edges.

Links:

- <https://openfyde.io/>
- <https://github.com/openFyde/overlay-rpi5-openfyde/releases>
- <https://github.com/openFyde/overlay-rpi4-openfyde/releases>

### Chromium OS for Raspberry Pi

This project is closest to "ChromiumOS on Raspberry Pi". It is maintained by the
FydeOS team and tries to stay closer to vanilla ChromiumOS than FydeOS.

Links:

- <https://github.com/FydeOS/chromium_os-raspberry_pi>
- <https://github.com/FydeOS/chromium_os-raspberry_pi/releases>

Supported target range from the project:

- Raspberry Pi 4B
- Raspberry Pi 400
- Raspberry Pi 5

Not recommended:

- Raspberry Pi 3 / 3B+
- Raspberry Pi Zero / Zero 2
- Older low-memory boards

Typical flashing flow:

1. Download the matching image file.
2. Flash it to a microSD card or USB storage with balenaEtcher, Raspberry Pi
   Imager, or Rufus.
3. Boot the board.
4. Expect board-specific limitations around GPU, Wi-Fi, Bluetooth, Linux
   containers, and Android support.

## RK3566 / RK3568 Route

The most relevant lead found so far is a FydeOS community post sharing
experimental openFyde `rk356x` builds.

Community post:

- <https://community.fydeos.com/t/topic/46279>

`rk356x` covers:

- RK3566
- RK3568
- RK3568J

Boards mentioned in the community build:

- Radxa ROCK 3A / 3B, RK3568
- Radxa ROCK 3C, RK3566/RK3568 family
- Radxa ZERO 3E / ZERO 3W, RK3566
- Orange Pi 3B, RK3566

Known limitations from the community notes:

- Local account only.
- Not recommended for serious work.
- Linux subsystem is not available.
- Android subsystem is not available.
- Mouse cursor may be invisible after boot until the cursor color is changed.
- Minimum 2 GB RAM, 4 GB recommended.
- Orange Pi 3B Wi-Fi is not available in the shared notes.
- Zero 3W Wi-Fi support depends on the exact wireless module variant.

### Taishan Pi RK3566

The community post has a Taishan Pi section, but it is marked TODO. That means
there is no confirmed ready-to-flash Taishan Pi RK3566 image in the material
found so far.

Practical expectation:

- Existing Linux/Android images remain the realistic baseline.
- openFyde on Taishan Pi RK3566 probably requires board porting work.
- The rk356x community builds can be useful references, not guaranteed images.

## RK3576 Route

No mature public ChromiumOS/openFyde/FydeOS image for RK3576 was found during
this investigation.

Relevant RK3576 boards to watch:

- KICKPI K7 / K7C
- Taishan Pi 3
- Radxa ROCK 4D
- FriendlyElec NanoPi M5
- Other RK3576 SBCs and industrial boards

Current practical route:

- Use vendor Debian, Ubuntu, Buildroot, or Android images first.
- Treat ChromiumOS/openFyde as a future porting project unless a board-specific
  image appears.

The openFyde official support list currently leans toward Raspberry Pi and
RK3588/RK3588S boards rather than RK3576.

openFyde official site:

- <https://openfyde.io/>

There is a weak signal that RK3576 matters to the FydeOS ecosystem because
FydeOS AI configuration material includes `target_platform: rk3576`, but that is
not the same as a public bootable OS image.

FydeOS AI setup page:

- <https://fydeos.io/help/knowledge-base/getting-started/setup/fydeos-ai-assistant/>

## Porting Reality Check

For an unsupported ARM board, "install ChromiumOS" usually means doing a board
port. Work can include:

- Bootloader and partition layout.
- Kernel branch selection.
- Device tree.
- GPU/display enablement.
- Wi-Fi and Bluetooth firmware.
- Audio routing.
- Touch and input devices.
- Camera support.
- Power management and suspend/resume.
- ChromiumOS board overlay.
- Verified boot decisions.
- Recovery image behavior.
- Update strategy.

ChromiumOS board porting reference:

- <https://www.chromium.org/chromium-os/developer-library/guides/chromiumos-board-porting-guide/>

## Decision Guide

Use this quick decision tree before spending time on a board:

1. If the device is an old Intel/AMD laptop or desktop, check ChromeOS Flex
   first.
2. If the device is Raspberry Pi 4/5/400/500, check FydeOS for SBC, openFyde,
   and Chromium OS for Raspberry Pi.
3. If the device is RK3566/RK3568, check the openFyde rk356x community build.
4. If the device is RK3576, assume no ready image until proven otherwise.
5. If the target board is unsupported, treat the work as an OS port, not a
   normal installation.

## Link Parking Lot

Add future links here before sorting them into sections.

- ChromiumOS FAQ: <https://www.chromium.org/chromium-os/chromium-os-faq/>
- ChromiumOS quick start: <https://www.chromium.org/chromium-os/quick-start-guide/>
- ChromiumOS board porting guide: <https://www.chromium.org/chromium-os/developer-library/guides/chromiumos-board-porting-guide/>
- ChromeOS Flex install requirements: <https://support.google.com/chromeosflex/answer/11552529>
- ChromeOS Flex certified models: <https://support.google.com/chromeosflex/answer/11513094>
- ChromeOS Flex differences: <https://support.google.com/chromeosflex/answer/11542901>
- FydeOS for Raspberry Pi: <https://fydeos.io/download/device/rpi5-fydeos/>
- openFyde: <https://openfyde.io/>
- Chromium OS for Raspberry Pi: <https://github.com/FydeOS/chromium_os-raspberry_pi>
- openFyde RK356x community build: <https://community.fydeos.com/t/topic/46279>

## Future Notes Template

Use this template when adding a new board or image:

```md
## Board Name

- SoC:
- RAM:
- Storage:
- Display:
- Network:
- Image source:
- Image version:
- Flash method:
- Boot result:
- Working:
- Broken:
- Logs:
- Verdict:
```
