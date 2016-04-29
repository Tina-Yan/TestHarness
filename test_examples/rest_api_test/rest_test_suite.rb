################################################################################
## Description:
##            Each public method in the class is one test case except pre_setup, tear_down and <testset>_test methods.
##            <testset> could be smoke/regression/integration. It defines different cases array for different test set
################################################################################

class SuiteOneClass
  include RestBasiclib   ## Include rest basic lib defined in test_harness/http_wrapper_lib

  def initialize(cfg,log)
  @cfg=cfg
  @log=log

  @log.info "------------------------------------------------------------"
  @log.info "This is the test suite for restful API test!"

  puts "------------------------------------------------------------"
  puts "This is the test suite for restful API test!"
  end

  ## This pre setup method for suite. It will be executed before the whole suite is executed
  def pre_setup_suite()
    @cfg['pre_setup'] ="defined"
    return true
  end

  ## This tear down method for suite. It will be executed after the whole suite is executed
  def tear_down_suite()
    return "deleted!"
  end

  ## This is somke test set definition. This smoke test will only run case_001 and case_002
  def smoke_test ()

    smoke_test = ["rest_get"]
    return smoke_test
  end

  ## This is integration test set definition. This integration test will run all test cases.
  ## By default, regression test will also run all test cases. So you don't need to define regression test set
  def integration_test()
    return ["all"]
  end

  ## The test case to test restful API get request for https://httpbin.org/get:
  def rest_get
    ##define the url path
    url ="/get"

    ##This is headers definition.
    headers = [
                  ['Cached-Control', "no-cache" ],
                  ["Content-Type", "application/x-www-form-urlencoded"]
    ]
    begin
      #------------------------
      # Send Get Request
      #------------------------
      request, response = send_get(url, headers)

      if response.code.to_i == 200
        actual_value = response.body.chop!
        actual_value.gsub!("\n","")
        return actual_value.gsub!(/\s+/, "")
      else
        return false
      end
    rescue Exception => ex
      @log.error "#### Response code is: #{response.code} #####"
      @log.error  ex.message
      puts  "#### Response code is: #{response.code} #####"
      puts ex.message
      return false
    end
  end
  ## The test case to test restful API post request for https://httpbin.org/post:
  def rest_post
    ##define the url path
    url ="/post"
    ##This is headers definition.
    headers = [
        ['Cached-Control', "no-cache" ],
        ["Content-Type",  "application/x-www-form-urlencoded; charset=UTF-8"]
    ]
    input_body = {"test_key" =>"test_value"}

    begin
      #------------------------
      #Send Post Request
      #------------------------
      request, response = send_post(url, input_body.to_json, headers)

      if response.code.to_i == 200
         actual_value =JSON.parse(response.body)
         ## return the value need to be validated
         actual_value = actual_value['form']
         return actual_value.to_json
      else
        return false
      end
    rescue Exception => ex
      @log.error "#### Response code is: #{response.code} #####"
      @log.error  ex.message
      puts  "#### Response code is: #{response.code} #####"
      puts ex.message
      return false
    end
  end
end