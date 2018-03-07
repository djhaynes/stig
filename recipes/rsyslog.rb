# Cookbook Name:: stig
# Recipe:: rsyslog
# Author: Ivan Suftin <isuftin@usgs.gov>
#
# Description: Configure /etc/rsyslog.conf
#
# CIS Benchmark Items
# RHEL6:  5.1.3
# CENTOS6: 4.1.3
# UBUNTU: 8.2.3

syslog_rules = node['stig']['logging']['rsyslog_rules']

# Fixed to check platform_family versus platform
#    'debian', 'ubuntu', 'linuxmint' are platforms; 
#    'debian' is the platform_family that includes those platforms
if node['platform_family'] == 'debian'
  syslog_rules.concat(node['stig']['logging']['rsyslog_rules_debian'])
end

# Fixed to check platform_family versus platform
#    'redhat', 'fedora', 'centos' are platforms; 
#    'rhel' is the platform_family that includes those platforms
if node['platform_family'] == 'rhel'
  syslog_rules.concat(node['stig']['logging']['rsyslog_rules_rhel'])
end

template '/etc/rsyslog.conf' do
  source 'etc_rsyslog.conf.erb'
  owner 'root'
  group 'root'
  mode 0o644
  variables(
    rsyslog_rules: node['stig']['logging']['rsyslog_rules'],
	rsyslog_queue_rules: node['stig']['logging']['rsyslog_queue_rules'],
  	server_port: node['stig']['rsyslog']['server_port'],
	server_name: node['stig']['rsyslog']['server_name'],
	encrypt_traffic: node['stig']['rsyslog']['encrypt_traffic']
  )
  notifies :run, 'execute[restart_syslog]', :immediately
end

execute 'restart_syslog' do
  user 'root'
  command 'pkill -HUP rsyslogd'
  action :nothing
end
