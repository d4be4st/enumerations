# required for constantize method
require 'active_support/core_ext/string/inflections.rb'

require 'enumerations/version'
require 'enumerations/base'
require 'enumerations/reflection'

# TODO: rename to Enumeration(s) in a major version change
module Enumeration
  def self.included(receiver)
    receiver.extend ClassMethods
  end

  module ClassMethods
    # Create an enumeration for the symbol <tt>name</tt>.
    # Options include <tt>foreign key</tt> attribute and Class name
    def enumeration(name, options = {})
      options[:foreign_key] ||= "#{name}_id".to_sym
      options[:class_name] ||= name.to_s.camelize

      # Getter for belongs_to
      define_method name do
        options[:class_name].constantize.find(send(options[:foreign_key]))
      end

      # Setter for belongs_to
      define_method "#{name}=" do |other|
        send("#{options[:foreign_key]}=", other.id)
      end

      # Store a list of used enumerations
      @_all_enumerations ||= []
      @_all_enumerations << Reflection.new(name, options)
    end

    # Output all the enumerations that this model has defined
    def reflect_on_all_enumerations
      @_all_enumerations
    end
  end
end

# Extend ActiveRecord with Enumeration capabilites
ActiveRecord::Base.send(:include, Enumeration) if defined? ActiveRecord
