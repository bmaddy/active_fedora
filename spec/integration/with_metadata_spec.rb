require 'spec_helper'

describe ActiveFedora::WithMetadata do
  before do
    class Sample < ActiveFedora::File
      include ActiveFedora::WithMetadata

      metadata do
        property :title, predicate: RDF::DC.title
      end
    end
  end

  after do
    Object.send(:remove_const, :Sample)
  end

  let(:base) { ActiveFedora::Base.new }
  let(:file) { Sample.new(base, 'ds1') }

  describe "properties" do
    it "should set and retrieve properties" do
      file.title = ['one', 'two']
      expect(file.title).to eq ['one', 'two']
    end
  end

  describe "#save" do
    before do
      file.title = ["foo"]
      base.save
      file.save
      base.reload
    end

    it "should save the metadata too" do
      expect(base.ds1.title).to eq ['foo']
    end
  end

end
