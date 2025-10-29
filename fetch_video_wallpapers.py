#!/usr/bin/env python3
"""
精美视频壁纸下载器
支持 Pexels 视频 API
自动筛选竖屏高分辨率视频，适配 iPhone
自动生成视频缩略图
"""

import os
import sys
import requests
import argparse
import subprocess
import shutil
from tqdm import tqdm
from typing import List, Dict

# iPhone 视频参数
MIN_WIDTH = 1080  # 最低宽度要求
MIN_HEIGHT = 1920  # 最低高度要求

# API 配置
API_KEYS = {
    "pexels": os.getenv("PEXELS_API_KEY", "UVnOyCZ3oAHshzgQewkztSoRWoe1gbzqFDJTN00dEJoc8RfkgIkX3AXj"),
}


def check_ffmpeg():
    """检查 FFmpeg 是否安装"""
    if not shutil.which('ffmpeg'):
        print("\n⚠️  警告：未检测到 FFmpeg")
        print("\nFFmpeg 用于生成视频缩略图。安装方法：")
        print("  macOS:   brew install ffmpeg")
        print("  Ubuntu:  sudo apt install ffmpeg")
        print("  Windows: 下载 https://ffmpeg.org/download.html\n")
        return False
    return True


def generate_thumbnail(video_path: str, thumbnail_path: str) -> bool:
    """生成视频缩略图"""
    try:
        os.makedirs(os.path.dirname(thumbnail_path), exist_ok=True)
        
        cmd = [
            'ffmpeg',
            '-i', video_path,
            '-ss', '00:00:00',       # 第 0 秒
            '-vframes', '1',          # 只提取 1 帧
            '-vf', 'scale=400:-1',    # 缩放到宽度 400px
            '-y',                     # 覆盖已存在的文件
            thumbnail_path
        ]
        
        result = subprocess.run(
            cmd,
            capture_output=True,
            timeout=10
        )
        
        if result.returncode == 0 and os.path.exists(thumbnail_path):
            file_size = os.path.getsize(thumbnail_path) / 1024
            print(f"  📸 生成缩略图: {os.path.basename(thumbnail_path)} ({file_size:.1f} KB)")
            return True
        else:
            print(f"  ⚠️  缩略图生成失败")
            return False
            
    except Exception as e:
        print(f"  ⚠️  缩略图生成异常: {e}")
        return False


class VideoDownloader:
    """视频下载器基类"""
    
    def __init__(self, api_key: str, save_dir: str):
        self.api_key = api_key
        self.save_dir = save_dir
        self.session = requests.Session()
        os.makedirs(save_dir, exist_ok=True)
        
        # 记录已下载的 URL，避免重复
        self.downloaded_file = os.path.join(save_dir, "_downloaded.txt")
        self.downloaded_urls = self._load_downloaded()
    
    def _load_downloaded(self) -> set:
        """加载已下载的 URL 列表"""
        if os.path.exists(self.downloaded_file):
            with open(self.downloaded_file, "r") as f:
                return set(f.read().splitlines())
        return set()
    
    def _save_downloaded(self, url: str):
        """保存已下载的 URL"""
        with open(self.downloaded_file, "a") as f:
            f.write(url + "\n")
    
    def _is_portrait(self, width: int, height: int) -> bool:
        """判断是否为竖屏视频"""
        return height > width and width >= MIN_WIDTH and height >= MIN_HEIGHT
    
    def download_video(self, url: str, filename: str, generate_thumb: bool = True) -> bool:
        """下载单个视频"""
        if url in self.downloaded_urls:
            print(f"⏩ 已跳过（重复）：{filename}")
            return False
        
        file_path = os.path.join(self.save_dir, filename)
        
        try:
            with self.session.get(url, stream=True, timeout=60) as r:
                r.raise_for_status()
                total_size = int(r.headers.get('content-length', 0))
                
                progress = tqdm(
                    total=total_size,
                    unit='B',
                    unit_scale=True,
                    unit_divisor=1024,
                    desc=f"⬇️  {filename}",
                    ascii=True
                )
                
                with open(file_path, "wb") as f:
                    for chunk in r.iter_content(chunk_size=8192):
                        if chunk:
                            f.write(chunk)
                            progress.update(len(chunk))
                progress.close()
                
                file_size_mb = os.path.getsize(file_path) / (1024 * 1024)
                print(f"✅ 已保存：{file_path} ({file_size_mb:.2f} MB)")
                
                # 生成缩略图
                if generate_thumb and check_ffmpeg():
                    thumb_filename = os.path.splitext(filename)[0] + '.jpg'
                    thumb_path = os.path.join(self.save_dir, 'thumbnails', thumb_filename)
                    generate_thumbnail(file_path, thumb_path)
                
                self._save_downloaded(url)
                self.downloaded_urls.add(url)
                return True
                
        except Exception as e:
            print(f"⚠️  下载失败：{filename}\n错误：{e}")
            if os.path.exists(file_path):
                os.remove(file_path)
            return False


class PexelsVideoDownloader(VideoDownloader):
    """Pexels 视频下载器"""
    
    API_URL = "https://api.pexels.com/videos/search"
    
    def search_videos(self, query: str, count: int = 5) -> List[Dict]:
        """搜索视频"""
        if not self.api_key:
            print("⚠️  未配置 Pexels API Key，跳过")
            return []
        
        print(f"\n🔍 正在从 Pexels 搜索视频：{query}")
        
        params = {
            "query": f"{query} mobile wallpaper animation",
            "per_page": min(count * 3, 80),  # 多获取一些，筛选后可能不够
            "orientation": "portrait",  # 竖屏
        }
        
        headers = {
            "Authorization": self.api_key,
        }
        
        try:
            response = self.session.get(self.API_URL, params=params, headers=headers, timeout=10)
            response.raise_for_status()
            data = response.json()
            
            videos = []
            for item in data.get("videos", []):
                video_files = item.get("video_files", [])
                
                # 查找最高质量的视频文件（优先 HD）
                best_video = None
                max_resolution = 0
                
                for vf in video_files:
                    width = vf.get("width", 0)
                    height = vf.get("height", 0)
                    quality = vf.get("quality", "")
                    file_type = vf.get("file_type", "")
                    
                    # 只要 mp4 格式的竖屏视频
                    if file_type == "video/mp4" and self._is_portrait(width, height):
                        resolution = width * height
                        
                        # 优先选择 HD 质量，或更高分辨率
                        if quality == "hd" or resolution > max_resolution:
                            best_video = {
                                "url": vf["link"],
                                "width": width,
                                "height": height,
                                "quality": quality,
                            }
                            max_resolution = resolution
                
                if best_video:
                    videos.append({
                        "id": item["id"],
                        "duration": item.get("duration", 0),
                        "url": best_video["url"],
                        "width": best_video["width"],
                        "height": best_video["height"],
                        "quality": best_video["quality"],
                        "user": item.get("user", {}).get("name", "Unknown"),
                    })
                
                if len(videos) >= count:
                    break
            
            print(f"✨ 找到 {len(videos)} 个合适的视频")
            return videos
            
        except Exception as e:
            print(f"❌ Pexels 搜索失败：{e}")
            return []
    
    def download_videos(self, query: str, count: int = 5):
        """下载视频"""
        videos = self.search_videos(query, count)
        
        success = 0
        for i, video in enumerate(videos, 1):
            duration = int(video["duration"])
            quality = video["quality"]
            filename = f"{query}_{i}_{video['id']}_{quality}_{duration}s.mp4"
            
            print(f"\n📹 视频 {i}/{len(videos)}: {video['width']}x{video['height']} {quality.upper()} {duration}s")
            
            if self.download_video(video["url"], filename, generate_thumb=True):
                success += 1
        
        print(f"\n📊 {query.capitalize()} - 成功下载 {success}/{len(videos)} 个视频")


def update_pubspec_yaml():
    """自动更新 pubspec.yaml 的 assets 配置"""
    yaml_path = 'pubspec.yaml'
    
    if not os.path.exists(yaml_path):
        print("⚠️  未找到 pubspec.yaml")
        return False
    
    print("\n📝 更新 pubspec.yaml...")
    
    try:
        with open(yaml_path, 'r', encoding='utf-8') as f:
            lines = f.readlines()
        
        # 找到 assets 部分并替换
        new_lines = []
        in_assets = False
        assets_replaced = False
        indent_count = 0
        
        for line in lines:
            # 检测 assets 开始
            if 'assets:' in line and not line.strip().startswith('#'):
                in_assets = True
                assets_replaced = True
                indent_count = len(line) - len(line.lstrip())
                
                # 写入新的 assets 配置
                new_lines.append(line)
                new_lines.append(f"{' ' * (indent_count + 2)}# 图片资源\n")
                new_lines.append(f"{' ' * (indent_count + 2)}- assets/images/\n")
                new_lines.append(f"{' ' * (indent_count + 2)}- assets/images/wallpapers/abstract/\n")
                new_lines.append(f"{' ' * (indent_count + 2)}- assets/images/wallpapers/aesthetic/\n")
                new_lines.append(f"{' ' * (indent_count + 2)}- assets/images/wallpapers/gradient/\n")
                new_lines.append(f"{' ' * (indent_count + 2)}- assets/images/wallpapers/minimal/\n")
                new_lines.append(f"{' ' * (indent_count + 2)}- assets/images/avatars/anime/\n")
                new_lines.append(f"{' ' * (indent_count + 2)}- assets/images/avatars/cute/\n")
                new_lines.append(f"{' ' * (indent_count + 2)}- assets/images/avatars/minimal/\n")
                new_lines.append(f"{' ' * (indent_count + 2)}- assets/images/avatars/vintage/\n")
                new_lines.append(f"{' ' * (indent_count + 2)}- assets/images/others/\n")
                new_lines.append(f"{' ' * (indent_count + 2)}\n")
                new_lines.append(f"{' ' * (indent_count + 2)}# 视频资源\n")
                new_lines.append(f"{' ' * (indent_count + 2)}- assets/videos/liquid/\n")
                new_lines.append(f"{' ' * (indent_count + 2)}- assets/videos/liquid/thumbnails/\n")
                new_lines.append(f"{' ' * (indent_count + 2)}- assets/videos/colorful/\n")
                new_lines.append(f"{' ' * (indent_count + 2)}- assets/videos/colorful/thumbnails/\n")
                continue
            
            # 跳过原有的 assets 条目
            if in_assets:
                # 检测 assets 结束（遇到新的顶级配置项）
                if line.strip() and not line.strip().startswith('-') and not line.strip().startswith('#'):
                    if len(line) - len(line.lstrip()) <= indent_count:
                        in_assets = False
                        new_lines.append(line)
                continue
            
            new_lines.append(line)
        
        if assets_replaced:
            with open(yaml_path, 'w', encoding='utf-8') as f:
                f.writelines(new_lines)
            print("✅ pubspec.yaml 已更新")
            return True
        else:
            print("⚠️  未找到 assets 配置")
            return False
            
    except Exception as e:
        print(f"❌ 更新 pubspec.yaml 失败：{e}")
        return False


def main():
    parser = argparse.ArgumentParser(
        description="精美视频壁纸下载器 - 支持 Pexels Videos",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
示例用法:
  # 下载液体动画视频
  python fetch_video_wallpapers.py --query liquid --count 5
  
  # 下载多个主题
  python fetch_video_wallpapers.py --query "liquid,colorful" --count 5

API Key 配置:
  使用 Pexels API Key
  - PEXELS_API_KEY 环境变量
  - 或通过 --pexels-key 参数
  
  免费申请: https://www.pexels.com/api/
        """
    )
    
    parser.add_argument(
        "--query", "-q",
        type=str,
        default="liquid,colorful",
        help="搜索关键词，多个用逗号分隔（默认: liquid,colorful）"
    )
    
    parser.add_argument(
        "--count", "-c",
        type=int,
        default=5,
        help="每个关键词下载的视频数量（默认: 5）"
    )
    
    parser.add_argument(
        "--dir", "-d",
        type=str,
        default="assets/videos",
        help="保存目录（默认: assets/videos）"
    )
    
    parser.add_argument(
        "--pexels-key",
        type=str,
        help="Pexels API Key"
    )
    
    parser.add_argument(
        "--no-thumbnail",
        action="store_true",
        help="不生成缩略图"
    )
    
    args = parser.parse_args()
    
    # 更新 API Key
    if args.pexels_key:
        API_KEYS["pexels"] = args.pexels_key
    
    # 解析关键词
    queries = [q.strip() for q in args.query.split(",") if q.strip()]
    
    if not queries:
        print("❌ 请至少提供一个搜索关键词")
        sys.exit(1)
    
    if not API_KEYS["pexels"]:
        print("\n❌ 错误：未配置 Pexels API Key")
        print("\n请通过以下方式之一配置:")
        print("  1. 环境变量: export PEXELS_API_KEY='your_key'")
        print("  2. 命令行参数: --pexels-key YOUR_KEY")
        print("\n免费申请: https://www.pexels.com/api/")
        sys.exit(1)
    
    # 检查 FFmpeg
    if not args.no_thumbnail:
        has_ffmpeg = check_ffmpeg()
        if not has_ffmpeg:
            print("\n⚠️  将跳过缩略图生成，或使用 --no-thumbnail 参数")
            response = input("\n是否继续？(y/N): ")
            if response.lower() != 'y':
                sys.exit(0)
    
    print("=" * 60)
    print("🎬 精美视频壁纸下载器")
    print("=" * 60)
    print(f"📱 目标: 竖屏高清视频 (至少 {MIN_WIDTH}x{MIN_HEIGHT})")
    print(f"🎯 优先: HD 质量，无文件大小限制")
    print(f"🔍 搜索关键词: {', '.join(queries)}")
    print(f"📊 每个关键词下载: {args.count} 个视频")
    print(f"📂 保存路径: {args.dir}")
    print(f"📸 生成缩略图: {'否' if args.no_thumbnail else '是'}")
    print("=" * 60)
    
    # 开始下载
    for query in queries:
        query_dir = os.path.join(args.dir, query.replace(" ", "_"))
        
        print(f"\n{'=' * 60}")
        print(f"📥 开始下载主题: {query}")
        print(f"{'=' * 60}")
        
        downloader = PexelsVideoDownloader(API_KEYS["pexels"], query_dir)
        downloader.download_videos(query, args.count)
    
    # 更新 pubspec.yaml
    print("\n" + "=" * 60)
    update_pubspec_yaml()
    
    print("\n" + "=" * 60)
    print("🎉 所有视频下载完成！")
    print("=" * 60)
    print(f"\n💡 提示:")
    print(f"  1. 视频已保存到: {args.dir}/")
    print(f"  2. pubspec.yaml 已自动更新")
    print(f"  3. 运行 'flutter pub get' 来应用更改")
    print(f"  4. 热重载应用查看效果\n")


if __name__ == "__main__":
    if sys.version_info.major < 3:
        print("⚠️  请使用 Python 3 运行此脚本")
        sys.exit(1)
    
    main()
