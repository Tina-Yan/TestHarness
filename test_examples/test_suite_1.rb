################################################################################
## Description:
##            Each public method in the class is one test case except pre_setup, tear_down and <testset>_test methods.
##            <testset> could be smoke/regression/integration. It defines different cases array for different test set
################################################################################

require "./common_lib.rb"  ##This is common libraries you want to share among test suites.

class SuiteOneClass
  include CommonLib

  def initialize(cfg,log)
  @cfg=cfg
  @log=log

  @log.info "------------------------------------------------------------"
  @log.info "This is test suite one!"

  puts "------------------------------------------------------------"
  puts "This is test suite one!"
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
    smoke_test = [
        "case_001",
        "case_002"
    ]
    return smoke_test
  end

  ## This is integration test set definition. This integration test will run all test cases.
  ## By default, regression test will also run all test cases. So you don't need to define regression test set
  def integration_test()
    return ["all"]
  end

  ## your test cases:
  def case_001
    puts "case 001"
    ret_res= {"test_value"=>"001",
              "test_array"=>[1,2]}
    return ret_res
  end
  def case_002
    puts "case 001"
    return "002"
  end

  def case_003
    b = random
    return func_sum(2,b)
  end

  def case_004
    return func_diff(5,1)
  end

## private methods are only for internal calls
private
  def func_sum (a, b)
     return a+b
  end

  def func_diff (a, b)
    return a-b
  end

end