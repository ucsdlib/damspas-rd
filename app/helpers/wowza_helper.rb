module WowzaHelper
  #---
  # Builds Wowza URL
  #
  # @param obj_id
  # @param file_set_id
  # @param file_name
  # @param request_ip
  # @return string or nil
  #---

  def wowza_url(obj_id, file_set_id, file_name, request_ip)
    plain_text = "#{obj_id} #{file_set_id} #{file_name} #{request_ip}"
    encrypted = encrypt_stream_name plain_text
    return Rails.configuration.wowza_baseurl + encrypted
  end


  ## video stream name encryption
  def encrypt_stream_name( plaintext )

    # random nonce
    nonce=rand(36**16).to_s(36)
    while nonce.length < 16 do
      nonce += "x"
    end

    # load key from environment variable
    key = ENV.fetch('APPS_DHH_STREAMING_KEY')

    # encrypt
    cipher = OpenSSL::Cipher::AES.new(128,:CBC)
    cipher.encrypt
    cipher.key = key
    cipher.iv = nonce
    enc = cipher.update(plaintext) + cipher.final

    # base64-encode
    b64 = Base64.encode64 enc
    b64 = b64.gsub("+","-").gsub("/","_").gsub("\n","")
    "#{nonce},#{b64}"
  end

end
