include Provision
def whyrun_supported?
    true
end

use_inline_resources

action :create do
  Chef::Application.fatal!("Missing requisition #{@current_resource.foreign_source_name}.") if !@current_resource.import_exists
  Chef::Application.fatal!("Missing node with foreign ID #{@current_resource.foreign_id}.") if !@current_resource.node_exists
  if @current_resource.exists
    Chef::Log.info "#{ @new_resource } already exists - nothing to do."
  else
    converge_by("Create #{ @new_resource }") do
      create_import_node_interface
      new_resource.updated_by_last_action(true)
    end
  end
end

def load_current_resource
  @current_resource = Chef::Resource::OpennmsImportNodeInterface.new(@new_resource.name)
  @current_resource.name(@new_resource.name)
  @current_resource.foreign_source_name(@new_resource.foreign_source_name)
  @current_resource.foreign_id(@new_resource.foreign_id)

  if import_exists?(@current_resource.foreign_source_name, node)
     @current_resource.import_exists = true
  end
  if import_node_exists?(@current_resource.foreign_source_name, @current_resource.foreign_id, node)
     @current_resource.node_exists = true
  end
  if import_node_interface_exists?(@current_resource.foreign_source_name, @current_resource.foreign_id, @current_resource.name, node)
     @current_resource.exists = true
  end
end

private

def create_import_node_interface
  Chef::Log.info "Adding interface..."
  add_import_node_interface(new_resource.name, new_resource.foreign_source_name,
    new_resource.foreign_id, new_resource.status, 
    new_resource.managed, new_resource.snmp_primary, node)
  Chef::Log.info "Added interface. Doing import..."
  sync_import(new_resource.foreign_source_name,true, node) if !new_resource.sync_import.nil? && new_resource.sync_import
  Chef::Log.info "imported!"
end
