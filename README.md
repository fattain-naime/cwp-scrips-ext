# CWP Scripts Extended

> **Unofficial community-maintained fix pack for CentOS Web Panel (CWP) built-in scripts**

---

## What is this?

This repository contains **fixed CWP scripts** that replace the stock scripts shipped with CentOS Web Panel.

The original CWP scripts (located at `/usr/local/cwpsrv/htdocs/resources/scripts/`) have several issues:

- **Insecure HTTP downloads** - multiple scripts used plain `http://` for downloading packages, RPMs, and updates
- **Deprecated commands** - heavy reliance on `service` instead of `systemctl` (CentOS 7 / RHEL 7 / AlmaLinux 8 / Rocky 8)
- **Outdated mirrors** - CentOS 7 EOL caused broken `mirrorlist.centos.org` / `mirror.centos.org` URLs
- **Missing safety** - dangerous operations (`rm -f`, `> /var/log/*`) without confirmation, dry-run, or backup
- **Outdated package sources** - hardcoded EOL repository URLs (Webtatic, CentOS mirrors, etc.)

This repo provides **drop-in replacements** with all issues fixed while preserving CWP compatibility.

---

## Why this repo exists

The stock CWP scripts are maintained by the CWP team but receive slow updates. After auditing all 97 scripts on a production CWP server, several classes of problems were found:

1. **Security review findings**: 6 scripts downloaded files over plaintext HTTP, exposing servers to man-in-the-middle package injection.
2. **EOL distros**: CentOS 7 reached EOL in June 2024; its mirror URLs (`mirrorlist.centos.org`, `mirror.centos.org`) now fail. Scripts referencing them break `yum`.
3. **Deprecated tooling**: `service` and `/etc/init.d/` calls still dominate, while EL8+ expects `systemctl`.
4. **No safety rails**: cleanup scripts truncate logs with zero confirmation, backup, or dry-run support.
5. **Broken installers**: several `install_*` scripts point to dead URLs or unsupported distro versions.

All scripts here are the **original CWP scripts with targeted fixes**. The original author is CentOS Web Panel; this repo only fixes and modernizes them.

---

## What was fixed

| Category | Count | Description |
|----------|-------|-------------|
| Security (HTTPS) | 16 scripts | All `http://` downloads upgraded to `https://` |
| Modernization | 25 scripts | `service` replaced with `systemctl` |
| Mirrors | 1 script | CentOS 7 to vault.centos.org, AlmaLinux/Rocky 8/9 auto-detection |
| Safety | 1 script | clean_logs: dry-run, yes flag, backup, confirmations |
| Compatibility | 2 scripts | Webtatic URL, Judy-devel package path |

---

## Scripts index

### AutoSSL / SSL

| Script | Purpose |
|--------|---------|
| autossl_fix_tmp_path | Fix AutoSSL webroot path for acme.sh renewals |
| autossl_generate_apache_conf | Generate Apache proxy config for ACME challenges |
| autossl_reload | Reload webservers after SSL certificate changes |
| generate_hostname_ssl | Generate self-signed hostname SSL and wire it into all services |
| hostname_ssl_restart_services | Reload all services after hostname SSL renewal |

### Firewall / Security

| Script | Purpose |
|--------|---------|
| cwp_bruteforce_protection | Configure CSF/LFD custom regex rules for CWP logins and WordPress |
| cwp_monitor | High-load monitor; kills PHP and restarts Apache at critical load |
| cwpsecure_update_rules | Update CWP Tomoyo kernel security rules (requires cwpsecure) |
| cwp_security_audit | Runtime audit of cwpsrv, php-fpm, Apache (ghost files, ports, libs) |
| security_is_my_server_hacked | Quick server compromise check |
| temp_hacker_check | Deep temp directory hacker artifact scan |
| install_supportKey | Install CWP support SSH access key and CSF allow rule |

### Package Installation

| Script | Purpose |
|--------|---------|
| install_acme | Install acme.sh (Let's Encrypt client) for CWP |
| install_api | Configure CWP API listener on port 2304 (SSL) |
| install_cbpolicyd | Install Cluebringer policyd for Postfix rate limiting |
| install_imagick | Compile and install PHP Imagick extension |
| install_maldet | Install Linux Malware Detect (maldet) |
| install_net2ftp | Install net2ftp web FTP client |
| install_netdata | Install Netdata monitoring agent with CWP integration |
| install_phpPgAdmin | Install phpPgAdmin for PostgreSQL management |
| install_pure-ftpd_tls | Enable TLS for Pure-FTPd using hostname certificate |
| install_terminal | Install CWP web terminal (Node.js + socket.io + xterm) |

### MySQL / Database

| Script | Purpose |
|--------|---------|
| checkdb | Scan all database tables for corruption and raise CWP alert |
| mysql_fix_myisam_tables | Repair MyISAM tables |
| mysql_phpmyadmin_update | Update phpMyAdmin to latest CWP-recommended version |
| mysql_pwd_reset | Reset MySQL/MariaDB root password |
| mysql_set_max_connections | Set MySQL max_connections |
| mysql_show_max_connections | Show current max_connections |
| upgrade_mysql | Upgrade MySQL 5.5 and phpMyAdmin (CentOS 6 only) |

### Logging / Cleanup

| Script | Purpose |
|--------|---------|
| clean_logs | Modular log cleanup with dry-run, backup, and confirmation |
| clean_all_server_logs | Legacy bulk log truncation (no safety rails) |
| clean_goaccess_files | Remove GoAccess reports older than N months |
| stats_clean_domlogs | Clean domain access logs |
| freshclam | Update ClamAV packages and virus database |

### Web Server

| Script | Purpose |
|--------|---------|
| apache_mpm_calculator | Calculate optimal Apache MPM settings from live memory usage |
| apache_server-status | Secure Apache server-status handler (localhost only) |
| dso_handler_remove | Disable DSO PHP handler, fall back to suPHP |
| fix_cwpsrv_logs | Fix cwpsrv log format and API port SSL config |
| restart_httpd | Restart Apache |
| restart_cwpsrv | Restart CWP panel and PHP services |
| reload_cwpsrv | Reload CWP services |
| varnish_clear_cache | Clear Varnish cache |

### DNS / Domains

| Script | Purpose |
|--------|---------|
| dns_sync_slave2 | Sync DNS zones to slave nameservers over SSH |
| list_domains | List all addon domains with user and path |
| list_subdomains | List all subdomains |
| list_users | List all CWP accounts |
| reseller_list_accounts | List reseller accounts |
| whoowns | Find which user owns a domain |
| userowner | Fix file ownership recursively for a user |

### Mail

| Script | Purpose |
|--------|---------|
| check_postqueue | Count Postfix deferred queue, optional threshold exit code |
| mail_queue_stats | Postfix mail queue statistics |
| mail_rebuild_sni_certs | Rebuild Dovecot/Postfix SNI certificates |
| mail_roundcube_update | Update Roundcube, plugins, and DB schema |
| mail_vmail_import | Import vmail accounts |
| update_roundcube | Update Roundcube to 1.5.8 with INTL extension handling |

### PHP

| Script | Purpose |
|--------|---------|
| cpanel_addhandlers | Add suPHP handlers for PHP 5.3 through 8.3 and EA-PHP |
| open_basedir-suphp | Fix open_basedir for suPHP |
| php_big_file_upload | Increase PHP upload limits and restart services |
| phpfpm_rebuild_user_conf | Rebuild PHP-FPM user pool configs |
| phpfpm_service_manage | Manage PHP-FPM service |
| php_mail_log | Enable PHP mail logging |

### System

| Script | Purpose |
|--------|---------|
| add_alert | Push alert notification into CWP admin panel |
| amavisd_fix_allowed_header_tests | Fix Amavisd bad-header rejection config |
| bandwidth_run | Calculate domain bandwidth from domlogs bytes files |
| cgroups_blkio | Show cgroups blkio device limits |
| centos7_fix_repository | Fix EOL distro repos: CentOS 7, AlmaLinux 8/9, Rocky 8/9 |
| check_api | Test CWP User API and External API endpoints plus CSF ports |
| chroot_add | Jail a user into sftp chroot with jailkit |
| chroot_remove | Remove a user chroot jail |
| clamd_fix_100_cpu_usage | Fix ClamAV 100 percent CPU usage on EL7 |
| cron_fix_openbasedir | Daily cron: rebuild user configs when open_basedir errors appear |
| cwp_set_memory_limit | Set CWP PHP memory limits based on total RAM |
| disk_check | Quick disk usage summary for key paths |
| disk_usage_per_user | Show quota usage per user via repquota |
| el8_stream_convert_to_cwp_stable | Convert CentOS Stream 8 repos to CWP delayed stable repos |
| image_rebuild_server_config | Full server rebuild: IP, hostname, SSL, passwords, CWP update |
| net_show_connections | Show active network connections |
| quota_check_status | Check quota status |
| system_info | Show system information summary |
| ulimit_user_check | Check user ulimits |
| update_cwp | Run CWP cron updater |
| update_ioncube | Update ionCube Loader for CWP PHP |
| update_openssl | Compile and install OpenSSL 1.1.1w to /usr/local/openssl |
| user_backup | Backup a user account |
| cwp_version | Show CWP version |
| cwp_api | CWP API wrapper for webservers reload |
| cwpsrv_rebuild_user_conf | Rebuild cwpsrv and php-fpm per-user configs |

---

## Notable fixes in detail

### centos7_fix_repository

The stock script only handled CentOS 7. The fixed version auto-detects the OS via `/etc/os-release`:

- CentOS 7 / RHEL 7: rewrites `mirror.centos.org` and `mirrorlist.centos.org` to `vault.centos.org`, including the OVH mirror variant
- AlmaLinux 8/9 and Rocky 8/9: rewrites `repo.almalinux.org` / `mirrors.almalinux.org` to `vault.centos.org`
- Unsupported versions exit with a clear error instead of corrupting repo files

### clean_logs

The stock script truncated logs immediately with no way back. The fixed version adds:

- `--dry-run` to preview every truncation and removal
- `--yes` for non-interactive cron use
- `--backup` to create timestamped `.bak` copies before truncating
- Per-profile confirmation prompts when running interactively
- `set -euo pipefail` for strict error handling

### Download URLs (16 scripts)

Every `http://` download was switched to `https://`:

| Script | What changed |
|--------|-------------|
| upgrade_mysql | Webtatic repo RPM and phpMyAdmin zip |
| mysql_phpmyadmin_update | phpMyAdmin zip and version check |
| cwpsecure_update_rules | CWP security rules tarball and version file |
| update_roundcube | Roundcube tarball, libicu RPM, intl.so |
| mail_roundcube_update | Roundcube tarball, plugins zip, SQL seeds, autologon plugin |
| update_openssl | OpenSSL source URL kept https, noted |
| install_maldet | maldetect-current.tar.gz |
| install_cbpolicyd | Cluebringer RPM and policyd.sql |
| install_net2ftp | net2ftp zip |
| softaculous_fix_update | Softaculous installer |
| install_phpPgAdmin | phpPgAdmin tarball |
| update_ioncube | ionCube loaders tarball |
| install_imagick | Imagick PECL tarball |
| install_acme | get.acme.sh bootstrap |
| cwp_update_admin, cwp_update_user, cwp_update_all, cwp_update_admin_design, cwp_update_user_design | CWP version checks |
| image_rebuild_server_config | CWP version check |
| install_netdata | okay.com.mx repo RPM and Judy-devel package (also moved to vault.centos.org) |

---

## Quick install

```bash
curl -fsSL https://raw.githubusercontent.com/fattain-naime/cwp-scrips-ext/main/install.sh | bash
```

What the installer does:

1. Backs up the existing `/usr/local/cwpsrv/htdocs/resources/scripts/` to `scripts.bak.<date>`
2. Downloads all fixed scripts from this repo
4. Sets executable permissions
5. Runs `bash -n` syntax check on every script
5. Prints a summary

To restore the originals: `rm -rf /usr/local/cwpsrv/htdocs/resources/scripts && mv /usr/local/cwpsrv/htdocs/resources/scripts.bak.<date> /usr/local/cwpsrv/htdocs/resources/scripts`

## Manual install (single script)

```bash
curl -fsSL https://raw.githubusercontent.com/fattain-naime/cwp-scrips-ext/main/clean_logs \
  -o /usr/local/cwpsrv/htdocs/resources/scripts/clean_logs
chmod +x /usr/local/cwpsrv/htdocs/resources/scripts/clean_logs
```

## Usage examples

```bash
# Preview log cleanup before running it
/usr/local/cwpsrv/htdocs/resources/scripts/clean_logs --dry-run system apache_domains

# Backup then clean with confirmation
/usr/local/cwpsrv/htdocs/resources/scripts/clean_logs --backup system

# Non-interactive cron usage
/usr/local/cwpsrv/htdocs/resources/scripts/clean_logs --yes --backup system apache_domains

# Fix EOL distro repositories
/usr/local/cwpsrv/htdocs/resources/scripts/centos7_fix_repository

# Check MySQL table health
/usr/local/cwpsrv/htdocs/resources/scripts/checkdb
```

---

## Requirements

- CentOS 7 / RHEL 7 / AlmaLinux 8/9 / Rocky Linux 8/9
- CWP installed at `/usr/local/cwpsrv/`
- Root access

---

## Disclaimer

This is an UNOFFICIAL community fix pack. The original scripts are copyright CentOS Web Panel (centos-webpanel.com). This repo only fixes bugs, dead URLs, deprecated commands, and missing safety rails. Use at your own risk and always test on a staging server first. The author is not affiliated with CWP.

---

## License

MIT License for the fixes. Original scripts remain the property of CentOS Web Panel.

---

## Author

Fattain Naime
Email: iamnaime@builderhall.com
GitHub: [fattain-naime](https://github.com/fattain-naime)

---

## Contributing

1. Fork the repo
2. Create a feature branch
3. Ensure `bash -n script_name` passes
4. Never commit ionCube-encoded CWP core files
5. Submit a pull request with a clear description of the fix