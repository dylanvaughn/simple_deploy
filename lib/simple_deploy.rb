require 'simple_deploy/aws'
require 'simple_deploy/env'
require 'simple_deploy/entry'
require 'simple_deploy/entry_lister'
require 'simple_deploy/exceptions'
require 'simple_deploy/configuration'
require 'simple_deploy/artifact'
require 'simple_deploy/stack'
require 'simple_deploy/misc'
require 'simple_deploy/template'
require 'simple_deploy/notifier'
require 'simple_deploy/logger'
require 'simple_deploy/version'
require 'simple_deploy/backoff'

module SimpleDeploy
  module_function

  def create_config(environment, custom_config = {})
    raise SimpleDeploy::Exceptions::IllegalStateException.new(
      'environment is not defined') unless environment

    @config = SimpleDeploy::Configuration.configure environment, custom_config
  end

  def config
    @config
  end

  def release_config
    @config = nil
  end

  def environments(custom_config = {})
    SimpleDeploy::Configuration.environments custom_config
  end

  def logger(log_level = 'info')
    @logger ||= SimpleDeployLogger.new :log_level => log_level
  end
end
