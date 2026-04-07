# 贡献指南

感谢您对 PHTunnel 项目的关注！我们欢迎所有形式的贡献。

## 如何贡献

### 报告 Bug

1. 在 [Issues](https://github.com/sdpong/phtunnel1/issues) 中搜索，确保 Bug 未被报告
2. 创建新的 Issue，包含：
   - 清晰的标题
   - 详细的 Bug 描述
   - 重现步骤
   - 预期行为和实际行为
   - 环境：
     - OpenWrt 版本
     - 设备型号
     - 架构
     - PHTunnel 版本
   - 相关日志

### 提出新功能

1. 在 Issues 中讨论新功能想法
2. 获得维护者反馈后，开始实现

### 提交代码

#### 开发流程

1. Fork 本仓库
2. 创建特性分支：
   ```bash
   git checkout -b feature/your-feature-name
   ```
3. 进行开发
4. 提交更改（遵循提交规范）
5. 推送到分支：
   ```bash
   git push origin feature/your-feature-name
   ```
6. 创建 Pull Request

#### 提交规范

提交信息格式：
```
<type>(<scope>): <subject>

<body>

<footer>
```

类型（type）：
- `feat`: 新功能
- `fix`: Bug 修复
- `docs`: 文档更新
- `style`: 代码格式（不影响功能）
- `refactor`: 重构
- `perf`: 性能优化
- `test`: 测试
- `chore`: 构建/工具更新

示例：
```
feat(phtunnel): add support for custom DNS servers

- Add new UCI options for custom DNS
- Update init script to use custom DNS
- Add documentation

Closes #123
```

### 代码规范

#### Makefile

- 使用 2 空格缩进
- 遵循 OpenWrt Makefile 规范
- 添加适当的注释

#### Shell 脚本

- 使用 4 空格缩进
- 使用 `#!/bin/bash` 或 `#!/bin/sh`
- 添加 `set -e` 以在错误时退出
- 添加有意义的注释

#### Lua 脚本

- 使用 4 空格缩进
- 遵循 Lua 编码规范
- 添加错误处理

### 测试

#### 本地测试

```bash
# 构建包
./scripts/build-all.sh -a x86_64

# 验证包
./scripts/verify-packages.sh

# 测试安装（在 OpenWrt 设备上）
apk add phtunnel_*.apk
```

#### 测试检查清单

- [ ] 代码编译成功
- [ ] 包格式正确
- [ ] 服务启动/停止正常
- [ ] LuCI 界面正常
- [ ] 日志记录正常
- [ ] 配置保存/加载正常

## Pull Request 流程

### PR 标题格式

```
<type>: <short description>
```

示例：
```
fix: resolve connection timeout issue
feat: add support for new architecture
docs: update installation instructions
```

### PR 描述模板

```markdown
## 变更类型
- [ ] Bug 修复
- [ ] 新功能
- [ ] 重大变更
- [ ] 文档更新

## 变更描述
<!-- 简要描述你的变更 -->

## 相关 Issue
<!-- 关联相关的 Issue，例如：Closes #123 -->

## 测试
<!-- 描述你如何测试这些变更 -->

## 检查清单
- [ ] 代码遵循项目规范
- [ ] 已添加测试
- [ ] 文档已更新
- [ ] 已通过本地测试
```

### 审查流程

1. 所有 PR 必须通过 CI 检查
2. 至少一名维护者审查通过
3. 解决所有审查意见
4. PR 被合并到主分支

## 发布流程

1. 更新版本号：
   ```bash
   ./scripts/version.sh bump patch  # 或 minor/major
   ```
2. 更新 CHANGELOG
3. 创建 PR 到主分支
4. 合并后推送 tag：
   ```bash
   ./scripts/version.sh tag
   git push origin main --tags
   ```
5. GitHub Actions 自动创建 Release

## 行为准则

- 尊重所有贡献者
- 建设性反馈
- 关注技术问题，避免人身攻击
- 接受并建设性地回应反馈

## 获取帮助

如有问题，请：
- 查看 [文档](README.md)
- 搜索 [Issues](https://github.com/sdpong/phtunnel1/issues)
- 创建新 Issue 描述你的问题

## 许可证

提交代码即表示您同意您的贡献将按照项目的许可证（GPL-2.0）进行许可。

---

感谢您的贡献！
