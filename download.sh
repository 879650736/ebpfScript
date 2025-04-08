#!/usr/bin/sh

# 获取原始内核版本用于目录命名
kernel_version=$(uname -r)
pkg_dir="./$kernel_version"
headers_dir="./${kernel_version}-headers"


base_version=$(echo "$kernel_version" | cut -d'-' -f1)
major_version=$(echo "$base_version" | cut -d'.' -f1) 
src_dir="./linux-src-${base_version}"

# 调整版本号用于包名（替换第一个'-'为'.'）
adjusted_version=$(echo "$kernel_version" | sed 's/-/./1')
pkg_name="linux-${adjusted_version}-x86_64.pkg.tar.zst"
headers_name="linux-headers-${adjusted_version}-x86_64.pkg.tar.zst"
mirror_url="https://mirrors.edge.kernel.org/archlinux/core/os/x86_64/${pkg_name}"
headers_mirror_url="https://mirrors.edge.kernel.org/archlinux/core/os/x86_64/${headers_name}"

# 官方内核源码URL
src_url="https://www.kernel.org/pub/linux/kernel/v${major_version}.x/linux-${base_version}.tar.xz"
src_name="linux-${base_version}.tar.xz"

# 下载包（仅在文件不存在时下载）
if ! wget -nc "$mirror_url"; then
    echo "错误：内核包下载失败，请检查版本号或镜像可用性"
    exit 1
fi
if ! wget -nc "$headers_mirror_url"; then
    echo "错误：头文件包下载失败，请检查版本号或镜像可用性"
    exit 1
fi
# 下载内核源码
echo "下载官方内核源码..."
if ! wget -nc "$src_url"; then
    echo "错误：内核源码下载失败，请检查版本号或镜像可用性"
    exit 1
fi

# 解压内核包到版本目录
if [ -f "$pkg_name" ]; then
    echo "正在解压内核包到 $pkg_dir ..."
    mkdir -p "$pkg_dir"
    unzstd "$pkg_name" -o "${pkg_name%.zst}" || exit 1
    tar -xvf "${pkg_name%.zst}" -C "$pkg_dir" || exit 1
    echo "内核包解压完成"
else
    echo "错误：内核包文件 $pkg_name 不存在"
    exit 1
fi

# 解压头文件包到headers目录
if [ -f "$headers_name" ]; then
    echo "正在解压头文件包到 $headers_dir ..."
    mkdir -p "$headers_dir"
    unzstd "$headers_name" -o "${headers_name%.zst}" || exit 1
    tar -xvf "${headers_name%.zst}" -C "$headers_dir" || exit 1
    echo "头文件包解压完成"
else
    echo "错误：头文件包文件 $headers_name 不存在"
    exit 1
fi
# 解压内核源码
if [ -f "$src_name" ]; then
    echo "正在解压内核源码到 $src_dir ..."
    mkdir -p "$src_dir"
    tar -xvf "$src_name" -C "$src_dir" --strip-components=1 || exit 1
    echo "内核源码解压完成"
else
    echo "错误：内核源码文件 $src_name 不存在"
    exit 1
fi
echo "所有操作完成"
echo "=============================="
echo "内核包目录: $pkg_dir"
echo "头文件目录: $headers_dir"
echo "源码目录: $src_dir"