module WowzaHelper
  #---
  # Builds Wowza URL
  #
  # @param obj_id
  # @param file_set_id
  # @param fedora_file
  # @media_type: 'audio', 'video'
  # @return string or nil
  #---

  def grabWowzaURL(obj_id, file_set_id, fedora_file, media_type, request_ip)
    encrypted = encrypt_stream_name( obj_id, file_set_id, fedora_file, media_type, request_ip )
    return Rails.configuration.wowza_baseurl + encrypted
  end


  ## video stream name encryption
  def encrypt_stream_name( obj_id, file_set_id, fedora_file, media_type, ip )

    # random nonce
    nonce=rand(36**16).to_s(36)
    while nonce.length < 16 do
      nonce += "x"
    end

    # load key from environment variable
    key = ENV.fetch('APPS_DHH_STREAMING_KEY') {'xxxxxxxxxxxxxxxx'}
    
    # encrypt
    str="#{obj_id} #{file_set_id} #{fedora_file} #{media_type} #{ip}"
    cipher = OpenSSL::Cipher::AES.new(128,:CBC)
    cipher.encrypt
    cipher.key = key
    cipher.iv = nonce
    enc = cipher.update(str) + cipher.final

    # base64-encode
    b64 = Base64.encode64 enc
    b64 = b64.gsub("+","-").gsub("/","_").gsub("\n","")
    "#{nonce},#{b64}"
  end

end
