require 'json'

module SimpleDeploy
  class StackUpdater

    def initialize(args)
      @config = SimpleDeploy.config
      @logger = SimpleDeploy.logger
      @entry = args[:entry]
      @name = args[:name]
      @template_body = args[:template_body]
    end

    def update_stack(attributes)
      if parameter_updated?(attributes) || @template_body
        @logger.debug 'Updated parameters or new template found.'
        update
      else
        @logger.debug 'No parameters require updating and no new template found.'
        false
      end
    end

    private

    def update
      if status.wait_for_stable
        @logger.info "Updating Cloud Formation stack #{@name}."
        cloud_formation.update :name       => @name,
                               :parameters => read_parameters_from_entry_attributes,
                               :template   => @template_body
      else
        raise "#{@name} did not reach a stable state."
      end
    end

    def parameter_updated?(attributes)
      (template_parameters - updated_parameters(attributes)) != template_parameters
    end

    def template_parameters
      json = JSON.parse @template_body
      json['Parameters'].nil? ? [] : json['Parameters'].keys
    end

    def updated_parameters attributes
      (attributes.map { |s| s.keys }).flatten
    end

    def read_parameters_from_entry_attributes
      h = {}
      entry_attributes = @entry.attributes
      template_parameters.each do |p|
        if entry_attributes[p] == 'nil'
          @logger.debug "Skipping attribute #{p}"
          next
        end
        h[p] = entry_attributes[p] if entry_attributes[p]
      end
      h
    end

    def cloud_formation
      @cloud_formation ||= AWS::CloudFormation.new
    end

    def status
      @status ||= Status.new :name => @name
    end
  end
end
