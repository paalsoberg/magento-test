
if node['magento']['capistrano']['enabled'] == true
      config_path = "#{site['capistrano']['deploy_to']}/shared/public"
    else
      config_path = node['docroot']
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
