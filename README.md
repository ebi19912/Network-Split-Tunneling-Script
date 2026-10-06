# Network Split Tunneling Script

This project provides an automated script to bypass a VPN for local IP addresses and specific DNS namespaces on Windows.

## Features / ویژگی‌ها

**English:**
- **Local IP Routing**: Automatically routes private networks (`10.x.x.x`, `172.16.x.x`, `192.168.x.x`) through your physical network gateway, bypassing the VPN.
- **DNS Split Routing (NRPT)**: Forces DNS queries for `Example.com` to be resolved strictly by specific local DNS servers (`10.10.10.100`, `10.10.10.101`).
- **Persistent Rules**: Network routes and DNS policies remain active even after system restarts.

**فارسی:**
- **مسیریابی آی‌پی‌های داخلی**: ترافیک شبکه‌های خصوصی (`10.x.x.x`، `172.16.x.x` و `192.168.x.x`) را به صورت خودکار از کارت شبکه اصلی شما (به جای VPN) عبور می‌دهد.
- **تفکیک درخواست‌های DNS**: درخواست‌های مربوط به دامنه `Example.com` را مجبور می‌کند تا مستقیماً توسط DNS سرورهای داخلی (`10.10.10.100` و `10.10.10.101`) ترجمه شوند.
- **تغییرات پایدار**: تنظیمات با ری‌استارت شدن سیستم پاک نمی‌شوند و نیازی به اجرای مجدد در هر بار اتصال نیست.

---

## How to use / نحوه استفاده

**English:**
1. Right-click on `RunMe.bat` and select **Run as administrator**.
2. Wait for the blue terminal screen to complete the process.
3. Once it says `Configuration completed!`, press any key to close it.

**فارسی:**
1. روی فایل `RunMe.bat` راست‌کلیک کرده و گزینه **Run as administrator** را انتخاب کنید.
2. منتظر بمانید تا صفحه آبی‌رنگ باز شده و عملیات را انجام دهد.
3. پس از مشاهده پیام `Configuration completed!`، یک کلید را فشار دهید تا پنجره بسته شود.

---

## Files / فایل‌ها
- `RunMe.bat`: A secure launcher that automatically requests administrator privileges and runs the PowerShell script bypassing restrictions.
- `FixNetwork.ps1`: The core PowerShell script containing all routing logic.
