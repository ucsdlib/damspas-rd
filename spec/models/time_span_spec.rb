require 'rails_helper'

describe TimeSpan do
  describe 'create nested TimeSpan' do
    before do
      @owner = ObjectResource.new(title:["Test Object Title"], created_date_attributes: [{start: ['2017-03-28'], finish: ['2017-03-28'], label: ['Mar 28, 2017']}])
    end

    subject { @owner.created_date.first }

    describe 'method #new_record?' do
      it { expect(subject.new_record?).to eq true }
    end

    context 'a persisted record' do
      before do
        @owner.save
      end

      after do
        @owner.delete
      end

      describe 'method #persisted?' do
        it { expect(subject.new_record?).to eq false }
        it { expect(subject.persisted?).to eq true }
      end

      describe 'method #final_parent' do
        it { expect(subject.final_parent.id).to eq @owner.uri }
      end

      describe '#start' do
        it { expect(subject.start).to eq ['2017-03-28'] }
      end

      describe '#finish' do
        it { expect(subject.finish).to eq ['2017-03-28'] }
      end

      describe '#label' do
        it { expect(subject.label).to eq ['Mar 28, 2017'] }
      end

      context 'method #display label' do
        describe 'has label' do
          it { expect(subject.display_label).to eq 'Mar 28, 2017' }
        end

        describe 'has different begin date and end date' do
          let(:test_owner) { ObjectResource.create(created_date_attributes: [{start: ['2017-03-28'], finish: ['2017-04-28']}])}
          it { expect(test_owner.created_date.first.display_label).to eq '2017-03-28 to 2017-04-28' }
        end

        describe 'has begin date only' do
          let(:test_owner) { ObjectResource.create(created_date_attributes: [{start: ['2017-03-28']}])}
          it { expect(test_owner.created_date.first.display_label).to eq '2017-03-28' }
        end
      end
    end
  end
end
