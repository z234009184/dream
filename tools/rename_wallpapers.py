#!/usr/bin/env python3
import os
import re
import sys
import yaml
from typing import List

SUPPORTED_EXT = (".jpg", ".jpeg", ".png", ".webp")


def natural_sort_key(s: str):
    return [int(text) if text.isdigit() else text.lower() for text in re.split(r"(\d+)", s)]


def rename_in_topic(topic_dir: str, topic: str) -> List[str]:
    files = [f for f in os.listdir(topic_dir) if os.path.splitext(f)[1].lower() in SUPPORTED_EXT]
    files.sort(key=natural_sort_key)

    changed = []
    for idx, fname in enumerate(files, 1):
        ext = os.path.splitext(fname)[1].lower()
        new_name = f"wallpaper_{topic}_{idx}{ext}"
        src = os.path.join(topic_dir, fname)
        dst = os.path.join(topic_dir, new_name)
        if src == dst:
            continue
        # 避免覆盖：若重名则追加序号
        counter = 1
        while os.path.exists(dst):
            new_name = f"wallpaper_{topic}_{idx}_{counter}{ext}"
            dst = os.path.join(topic_dir, new_name)
            counter += 1
        os.rename(src, dst)
        changed.append(new_name)
        print(f"✅ {fname} -> {new_name}")
    return changed


def update_pubspec(pubspec_path: str, base_dir: str):
    if not os.path.exists(pubspec_path):
        print(f"⚠️ 未找到 {pubspec_path}，跳过自动更新。")
        return

    with open(pubspec_path, "r", encoding="utf-8") as f:
        content = yaml.safe_load(f)

    if "flutter" not in content:
        content["flutter"] = {}

    assets = content["flutter"].get("assets", [])

    for root, dirs, files in os.walk(base_dir):
        if any(fname.lower().endswith(SUPPORTED_EXT) for fname in files):
            rel_path = os.path.relpath(root, os.path.dirname(pubspec_path)) + "/"
            rel_path = rel_path.replace("\\", "/")
            if rel_path not in assets:
                assets.append(rel_path)
                print(f"➕ 追加资源路径: {rel_path}")

    content["flutter"]["assets"] = sorted(list(set(assets)))

    with open(pubspec_path, "w", encoding="utf-8") as f:
        yaml.dump(content, f, allow_unicode=True, sort_keys=False)

    print("✅ pubspec.yaml 已更新！")


def main():
    base_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "assets", "images", "wallpapers"))
    pubspec_path = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "pubspec.yaml"))

    if not os.path.exists(base_dir):
        print(f"❌ 未找到目录: {base_dir}")
        sys.exit(1)

    print(f"📂 重命名目录: {base_dir}")
    topics = [d for d in os.listdir(base_dir) if os.path.isdir(os.path.join(base_dir, d))]
    topics.sort()

    total_changed = 0
    for topic in topics:
        topic_dir = os.path.join(base_dir, topic)
        print(f"\n— 处理主题: {topic}")
        changed = rename_in_topic(topic_dir, topic)
        total_changed += len(changed)

    print(f"\n📊 共重命名 {total_changed} 个文件")

    update_pubspec(pubspec_path, base_dir)


if __name__ == "__main__":
    if sys.version_info.major < 3:
        print("⚠️ 请使用 Python 3 运行此脚本")
        sys.exit(1)
    main()
