require 'rexml/document'

actions :create
default_action :create

attribute :package, :name_attribute => true, :kind_of => String, :required => true
attribute :remote, :kind_of => [TrueClass, FalseClass], :default => false
attribute :filter, :kind_of => String, :default => "IPADDR != '0.0.0.0'", :required => true
attribute :specifics, :kind_of => Array
attribute :include_ranges, :kind_of => Hash
attribute :exclude_ranges, :kind_of => Hash
attribute :include_urls, :kind_of => Array
attribute :rrd_step, :kind_of => Fixnum, :default => 300
attribute :rras, :kind_of => Array, :default => ['RRA:AVERAGE:0.5:1:2016', 'RRA:AVERAGE:0.5:12:1488','RRA:AVERAGE:0.5:288:366','RRA:MAX:0.5:288:366','RRA:MIN:0.5:288:366']
attribute :outage_calendars, :kind_of => Array
# BEGIN => {'interval' => 00000, 'end' => 00000, 'delete' => true}, ...
attribute :downtimes, :kind_of => Hash, :default => {0 => {'interval' => 30000, 'end' => 300000}, 300000 => {'interval' => 300000, 'end' => 43200000}, 43200000 => {'interval' => 600000, 'end' => 432000000}, 432000000 => {'delete' => true}}

attr_accessor :exists
