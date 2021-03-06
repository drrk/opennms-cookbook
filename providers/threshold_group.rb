include Threshold
def whyrun_supported?
    true
end

use_inline_resources

action :create do
  if @current_resource.exists
    Chef::Log.info "#{ @new_resource } already exists - nothing to do."
  else
    converge_by("Create #{ @new_resource }") do
      create_threshold_group
      new_resource.updated_by_last_action(true)
    end
  end
end

def load_current_resource
  @current_resource = Chef::Resource::OpennmsThresholdGroup.new(@new_resource.name)
  @current_resource.name(@new_resource.name)

  if group_exists?(@current_resource.name, node)
    @current_resource.exists = true
  end
end

private

def create_threshold_group
  Chef::Log.debug "Adding thresholding group: '#{ new_resource.name }'"
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/thresholds.xml")
  contents = file.read
  doc = REXML::Document.new(contents, { :respect_whitespace => :all })
  doc.context[:attribute_quote] = :quote
  file.close
  
  group_el = REXML::Element.new 'group'
  group_el.attributes['name'] = new_resource.name
  group_el.attributes['rrdRepository'] = new_resource.rrd_repository
  
  last_group_el = doc.root.elements["/thresholding-config/group[last()]"]
  if !last_group_el.nil?
    doc.root.insert_after(last_group_el, group_el)
  else
    doc.root.add_element group_el
  end

  out = ""
  formatter = REXML::Formatters::Pretty.new(2)
  formatter.compact = true
  formatter.write(doc, out)
  ::File.open("#{node['opennms']['conf']['home']}/etc/thresholds.xml", "w"){ |file| file.puts(out) }
end
