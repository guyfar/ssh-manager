# SSH Server Manager (`s`)

一个极简的 SSH 服务器管理工具，让你用一个字母 `s` 管理和登录所有 VPS 服务器。

支持 **fzf 模糊搜索**、**服务器分组**、**免密登录配置**、**连通性检测**。

## 一键安装

```bash
curl -fsSL https://raw.githubusercontent.com/guyfar/ssh-manager/main/install.sh | bash
```

## 效果预览

```
$ s
🖥  SSH Server Manager - 选择服务器 (ESC退出)
搜索: _

  [生产环境]
  > prod-web-01    1.2.3.4    :22   root     生产Web服务器1
    prod-web-02    1.2.3.5    :22   root     生产Web服务器2
    prod-db-01     1.2.3.6    :3306 root     生产数据库主库

  [测试环境]
    test-api       10.0.0.1   :22   ubuntu   测试API服务器
```

## 使用方法

| 命令 | 功能 |
|------|------|
| `s` | 交互式选择服务器并登录 |
| `s add` | 添加新服务器 |
| `s rm` | 删除服务器 |
| `s list` | 列出所有服务器 |
| `s edit` | 编辑配置文件 |
| `s key` | 配置 SSH 免密登录 |
| `s ping` | 检测所有服务器连通性 |
| `s <关键词>` | 模糊搜索并登录 |
| `s help` | 显示帮助 |

## 配置文件

配置文件位于 `~/.ssh-manager/servers.conf`，格式如下：

```conf
# 格式: 名称 | IP地址 | 端口 | 用户名 | 备注说明

[生产环境]
prod-web-01   | 1.2.3.4     | 22   | root   | 生产Web服务器1
prod-db-01    | 1.2.3.6     | 3306 | root   | 生产数据库主库

[测试环境]
test-api      | 10.0.0.1    | 22   | ubuntu | 测试API服务器

[海外节点]
us-node-01    | 8.8.8.1     | 22   | admin  | 美国节点1
```

## 免密登录

```bash
# 为指定服务器配置 SSH Key 免密登录
s key

# 添加服务器时也会询问是否配置免密
s add
```

工具会自动检测本地 SSH 公钥（支持 RSA / Ed25519），如果没有会自动生成，然后通过 `ssh-copy-id` 推送到目标服务器。

## 依赖

- **bash** 4.0+（macOS/Linux 自带）
- **fzf**（可选，强烈推荐，提供模糊搜索体验）

```bash
# macOS
brew install fzf

# Linux
sudo apt install fzf   # Debian/Ubuntu
sudo yum install fzf   # CentOS/RHEL
```

## 卸载

```bash
sudo rm /usr/local/bin/s
rm -rf ~/.ssh-manager
```

## License

MIT
