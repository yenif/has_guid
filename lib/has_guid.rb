require 'uuidtools'
module HasGuid
  def self.included(base)
    base.extend(ClassMethods)
    super
  end

  module ClassMethods
    def has_guid(attr = :guid)
      self.instance_eval do
        validates_each attr, :on => :update, :if => :"#{attr.to_s}_was" do |record, attr, value|
          record.errors.add attr, "can't be changed once set" if record.send("#{attr.to_s}_changed?".to_sym)
        end
        before_validation_on_create :initialize_guid

        define_method :initialize_guid do
          # set guid
          self.send("#{attr.to_s}=".to_sym, UUIDTools::UUID.random_create.to_s())
        end

        define_method :to_param do #overide default of :id
          guid
        end

        # add guid to list of default protected attributes 
        define_method :attributes_protected_by_default do
          super << attr
        end
      end
    end
  end
end

class ActiveRecord::Base
  include HasGuid
end
