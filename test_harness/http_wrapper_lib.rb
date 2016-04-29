################################################################################
##
## Description:
##     This module contains common methods to test restful API
##
## Author:
##     Tina Yan
##
## Revision:
##    Sep 09, 2015    add send http requests methods (GET, POST, PUT, DELETE, PATCH)
################################################################################


require 'net/ssh'
require 'net/http'
require 'net/https'
require 'json'
require "active_support/all"

module HttpBasicLib

  #######################################################################################
  ## send_request(http,request)
  ## Description:
  ## -- common send request
  ## Input parameters:
  ## -- http:
  ## -- request:
  ## output:
  ## -- request:
  ## -- response:
  #######################################################################################
  def send_request(http,request)
    response = nil
    #Make request here
    start_time = Time.now()
    begin
      response = http.request(request)
    rescue Exception => ex
      @log.error ex.message
      puts ex.message
      return request, response
    end
    return request, response
  end
  #######################################################################################
  ## connect(server=@cfg['test_host'], port=@cfg['port'])
  ## Description:
  ## -- connect to test host
  ## Input parameters:
  ## -- server: The ip of test host
  ## -- port: The port of test host
  ## output:
  ## -- http: The http object
  #######################################################################################
  def connect(server=@cfg['test_host'], port=@cfg['port'])
    http = Net::HTTP.new(server, port)
    http = is_https( http )
    http.read_timeout=@cfg['http_timeout']
    http.open_timeout=@cfg['http_timeout']
    return http
  end
  #######################################################################################
  ## is_https( http_obj )
  ## Description:
  ## -- judge if the http handler requires ssl verification
  ## Input parameters:
  ## -- http_obj: The http object
  ## output:
  ## -- http_obj: The http object
  #######################################################################################
  def is_https( http_obj )
    if @cfg['port'] == '443'
      require 'net/https'
      http_obj.use_ssl = true
      http_obj.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end
    return http_obj
  end
end

module RestBasiclib
  include HttpBasicLib
  @@NUMBER_OF_ZEROS = 4

  #######################################################################################
  ## send_get(url,headers=nil,http=nil)
  ## Description:
  ## -- Send http GET request
  ## Input parameters:
  ## -- url: The tested url
  ## -- headers: The headers
  ## -- http_obj: The http object
  ## output:
  ## -- response: The response information
  ## -- request: The request information
  #######################################################################################
  def send_get(url,headers=nil,http=nil)
    request = Net::HTTP::Get.new( url )
    http = connect(@cfg['test_host'], @cfg['port']) if http==nil

    #Headers handling
    if headers != nil
      headers.each do |h|
        request.add_field h[0], h[1]
      end
    end

    request, response = send_request(http,request)
    return request, response

  end
  #######################################################################################
  ## send_post(url,input_body,headers,http=nil)
  ## Description:
  ## -- Send http POST request
  ## Input parameters:
  ## -- url: The tested url
  ## -- input_body: The posted body
  ## -- headers: The headers
  ## -- http_obj: The http object
  ## output:
  ## -- response: The response information
  ## -- request: The request information
  #######################################################################################
  def send_post(url,input_body,headers,http=nil)
    request = Net::HTTP::Post.new(url)
    http = connect(@cfg['test_host'], @cfg['port']) if http==nil
    #Headers handling
    if headers != nil
      headers.each do |h|
        request.add_field h[0], h[1]
      end
    end

    #Body and response
    request.body = input_body
    request, response = send_request(http,request)
    return request, response

  end
  #######################################################################################
  ## send_put(url,input_body,headers,http=nil)
  ## Description:
  ## -- Send http PUT request
  ## Input parameters:
  ## -- url: The tested url
  ## -- input_body: The posted body
  ## -- headers: The headers
  ## -- http_obj: The http object
  ## output:
  ## -- response: The response information
  ## -- request: The request information
  #######################################################################################
  def send_put(url,input_body,headers,http=nil)

    request = Net::HTTP::Put.new( url )
    http = connect(@cfg['test_host'], @cfg['port']) if http==nil

    #Headers handling
    if headers != nil
      headers.each do |h|
        request.add_field h[0], h[1]
      end
    end

    #Body and response
    request.body = input_body
    request, response = send_request(http,request)
    return request, response

  end
  #######################################################################################
  ## send_delete(url,input_body,headers,http=nil)
  ## Description:
  ## -- Send http DELETE request
  ## Input parameters:
  ## -- url: The tested url
  ## -- input_body: The posted body
  ## -- headers: The headers
  ## -- http_obj: The http object
  ## output:
  ## -- response: The response information
  ## -- request: The request information
  #######################################################################################
  def send_delete(url,input_body,headers,http=nil)

    request = Net::HTTP::Delete.new( url )
    http = connect(@cfg['test_host'], @cfg['port']) if http==nil

    #Headers handling
    if headers != nil
      headers.each do |h|
        request.add_field h[0], h[1]
      end
    end

    #Body and response
    request.body = input_body
    request, response = send_request(http,request)
    return request, response

  end
  #######################################################################################
  ## send_patch(url,input_body,headers,http=nil)
  ## Description:
  ## -- Send http PATCH request
  ## Input parameters:
  ## -- url: The tested url
  ## -- input_body: The posted body
  ## -- headers: The headers
  ## -- http_obj: The http object
  ## output:
  ## -- response: The response information
  ## -- request: The request information
  #######################################################################################
  def send_patch(url,input_body,headers,http=nil)

    request = Net::HTTP::Patch.new( url )
    http = connect(@cfg['test_host'], @cfg['port']) if http==nil

    #Headers handling
    if headers != nil
      headers.each do |h|
        request.add_field h[0], h[1]
      end
    end

    #Body and response
    request.body = input_body
    request, response = send_request(http,request)
    return request, response
  end

end
