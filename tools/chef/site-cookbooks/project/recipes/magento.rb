::Chef::Recipe.send(:include, ConfigDrivenHelper::Util)

node['nginx']['sites'].each_pair do |name, siteMash|
  site = immutablemash_to_hash(siteMash)

  if site['inherits']
    site = ::Chef::Mixin::DeepMerge.hash_only_merge(
      immutablemash_to_hash(node['nginx']['shared_config'][site['inherits']]),
      site
    )
  end

  site = ::Chef::Mixin::DeepMerge.hash_only_merge(immutablemash_to_hash(node["nginx-sites"]), site)

  if site['type'] == 'magento'

    cron_d "magento-#{name}" do
      command "sh #{site['docroot']}/cron.sh"
      user 'apache'
    end

    magento = immutablemash_to_hash(node['magento'])

    if site['magento']
      magento = ::Chef::Mixin::DeepMerge.hash_only_merge(
        magento,
        immutablemash_to_hash(site['magento']))
    end

    if site['capistrano']
      config_path = "#{site['capistrano']['deploy_to']}/shared/public"
    else
      config_path = site['docroot']
    end


directory config_path do
  recursive true
  mode "0755"
  action :create
end

template "#{config_path}/app/etc/local.xml" do
  source "local.xml.erb"
  mode 0644
  variables({
    :magento => magento
  })
end

  end
end
