module Rack
  class ReverseProxyMatcher
    def initialize(matcher,url=nil,options)
      @url=url
      @options=options

      if matcher.kind_of?(String)
        @matcher = /^#{matcher.to_s}/
      elsif matcher.respond_to?(:match)
        @matcher = matcher
      else
        raise "Invalid Matcher for reverse_proxy"
      end
    end

    attr_reader :matcher,:url,:options

    def match?(path)
      match_path(path) ? true : false
    end

    def get_uri(path,env)
      _url=(url.respond_to?(:call) ? url.call(env) : url.clone)
      if _url =~/\$\d/
        match_path(path).to_a.each_with_index { |m, i| _url.gsub!("$#{i.to_s}", m) }
        URI(_url)
      else
        _url.include?(path) ? URI.parse(_url) : URI.join(_url, path)
      end
    end
    
    def to_s
      %Q("#{matcher.to_s}" => "#{url}")
    end

    private
    def match_path(path)
      match = matcher.match(path)
      @url = match.url(path) if match && url.nil?
      match
    end
  end
end