#!/bin/bash
# 初始化 iptables 出站白名单，并启动健壮的域名守护进程
#
# 功能说明：
# 1. 设置静态 IP 白名单（通过配置文件 iptables-whitelist.yaml 配置）
# 2. 设置动态域名白名单（通过配置文件 iptables-whitelist.yaml 配置）
# 3. 定时解析域名 IP，动态更新白名单
# 4. 使用 ipset timeout 特性，自动清理过期的 IP
#
# 设计说明：
# - 本脚本不支持配置文件的热重载（无需监控文件变化）
# - 域名白名单已通过定时任务自动更新，无需手动干预
# - 静态 IP 白名单修改需要重启容器生效，这是有意设计
#
# 不支持热重载的优点：
# 1. 避免复杂的文件监控逻辑，减少出错点
# 2. 配置修改需要重启，符合传统运维习惯，降低误操作风险
# 3. 重启时重新加载全部配置，确保配置一致性
# 4. 域名 IP 已通过守护进程自动更新，覆盖 99% 的动态场景
# 5. 简化故障排查，问题更容易复现和定位
#
# 更新配置的方式：
# - 修改配置文件后，重启容器即可：docker compose restart
# - 域名 IP 无需手动更新，守护进程会自动处理

# 设置 Bash 严格模式（主进程）
# -e: 任何命令返回非零退出码时，立即退出脚本
# -u: 使用未定义的变量时，立即退出脚本
# -o pipefail: 管道中任何命令失败时，整个管道返回失败状态
# 这些设置可以帮助在早期发现问题，避免错误扩散
set -euo pipefail

# ========================================
# 配置文件路径
# ========================================
CONFIG_FILE="/etc/iptables-whitelist/config.yaml"

# ========================================
# YAML 解析函数
# ========================================

# 从 YAML 文件读取简单键值对（支持数组和字符串）
# 用法: value=$(get_yaml_value "key")
get_yaml_value() {
  local key=$1
  local config_file=$2
  local value=""
  
  # 查找 key: value 或 key: 后面的内容
  if [ -f "$config_file" ]; then
    # 匹配 "key:" 并获取其值
    value=$(grep -E "^[[:space:]]*${key}[[:space:]]*:" "$config_file" | head -1 | sed "s/^[[:space:]]*${key}[[:space:]]*:[[:space:]]*//")
  fi
  
  echo "$value"
}

# 从 YAML 文件读取数组
# 用法: array=($(get_yaml_array "key" "config_file"))
get_yaml_array() {
  local key=$1
  local config_file=$2
  local in_array=0
  local result=()
  
  if [ -f "$config_file" ]; then
    while IFS= read -r line; do
      # 跳过注释
      [[ "$line" =~ ^[[:space:]]*# ]] && continue
      
      # 检测数组开始
      if [[ "$line" =~ ^[[:space:]]*${key}[[:space:]]*:[[:space:]]*$ ]]; then
        in_array=1
        continue
      fi
      
      # 在数组中读取值
      if [ "$in_array" -eq 1 ]; then
        # 遇到新的顶级 key，结束数组
        if [[ "$line" =~ ^[[:space:]]*[a-zA-Z_][a-zA-Z0-9_]*[[:space:]]*:[[:space:]]*$ ]]; then
          break
        fi
        
        # 读取 - 开头的数组项（纯值格式）
        if [[ "$line" =~ ^[[:space:]]*-[[:space:]]+[a-zA-Z0-9] ]]; then
          local value=$(echo "$line" | sed "s/^[[:space:]]*-[[:space:]]*//")
          # 移除注释
          value=$(echo "$value" | sed 's/[[:space:]]*#.*$//' | sed 's/[[:space:]]*$//')
          [ -n "$value" ] && result+=("$value")
        fi
      fi
    done < "$config_file"
  fi
  
  printf '%s\n' "${result[@]}"
}

# 读取域名数组（包含 name 和 desc）
# 用法: while IFS= read -r domain; do ... done < <(get_yaml_domains)
get_yaml_domains() {
  local config_file=$1
  local in_array=0
  local result=()
  
  if [ -f "$config_file" ]; then
    while IFS= read -r line; do
      [[ "$line" =~ ^[[:space:]]*# ]] && continue
      
      if [[ "$line" =~ ^[[:space:]]*domains:[[:space:]]*$ ]]; then
        in_array=1
        continue
      fi
      
      if [ "$in_array" -eq 1 ]; then
        if [[ "$line" =~ ^[[:space:]]*[a-zA-Z_][a-zA-Z0-9_]*[[:space:]]*:[[:space:]]*$ ]]; then
          break
        fi
        
        if [[ "$line" =~ ^[[:space:]]*-+[[:space:]]+name:[[:space:]]+ ]]; then
          local name=$(echo "$line" | sed "s/^[[:space:]]*-[[:space:]]*name:[[:space:]]*//" | sed 's/[[:space:]]*#.*$//' | sed 's/[[:space:]]*$//')
          [ -n "$name" ] && result+=("$name")
        fi
      fi
    done < "$config_file"
  fi
  
  printf '%s\n' "${result[@]}"
}

# ========================================
# 加载配置
# ========================================

if [ ! -f "$CONFIG_FILE" ]; then
  echo "❌ 配置文件不存在: $CONFIG_FILE"
  exit 1
fi

echo "✅ 从配置文件加载: $CONFIG_FILE"

# 读取静态 IP 白名单
STATIC_IPS=($(get_yaml_array "static_ips" "$CONFIG_FILE"))
STATIC_WHITELIST_IP=$(IFS=,; echo "${STATIC_IPS[*]}")

# 读取域名白名单
DOMAINS=($(get_yaml_domains "$CONFIG_FILE"))
DYNAMIC_WHITELIST_DOMAIN=$(IFS=,; echo "${DOMAINS[*]}")

# 读取内网网段
PRIVATE_NETWORKS=($(get_yaml_array "private_networks" "$CONFIG_FILE"))

# 读取 DNS 服务器
DNS_SERVER_ARRAY=($(get_yaml_array "dns_servers" "$CONFIG_FILE"))
DNS_SERVER_COUNT=${#DNS_SERVER_ARRAY[@]}

# 读取定时配置
UPDATE_INTERVAL=$(get_yaml_value "update_interval" "$CONFIG_FILE")
UPDATE_INTERVAL=${UPDATE_INTERVAL:-30}

# 安全检查：UPDATE_INTERVAL 最小值为 30 秒
if ! [[ "$UPDATE_INTERVAL" =~ ^[0-9]+$ ]] || [ "$UPDATE_INTERVAL" -lt 30 ]; then
  echo "⚠️  UPDATE_INTERVAL 必须为数字且不小于 30 秒，已自动设置为 300 秒"
  UPDATE_INTERVAL=300
fi

IPSET_TIMEOUT=$(get_yaml_value "ipset_timeout" "$CONFIG_FILE")
IPSET_TIMEOUT=${IPSET_TIMEOUT:-3600}

# 读取日志配置
LOG_FILE=$(get_yaml_value "log_file" "$CONFIG_FILE")
LOG_FILE=${LOG_FILE:-"/var/log/iptables-whitelist/watcher.log"}
LOG_MAX_SIZE=$(get_yaml_value "log_max_size" "$CONFIG_FILE")
LOG_MAX_SIZE=${LOG_MAX_SIZE:-10485760}
LOG_BACKUP_COUNT=$(get_yaml_value "log_backup_count" "$CONFIG_FILE")
LOG_BACKUP_COUNT=${LOG_BACKUP_COUNT:-5}

# ========================================
# 配置参数（已从配置文件加载）
# ========================================

# ipset 名称定义
# 存储动态域名解析的 IP
IPSET_NAME_DOMAIN="whitelist_domain"
# 存储静态 IP 白名单
IPSET_NAME_STATIC="whitelist_static"
# 存储 DNS 服务器 IP
IPSET_NAME_DNS="whitelist_dns"
# 存储内网 CIDR 段
IPSET_NAME_PRIVATE="whitelist_private"


# ========================================
# 日志函数
# ========================================

log_to_file() {
  local log_dir
  log_dir=$(dirname "$LOG_FILE")
  mkdir -p "$log_dir"
  local msg="[$(date '+%Y-%m-%d %H:%M:%S')] $*"
  echo "$msg" >> "$LOG_FILE"
  sync
}

# ========================================
# 主初始化流程
# ========================================

log_to_file "ℹ️  脚本启动，日志文件: $LOG_FILE"

# 检查必要命令是否存在
for cmd in iptables ipset dig timeout; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    log_to_file "❌ 缺少必要命令: $cmd"
    exit 1
  fi
done

# 创建或清空 ipset
# 1. 动态域名 IP ipset（带 timeout 特性）
ipset create "$IPSET_NAME_DOMAIN" hash:ip timeout "$IPSET_TIMEOUT" family inet 2>/dev/null || ipset flush "$IPSET_NAME_DOMAIN"

# 2. 静态 IP 白名单 ipset（永久有效，不设置 timeout）
ipset create "$IPSET_NAME_STATIC" hash:ip family inet 2>/dev/null || ipset flush "$IPSET_NAME_STATIC"

# 3. DNS 服务器 IP ipset（永久有效）
ipset create "$IPSET_NAME_DNS" hash:ip family inet 2>/dev/null || ipset flush "$IPSET_NAME_DNS"

# 4. 内网 CIDR 段 ipset（使用 hash:net 类型支持网段）
ipset create "$IPSET_NAME_PRIVATE" hash:net family inet 2>/dev/null || ipset flush "$IPSET_NAME_PRIVATE"

# 清空并重建 iptables OUTPUT 链规则
iptables -F OUTPUT

# 规则 1: 允许本地回环流量
iptables -A OUTPUT -o lo -j ACCEPT

# 规则 2: 允许已建立和相关联的连接（关键规则）
# 此规则确保已有的流式连接不会因 IP 白名单变化而中断
iptables -A OUTPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# 规则 3: 允许内网私有地址段（使用 ipset 匹配）
# 10.x.x.x, 172.16-31.x.x, 192.168.x.x
for network in "${PRIVATE_NETWORKS[@]}"; do
  ipset add "$IPSET_NAME_PRIVATE" "$network" 2>/dev/null || true
done
iptables -A OUTPUT -m set --match-set "$IPSET_NAME_PRIVATE" dst -j ACCEPT

# 规则 4: 允许 DNS 查询（UDP/TCP 53 端口到 DNS 服务器）
# 将所有 DNS 服务器 IP 添加到 ipset
for dns in "${DNS_SERVER_ARRAY[@]}"; do
  ipset add "$IPSET_NAME_DNS" "$dns" 2>/dev/null || true
done
iptables -A OUTPUT -m set --match-set "$IPSET_NAME_DNS" dst -p udp --dport 53 -j ACCEPT
iptables -A OUTPUT -m set --match-set "$IPSET_NAME_DNS" dst -p tcp --dport 53 -j ACCEPT

# # 允许 ICMP 流量（ping 功能，可选）
# # 如果不需要 ping 功能，可以注释掉这一行以提高安全性
# iptables -A OUTPUT -p icmp --icmp-type echo-request -j ACCEPT

# 规则 5: 添加静态 IP 白名单（通过配置文件配置）
if [ -n "${STATIC_WHITELIST_IP}" ]; then
  IFS=','; for item in $STATIC_WHITELIST_IP; do
    item=$(echo "$item" | tr -d ' ')
    [ -z "$item" ] && continue
    if [[ "$item" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+(/[0-9]+)?$ ]]; then
      ipset add "$IPSET_NAME_STATIC" "$item" 2>/dev/null || true
    fi
  done
fi
iptables -A OUTPUT -m set --match-set "$IPSET_NAME_STATIC" dst -j ACCEPT

# 规则 6: 允许 ipset 中的动态域名 IP
# 只有匹配 ipset 的流量才能通过
iptables -A OUTPUT -m set --match-set "$IPSET_NAME_DOMAIN" dst -j ACCEPT

# 规则 7: 默认拒绝所有其他出站流量
# 所有不符合上述规则的流量都会被丢弃
iptables -P OUTPUT DROP

log_to_file "✅ iptables 规则初始化完成（更新间隔: ${UPDATE_INTERVAL} 秒）"

# ========================================
# 启动域名解析守护进程
# ========================================

if [ -n "${DYNAMIC_WHITELIST_DOMAIN}" ]; then
  (
    # 环境变量传递
    STATIC_WHITELIST_IP="${STATIC_WHITELIST_IP}"
    DYNAMIC_WHITELIST_DOMAIN="${DYNAMIC_WHITELIST_DOMAIN}"
    IPSET_TIMEOUT="${IPSET_TIMEOUT}"

    # 守护进程的日志函数（包含 sync 强制写入磁盘）
    log_to_file() {
      local log_dir
      log_dir=$(dirname "$LOG_FILE")
      mkdir -p "$log_dir"
      local msg="[$(date '+%Y-%m-%d %H:%M:%S')] $*"
      echo "$msg" >> "$LOG_FILE"
      sync
    }

    # 随机选择 DNS 服务器函数
    # 避免使用单一 DNS 服务器，减少缓存影响
    get_random_dns() {
      # 在子 shell 中需要重新初始化 RANDOM
      local idx=$((RANDOM % DNS_SERVER_COUNT))
      echo "${DNS_SERVER_ARRAY[$idx]}"
    }

    # 错误处理：忽略 HUP TERM INT 信号，防止守护进程意外退出
    set +e
    trap '' HUP TERM INT

    log_to_file "ℹ️  域名解析守护进程启动 (PID=$$)"
    log_to_file "ℹ️  监控域名: ${DYNAMIC_WHITELIST_DOMAIN}"
    [ -n "${STATIC_WHITELIST_IP}" ] && log_to_file "ℹ️  静态 IP 白名单: ${STATIC_WHITELIST_IP}"

    # ========================================
    # 域名解析和 IP 更新函数
    # ========================================
    update_once() {
      log_to_file "🚀 开始域名解析任务..."
      local total_added=0
      local total_updated=0

      # 每次解析任务随机选择一个 DNS 服务器（所有域名使用同一个）
      local dns_server=$(get_random_dns)
      log_to_file "📡 本次解析使用 DNS 服务器: $dns_server"

      # 用于记录 IP 与域名的映射关系
      declare -A IP_DOMAIN_MAP

      # 解析静态 IP 白名单（用于过滤重复 IP）
      declare -A STATIC_IPS
      if [ -n "${STATIC_WHITELIST_IP}" ]; then
        IFS=','; for item in $STATIC_WHITELIST_IP; do
          item=$(echo "$item" | tr -d ' ')
          [ -z "$item" ] && continue
          if [[ "$item" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
            STATIC_IPS["$item"]=1
          fi
        done
      fi

      # 遍历所有需要监控的域名
      IFS=','; for domain in ${DYNAMIC_WHITELIST_DOMAIN}; do
        domain=$(echo "$domain" | tr -d ' ')
        [ -z "$domain" ] && continue
        log_to_file "🔍 解析域名: $domain"

        # 使用 dig 查询域名的 A 记录（IPv4 地址）
        # +short: 只显示 IP 地址，不显示其他信息
        # @dns_server: 指定 DNS 服务器
        local raw_ips=""
        if ! raw_ips=$(timeout 5 dig +short "@$dns_server" "$domain" A 2>/dev/null); then
          log_to_file "⚠️  $domain: dig 超时、失败或无响应 (DNS: $dns_server)"
          continue
        fi

        # 验证并提取有效的 IPv4 地址
        local valid_ips=()
        if [ -n "$raw_ips" ]; then
          while IFS= read -r line; do
            [ -z "$line" ] && continue
            if [[ "$line" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
              valid_ips+=("$line")
            fi
          done <<< "$raw_ips"$'\n'
        fi

        # 如果没有解析到有效 IP，跳过此域名
        if [ ${#valid_ips[@]} -eq 0 ]; then
          log_to_file "⚠️  $domain: 未解析到有效 IPv4 地址"
          continue
        fi

        # 将解析到的 IP 添加到 ipset
        local count=0
        for ip in "${valid_ips[@]}"; do
          # 如果 IP 已在静态白名单中，跳过
          if [ -n "${STATIC_IPS[$ip]:-}" ]; then
            log_to_file "⏭️  IP: $ip - 已在静态白名单中，跳过"
          # 尝试添加或更新 IP
          # -exist: 如果 IP 已存在，只更新 timeout
          elif ipset add "$IPSET_NAME_DOMAIN" "$ip" timeout "$IPSET_TIMEOUT" -exist 2>/dev/null; then
            # 检查 IP 是否已经存在
            if ipset test "$IPSET_NAME_DOMAIN" "$ip" 2>/dev/null; then
              # IP 已存在，刷新 TTL（超时时间）
              ipset add "$IPSET_NAME_DOMAIN" "$ip" timeout "$IPSET_TIMEOUT" -exist 2>/dev/null
              log_to_file "🔄 更新 IP: $ip (TTL: ${IPSET_TIMEOUT}s)"
              ((total_updated++))
            else
              # 新 IP，添加到 ipset
              log_to_file "✅ 添加 IP: $ip (TTL: ${IPSET_TIMEOUT}s)"
              ((count++))
              ((total_added++))
            fi
            IP_DOMAIN_MAP["$ip"]="$domain"
          else
            log_to_file "❌ 无法添加 IP: $ip"
          fi
        done
        log_to_file "💡 $domain: 添加 $count 个新 IP，更新 $total_updated 个已有 IP"
      done

      log_to_file "📈 本次解析完成，共添加 $total_added 个新 IP，更新 $total_updated 个已有 IP"

      # ========================================
      # 输出白名单快照
      # ========================================
      log_to_file "────────────────────────────────────────"
      log_to_file "📊 完整出站白名单快照"

      # 输出静态 IP 白名单
      log_to_file "[STATIC IP/CIDR]"
      if [ -n "${STATIC_WHITELIST_IP}" ]; then
        local found=0
        IFS=','; for item in $STATIC_WHITELIST_IP; do
          item=$(echo "$item" | tr -d ' ')
          [ -z "$item" ] && continue
          if [[ "$item" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+(/[0-9]+)?$ ]]; then
            log_to_file "  - $item"
            found=1
          fi
        done
        [ "$found" -eq 0 ] && log_to_file "  (none)"
      else
        log_to_file "  (none)"
      fi

      # 输出动态域名解析的 IP（排除静态白名单中的 IP）
      log_to_file "[DYNAMIC DOMAIN IPs]"
      local found=0
      local members
      members=$(ipset list "$IPSET_NAME_DOMAIN" 2>/dev/null | sed -n '/^Members:/,$p' | tail -n +2)
      if [ -n "$members" ]; then
        while IFS= read -r line; do
          [ -z "$(echo "$line" | tr -d ' \t')" ] && continue
          local ip
          ip=$(echo "$line" | awk '{print $1}')
          if [[ "$ip" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
            if [ -z "${STATIC_IPS[$ip]:-}" ]; then
              log_to_file "  - $ip"
              found=1
            fi
          fi
        done <<< "$members"
      fi
      [ "$found" -eq 0 ] && log_to_file "  (none)"

      log_to_file "────────────────────────────────────────"
      log_to_file ""

      # ========================================
      # 日志轮转
      # ========================================
      # 当日志文件超过 LOG_MAX_SIZE 时，进行轮转
      # 轮转策略：
      # 1. 删除最老的备份（.5）
      # 2. 重命名 .4 -> .5, .3 -> .4, ..., .1 -> .2
      # 3. 复制当前日志到 .1
      # 4. 清空当前日志文件
      # 使用 cp 而不是 mv，避免破坏文件描述符
      if [ -f "$LOG_FILE" ]; then
        current_size=$(stat -c%s "$LOG_FILE" 2>/dev/null || echo 0)
        if [ "$current_size" -gt "$LOG_MAX_SIZE" ]; then
          [ -f "${LOG_FILE}.${LOG_BACKUP_COUNT}" ] && rm -f "${LOG_FILE}.${LOG_BACKUP_COUNT}"
          for ((i=LOG_BACKUP_COUNT-1; i>=1; i--)); do
            [ -f "${LOG_FILE}.${i}" ] && mv "${LOG_FILE}.${i}" "${LOG_FILE}.$((i+1))"
          done
          cp "$LOG_FILE" "${LOG_FILE}.1"
          truncate -s 0 "$LOG_FILE"
          log_to_file "ℹ️  日志已轮转（保留 ${LOG_BACKUP_COUNT} 份）"
        fi
      fi
    }

    # 首次执行域名解析
    update_once

    # 持续循环，定时更新
    while true; do
      sleep "$UPDATE_INTERVAL"
      update_once
    done
  ) </dev/null &

  # 将守护进程从当前 shell 分离，使其在后台独立运行
  disown
  log_to_file "🔄 已启动域名解析守护进程（日志仅写入 $LOG_FILE）"
else
  log_to_file "ℹ️  配置文件中未设置域名白名单，跳过守护进程"
fi

exit 0