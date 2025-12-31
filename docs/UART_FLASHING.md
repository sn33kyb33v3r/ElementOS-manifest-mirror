# ElementOS UART Flashing Instructions

This document provides detailed instructions for flashing ElementOS using UART/serial connection.

## Overview

UART flashing is an advanced method that provides low-level access to the device's bootloader. This method is useful when:
- The device is bricked
- Normal flashing methods fail
- You need to debug bootloader issues
- You want to flash custom bootloaders

## Prerequisites

### Hardware Required

- **Samsung Galaxy S20 FE (SM-G780F)**
- **USB to UART adapter** (FTDI FT232RL or similar)
- **Jumper wires** (4x female-to-female)
- **Computer** with Linux/macOS/Windows
- **Soldering equipment** (if making permanent connection)

### Software Required

- **Heimdall** (Linux/macOS) or **Odin** (Windows)
- **Terminal emulator** (minicom, screen, PuTTY)
- **ElementOS build artifacts** (boot.img, vendor_boot.img)

## UART Connection

### Pinout

The Samsung Galaxy S20 FE UART pins are located on the motherboard:

```
UART Header (JTAG):
┌─────────────────┐
│ 1 - VCC (3.3V)  │
│ 2 - TX          │
│ 3 - RX          │
│ 4 - GND         │
└─────────────────┘
```

### Connection Diagram

```
USB-UART Adapter    →    Samsung S20 FE
─────────────────────────────────────
VCC (3.3V)         →    VCC (Pin 1)
TX                 →    RX (Pin 3)
RX                 →    TX (Pin 2)
GND                →    GND (Pin 4)
```

**Note**: Do NOT connect VCC if your UART adapter is self-powered!

## Preparing the Device

### 1. Disassemble the Device

**Warning**: This will void your warranty!

1. Power off the device completely
2. Remove SIM card tray
3. Remove back cover (requires heat gun and suction cup)
4. Disconnect battery connector
5. Locate UART header on motherboard

### 2. Connect UART Adapter

1. Connect jumper wires to UART adapter
2. Connect other ends to UART header pins
3. Double-check connections (TX↔RX, RX↔TX, GND↔GND)
4. **Important**: Leave VCC disconnected if adapter is USB-powered

### 3. Set Up Terminal

**Linux/macOS:**
```bash
# Find UART device
ls /dev/ttyUSB*

# Connect with minicom
minicom -b 115200 -D /dev/ttyUSB0

# Or use screen
screen /dev/ttyUSB0 115200
```

**Windows:**
1. Open Device Manager
2. Find COM port number for UART adapter
3. Open PuTTY or Tera Term
4. Configure: COMx, 115200 baud, 8N1

## Bootloader Access

### 1. Enable UART Boot

1. Connect UART adapter to computer
2. Open terminal connection (115200 baud)
3. Connect device battery
4. Press and hold Volume Down + Volume Up
5. Connect USB cable
6. Device should show bootloader prompt in terminal

### 2. Bootloader Commands

Once connected, you'll see the Samsung bootloader prompt:

```
Samsung Secure Bootloader
Version: EXYNOS990-AB12345
[sbl1] >
```

Available commands:
```
help        - Show help
version     - Show bootloader version
download    - Enter download mode
fastboot    - Enter fastboot mode
recovery    - Boot recovery
reset       - Reset device
info        - Show device info
```

## Flashing Process

### Method 1: Bootloader Direct Flash

1. **Enter download mode:**
   ```
   [sbl1] > download
   ```

2. **In another terminal, flash with Heimdall:**
   ```bash
   heimdall flash --BOOT boot.img --VENDOR_BOOT vendor_boot.img
   ```

3. **Monitor progress in UART terminal**

### Method 2: Fastboot via UART

1. **Enter fastboot mode:**
   ```
   [sbl1] > fastboot
   ```

2. **Flash with fastboot:**
   ```bash
   fastboot flash boot boot.img
   fastboot flash vendor_boot vendor_boot.img
   fastboot reboot
   ```

### Method 3: Custom Bootloader

For advanced users, you can flash a custom bootloader:

1. **Build custom bootloader:**
   ```bash
   # Build lk2nd or similar
   make lk2nd_defconfig
   make -j$(nproc)
   ```

2. **Flash bootloader:**
   ```bash
   heimdall flash --BL lk2nd.img
   ```

## Debugging with UART

### Kernel Boot Logs

To capture kernel boot logs:

1. **Connect UART before booting**
2. **Boot device normally**
3. **Watch for kernel messages:**
   ```
   [    0.000000] Booting Linux on physical CPU 0x0
   [    0.000000] Linux version 5.4.147-elementos...
   ```

### Common Debug Scenarios

#### Boot Loop
```
# Watch for errors in UART output
[    2.345678] EXT4-fs (sda1): error loading journal
[    2.345679] Kernel panic - not syncing: VFS: Unable to mount root fs
```

#### Kernel Panic
```
# Capture panic message
[   12.345678] Call trace:
[   12.345679]  dump_backtrace+0x0/0x180
[   12.345680]  show_stack+0x20/0x30
```

#### SELinux Issues
```
# Check SELinux denials
[    5.678901] type=1400 audit(1640995200.123:4): avc: denied
```

## Advanced UART Operations

### Memory Dumps

```bash
# Dump memory regions
heimdall print-pit
heimdall download-pit pit.img
```

### Partition Information

```bash
# List partitions
heimdall print-pit
```

### Emergency Recovery

If the device is bricked:

1. **Connect UART**
2. **Force download mode:**
   - Short test points on motherboard
   - Or use JIG (USB adapter with 301kΩ resistor)

3. **Flash stock firmware:**
   ```bash
   heimdall flash --RECOVERY recovery.img --SYSTEM system.img --VENDOR vendor.img
   ```

## Safety Precautions

### Electrical Safety

- **Never connect 5V UART to 3.3V device**
- **Use proper grounding**
- **Disconnect power before making connections**
- **Double-check polarity before powering on**

### Device Safety

- **Backup all data before proceeding**
- **Understand risks of bricking device**
- **Have stock firmware ready for recovery**
- **Work in ESD-safe environment**

### Legal Considerations

- **Warranty will be voided**
- **May violate carrier terms**
- **Check local regulations**

## Troubleshooting

### Common Issues

#### No UART Output
- Check baud rate (115200)
- Verify TX/RX connections
- Try different terminal program
- Check UART adapter drivers

#### Garbled Output
- Verify ground connection
- Try lower baud rate (9600)
- Check for loose connections

#### Device Won't Enter Download Mode
- Check battery level (>30%)
- Try different USB cable
- Verify button combinations

#### Flashing Fails
- Check Heimdall/Odin version
- Verify driver installation
- Try different USB port

### Recovery Methods

#### EDL Mode (Emergency Download)

If all else fails:

1. **Force EDL mode:**
   - Short EDL test points
   - Connect USB cable
   - Device should show as "Qualcomm HS-USB QDLoader 9008"

2. **Use QPST/QFIL to flash:**
   - Load firehose programmer
   - Flash raw partitions

#### JTAG Recovery

For severe bricks:

1. **Connect JTAG programmer**
2. **Identify JTAG pins on motherboard**
3. **Use OpenOCD or similar to flash**

## Technical Specifications

### UART Parameters

- **Baud Rate**: 115200 bps
- **Data Bits**: 8
- **Stop Bits**: 1
- **Parity**: None
- **Flow Control**: None

### Bootloader Protocol

- **Samsung SBL**: Custom protocol
- **Fastboot**: Standard Android protocol
- **Download Mode**: Samsung proprietary

### Pin Voltages

- **VCC**: 3.3V (do not connect if USB-powered)
- **TX/RX**: 3.3V logic
- **GND**: 0V

## Resources

### Tools

- **Heimdall**: https://github.com/Benjamin-Dobell/Heimdall
- **Odin**: Samsung official flashing tool
- **QPST**: Qualcomm flashing tool
- **OpenOCD**: Open On-Chip Debugger

### Documentation

- **Samsung Bootloader**: https://developer.samsung.com/
- **Exynos Documentation**: https://developer.arm.com/
- **Android Fastboot**: https://android.googlesource.com/

### Community

- **XDA Forums**: https://forum.xda-developers.com/
- **ElementOS Matrix**: #elementos:matrix.org
- **GitHub Issues**: https://gitlab.com/elementos/elementos/issues

## Disclaimer

UART flashing is an advanced procedure that carries significant risks:

- **Permanent bricking** of device
- **Warranty voiding**
- **Data loss**
- **Hardware damage**

Proceed at your own risk. Always have a recovery plan and backup of stock firmware.

## License

This document is part of ElementOS and is licensed under the Apache License 2.0.