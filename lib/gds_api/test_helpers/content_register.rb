require 'gds_api/test_helpers/json_client_helper'
require 'json'

module GdsApi
  module TestHelpers
    module ContentRegister
      CONTENT_REGISTER_ENDPOINT = Plek.current.find('content-register')

      def content_register_has_entries(entries_by_format)
        entries_by_format.each do |format, entries|
          stub_request(:get, "#{CONTENT_REGISTER_ENDPOINT}/entries?format=#{format}").to_return(
            status: 200,
            body: entries.to_json
          )
        end
      end
    end
  end
end
