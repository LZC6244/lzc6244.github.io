---
layout:         post
title:          Git 更新本地未提交 commit 提交时间
create_time:    2026-07-20 21:23
update_time:    
categories:     [Tools,Git]
---



# 场景

有时需要修改最近一次 commit 的提交时间，常见场景：

- 修正因系统时间错误导致的时间偏差
- 补交之前遗漏的 commit，希望记录实际编写时间
- 整理提交历史时统一时间线

本文记录通过 `git commit --amend` 修改本地**未推送** commit 的 Author Date 和 Committer Date 的方法。



# 命令

```bash
# NEW_DATE 为目标时间，格式：YYYY-MM-DD HH:MM:SS +时区
NEW_DATE="2026-07-01 10:33:02 +0800" && env GIT_AUTHOR_DATE="$NEW_DATE" GIT_COMMITTER_DATE="$NEW_DATE" git commit --amend --no-edit --date="$NEW_DATE"
```



## 参数说明

### 环境变量

`GIT_AUTHOR_DATE`
: 覆盖 Author Date（作者时间），即代码最初编写的时间

`GIT_COMMITTER_DATE`
: 覆盖 Committer Date（提交者时间），即代码实际被提交到仓库的时间

<blockquote class="tip">
Author Date 和 Committer Date 在 <code>git rebase</code>、<code>git cherry-pick</code> 等场景下可能不同，一般情况两者保持一致即可。
</blockquote>

### git commit 选项

`--amend`
: 修改最近一次 commit，而不是创建新的 commit

`--no-edit`
: 不打开编辑器修改 commit message，保持原提交信息不变

`--date`
: 设置 commit 的日期，等同于设置 Committer Date

> 使用 `env`（而非 `export`）可确保环境变量仅对当前命令生效，不会污染当前 shell 会话。



## 简化版本

如果不需要修改 Author Date，可省略环境变量：

```bash
git commit --amend --no-edit --date="2026-07-01 10:33:02 +0800"
```

此命令仅修改 Committer Date，Author Date 保持不变。



# 查看 commit 时间

使用 `--format=fuller` 可同时查看 Author Date 和 Committer Date：

```bash
git log --format=fuller
```

输出示例：

```
commit abc123def456...
Author:     Your Name <your@email.com>
AuthorDate: Mon Jul 20 21:23:00 2026 +0800
Commit:     Your Name <your@email.com>
CommitDate: Mon Jul 20 21:23:00 2026 +0800
```



# 注意事项

<span style="color:red">`--amend` 会改变 commit hash，仅适用于本地尚未推送的 commit。</span>

如果该 commit 已推送到远程，再次推送需要 `--force`，且会影响其他协作者，不建议对已推送的 commit 使用。



# 参考

- [Git - git-commit Documentation](https://git-scm.com/docs/git-commit)
- [Git - Environment Variables](https://git-scm.com/book/en/v2/Git-Internals-Environment-Variables)

