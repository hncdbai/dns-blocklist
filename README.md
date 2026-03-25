# DNS Blocklist (Smart Merge Version)

一个基于 GitHub Actions 自动构建的 DNS 广告拦截规则项目，支持：

* 多规则自动合并
* 去重优化
* 国内 / 国际分离
* 白名单保护（含远程白名单）
* 每日自动更新

---

## 📦 规则来源

### 主规则（稳定核心）

* AdGuard DNS Filter
* OISD Blocklist (Small)

### 国内增强

* CHN: AdRules DNS List

### 安全规则

* URLHaus (Malware)

---

## ⚙️ 构建逻辑

规则通过脚本自动处理：

1. 下载所有规则源
2. 提取域名（适配 DNS）
3. 去重
4. 应用白名单（最高优先级）
5. 输出多个版本规则

---

## 📁 输出文件说明

### `blocklist-full.txt`
https://ghfast.top/https://raw.githubusercontent.com/hncdbai/dns-blocklist/main/blocklist-full.txt

**最完整版本**

包含：

* 主规则 + 国内规则 + 扩展规则

特点：

* 拦截最强
* 误杀风险最高

适合：

* 测试环境
* 内部使用

---

### `blocklist-cn.txt` ⭐ 推荐
https://ghfast.top/https://raw.githubusercontent.com/hncdbai/dns-blocklist/main/blocklist-cn.txt

**国内优化版本**

包含：

* 主规则 + 国内规则

特点：

* 国内广告拦截效果好
* 稳定性高

适合：

* 国内网络
* 酒店 / 公共网络

---

### `blocklist-global.txt`
https://ghfast.top/https://raw.githubusercontent.com/hncdbai/dns-blocklist/main/blocklist-global.txt

**国际稳定版本**

包含：

* 主规则 + 安全规则（不含国内规则）

特点：

* 兼容性最好
* 几乎不影响国际服务

适合：

* 海外环境
* 对稳定性要求极高

---

## 🧾 白名单系统

本项目采用三层白名单机制：

### 1️⃣ 手动白名单

文件：`whitelist.txt`

用于：

* 投屏（AirPlay / Chromecast）
* 局域网服务
* 系统核心域名

---

### 2️⃣ 自动白名单（可选）

文件：`whitelist-auto.txt`

用于：

* 后续扩展自动学习（当前可为空）

---

### 3️⃣ 远程白名单

来源：
https://raw.githubusercontent.com/BlueSkyXN/AdGuardHomeRules/master/ok.txt

特点：

* 减少误杀
* 提高稳定性

---

## 🔄 自动更新

使用 GitHub Actions：

* 每天自动更新一次
* 自动提交最新规则

---

## 🚀 使用方法

将以下地址填入你的 DNS 工具（如 AdGuard Home / Pi-hole）：

```
https://raw.githubusercontent.com/<你的用户名>/<仓库名>/main/blocklist-cn.txt
```

推荐使用：

👉 `blocklist-cn.txt`
https://ghfast.top/https://raw.githubusercontent.com/hncdbai/dns-blocklist/main/blocklist-cn.txt

---

## ⚠️ 注意事项

* 不建议叠加过多规则源（已做去重优化）
* 如遇访问异常，请检查白名单
* 本项目优先保证稳定性，其次才是拦截率

---

## 🧠 项目特点

* 自动化维护
* 低误杀设计
* 适合复杂网络（如酒店 / 多设备环境）
* 支持扩展（可自定义规则源）

---

## 📌 License

仅用于学习与个人网络优化，请勿用于非法用途。
