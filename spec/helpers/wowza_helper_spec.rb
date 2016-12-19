require 'rails_helper'
describe WowzaHelper, type: :helper do
  context 'encrypt audio URL' do
    let (:obj_id) { '3j333268h' }
    let (:file_set_id) { 'd504rk75p' }
    let (:fedora_file) { '34cddd4138eeb3686bdb095b9a26ac077919b0f0' }
    let (:file_name) { 'mp3' }
    let (:request_ip) { '127.0.0.1' }
    subject { helper.grabWowzaURL(obj_id, file_set_id, fedora_file, file_name, request_ip) }

    it "forms the correct encryption" do
      expect(subject).to match(/,/)
    end
  end
end
