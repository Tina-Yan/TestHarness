################################################################################
##
## Description:
##     This is the test harness. With this harness, testers could compose their test cases with any style they like.
##     And don't need to care about how their test cases are executed and test results are validated.
##
## Author:
##     Tina Yan
##
## Revision:
##    March 19th, 2016    Complete POC code for harness. It includes test runner,
##                        test results validation, pre-setup and teardown from both test suite level and case level.
##    April 11th, 2016    Add the option to run cases with different testset: '--testset'
##                        Add the option to run specified cases by defining cases index with '--run' flag
## Examples:
##    ruby main.rb --help
##    ruby main.rb --testset integration --run 1,2,3
##    ruby main.rb --run 1-7
##
################################################################################
require 'getoptlong'
require 'json'
require "logger"

class TestHarness

  def initialize(cfg_file,log)
    @start_time           = Time.now

    fp = File.new "actual_result.json", 'wb'
    fp.close
    cfg={}
    if File.exists?(cfg_file)
      eval(File.new(cfg_file).read)
    else
      raise StandardError.new('Cannot find config file!')
    end
    cfg['log_file']=log
    cfg['delete_logs'] = true
    if File.exists?(cfg['log_file']) and cfg['delete_logs']
      File.delete(cfg['log_file'])
    end
    @log = Logger.new( cfg['log_file'] )
    @log_console = Logger.new(STDOUT )
    @cfg = cfg
    @aid_methods = [
        "pre_setup_suite",
        "tear_down_suite",
        "pre_setup_case",
        "tear_down_case",
        "smoke_test",
        "regression_test",
        "integration_test",
        "staging_test",
        "production_test",
     ]
    @idx = 0
    @ord = 0
    @cfg['run_testcases']=[]
    @cfg['testset_cases'] = []

  end

  #######################################################################################
  ## output_cfg_log()
  ## Description:
  ## -- return @cfg and @log for outside class use
  ## Input parameters:
  ## -- none
  ## output:
  ## -- @cfg: The input hash which includes pre-defined configuration in config.rb file
  ## -- @log: return log object
  #######################################################################################
  def output_cfg_log()
    return @cfg, @log
  end

  #######################################################################################
  ## run_test(obj)
  ## Description:
  ## -- The main non-data-driven test execution engine. It will run all test cases for specified suite
  ## Input parameters:
  ## -- obj: The test suite object
  ## output:
  ## -- file: return test result for each test cases and save them into "actual_result.json"
  #######################################################################################
  def run_test(obj, testset)
    @cfg['testset'] = testset
    test_sets =[]
    run_cases_idx = []
    fp = File.open "actual_result.json", 'a'
    result =""
    ##Get methods from test suite class and execute them one by one
    methods = obj.class.instance_methods(false)

    methods.each do |method|
      if (method.to_s == "#{testset}_test")
        test_sets = obj.send(method)

      end
    end

    if test_sets ==[] and testset != "regression"
      raise StandardError.new("Missing testset define for: \"#{testset}\" in your test suite")
    end
    #-----------------------------------------------------------------
    # run pre_setup for suite if pre_setup_suite is defined
    #-----------------------------------------------------------------
    setup_teardown_wrap(obj, "pre_setup_suite", fp)

    methods.each do |method|
      if  @aid_methods.include?(method.to_s.downcase)
        next
      else
        begin
          if  testset == "regression" or test_sets == ["all"]

            #-----------------------------------------------------------------
            # execute pre setup before each case
            #-----------------------------------------------------------------
            @idx+=1
            if @cfg['run_testcases'].include?(@idx.to_s) or @cfg['run_testcases']==[]
              setup_teardown_wrap(obj, "pre_setup_case", fp)

              run_cases_idx.push(@idx.to_s)
              #-----------------------------------------------------------------
              # execute method
              #-----------------------------------------------------------------
              @log.info "************************************************************"
              @log.info "idx:#{@idx}  #{method}()"
              puts  "************************************************************"
              puts  "idx:#{@idx}  #{method}()"
              method_output =obj.send(method)
              result = {"idx" => @idx, "#{method}" => method_output}
              fp.print result.to_json
              fp.print "\n"
              #-----------------------------------------------------------------
              # execute tear down after each case
              #-----------------------------------------------------------------
              setup_teardown_wrap(obj, "tear_down_case", fp)
            else
              next
            end

          elsif test_sets.include?(method.to_s)
            @idx+=1
            if @cfg['run_testcases'].include?(@idx.to_s) or @cfg['run_testcases']==[]
              #-----------------------------------------------------------------
              # execute pre setup before each case
              #-----------------------------------------------------------------
              setup_teardown_wrap(obj, "pre_setup_case", fp)
              run_cases_idx.push(@idx.to_s)
              #-----------------------------------------------------------------
              # execute method
              #-----------------------------------------------------------------
              @log.info "************************************************************"
              @log.info "idx:#{@idx}  #{method}()"
              puts  "************************************************************"
              puts  "idx:#{@idx}  #{method}()"
              method_output =obj.send(method)
              result = {"idx" => @idx, "#{method}" => method_output}
              fp.print result.to_json
              fp.print "\n"
              #-----------------------------------------------------------------
              # execute tear down after each case
              #-----------------------------------------------------------------
              setup_teardown_wrap(obj, "tear_down_case", fp)
            else
              next
            end
          else
            next
          end

        rescue StandardError => ex
          bt = ex.backtrace.join("\n")
          @log.error "Execute method #{method} failed,the error is #{ex} "
          puts "Execute method #{method} failed,the error is #{ex} "
        end
      end
    end
    #-----------------------------------------------------------------
    # run tear down for suite if tear_down suite is defined
    #-----------------------------------------------------------------
    setup_teardown_wrap(obj, "tear_down_suite", fp)
    fp.close
    @log.info "************************************************************"
    puts "************************************************************"
    @log.info "cases: #{run_cases_idx} "; puts "cases: #{run_cases_idx} were executed" if run_cases_idx!=[]
  end

  #######################################################################################
  ## setup_teardown_wrap(obj, mode, fp)
  ## Description:
  ## -- run pre-setup or tear_down from test suite level and test case levl
  ## Input parameters:
  ## -- obj: The test suite object
  ## -- mode: Ther are 4 modes can be passed into: 1, pre_setup_suite; 2, tear_down_suite; 3, pre_setup_case; 4, tear_down_case
  ## -- fp: File handler of "actual_result.json"
  ## output:
  ## -- file: updated "actual_result.json" file
  #######################################################################################
  def setup_teardown_wrap(obj, mode, fp)
    method_name =false
    method_ret = false
    method_name, method_ret = pre_setup_tear_down(obj, mode)
    if method_name && method_ret
      result ={"ord" => @ord, "#{method_name}" => method_ret}
      fp.print result.to_json
      fp.print "\n"
    end
  end

  #######################################################################################
  ## pre_setup_tear_down(obj, mode)
  ## Description:
  ## -- Actual code to run pre setup and tear down
  ## Input parameters:
  ## -- obj: The test suite object
  ## -- mode: Ther are 4 modes can be passed into: 1, pre_setup_suite; 2, tear_down_suite; 3, pre_setup_case; 4, tear_down_case
  ## output:
  ## -- method: the method name, return false if there is no pre-setup or tear-down cases defined in test suite.
  ## -- output: the test result for this method, return false if there is no pre-setup or tear-down cases defined in test suite.
  #######################################################################################
  def pre_setup_tear_down(obj, mode)
    methods = obj.class.instance_methods(false)
    methods.each do |method|
      if method.to_s.include?(mode)
        @ord+=1
        @log.info "************************************************************"
        @log.info "ord:#{@ord} #{method}()"
        puts "************************************************************"
        puts "ord:#{@ord} #{method}()"
        output = obj.send(method)
        return method, output
      end
    end
    return false, false
  end

  #######################################################################################
  ## input_parm()
  ## Description:
  ## -- Handle input arguments for running main.rb file. Currently only "--testset" is supported.
  ## Input parameters:
  ## -- args:  arguments imported from command line
  ## output:
  ## -- testset: return input test set value from command line
  ## -- run_cases: cases need to be run
  #######################################################################################
  def input_parm(args)
    testset = "smoke"
    @cfg['run_cases']=[]

    args.each do |arg|
      case arg
        when "--help", "-h"
        help =
%"           -t, --testset                 smoke (default), regression or integration
           -r, --run                     an array of indexes of test cases, which will be executed

Examples:
           ruby main.rb --help
           ruby main.rb --testset integration --run 1,2,3
           ruby main.rb --run 1-7
"
          puts help
        when "--testset", "-t"
          idx = args.index(arg)
          raise StandardError.new('Missing --testset value define!') if args[idx+1] == nil
          testset = args[idx+1]
        when "--run", "-r"
          idx = args.index(arg)
          raise StandardError.new('Missing --run cases index array define!') if args[idx+1] == nil
          value=args[idx+1]
          @cfg['run_cases'] = value.strip
      end
    end
    if @cfg['run_cases']!= []
      parse_cmdline_run_parm()
    end

    return testset

  end

  #########################################################################################
  ## parse_cmdline_run_parm()
  ## Description:
  ## -- Parse the value when input argument is run
  ## Input parameters:
  ## -- none
  ## output:
  ## -- run_testcases: the returned cases array
  #########################################################################################
  def parse_cmdline_run_parm()

    @cfg['run_testcases'] = []
    if @cfg['run_cases'] == []
      return
    end
    run_testcases = []


    if @cfg['run_cases'].include?(",")
      run_testcases = @cfg['run_cases'].gsub(/\s+/, "").strip().split(',')
    elsif @cfg['run_cases'].include?("-") and @cfg['run_cases'].include?(".")
      run_testcases = get_idx_using_range()
    elsif @cfg['run_cases'].include?("-")
      run_testcases = get_idx_using_range()
    elsif @cfg['run_cases'].strip.match(/^\d+$/)
      r = @cfg['run_cases'].strip
      if r == nil
        run_testcases = []
      else
        run_testcases << r
      end
      # error
    else
      raise StandardError.new("ERROR: #{@cfg['run_cases']} - run command line contains invalid paramater")
    end

    @cfg['run_testcases'] = run_testcases.uniq

    return
  end
  #######################################################################################
  ##  get_testset_cfg(testset)
  ## Description:
  ## -- return specific configuration for defined testset
  ## Input parameters:
  ## -- testset: The testset type, it could be: smoke, regression, integration, staging and production
  ## output:
  ## -- @cfg["environments"][env]: specified configuration for given testset
  #######################################################################################
  def get_testset_cfg(testset)
    env = @cfg["testsets"][testset]
    return @cfg["environments"][env]
  end

  #########################################################################################
  ## get_idx_using_range()
  ## Description:
  ## -- Return index array when the give cases array has range defined
  ## Input parameters:
  ## -- none
  ## output:
  ## -- run: the returned cases array
  #########################################################################################

  def get_idx_using_range()

    run = []
    test_cases = @cfg['run_cases'].gsub(/\s+/, "").strip().split('-')

    # get begining and ending idx numbers from values in testcases-bak.rb file
    b = e = 0
    b = test_cases[0].to_i
    e = test_cases[1].to_i

    if b == 0 or e == 0
      raise StandardError.new("ERROR: invalid begining or ending run value. ")
      return
    end
    while b <= e do
      run << b.to_s
      b+=1
    end
    return run
  end

  #########################################################################################
  ## find_expect_line(act_line, exp_lines)
  ## Description:
  ## -- find expect line according to given actual line
  ## Input parameters:
  ## -- act_line: The actual line
  ## -- exp_lines: The expect line array which was import from expect_result file
  ## output:
  ## -- exp_line: the found expect line
  #########################################################################################
  def find_expect_line(act_line, exp_lines)
    index = nil
    index = act_line['idx']
    order = act_line['ord']

    exp_lines.each do |exp_line|
      exp_line = JSON.parse(exp_line)
      if  index == nil and exp_line['ord'] == order
        return exp_line
      elsif order==nil and exp_line['idx'] == index
        return exp_line
      else
        next
      end
    end
    return nil
  end
  #######################################################################################
  ## validate_results(actual_result, expect_result)
  ## Description:
  ## -- This method will compare actual test result file with expected test result file line by line
  ## Input parameters:
  ## -- actual_result: The file handler of actual result file
  ## -- expect_result: The file handler of expected result file
  ## output:
  ## -- main.log: This method will write down validation results into main.log file
  #######################################################################################
  def validate_results(actual_result, expect_result)
    total = 0
    pass_count = 0
    fail_count = 0
    case_idx = 0
    case_ord = 0

    @cfg_env= get_testset_cfg(@cfg['testset'])

    @log.info "************************************************************"
    @log.info "***** Test results validation for each test case begin *****"
    @log.info "************************************************************"
    puts "************************************************************"
    puts "***** Test results validation for each test case begin *****"
    puts "************************************************************"
    if actual_result == nil or expect_result ==nil
      raise StandardError.new('Missing actual result or expected result!')
    end

    fp_expect = File.open(expect_result, "rb")
    exp_lines = fp_expect.readlines
    fp_expect.close

    fp_actual = File.open(actual_result, "rb")
    act_lines = fp_actual.readlines
    fp_actual.close

    if act_lines.length == exp_lines.length
      i=0
      while i < act_lines.length
        exp_line = JSON.parse(exp_lines[i])
        act_line = JSON.parse(act_lines[i])
        if exp_line == act_line
#          @log.result('pass')
          print "\e[32mPASS\e[0m:"
          case_title = nil
          exp_line.each { |key, val| case_title=key }
          if @aid_methods.include?(case_title)
            case_ord+=1
            @log.info "PASS: #{act_line}"
            puts "#{act_line}"
          else
            pass_count+=1; case_idx+=1
            @log.info "PASS: #{act_line}"
            puts  "#{act_line}"
          end
        else
          print "\e[31mFAIL\e[0m:"
          case_title = nil
          exp_line.each { |key, val| case_title=key }
          if @aid_methods.include?(case_title)
            case_ord+=1
            @log.error "FAIL: ord:#{case_ord} #{case_title}"
            puts " ord:#{case_ord} #{case_title}"
          else
            fail_count+=1; case_idx+=1
            @log.error "FAIL: idx:#{case_idx}  #{case_title}:"
            puts " idx:#{case_idx}  #{case_title}:"
          end
          @log.error "     expect value is: #{exp_line}"
          @log.error "     actual value is: #{act_line}"
          puts "     expect value is: #{exp_line}"
          puts "     actual value is: #{act_line}"
        end
        i+=1
      end
    elsif  @cfg['run_cases']!=[]

      act_lines.each do |act_line|

        act_line_parse = JSON.parse(act_line)

        exp_line = find_expect_line(act_line_parse, exp_lines)

        if exp_line == act_line_parse
          pass_count+=1 if act_line_parse.keys.include?('idx')
          print "\e[32mPASS\e[0m:"
          @log.info "PASS: #{act_line_parse}"
          puts " #{act_line_parse}"
        elsif exp_line == nil
          print "\e[31mFAIL\e[0m:"
          @log.error "FAIL: #{act_line_parse}"
          @log.error "      Cannot find expected value for the line: #{act_line_parse}"
          puts " #{act_line_parse}"
          puts "      Cannot find expected value for the line: #{act_line_parse}"
        else
          fail_count+=1 if act_line_parse.keys.include?('idx')
          print  "\e[31mFAIL\e[0m:"
          @log.error " #{act_line_parse}"
          @log.error "     expect value is: #{exp_line}"
          @log.error "     actual value is: #{act_line_parse}"
          puts " #{act_line_parse}"
          puts "     expect value is: #{exp_line}"
          puts "     actual value is: #{act_line_parse}"
        end
      end
    else
      @log.error "actual length: #{act_lines.length}; expect length:#{exp_lines.length}"
      puts "actual length: #{act_lines.length}; expect length:#{exp_lines.length}"
      raise StandardError.new('Expected result lines are not equal to Actual result lines')
    end
    total = fail_count + pass_count
    @log.info "RSLT: {\"total\"=>#{total}, \"pass\"=>#{pass_count}, \"fail\"=>#{fail_count}}"
    @log.info "TIME: #{ Time.at(Time.now - @start_time).utc.strftime("%H:%M:%S") }"
    @log.info "************************************************************"
    @log.info "*****  Test results validation for each test case end  *****"
    @log.info "************************************************************"
    puts "RSLT: {\"total\"=>#{total}, \"pass\"=>#{pass_count}, \"fail\"=>#{fail_count}}"
    puts "TIME: #{ Time.at(Time.now - @start_time).utc.strftime("%H:%M:%S") }"
    puts "************************************************************"
    puts "*****  Test results validation for each test case end  *****"
    puts "************************************************************"
  end
end

