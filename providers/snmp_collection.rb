def whyrun_supported?
    true
end

use_inline_resources

action :create do
  if @current_resource.exists
    Chef::Log.info "#{ @new_resource } already exists - nothing to do."
  else
    converge_by("Create #{ @new_resource }") do
      create_snmp_collection
      new_resource.updated_by_last_action(true)
    end
  end
end

def load_current_resource
  @current_resource = Chef::Resource::OpennmsSnmpCollection.new(@new_resource.name)
  @current_resource.name(@new_resource.name)

  # Good enough for create/delete but that's about it
  if collection_exists?(@current_resource.name)
     @current_resource.exists = true
  end
end


private

def collection_exists?(name)
  Chef::Log.debug "Checking to see if this snmp collection exists: '#{ name }'"
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/datacollection-config.xml", "r")
  doc = REXML::Document.new file
  !doc.elements["/datacollection-config/snmp-collection[@name='#{name}']"].nil?
end

def create_snmp_collection
  Chef::Log.debug "Creating snmp collection : '#{ new_resource.name }'"
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/datacollection-config.xml", "r")
  contents = file.read
  doc = REXML::Document.new(contents, { :respect_whitespace => :all })

  collection_el = doc.root.add_element 'snmp-collection', {'name' => new_resource.name,'snmpStorageFlag' => new_resource.snmp_stor_flag }
  if new_resource.max_vars_per_pdu
    collection_el.add_attribute('maxVarsPerPdu' => new_resource.max_vars_per_pdu )
  end
  rrd_el = collection_el.add_element 'rrd', { 'step' => new_resource.rrd_step }
  new_resource.rras.each { |rra|
    rra_el = rrd_el.add_element 'rra'
    rra_el.add_text(rra)
  }

  out = ""
  #doc.write(out,3)
  formatter = REXML::Formatters::Pretty.new(2)
  formatter.compact = true
  formatter.write(doc, out)
  ::File.open("#{node['opennms']['conf']['home']}/etc/datacollection-config.xml", "w"){ |file| file.puts(out) }
end

def delete_snmp_collection
  #TODO

end