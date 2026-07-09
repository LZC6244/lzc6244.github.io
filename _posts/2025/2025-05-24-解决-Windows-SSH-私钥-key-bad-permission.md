---
layout:         post
title:          解决 Windows SSH 私钥 key bad permission
create_time:    2025-05-24 20:11
update_time:    
categories:     [Other]
---


# 解决方案

1. 右键文件，点击私钥文件点击属性，切换到安全标签页，点击右下角高级

![](/imgs/JeKyll/2025/2025-05-24-解决-Windows-SSH-私钥-key-bad-permission-004.png)





2. 点击禁用继承，删除所有已继承的权限

![](/imgs/JeKyll/2025/2025-05-24-解决-Windows-SSH-私钥-key-bad-permission-001.png)



3. 点击左下角添加按钮，添加新的访问权限

![](/imgs/JeKyll/2025/2025-05-24-解决-Windows-SSH-私钥-key-bad-permission-005.png)



4. 依次添加当前 Windows 系统用户和 system 用户（可选）

![](/imgs/JeKyll/2025/2025-05-24-解决-Windows-SSH-私钥-key-bad-permission-006.png)

![](/imgs/JeKyll/2025/2025-05-24-解决-Windows-SSH-私钥-key-bad-permission-002.png)

![](/imgs/JeKyll/2025/2025-05-24-解决-Windows-SSH-私钥-key-bad-permission-003.png)



5. 再次尝试 ssh 登录即可，查看是否仍出现 `bad permission`



