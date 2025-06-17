#!/usr/bin/env python3

# Import stuff.
import shutil  # 用于复制和删除文件夹、文件
import os  # 用于获取文件路径和目录操作
from pathlib import Path  # 用于判断文件夹是否存在
import re  # 正则表达式处理字符串
import json  # 处理 JSON 数据

# 导入 Silica 工具包中的类
from util.DepictionGenerator import DepictionGenerator
from util.PackageLister import PackageLister
from util.DebianPackager import DebianPackager

# 当前 Silica 版本号
version = "1.2.2"


def main():
    print("Silica Compiler {0}".format(version))

    ###########
    # Step 0: 清理 "repo" 和 "temp" 文件夹，保留 DEB 文件
    ###########

    root = os.path.dirname(os.path.abspath(__file__)) + "/"  # 当前脚本所在路径

    # 清理旧的描述文件，保留 DEB 包
    DepictionGenerator.CleanUp()

    # 删除临时文件夹（如果存在）
    try:
        shutil.rmtree(root + "temp/")
    except Exception:
        pass

    ###########
    # Step 1: 创建必要的文件夹和变量（包括 temp 文件夹）
    ###########
PackageLister.CreateFolder("repo")
PackageLister.CreateFolder("repo/web")
PackageLister.CreateFolder("repo/depiction")
PackageLister.CreateFolder("repo/depiction/web")
PackageLister.CreateFolder("repo/depiction/native")
PackageLister.CreateFolder("repo/depiction/native/help")
PackageLister.CreateFolder("repo/pkg")
PackageLister.CreateFolder("repo/assets")
PackageLister.CreateFolder("repo/api")

    # 如果使用 DEB 包，确保生成所有 index.json 文件
    DebianPackager.CheckForSilicaData()

    # 获取 tweak 发布信息和仓库配置
    tweak_release = PackageLister.GetTweakRelease()
    repo_settings = PackageLister.GetRepoSettings()

    # 为每个 tweak 创建对应的 assets 目录
    for tweak in tweak_release:
        PackageLister.CreateFolder("repo/assets/" + tweak['bundle_id'])

    ###########
    # Step 2: 复制图标、横幅、描述和截图等资源文件
    ###########
    for package_name in PackageLister.ListDirNames():
        package_bundle_id = PackageLister.DirNameToBundleID(package_name)

        # 复制 icon.png，找不到时使用默认图标
        try:
            shutil.copy(root + "Packages/" + package_name + "/silica_data/icon.png",
                        root + "repo/assets/" + package_bundle_id + "/icon.png")
        except Exception:
            category = PackageLister.ResolveCategory(tweak_release, package_bundle_id)
            category = re.sub(r'\([^)]*\)', '', category).strip()
            try:
                shutil.copy(root + "Styles/Generic/Icon/" + category + ".png",
                            root + "repo/assets/" + package_bundle_id + "/icon.png")
            except Exception:
                try:
                    shutil.copy(root + "Styles/Generic/Icon/Generic.png",
                                root + "repo/assets/" + package_bundle_id + "/icon.png")
                except Exception:
                    PackageLister.ErrorReporter("Configuration Error!", "缺少默认图标文件 Styles/Generic/Icon/Generic.png")

        # 复制 banner.png，找不到时使用默认横幅
        try:
            shutil.copy(root + "Packages/" + package_name + "/silica_data/banner.png",
                        root + "repo/assets/" + package_bundle_id + "/banner.png")
        except Exception:
            category = PackageLister.ResolveCategory(tweak_release, package_bundle_id)
            category = re.sub(r'\([^)]*\)', '', category).strip()
            try:
                shutil.copy(root + "Styles/Generic/Banner/" + category + ".png",
                            root + "repo/assets/" + package_bundle_id + "/banner.png")
            except Exception:
                try:
                    shutil.copy(root + "Styles/Generic/Banner/Generic.png",
                               root + "repo/assets/" + package_bundle_id + "/banner.png")
                except Exception:
                    PackageLister.ErrorReporter("Configuration Error!", "缺少默认横幅文件 Styles/Generic/Banner/Generic.png")

        # 复制描述文件 description.md（可选）
        try:
            shutil.copy(root + "Packages/" + package_name + "/silica_data/description.md",
                        root + "repo/assets/" + package_bundle_id + "/description.md")
        except Exception:
            pass

        # 复制截图文件夹（可选）
        try:
            shutil.copytree(root + "Packages/" + package_name + "/silica_data/screenshots",
                            root + "repo/assets/" + package_bundle_id + "/screenshot")
        except Exception:
            pass

    # 复制仓库图标文件
    try:
        shutil.copy(root + "Styles/icon.png", root + "repo/CydiaIcon.png")
    except Exception:
        PackageLister.ErrorReporter("Configuration Error!", "缺少仓库图标 Styles/icon.png")

    ###########
    # Step 3: 生成 HTML 描述页并复制样式表和 JS
    ###########

    # 复制 CSS 和 JS 文件
    shutil.copy(root + "Styles/index.css", root + "repo/web/index.css")
    shutil.copy(root + "Styles/index.js", root + "repo/web/index.js")

    # 生成主页 index.html 和 404.html
    index_html = DepictionGenerator.RenderIndexHTML()
    PackageLister.CreateFile("repo/index.html", index_html)
    PackageLister.CreateFile("repo/404.html", index_html)

    # 为每个 tweak 生成网页描述
    for tweak_data in tweak_release:
        tweak_html = DepictionGenerator.RenderPackageHTML(tweak_data)
        PackageLister.CreateFile("repo/depiction/web/" + tweak_data['bundle_id'] + ".html", tweak_html)

    # 生成 CNAME 文件（如果仓库不是 github.io 域名）
    if "github.io" not in repo_settings['cname'].lower():
        PackageLister.CreateFile("repo/CNAME", repo_settings['cname'])

    ###########
    # Step 4: 生成 Sileo 描述文件和 featured JSON
    ###########

    # 生成 sileo-featured.json（首页轮播推荐）
    carousel_obj = DepictionGenerator.NativeFeaturedCarousel(tweak_release)
    PackageLister.CreateFile("repo/sileo-featured.json", carousel_obj)

    # 生成每个 tweak 的原生 JSON 描述和帮助文档
    for tweak_data in tweak_release:
        tweak_json = DepictionGenerator.RenderPackageNative(tweak_data)
        PackageLister.CreateFile("repo/depiction/native/" + tweak_data['bundle_id'] + ".json", tweak_json)
        help_depiction = DepictionGenerator.RenderNativeHelp(tweak_data)
        PackageLister.CreateFile("repo/depiction/native/help/" + tweak_data['bundle_id'] + ".json", help_depiction)

    ###########
    # Step 5: 根据 settings.json 生成 Release 文件
    ###########

    release_file = DebianPackager.CompileRelease(repo_settings)
    PackageLister.CreateFile("repo/Release", release_file)

    ###########
    # Step 6: 复制 Packages 目录内容到临时 temp 文件夹
    ###########

    # 复制时删除 silca_data 文件夹
    PackageLister.CreateFolder("temp")
    for package_name in PackageLister.ListDirNames():
        bundle_id = PackageLister.DirNameToBundleID(package_name)
        try:
            shutil.copytree(root + "Packages/" + package_name, root + "temp/" + bundle_id)
            shutil.rmtree(root + "temp/" + bundle_id + "/silica_data")
        except Exception:
            try:
                shutil.rmtree(root + "temp/" + bundle_id + "/silica_data")
            except Exception:
                pass

        # 如果有 scripts 目录，复制到 DEBIAN 目录下
        script_check = Path(root + "Packages/" + package_name + "/silica_data/scripts/")
        if script_check.is_dir():
            shutil.copytree(root + "Packages/" + package_name + "/silica_data/scripts", root + "temp/" + bundle_id + "/DEBIAN")
        else:
            PackageLister.CreateFolder("temp/" + bundle_id + "/DEBIAN")

    ###########
    # Step 7: 生成 CONTROL 文件，制作 DEB 包，并复制到 repo/pkg
    ###########

    for tweak_data in tweak_release:
        control_file = DebianPackager.CompileControl(tweak_data, repo_settings)
        PackageLister.CreateFile("temp/" + tweak_data['bundle_id'] + "/DEBIAN/control", control_file)
        DebianPackager.CreateDEB(tweak_data['bundle_id'], tweak_data['version'])
        shutil.copy(root + "temp/" + tweak_data['bundle_id'] + ".deb", root + "repo/pkg/" + tweak_data['bundle_id'] + ".deb")

    ###########
    # Step 8: 生成 Packages 文件，签名 Release 文件
    ###########

    DebianPackager.CompilePackages()
    DebianPackager.SignRelease()

    ###########
    # Step 9: 生成 API JSON 接口文件
    ###########

    PackageLister.CreateFile("repo/api/tweak_release.json", json.dumps(tweak_release, separators=(',', ':')))
    PackageLister.CreateFile("repo/api/repo_settings.json", json.dumps(repo_settings, separators=(',', ':')))
    PackageLister.CreateFile("repo/api/about.json", json.dumps(DepictionGenerator.SilicaAbout(), separators=(',', ':')))

    ###########
    # Step 10: 清理临时文件夹并自动推送到 GitHub（如果配置启用）
    ###########

    shutil.rmtree(root + "temp/")  # 删除临时文件夹

    try:
        # 根据配置自动推送 git
        if repo_settings['automatic_git'].lower() == "true":
            DebianPackager.PushToGit()
    except Exception:
        pass


if __name__ == '__main__':
    # 实例化 Silica 三大类
    DepictionGenerator = DepictionGenerator(version)
    PackageLister = PackageLister(version)
    DebianPackager = DebianPackager(version)
    main()
