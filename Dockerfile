# === 阶段1：构建汉化文件 ===
# 使用一个包含 Node.js 环境的基础镜像，因为生成脚本需要它
FROM node:18 AS builder

# 设置工作目录
WORKDIR /app

# 复制 package.json 文件并安装依赖项
# 这是运行生成脚本所必需的
COPY package.json .
RUN npm install

# 复制所有生成汉化文件所需的源代码
COPY . .

# 执行核心的“生成”命令，这会在 /app 目录下创建一个 dist 文件夹
RUN npm run i18n:translate


# === 阶段2：构建最终运行镜像 ===
# 使用官方的 n8n 镜像作为最终的运行环境
FROM n8nio/n8n:latest

# 设置默认语言为中文
ENV N8N_DEFAULT_LOCALE=zh-CN

# 从“阶段1”(builder)中，将刚刚生成好的 dist 文件夹，
# 复制到 n8n 镜像的正确位置。
COPY --from=builder /app/dist /usr/local/lib/node_modules/n8n/node_modules/n8n-editor-ui/dist
