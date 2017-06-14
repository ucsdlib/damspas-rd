require 'spec_helper'

describe RelatedResourceInput, type: :input do
  before do
    class Foo < ActiveFedora::Base
      property :relation, predicate: ::RDF::Vocab::DC.relation, class_name: RelatedResource
      accepts_nested_attributes_for :relation
    end
  end

  after do
    Object.send(:remove_const, :Foo)
  end

  context 'with related_resource' do
    let(:foo) { Foo.new }
    let(:bar) { [{ related_type: ['relation'], name: ['Related resource name'], url: ['http://test.com/any/url'] }] }

    subject do
      foo.relation_attributes = bar
      input_for(foo, :relation, as: :related_resource, required: true)
    end

    it 'renders related_resource' do
      expect(subject)
        .to have_selector('.form-group.foo_relation.multi_value label.required[for=foo_relation]', text: 'Relation')
      expect(subject)
        .to have_selector('.form-group.foo_relation.multi_value ul.listing li div.row div.col-md-1 label', count: 3)
      expect(subject)
        .to have_selector('.form-group.foo_relation.multi_value ul.listing li div.row div.col-md-5 input.foo_relation',
                          count: 2)
    end
  end

  context 'related_resource nil' do
    let(:foo) { Foo.new }
    let(:bar) { nil }

    subject do
      foo.relation = bar
      input_for(foo, :relation, as: :related_resource, required: true)
    end

    it 'renders related_resource given a nil object' do
      expect(subject)
        .to have_selector('.form-group.foo_relation.multi_value label.required[for=foo_relation]', text: 'Relation')
      expect(subject).to have_selector('.form-group.foo_relation.multi_value ul.listing')
    end
  end

  describe '#build_field' do
    let(:foo) { Foo.new }
    let(:builder) { double('builder', object: foo, object_name: 'foo') }
    let(:subject) { RelatedResourceInput.new(builder, :relation, nil, :intangible, {}) }

    before do
      foo.relation_attributes = [{ related_type: ['relation'], name: ['Related resource name'],
                                   url: ['http://test.com/any/url'] }]
    end

    it 'renders related_resource' do
      expect(subject).to receive(:build_field).with(foo.relation.first, Integer)
      subject.input({})
    end
  end
end
