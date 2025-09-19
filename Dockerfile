# 使用 CentOS 7 作为基础镜像
FROM registry.cn-hangzhou.aliyuncs.com/aicpn/rockylinux-compiler:8.10-amd64

# 设置工作目录
WORKDIR /root

# 拷贝本地的 Go 安装包到容器内
COPY go1.22.2.linux-amd64.tar.gz /root

# 解压并安装 Go
RUN tar -C /usr/local -xzf /root/go1.22.2.linux-amd64.tar.gz && \
    # 删除安装包以节省空间
    rm -f /root/go1.22.2.linux-amd64.tar.gz

# 设置 Go 环境变量
ENV GOROOT=/usr/local/go
ENV GOPATH=/usr/local/gopath
ENV PATH=$PATH:$GOROOT/bin:$GOPATH/bin

# 设置 Go 环境变量和代理
RUN go env -w GOPROXY=https://goproxy.cn,direct
RUN go env -w GO111MODULE=on

# 安装 protobuf 和 gRPC 插件
RUN go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
RUN go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest

# 验证安装的 Go 版本
RUN go version
