require 'webmock'
require 'json'

module FakebookAPI
  class FacebookObject
    
    include WebMock::API

    def initialize(params)
      @count = 100
      @results_per_page = 50 

      stub_request(http_method, url_matcher).to_return(to_return)
    end

    private

    def url_matcher
      "https://graph.facebook.com/me/#{facebook_object}?access_token=#{FakebookAPI.access_token}"
    end

    def facebook_object 
      raise("Abstract")
    end

    def http_method
      raise("Abstract")
    end

    def to_return
      { :status => 200, :body => return_body, :headers => {} }
    end

    def return_body
      return_collection = Array.new
      @count.times do
        return_collection << generate_fakebook_object
      end
      JSON.generate return_collection
    end

    def generate_fakebook_object
      generated_object = {}
      structure.each do |key, value|
        generated_object[key] = fakebook_field_handler(key)
      end
      generated_object
    end

    #lets overload for the moment but we might not end up needing this
    def fakebook_field_handler(key)
      FakebookAPI::FakebookFields
        .const_get(FakebookAPI::ObjectDispatcher.classify(key))
        .new
        .generated_value
    end
    
  end
end
