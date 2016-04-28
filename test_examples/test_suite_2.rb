################################################################################
## Description:
##            Each public method in the class is one test case except pre_setup, tear_down and <testset>_test methods.
##            <testset> could be smoke/regression/integration. It defines different cases array for different test set
################################################################################

class SuiteTwoClass
  def initialize(cfg,log)
    @cfg = cfg
    @log=log

    @log.info "------------------------------------------------------------"
    @log.info "This is test suite two!"

    puts "------------------------------------------------------------"
    puts "This is test suite two!"

  end

  ## This pre setup method for case. It will be executed before each case is executed
  def pre_setup_case()
    return "pre_setup_for_case"
  end

  ## This tear down method for case. It will be executed after  each case is executed
  def tear_down_case()
    return "tear_down_for_case"
  end

  ## This is somke test set definition. This smoke test will only run case_aaaa
  def smoke_test()
    return ["case_aaaa"]
  end

  ## This is integration test set definition. This Integration test will run case_aaaa and case_cccc.
  ## By default, regression test will also run all test cases. So you don't need to define regression test set
  def integration_test()
    int =["case_aaaa","case_cccc"]
    return int
  end

  ## The followings are your test cases
  def case_aaaa()
    puts "case aaaa"
    return 003
  end
  def case_bbbb()
    puts "case bbbb"
    return 004
  end
  def case_cccc()
    puts "case ccc"
    return 005
  end
end