# frozen_string_literal: true
# name: imglink-discourse
# about: ImgLink production integration package for Discourse
# version: 1.0.0
# authors: ImgLink

require "net/http"
require "json"
require "securerandom"

init = proc do
  module ::ImgLinkDiscourse
    class UploadError < StandardError; end

    class Client
      def self.upload(file_path, api_key: nil, api_base: nil, timeout_seconds: 30)
        raise UploadError, "File not found" unless File.file?(file_path)

        resolved_api_key = api_key || ENV["IMGLINK_API_KEY"]
        resolved_api_base = (api_base || ENV["IMGLINK_API_BASE"] || "https://imglink.cc").sub(%r{/$}, "")
        raise UploadError, "Missing ImgLink API key" if resolved_api_key.nil? || resolved_api_key.empty?

        uri = URI.parse("#{resolved_api_base}/api/v1/upload")
        boundary = "----imglink-#{SecureRandom.hex(12)}"
        payload = multipart_payload(file_path, boundary)

        request = Net::HTTP::Post.new(uri)
        request["X-API-Key"] = resolved_api_key
        request["Accept"] = "application/json"
        request["Content-Type"] = "multipart/form-data; boundary=#{boundary}"
        request.body = payload

        response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https", read_timeout: timeout_seconds, open_timeout: 10) do |http|
          http.request(request)
        end

        parsed = JSON.parse(response.body) rescue nil
        unless response.code.to_i.between?(200, 299)
          message = parsed.is_a?(Hash) && parsed["error"] ? parsed["error"] : "HTTP #{response.code}"
          raise UploadError, "ImgLink API error: #{message}"
        end

        unless parsed.is_a?(Hash) && parsed["url"]
          raise UploadError, "ImgLink response missing url"
        end

        parsed
      end

      def self.multipart_payload(file_path, boundary)
        file_name = File.basename(file_path)
        mime_type = "application/octet-stream"
        file_content = File.binread(file_path)

        [
          "--#{boundary}\r\n",
          "Content-Disposition: form-data; name=\"image\"; filename=\"#{file_name}\"\r\n",
          "Content-Type: #{mime_type}\r\n\r\n",
          file_content,
          "\r\n--#{boundary}--\r\n",
        ].join
      end
    end
  end
end

if defined?(after_initialize)
  after_initialize { init.call }
else
  init.call
end

