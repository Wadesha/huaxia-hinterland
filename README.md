# 🌐 https://wadesha.github.io/huaxia-hinterland/

---

## 华夏腹地 · Hinterland of Huaxia

> 仿 Lonely Planet 文风双语目的地写作系列
> LP-style bilingual travel writing — inspired by Lonely Planet, but 100% original.

### 在线阅读

**[🎲 随机开启一篇 →](https://wadesha.github.io/huaxia-hinterland/)** — 首页每次刷新随机加载一篇，点「换一篇」继续探索。

### 内容概览

| 分类 | 数量 | 说明 |
|------|------|------|
| LP 文风城市双语页 | ~30 | 山东 / 河南 / 河北 / 山西 / 陕西 / 甘肃 / 湖北 / 安徽 |
| 县级地志 HTML | ~50 | 淮海区域各县 |
| 区域综合索引 | 1 | 淮海腹地综合索引 |
| 文风对比版 | 若干 | 同一主题 V1 / V2 两种写法对比 |

### 📁 项目结构

```
huaxia-hinterland/              ← GitHub Pages 根目录（发布内容）
├── index.html                  ← 随机阅读首页（入口）
├── publish.ps1                 ← 一键发布脚本
├── README.md                   ← 本文件
├── zlibrary/                   ← 子目录：综合索引
├── *_LP文风_双语.html           ← LP 风格城市双语页面
├── *.html (县级)                ← 淮海区域各县地志
├── *_V1现行版.html              ← 文风实验 V1
├── *_V2校准版.html              ← 文风实验 V2
├── *_双版本对比.html            ← V1/V2 对比页
├── 双线实验.html                ← 双线文风实验
└── 京都_游记与攻略_LP风格.html   ← 京都 LP 风格单篇
```

### 🔒 私有内容（已 .gitignore 排除，不发布）

以下内容仅供本地个人研究，**不会**推送到公开仓库：

- `lp_books/` — Lonely Planet 原文章节
- `lp_articles_html/`, `lp_articles_md/` — LP 原文语料库
- `lp_style_profile.json`, `lp_book_profile.json` — 文风学习产物
- `*.py`, `*.csv` — 生成脚本与数据
- `LP文风拆解.md` 等学习笔记

### 🚀 发布流程

```powershell
# 预览将要提交的内容（Dry Run）
.\publish.ps1 -DryRun

# 常规发布
.\publish.ps1

# 带自定义提交信息
.\publish.ps1 -Message "新增: 洛阳 LP 文风页面"

# 先运行生成脚本再发布
.\publish.ps1 -RunPy gen_destinations.py
```

脚本自动完成：
1. 扫描所有 `.html` 内容页（排除 index/V1/V2/对比/tmp）
2. 更新 `index.html` 里的 `CONTENT_PAGES` 数组
3. `git add → commit → push`（受 `.gitignore` 保护，敏感内容不会泄露）

### ⌨️ 键盘快捷键（首页）

- **Space** / **R** — 换一篇
- `?page=文件名` — 直接打开指定页面
- `?view=all` — 切到浏览全部模式

### 版权声明

本文为 **Lonely Planet 文风仿写练习**：内容原创，仅借其笔法，不复制任何 LP 原文。地名与史实为公开常识，欢迎实地核对。
