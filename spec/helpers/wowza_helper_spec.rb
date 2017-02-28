require 'rails_helper'
describe WowzaHelper, type: :helper do
  context 'encrypt audio URL without setting APPS_DHH_STREAMING_KEY key' do
    let (:obj_id) { '3j333268h' }
    let (:file_set_id) { 'd504rk75p' }
    let (:file_name) { 'p-mp3.mp3' }
    let (:request_ip) { '127.0.0.1' }
    subject { helper.wowza_url(obj_id, file_set_id, file_name, request_ip) }

    it "should raise KeyError" do
      expect { raise KeyError }.to raise_error (KeyError)
    end
  end

  context 'encrypt audio URL' do
    before do
      ENV['APPS_DHH_STREAMING_KEY'] = 'xxxxxxxxxxxxxxxx' if ENV['APPS_DHH_STREAMING_KEY'].nil?
    end
    after do
      ENV.delete('APPS_DHH_STREAMING_KEY') if ENV['APPS_DHH_STREAMING_KEY'] == 'xxxxxxxxxxxxxxxx'
    end
    let (:obj_id) { '3j333268h' }
    let (:file_set_id) { 'd504rk75p' }
    let (:file_name) { 'p-mp3.mp3' }
    let (:request_ip) { '127.0.0.1' }
    subject { helper.wowza_url(obj_id, file_set_id, file_name, request_ip) }

    it "forms the correct encryption" do
      expect(subject).to match(/,/)
    end
  end
end
