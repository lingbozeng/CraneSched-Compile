#!/bin/bash

# 设置默认分支为 master
BRANCH_OR_COMMIT=${1:-master}

# 获取当前日期
DATE=$(date +%Y%m%d)

# 拉取并运行容器
docker run --rm -it \
    -v $(pwd):/workspace \
    registry.cn-hangzhou.aliyuncs.com/aicpn/ubuntu-compiler:22.04-amd64 bash -c "
    
    # 克隆项目并切换到指定分支
    cd /workspace
    git clone https://github.com/PKUHPC/CraneSched-FrontEnd.git
    cd CraneSched-FrontEnd
    git checkout $BRANCH_OR_COMMIT

    make all

    # 创建相对目录并移动文件到相应位置
    mkdir -p /workspace/usr/local
    mkdir -p /workspace/usr/lib64/cranesched
    mkdir -p /workspace/usr/lib/systemd/system
    mkdir -p /workspace/etc/crane

    \cp -r build/bin /workspace/usr/local/
    \cp -r build/plugin /workspace/usr/lib64/cranesched
    \cp etc/cfored.service /workspace/usr/lib/systemd/system
    \cp etc/cplugind.service /workspace/usr/lib/systemd/system
    \cp plugin/energy/energy.yaml /workspace/etc/crane
    \cp plugin/event/event.yaml /workspace/etc/crane
    \cp plugin/mail/mail.yaml /workspace/etc/crane
    \cp plugin/monitor/monitor.yaml /workspace/etc/crane
    \cp plugin/powerControl/powerControl.yaml /workspace/etc/crane

    # 创建压缩包
    cd /workspace
    tar -czvf CraneSched-FrontEnd-$DATE.tgz usr/ etc/

    # 删除项目和 usr 目录
    rm -rf /workspace/CraneSched-FrontEnd
    rm -rf /workspace/usr
    rm -rf /workspace/etc
"
