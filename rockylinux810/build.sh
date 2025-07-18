#!/bin/bash

# 设置默认分支为 master
BRANCH_OR_COMMIT=${1:-master}

# 获取当前日期
DATE=$(date +%Y%m%d)

# 拉取并运行容器
docker run --rm -it \
    -v $(pwd):/workspace \
    registry.cn-hangzhou.aliyuncs.com/aicpn/rockylinux-compiler:8.10-amd64 bash -c "
    
    # 克隆项目并切换到指定分支
    cd /workspace
    git clone https://github.com/PKUHPC/CraneSched.git
    cd CraneSched
    git checkout $BRANCH_OR_COMMIT

    # 禁用avx512指令集，程序运行机器只支持avx2指令集，使用 sed 自动替换 CMakeLists.txt 中的 -march=native 为 -mavx2 -march=native
    sed -i 's/-march=native/-mavx2 -march=native -mno-avx512f -mno-avx512dq -mno-avx512ifma -mno-avx512cd -mno-avx512bw -mno-avx512vl -mno-avx512vbmi -mno-avx512vbmi2 -mno-avx512vnni -mno-avx512bitalg -mno-avx512vpopcntdq/g' CMakeLists.txt

    # 启用 gcc-toolset-14
    scl_source enable gcc-toolset-14

    # 创建 build 目录并进入
    mkdir -p build
    cd build

    # 配置编译环境
    cmake -G Ninja -DCMAKE_C_COMPILER=/opt/rh/gcc-toolset-14/root/usr/bin/gcc -DCMAKE_CXX_COMPILER=/opt/rh/gcc-toolset-14/root/usr/bin/g++ ..

    # 执行编译
    cmake --build . --target cranectld craned pam_crane

    # 创建相对目录并移动文件到相应位置
    mkdir -p /workspace/usr/local/bin
    mkdir -p /workspace/usr/lib64/security

    cp src/CraneCtld/cranectld /workspace/usr/local/bin/
    cp src/Craned/craned /workspace/usr/local/bin/
    cp src/Misc/Pam/pam_crane.so /workspace/usr/lib64/security/

    # 创建压缩包
    cd /workspace
    tar -czvf CraneSched-$DATE.tgz usr/local/bin/cranectld usr/local/bin/craned usr/lib64/security/pam_crane.so

    # 删除项目和 usr 目录
    # rm -rf /workspace/CraneSched
    rm -rf /workspace/usr
"
