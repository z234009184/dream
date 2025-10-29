#!/bin/bash
# 生成测试视频（需要安装 ffmpeg）
# 安装 ffmpeg: brew install ffmpeg

set -e

VIDEOS_DIR="assets/images/wallpapers"

echo "🎬 生成测试视频..."
echo ""

# 检查 ffmpeg 是否安装
if ! command -v ffmpeg &> /dev/null; then
    echo "❌ 未找到 ffmpeg"
    echo "请先安装: brew install ffmpeg"
    exit 1
fi

# 创建目录
mkdir -p "$VIDEOS_DIR/abstract"
mkdir -p "$VIDEOS_DIR/aesthetic"
mkdir -p "$VIDEOS_DIR/gradient"
mkdir -p "$VIDEOS_DIR/minimal"

# 1. 抽象渐变动画 (彩虹渐变)
echo "📹 生成 abstract_1.mp4..."
ffmpeg -f lavfi -i "color=c=0x6C5CE7:s=1080x1920:d=10,format=rgb24" \
    -vf "geq=r='255*sin(2*PI*(X/W+T/5))':g='255*sin(2*PI*(Y/H+T/5))':b='255*sin(2*PI*((X+Y)/(W+H)+T/5))'" \
    -c:v libx264 -t 10 -pix_fmt yuv420p -y "$VIDEOS_DIR/abstract/abstract_1.mp4" 2>/dev/null

# 2. 美学渐变 (紫色到粉色)
echo "📹 生成 aesthetic_1.mp4..."
ffmpeg -f lavfi -i "color=c=0x6C5CE7:s=1080x1920:d=10" \
    -vf "geq=r='255*0.5*(1+sin(2*PI*T/10))':g='100':b='200+55*sin(2*PI*T/10)'" \
    -c:v libx264 -t 10 -pix_fmt yuv420p -y "$VIDEOS_DIR/aesthetic/aesthetic_1.mp4" 2>/dev/null

# 3. 渐变动画 (平滑渐变)
echo "📹 生成 gradient_1.mp4..."
ffmpeg -f lavfi -i "color=c=black:s=1080x1920:d=10" \
    -vf "geq=r='255*(Y/H)':g='255*(1-Y/H)*0.6':b='255*0.8'" \
    -c:v libx264 -t 10 -pix_fmt yuv420p -y "$VIDEOS_DIR/gradient/gradient_1.mp4" 2>/dev/null

# 4. 极简动画 (呼吸效果)
echo "📹 生成 minimal_1.mp4..."
ffmpeg -f lavfi -i "color=c=0x1C1C1E:s=1080x1920:d=10" \
    -vf "geq=r='50+50*sin(2*PI*T/5)':g='50+50*sin(2*PI*T/5)':b='50+50*sin(2*PI*T/5)'" \
    -c:v libx264 -t 10 -pix_fmt yuv420p -y "$VIDEOS_DIR/minimal/minimal_1.mp4" 2>/dev/null

echo ""
echo "✅ 完成！生成了 4 个测试视频"
echo ""
echo "📁 视频位置："
echo "  - $VIDEOS_DIR/abstract/abstract_1.mp4"
echo "  - $VIDEOS_DIR/aesthetic/aesthetic_1.mp4"
echo "  - $VIDEOS_DIR/gradient/gradient_1.mp4"
echo "  - $VIDEOS_DIR/minimal/minimal_1.mp4"
echo ""
echo "📝 下一步："
echo "  1. 运行 'flutter pub get'"
echo "  2. 热重载应用查看效果"

