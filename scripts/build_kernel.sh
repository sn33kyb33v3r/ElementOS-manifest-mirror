#!/bin/bash
set -e

cd /elementos/${TARGET_KERNEL_SOURCE}
make ${TARGET_KERNEL_DEFCONFIG}
make -j$(nproc) Image.gz-dtb
cp arch/arm64/boot/Image.gz-dtb /elementos/out/target/product/r8s/kernel
