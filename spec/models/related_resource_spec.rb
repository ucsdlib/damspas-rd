require 'rails_helper'

describe RelatedResource do
  describe 'create related resource' do
    let(:owner) do
      ObjectResource.new(title: ["Test Object Title"],
                         related_resource_attributes: [{ related_type: ['relation'],
                                                         name: ['Related resource name'],
                                                         url: ['http://test.com/any/url'] }])
    end

    subject { owner.related_resource.first }

    it { expect(subject.new_record?).to eq true }

    context 'a persisted record' do
      before do
        owner.save
      end

      describe 'method #persisted?' do
        it { expect(subject.new_record?).to eq false }
        it { expect(subject.persisted?).to eq true }
      end

      describe 'method #final_parent' do
        it { expect(subject.final_parent.id).to eq owner.uri }
      end

      describe '#label' do
        it { expect(subject.name).to eq ['Related resource name'] }
      end

      describe '#url' do
        it { expect(subject.url).to eq ['http://test.com/any/url'] }
      end

      context '#display_label' do
        let(:label) { "#{subject.related_type.first}: #{subject.name.first} #{subject.url.first}" }

        it { expect(subject.display_label).to eq label }

        describe '#display_label with label only' do
          let(:nested_owner) do
            ObjectResource.create(title: ["Test Object Title"],
                                  related_resource_attributes: [{ related_type: ['relation'],
                                                                  name: ['Related resource name'] }])
          end
          let(:label) { "#{subject.related_type.first}: #{subject.name.first}" }

          it { expect(nested_owner.related_resource.first.display_label).to eq label }
        end

        describe '#display_label with url only' do
          let(:owner) do
            ObjectResource.new(title: ["Test Object Title"],
                               related_resource_attributes: [{ related_type: ['relation'],
                                                               url: ['http://test.com/any/url'] }])
          end

          it { expect(subject.display_label).to eq "#{subject.related_type.first}: #{subject.url.first}" }
        end
      end
    end
  end
end
