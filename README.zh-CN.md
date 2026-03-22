# Nook (`nk`)

`Nook` 是一个轻量的 SSH 服务器书签工具，适合长期在终端里管理和登录服务器的人。

它保留了单文件 Bash 工具的轻量特性，同时补上了更适合开源项目的品牌、入口命令和使用体验。

## 特性

- `fzf` 交互式服务器选择
- 服务器分组管理
- SSH 免密配置
- 连通性检测
- 从 `~/.ssh-manager` 自动迁移到 `~/.config/nook`
- `nk doctor` 诊断命令

## 安装

```bash
curl -fsSL https://raw.githubusercontent.com/guyfar/nook-ssh/main/install.sh | bash
```

安装后主命令为 `nk`。

默认配置目录为：

```text
~/.config/nook/
```

如果检测到旧版 `~/.ssh-manager/` 配置，Nook 会自动迁移。

## 用法

| 命令 | 功能 |
|------|------|
| `nk` | 打开交互式选择器 |
| `nk add` | 添加服务器 |
| `nk rm` | 删除服务器 |
| `nk list` | 列出服务器 |
| `nk edit` | 编辑配置 |
| `nk key` | 配置 SSH 免密 |
| `nk ping` | 检测连通性 |
| `nk doctor` | 输出诊断信息 |
| `nk <关键词>` | 搜索并连接 |
| `nk help` | 显示帮助 |

兼容别名：

| 命令 | 说明 |
|------|------|
| `s` | 旧入口，保留兼容，不再推荐作为主命令 |

## 配置格式

```conf
# Format : name | host | port | user | password(optional) | description

[production]
# prod-web-01 | 1.2.3.4 | 22 | root | yourpass | production web node
# prod-web-02 | 1.2.3.5 | 22 | root |          | production web node 2
# prod-db-01  | 1.2.3.6 | 3306 | root | dbpass123 | primary database
```

## 诊断

```bash
nk doctor
```

这个命令会输出版本、配置路径、服务器数量以及 `ssh` / `fzf` / `sshpass` 的可用性，方便排查环境问题。

## 开发

```bash
bash -n nk s install.sh
./nk help
NOOK_INSTALL_DIR=/tmp/nook-bin XDG_CONFIG_HOME=/tmp/nook-xdg bash ./install.sh
```

## 协作与发布

- 贡献说明：`CONTRIBUTING.md`
- 更新记录：`CHANGELOG.md`
- 发布检查：`RELEASE_CHECKLIST.md`

## License

MIT
