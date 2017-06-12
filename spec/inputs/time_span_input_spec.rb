require 'spec_helper'

describe TimeSpanInput, type: :input do
  before do
    class Foo < ActiveFedora::Base
      property :bar, predicate: ::RDF::Vocab::DC.created, class_name: TimeSpan
      accepts_nested_attributes_for :bar
    end
  end

  after do
    Object.send(:remove_const, :Foo)
  end

  context 'with time span' do
    let(:foo) { Foo.new }
    let(:bar) { [{ start: ['2017-03-30'], finish: ['2017-03-30'], label: ['2017-03-30'] }] }

    subject do
      foo.bar_attributes = bar
      input_for(foo, :bar, as: :time_span, required: true)
    end

    it 'renders time span' do
      expect(subject).to have_selector('.form-group.foo_bar.time_span label.required[for=foo_bar]', text: 'Bar')
      expect(subject)
        .to have_selector('.form-group.foo_bar.time_span ul.listing li div.row div.col-md-1 label', count: 3)
      expect(subject)
        .to have_selector('.form-group.foo_bar.time_span ul.listing li div.row div.col-md-5 input.foo_bar', count: 3)
    end
  end

  context 'time span nil' do
    let(:foo) { Foo.new }
    let(:bar) { nil }

    subject do
      foo.bar = bar
      input_for(foo, :bar, as: :time_span, required: true)
    end

    it 'renders time span given a nil object' do
      expect(subject).to have_selector('.form-group.foo_bar.time_span label.required[for=foo_bar]', text: 'Bar')
      expect(subject).to have_selector('.form-group.foo_bar.time_span ul.listing')
    end
  end

  describe '#build_field' do
    let(:foo) { Foo.new }
    let(:builder) { double('builder', object: foo, object_name: 'foo') }
    let(:subject) { TimeSpanInput.new(builder, :bar, nil, :time_span, {}) }

    before { foo.bar_attributes = [{ start: ['2017-03-30'], finish: ['2017-03-30'], label: ['2017-03-30'] }] }

    it 'renders time span' do
      expect(subject).to receive(:build_field).with(foo.bar.first, Integer)
      subject.input({})
    end
  end
end
