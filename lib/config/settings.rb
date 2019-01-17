require 'yaml'

module Ordy
  CONFIG_PATH = 'lib/config/settings.yml'

  def self.config
    @config ||= JSON.parse(YAML::load_file(CONFIG_PATH).to_json, object_class: OpenStruct)
  end
end