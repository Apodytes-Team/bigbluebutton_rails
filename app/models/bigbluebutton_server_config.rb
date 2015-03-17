require 'bigbluebutton_api'

class BigbluebuttonServerConfig < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection

  belongs_to :server, class_name: 'BigbluebuttonServer'
  validates :server_id, presence: true

  serialize :available_layouts, Array

  def get_available_layouts
    if self.available_layouts.blank?
      layouts = self.server.api.get_available_layouts
      self.update_attributes(available_layouts: layouts) unless layouts.nil?
    end
    self.available_layouts
  end

  # This is called when the config.xml is requested to update the info that is
  # being stored locally. Currently the only info stored is about the available
  # layouts. It is also called without the config_xml parameter when we are
  # forcing the update (via Resque task for example).
  def update_config(config_xml=nil)
    # if config_xml is nil, fetch it.
    config_xml = self.server.api.get_default_config_xml if config_xml.nil?
    layouts = self.server.api.get_available_layouts(config_xml)
    self.update_attributes(available_layouts: layouts) unless layouts.nil?
  end
end
