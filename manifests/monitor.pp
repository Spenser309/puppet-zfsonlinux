# == Class: zfsonlinux::monitor
#
# Adds monitoring capabilities for ZFS
#
# === Parameters
#
# [*monitor_tool*]
#   Name of the application used for monitoring
#   ZFS.  Valid values are zabbix.
#   Required: true
#
# [*monitor_username*]
#   Username used to monitor ZFS
#   Required: Dependent on value for monitor_tool
#
# [*monitor_sudoers_path*]
#   Path of the file where ZFS monitoring sudo
#   rules are defined.
#   Default: $zfsonlinux::params::monitor_sudoers_path
#
# [*monitor_tool_conf_dir*]
#   Directory to put monitoring tool's ZFS scripts
#   and configuration files.
#   Default: Dependent on value for monitor_tool
#
# [*manage_sudo*]
#   Boolean value that defines if ZFS monitoring
#   sudo rules will be managed by this module.
#   Default: true
#
# [*monitor_sudo_commands*]
#   List of commands the monitoring user can execute
#   using sudo.  Value must be a comman delimited String
#   or an Array.
#   Default: $zfsonlinux::params::monitor_sudo_commands
#
# [*include_arcstat*]
#   Sets if the zfsonlinux::arcstat class should be included
#   Default: false
#
# === Authors
#
# Trey Dockendorf <treydock@gmail.com>
#
# === Copyright
#
# Copyright 2013 Trey Dockendorf
#
class zfsonlinux::monitor (
  $monitor_tool,
  $monitor_username       = 'UNSET',
  $monitor_sudoers_path   = $zfsonlinux::params::monitor_sudoers_path,
  $monitor_tool_conf_dir  = 'UNSET',
  $manage_sudo            = true,
  $monitor_sudo_commands  = $zfsonlinux::params::monitor_sudo_commands,
  $include_arcstat        = false
) inherits zfsonlinux::params {

  validate_re($monitor_tool, '^(zabbix)$')
  validate_bool($manage_sudo)
  validate_bool($include_arcstat)

  $monitor_username_real = $monitor_username ? {
    'UNSET' => $zfsonlinux::params::monitor_tool_defaults[$monitor_tool]['username'],
    default => $monitor_username,
  }
  $monitor_tool_conf_dir_real = $monitor_tool_conf_dir ? {
    'UNSET' => $zfsonlinux::params::monitor_tool_defaults[$monitor_tool]['conf_dir'],
    default => $monitor_tool_conf_dir,
  }

  include "zfsonlinux::monitor::${monitor_tool}"
  if $manage_sudo { include zfsonlinux::monitor::sudo }
  if $include_arcstat { include zfsonlinux::arcstat }

}
