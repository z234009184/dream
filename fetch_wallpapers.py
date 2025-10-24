#!/usr/bin/env python3
"""
精美手机壁纸下载器
支持 Unsplash、Pexels、Pixabay 三大平台
自动筛选竖屏高分辨率壁纸，适配 iPhone 16 Pro Max (2868×1320)
"""

import os
import sys
import yaml
import requests
import argparse
from tqdm import tqdm
from typing import List, Dict

# iPhone 16 Pro Max 屏幕参数
IPHONE_16_PRO_MAX_WIDTH = 1320
IPHONE_16_PRO_MAX_HEIGHT = 2868
MIN_WIDTH = 1080  # 最低宽度要求
MIN_HEIGHT = 1920  # 最低高度要求

# API 配置（需要用户自己申请免费 API Key）
# Unsplash: https://unsplash.com/developers
# Pexels: https://www.pexels.com/api/
# Pixabay: https://pixabay.com/api/docs/

API_KEYS = {
    "unsplash": os.getenv("UNSPLASH_ACCESS_KEY", "PFlTx2bnjVBr79J1smQTL3eCp8nvsYG9Jc_te180kok"),
    "pexels": os.getenv("PEXELS_API_KEY", "UVnOyCZ3oAHshzgQewkztSoRWoe1gbzqFDJTN00dEJoc8RfkgIkX3AXj"),
    "pixabay": os.getenv("PIXABAY_API_KEY", "52879973-e999f09061badd52d0cc7fa14"),
}


class WallpaperDownloader:
    """壁纸下载器基类"""
    
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
        """判断是否为竖屏壁纸"""
        return height > width and width >= MIN_WIDTH and height >= MIN_HEIGHT
    
    def download_image(self, url: str, filename: str) -> bool:
        """下载单张图片"""
        if url in self.downloaded_urls:
            print(f"⏩ 已跳过（重复）：{filename}")
            return False
        
        file_path = os.path.join(self.save_dir, filename)
        
        try:
            with self.session.get(url, stream=True, timeout=30) as r:
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
                
                print(f"✅ 已保存：{file_path}")
                self._save_downloaded(url)
                self.downloaded_urls.add(url)
                return True
                
        except Exception as e:
            print(f"⚠️  下载失败：{filename}\n错误：{e}")
            if os.path.exists(file_path):
                os.remove(file_path)
            return False


class UnsplashDownloader(WallpaperDownloader):
    """Unsplash 壁纸下载器"""
    
    API_URL = "https://api.unsplash.com/search/photos"
    
    def search_wallpapers(self, query: str, count: int = 10) -> List[Dict]:
        """搜索壁纸"""
        if not self.api_key:
            print("⚠️  未配置 Unsplash API Key，跳过")
            return []
        
        print(f"\n🔍 正在从 Unsplash 搜索：{query}")
        
        params = {
            "query": f"{query} mobile wallpaper portrait",
            "per_page": min(count * 2, 30),  # 多获取一些，筛选后可能不够
            "orientation": "portrait",  # 竖屏
            "order_by": "latest",  # 改为最新
        }
        
        headers = {
            "Authorization": f"Client-ID {self.api_key}",
        }
        
        try:
            response = self.session.get(self.API_URL, params=params, headers=headers, timeout=10)
            response.raise_for_status()
            data = response.json()
            
            wallpapers = []
            for item in data.get("results", []):
                width = item.get("width", 0)
                height = item.get("height", 0)
                
                if self._is_portrait(width, height):
                    wallpapers.append({
                        "url": item["urls"]["raw"] + f"&w={IPHONE_16_PRO_MAX_WIDTH}&h={IPHONE_16_PRO_MAX_HEIGHT}&fit=crop",
                        "id": item["id"],
                        "author": item["user"]["name"],
                    })
                
                if len(wallpapers) >= count:
                    break
            
            print(f"✨ 找到 {len(wallpapers)} 张合适的壁纸")
            return wallpapers
            
        except Exception as e:
            print(f"❌ Unsplash 搜索失败：{e}")
            return []
    
    def download_wallpapers(self, query: str, count: int = 10):
        """下载壁纸"""
        wallpapers = self.search_wallpapers(query, count)
        
        success = 0
        for i, wp in enumerate(wallpapers, 1):
            filename = f"unsplash_{query}_{i}_{wp['id']}.jpg"
            if self.download_image(wp["url"], filename):
                success += 1
        
        print(f"\n📊 Unsplash - 成功下载 {success}/{len(wallpapers)} 张")


class PexelsDownloader(WallpaperDownloader):
    """Pexels 壁纸下载器"""
    
    API_URL = "https://api.pexels.com/v1/search"
    
    def search_wallpapers(self, query: str, count: int = 10) -> List[Dict]:
        """搜索壁纸"""
        if not self.api_key:
            print("⚠️  未配置 Pexels API Key，跳过")
            return []
        
        print(f"\n🔍 正在从 Pexels 搜索：{query}")
        
        params = {
            "query": f"{query} mobile wallpaper",
            "per_page": min(count * 2, 80),
            "orientation": "portrait",
        }
        
        headers = {
            "Authorization": self.api_key,
        }
        
        try:
            response = self.session.get(self.API_URL, params=params, headers=headers, timeout=10)
            response.raise_for_status()
            data = response.json()
            
            wallpapers = []
            for item in data.get("photos", []):
                width = item.get("width", 0)
                height = item.get("height", 0)
                
                if self._is_portrait(width, height):
                    # 使用 large2x 或 original 尺寸
                    url = item["src"].get("original", item["src"].get("large2x"))
                    wallpapers.append({
                        "url": url,
                        "id": item["id"],
                        "photographer": item["photographer"],
                    })
                
                if len(wallpapers) >= count:
                    break
            
            print(f"✨ 找到 {len(wallpapers)} 张合适的壁纸")
            return wallpapers
            
        except Exception as e:
            print(f"❌ Pexels 搜索失败：{e}")
            return []
    
    def download_wallpapers(self, query: str, count: int = 10):
        """下载壁纸"""
        wallpapers = self.search_wallpapers(query, count)
        
        success = 0
        for i, wp in enumerate(wallpapers, 1):
            filename = f"pexels_{query}_{i}_{wp['id']}.jpg"
            if self.download_image(wp["url"], filename):
                success += 1
        
        print(f"\n📊 Pexels - 成功下载 {success}/{len(wallpapers)} 张")


class PixabayDownloader(WallpaperDownloader):
    """Pixabay 壁纸下载器"""
    
    API_URL = "https://pixabay.com/api/"
    
    def search_wallpapers(self, query: str, count: int = 10) -> List[Dict]:
        """搜索壁纸"""
        if not self.api_key:
            print("⚠️  未配置 Pixabay API Key，跳过")
            return []
        
        print(f"\n🔍 正在从 Pixabay 搜索：{query}")
        
        params = {
            "key": self.api_key,
            "q": f"{query} mobile wallpaper",
            "image_type": "photo",
            "orientation": "vertical",
            "per_page": min(count * 2, 200),
            "safesearch": "true",
        }
        
        try:
            response = self.session.get(self.API_URL, params=params, timeout=10)
            response.raise_for_status()
            data = response.json()
            
            wallpapers = []
            for item in data.get("hits", []):
                width = item.get("imageWidth", 0)
                height = item.get("imageHeight", 0)
                
                if self._is_portrait(width, height):
                    wallpapers.append({
                        "url": item["largeImageURL"],
                        "id": item["id"],
                        "tags": item.get("tags", ""),
                    })
                
                if len(wallpapers) >= count:
                    break
            
            print(f"✨ 找到 {len(wallpapers)} 张合适的壁纸")
            return wallpapers
            
        except Exception as e:
            print(f"❌ Pixabay 搜索失败：{e}")
            return []
    
    def download_wallpapers(self, query: str, count: int = 10):
        """下载壁纸"""
        wallpapers = self.search_wallpapers(query, count)
        
        success = 0
        for i, wp in enumerate(wallpapers, 1):
            filename = f"pixabay_{query}_{i}_{wp['id']}.jpg"
            if self.download_image(wp["url"], filename):
                success += 1
        
        print(f"\n📊 Pixabay - 成功下载 {success}/{len(wallpapers)} 张")


def update_pubspec_assets(pubspec_path: str, base_dir: str):
    """自动更新 pubspec.yaml 中的 assets 路径"""
    if not os.path.exists(pubspec_path):
        print(f"⚠️  未找到 {pubspec_path}，跳过自动更新。")
        return
    
    print(f"\n🧩 正在更新 {pubspec_path} ...")
    
    with open(pubspec_path, "r", encoding="utf-8") as f:
        content = yaml.safe_load(f)
    
    if "flutter" not in content:
        content["flutter"] = {}
    
    assets = content["flutter"].get("assets", [])
    
    # 遍历所有包含图片的目录
    for root, dirs, files in os.walk(base_dir):
        # 跳过隐藏文件和 _downloaded.txt
        image_files = [
            f for f in files 
            if f.lower().endswith((".jpg", ".png", ".jpeg", ".webp")) 
            and not f.startswith("_")
        ]
        
        if image_files:
            rel_path = os.path.relpath(root, os.path.dirname(pubspec_path)) + "/"
            rel_path = rel_path.replace("\\", "/")
            if rel_path not in assets:
                assets.append(rel_path)
                print(f"  ➕ 添加路径：{rel_path}")
    
    content["flutter"]["assets"] = sorted(list(set(assets)))
    
    with open(pubspec_path, "w", encoding="utf-8") as f:
        yaml.dump(content, f, allow_unicode=True, sort_keys=False)
    
    print("✅ pubspec.yaml 已自动更新成功！")


def main():
    parser = argparse.ArgumentParser(
        description="精美手机壁纸下载器 - 支持 Unsplash/Pexels/Pixabay",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
示例用法:
  # 下载自然风景壁纸
  python fetch_wallpapers.py --query nature --count 10
  
  # 从多个平台下载
  python fetch_wallpapers.py --query "sunset ocean" --platforms unsplash,pexels --count 5
  
  # 下载多个主题
  python fetch_wallpapers.py --query "nature,city,space" --count 8

API Key 配置:
  可通过环境变量或命令行参数设置：
  - UNSPLASH_ACCESS_KEY / --unsplash-key
  - PEXELS_API_KEY / --pexels-key
  - PIXABAY_API_KEY / --pixabay-key
  
  免费申请地址:
  - Unsplash: https://unsplash.com/developers
  - Pexels: https://www.pexels.com/api/
  - Pixabay: https://pixabay.com/api/docs/
        """
    )
    
    parser.add_argument(
        "--query", "-q",
        type=str,
        default="nature,landscape,minimal",
        help="搜索关键词，多个用逗号分隔（默认: nature,landscape,minimal）"
    )
    
    parser.add_argument(
        "--count", "-c",
        type=int,
        default=10,
        help="每个关键词下载的图片数量（默认: 10）"
    )
    
    parser.add_argument(
        "--platforms", "-p",
        type=str,
        default="unsplash,pexels,pixabay",
        help="使用的平台，多个用逗号分隔（默认: unsplash,pexels,pixabay）"
    )
    
    parser.add_argument(
        "--dir", "-d",
        type=str,
        default="assets/images/wallpapers",
        help="保存目录（默认: assets/images/wallpapers）"
    )
    
    parser.add_argument(
        "--pubspec",
        type=str,
        default="pubspec.yaml",
        help="pubspec.yaml 文件路径（默认: pubspec.yaml）"
    )
    
    parser.add_argument(
        "--unsplash-key",
        type=str,
        help="Unsplash API Key"
    )
    
    parser.add_argument(
        "--pexels-key",
        type=str,
        help="Pexels API Key"
    )
    
    parser.add_argument(
        "--pixabay-key",
        type=str,
        help="Pixabay API Key"
    )
    
    args = parser.parse_args()
    
    # 更新 API Keys
    if args.unsplash_key:
        API_KEYS["unsplash"] = args.unsplash_key
    if args.pexels_key:
        API_KEYS["pexels"] = args.pexels_key
    if args.pixabay_key:
        API_KEYS["pixabay"] = args.pixabay_key
    
    # 解析关键词和平台
    queries = [q.strip() for q in args.query.split(",") if q.strip()]
    platforms = [p.strip().lower() for p in args.platforms.split(",") if p.strip()]
    
    if not queries:
        print("❌ 请至少提供一个搜索关键词")
        sys.exit(1)
    
    print("=" * 60)
    print("🎨 精美手机壁纸下载器")
    print("=" * 60)
    print(f"📱 目标尺寸: {IPHONE_16_PRO_MAX_WIDTH}×{IPHONE_16_PRO_MAX_HEIGHT} (iPhone 16 Pro Max)")
    print(f"🔍 搜索关键词: {', '.join(queries)}")
    print(f"🌐 使用平台: {', '.join(platforms)}")
    print(f"📊 每个关键词下载: {args.count} 张")
    print(f"📂 保存路径: {args.dir}")
    print("=" * 60)
    
    # 检查 API Keys
    active_platforms = []
    if "unsplash" in platforms and API_KEYS["unsplash"]:
        active_platforms.append("unsplash")
    if "pexels" in platforms and API_KEYS["pexels"]:
        active_platforms.append("pexels")
    if "pixabay" in platforms and API_KEYS["pixabay"]:
        active_platforms.append("pixabay")
    
    if not active_platforms:
        print("\n❌ 错误：未配置任何有效的 API Key")
        print("\n请通过以下方式之一配置 API Key:")
        print("  1. 环境变量:")
        print("     export UNSPLASH_ACCESS_KEY='your_key'")
        print("     export PEXELS_API_KEY='your_key'")
        print("     export PIXABAY_API_KEY='your_key'")
        print("\n  2. 命令行参数:")
        print("     --unsplash-key YOUR_KEY")
        print("     --pexels-key YOUR_KEY")
        print("     --pixabay-key YOUR_KEY")
        print("\n免费申请地址:")
        print("  - Unsplash: https://unsplash.com/developers")
        print("  - Pexels: https://www.pexels.com/api/")
        print("  - Pixabay: https://pixabay.com/api/docs/")
        sys.exit(1)
    
    print(f"\n✅ 已激活平台: {', '.join(active_platforms)}\n")
    
    # 开始下载
    for query in queries:
        query_dir = os.path.join(args.dir, query.replace(" ", "_"))
        
        print(f"\n{'=' * 60}")
        print(f"📥 开始下载主题: {query}")
        print(f"{'=' * 60}")
        
        if "unsplash" in active_platforms:
            downloader = UnsplashDownloader(API_KEYS["unsplash"], query_dir)
            downloader.download_wallpapers(query, args.count)
        
        if "pexels" in active_platforms:
            downloader = PexelsDownloader(API_KEYS["pexels"], query_dir)
            downloader.download_wallpapers(query, args.count)
        
        if "pixabay" in active_platforms:
            downloader = PixabayDownloader(API_KEYS["pixabay"], query_dir)
            downloader.download_wallpapers(query, args.count)
    
    # 更新 pubspec.yaml
    update_pubspec_assets(args.pubspec, args.dir)
    
    print("\n" + "=" * 60)
    print("🎉 所有壁纸下载完成！")
    print("=" * 60)
    print(f"\n💡 提示:")
    print(f"  1. 壁纸已保存到: {args.dir}/")
    print(f"  2. pubspec.yaml 已自动更新")
    print(f"  3. 运行 'flutter pub get' 来应用更改")
    print(f"  4. 所有壁纸都是竖屏高分辨率，适配 iPhone 16 Pro Max\n")


if __name__ == "__main__":
    if sys.version_info.major < 3:
        print("⚠️  请使用 Python 3 运行此脚本")
        sys.exit(1)
    
    main()
