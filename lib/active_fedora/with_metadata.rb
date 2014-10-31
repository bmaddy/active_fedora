module ActiveFedora
  module WithMetadata
    extend ActiveSupport::Concern

    def method_missing(name, *args)
      if metadata_node.respond_to? name
        metadata_node.send(name, *args)
      else
        super
      end
    end

    def metadata_node
      @metadata_node ||= Class.new(MetadataNode).new(self)
    end

    def save(*)
      super
      metadata_node.save # TODO if changed?
    end

    module ClassMethods
      attr_reader :metadata_schema
      def metadata(&block)
        @metadata_schema = MetadataSchema.new(block)
      end
    end

    class MetadataNode < ActiveTriples::Resource
      def initialize(file)
        @file = file
        if file.new_record?
          uri = RDF::URI.new nil
        else
          raise "#{file} must respond_to described_by" unless file.respond_to? :described_by
          uri = file.described_by
        end
        class_eval &file.class.metadata_schema.block
        super(uri)
      end

      def save
        raise NotImplementedError, "Okay, now how do we persist this resource?"
      end

    end

    class MetadataSchema
      attr_reader :block
      def initialize(block)
        @block = block
      end
    end
  end
end
