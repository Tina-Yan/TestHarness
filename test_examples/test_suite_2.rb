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
  def pre_setup_case()
    return "pre_setup_for_case"
  end
  def tear_down_case()
    return "tear_down_for_case"
  end
  def smoke_test()
    return ["case_aaaa"]
  end
  def integration_test()
    int =["case_aaaa","case_cccc"]
    return int
  end
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