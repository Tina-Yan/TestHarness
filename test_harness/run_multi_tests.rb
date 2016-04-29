################################################################################
##
## Description:
##     This utility: run_multi_tests, could help your run multiple test suites in multiple folders with multiple processes.
##     You just need to let it know the root directory of your test suites.
##     Then the utility will scan all sub-directories recursively under the root directory and run main.rb in each directory.
##     Finally the utility will generate the all_main.log which merges all the main.log of all test suites and calculate the total cases run,
##     total cases passed and total cases failed.
##
## Output: all_main.log
##     In the merged log: all_main.log, you could see status for each test suite. We defined the following status:
##     status  =>  Completed: The test completed correctly.
##     status  =>  Error: The test aborted for some reason, so the main.log didn't go to the right end.
##     status  =>  Crashed: The main.log of the test suite was not generated for exceptions.
##
## Author:
##     Tina Yan
##
## Revision:
##    April 19th, 2016    Complete class RunMultiTests. The main methods are run_tests, search_main_log and merge_main_log
##
## Examples:
##        ruby run_multi_tests.rb --help
##        ruby run_multi_tests.rb --testset regression --root_folder "C:\\TestHarness\\test_examples"
################################################################################

require "json"
require 'getoptlong'

class RunMultiTests
  def initialize()
    @suite =[]
    @all_dirs =[]
    @root_dir =""
  end

  ## output the value of @suite
  def output_suite()
    return @suite
  end

  #######################################################################################
  ## fetch_all_dirs(root_dir)
  ## Description:
  ## -- Find all directories recursively under root_dir
  ## Input parameters:
  ## -- root_dir: the root folder which you want to run your test suites
  ## output:
  ## -- @all_dirs: all sub directories
  #######################################################################################
  def fetch_all_dirs(root_dir)
    @all_dirs.push(root_dir)
    ## scan the root_dir folder and puts all sub-directories into the array: dirs
    dirs = Dir.entries(root_dir).select { |file| File.directory? File.join(root_dir, file) }
    dirs.delete_if { |x| x == "." or x == ".." }
    if dirs != []
      dirs.each do |sub_dir|
        fetch_all_dirs("#{root_dir}/#{sub_dir}")
      end
    end
  end

  #######################################################################################
  ## run_tests(testset, dirs, create_testrail_cases=false, enable_testrail=false)
  ## Description:
  ## -- return test suites one by one
  ## Input parameters:
  ## -- testset: The testset, it can be "smoke/regression/integration/staging/production. The default value is "smoke"
  ##             user could specify this by input argument.
  ## -- dirs: The arry which holds all tested directories.
  ## output:
  ## -- none
  #######################################################################################
  def run_tests(root_dir, testset="smoke")
    @root_dir  = root_dir

    ##get all directories recursively
    fetch_all_dirs(root_dir)

    ##each element in directories array, and run each suite one by one
    @all_dirs.each do |each_dir|
      if  File.exist?("#{each_dir}/main.rb")
        File.delete("#{each_dir}/main.log") if File.exist?("#{each_dir}/main.log")
          Dir.chdir(each_dir)
          ##print all running directories int console
          puts Dir.pwd
          IO.popen(" ruby main.rb --testset #{testset}")
          test_status = {"test_name" => "#{each_dir}", "status" => "start", "detail" => "", "cache" => 0}
          @suite.push(test_status)
      end
      Dir.chdir(root_dir)
    end
  end

  #######################################################################################
  ##  search_main_log()
  ## Description:
  ## -- search generated main.log and set status for each suite
  ## Input parameters:
  ## -- none
  ## output:
  ## -- @suite: the array which holds the name, status and detail for all tested suites.
  ##            the status of each suite could be running, completed and crashed.
  #######################################################################################
  def search_main_log()
    flag =false
    line_index = 0

    if @suite == []
      puts "No main.rb was found in directories under #{@root_dir}!"
      return
    end

    begin
      @suite.each do |each_suite|
        if each_suite['status'] == "Completed" or each_suite['status'] == "Crashed" or each_suite['status'] == "Error"
          next
        else
          sub_folder = each_suite['test_name']
          if File.exist?("#{sub_folder}/main.log")
            fp_log = File.open("#{sub_folder}/main.log", "rb")
            lines = fp_log.readlines
            fp_log.close
            if each_suite['cache'] != 0
              lines = lines[(each_suite['cache'])..-1]
            end
            last_line = lines[-1]
            ## It means the main.log stopped before it goes to the right end when lines is []. Mark error.
            if lines == []
               each_suite['status'] = "Error"
               each_suite['detail'] = "RSLT: {\"total\"=>0, \"pass\"=>0, \"fail\"=>0}"
               next
            ## keep searching the result line: "RSLT:" when lines is not empty.
            else
              lines.each do |each_log_line|
                ## print the progress in console
                puts each_log_line
                if each_log_line.include?("RSLT:")
                  each_suite['status'] = "Completed"
                  detail_str = each_log_line.split(": RSLT:")
                  detail_str = detail_str[1].strip
                  each_suite['detail'] = detail_str
                  break
                elsif each_log_line.to_s == last_line.to_s
                  ## save index into cache so the log search will start from this index next time
                  line_index = lines.index("#{each_log_line}")
                  each_suite['cache'] = line_index.to_i + each_suite['cache'] + 1
                  break
                else
                  next
                end
              end
            end
            if each_suite['status'] == "start"
              each_suite['status'] = "running"
            end
          else
            each_suite['status'] = "Crashed"
            next
          end
        end
      end
    rescue
      puts :"something wrong, error:#{$!.message}"
    end
    i=0
    @suite.each do |each_suite|
      i+=1 if each_suite['status'] == "Completed" or each_suite['status'] == "Crashed" or each_suite['status'] == "Error"
    end
    flag = true if i == @suite.length
    return flag
  end

  #######################################################################################
  ## merge_main_log(all_main)
  ## Description:
  ## -- merge all main.log together into all_main.log
  ## Input parameters:
  ## -- all_main: the name of all_main.log
  ## output:
  ## --  all_main.log. The log which has all main.log files merged and total calculation for total cases run, passed cases and failed cases.
  #######################################################################################
  def merge_main_log(all_main)

    total_all = 0
    pass_all = 0
    fail_all = 0
    if @suite == []
      fp_all = File.open(all_main, "a")
      fp_all << "     ##########################################################################\n"
      fp_all << "     #################  No main.rb was found in directories under #{@root_dir}! \n"
      fp_all.close
      return
    end

    @suite.each do |each_suite|
      each_dir = each_suite['test_name']
      fp_all = File.open(all_main, "a")
      fp_all << "     ##########################################################################\n"
      fp_all << "     #################  Test Suite:  #{each_dir}                               \n"
      fp_all << "     #################  Status:      #{each_suite['status']}! \n"
      fp_all << "     ##########################################################################\n"
      fp_all.close
      system("cat #{each_dir}/main.log >> #{all_main} ") if File.exist?("#{each_dir}/main.log")
      total, pass, fail = calc_total(each_suite['detail'])
      total_all = total_all + total
      pass_all = pass_all +pass
      fail_all = fail_all+ fail
    end

    fp_all = File.open(all_main, "a")
    fp_all << "     ##########################################################################\n"
    fp_all << "     #################  total_cases_run    => #{total_all} \n"
    fp_all << "     #################  total_passed_cases => #{pass_all} \n"
    fp_all << "     #################  total_failed_cases => #{fail_all}  \n"
    fp_all.close

    ## print total cases run, total passed cases and total failed cases
    puts "*********************************************************************************"
    puts "***** total_all=> #{total_all}, pass_all => #{pass_all}, fail_all =>#{fail_all} *****"
  end

  #######################################################################################
  ##  calc_total(detail)
  ## Description:
  ## -- Parse the total cases run, passed cases and failed cases for one test suite
  ## Input parameters:
  ## -- detail: the detail of each test suite
  ## output:
  ## --  total: The total cases run for tested suite
  ## --  pass:  The passed cases for tested suite
  ## --  fail:  The failed cases for tested suite
  #######################################################################################
  def calc_total(detail)

    total = detail.to_s.slice(/\"total\"\=\>\d+\,/)
    total = total.slice(/\>\d+\,/)
    total = total[1..-2]

    pass = detail.to_s.slice(/\"pass\"\=\>\d+\,/)
    pass = pass.slice(/\>\d+\,/)
    pass = pass[1..-2]

    fail = detail.to_s.slice(/\"fail\"\=\>\d+/)
    fail = fail.slice(/\>\d+/)
    fail =fail[1..-1]

    return total.to_i, pass.to_i, fail.to_i

  end

end

############### Main Logic ##################

## Handle the input arguments
parse_opts = GetoptLong.new(
    ['--help', '-h', GetoptLong::NO_ARGUMENT],
    ['--testset', '-t', GetoptLong::REQUIRED_ARGUMENT],
    ['--root_folder', '-f', GetoptLong::REQUIRED_ARGUMENT],
    ['--wait_log_time', '-w', GetoptLong::REQUIRED_ARGUMENT],
)


root_dir = File.expand_path(File.dirname(__FILE__))
testset = "smoke"
help = false
wait_log_time =15

parse_opts.quiet = true


parse_opts.each do |key, value|

  case key
    when "--help", '-h'
      puts <<-EOF

description:
      This handy tool: run_multi_tests, could help your run multiple test suites in multiple folders with multiple processes.
      You just need to let it know the root directory of your test suites. Then the utility will scan all sub-directories recursively and run main.rb in each directory.

options:
    --help, -h:
      show help
    --testset x, -t x:
      Input the expected test set, The default value is smoke. It could be smoke/regression/integration
    --root_folder x, -f x:
      The root folder which contains all your test suites (you may differentiate test suites in multiple sub-folders). The default value is current folder.
    --wait_log_time x, -w x:
      You can set time intervals to search main.log repeatedly. The default value is 15 seconds.
      If the log doesn't expand within wait_log_time, the Error status will be set for the testing suite. You could increase the wait_log_time to avoid this.

output:
     The merged log: all_main.log will be generated after all tests completed.
     you could find status for each test suite in all_main.log. We defined the following status:
     status  =>  Completed: The tests completed correctly.
     status  =>  Error: The test aborted for some reason, so the main.log didn't go to the right end.
     status  =>  Crashed: The main.log of the test suite was not generated for exceptions.

examples:
     ruby run_multi_tests.rb --help
     ruby run_multi_tests.rb --testset regression --root_folder "C:\\TestHarness\\test_examples"
     ruby run_multi_tests.rb --testset regression --root_folder "C:\\TestHarness\\test_examples" --wait_log_time 30

      EOF
      help = true
      break
    when "--root_folder", '-f'
      root_dir =value
    when "--testset"
      testset = value.to_s
    when  "--wait_log_time",  '-w'
      wait_log_time = value.to_i
  end
end

exit if help == true

tests_exe=RunMultiTests.new

start_time = Time.now

puts "start at: #{start_time}"
## run tests with multiple processes
tests_exe.run_tests(root_dir, testset)

suites = tests_exe.output_suite()

success_flag = false
sleep (10 + wait_log_time)

## keep searching main.log for each test suite if main.log keeps expanding. exit the loop when test completed.
success_flag == tests_exe.search_main_log()

while success_flag == false and suites!=[]
  sleep wait_log_time
  success_flag = tests_exe.search_main_log()
end

## merge all main.log together into all_main.log. all_main.log is under root_dir folder
if  File.exist?("all_main.log")
  File.delete("all_main.log")
end
all_main ="all_main.log"
tests_exe.merge_main_log(all_main)

## print finished in console
puts "***** All tests finished! Please see #{root_dir}\\all_main.log for details. *****"
puts "*********************************************************************************"

end_time = Time.now

puts "end at: #{end_time}"

## calculate total run time
cost_time = end_time.to_i - start_time.to_i

cost_time = Time.at(cost_time).utc.strftime("%H:%M:%S")

puts "total cost time: #{cost_time} "

fp_all = File.open(all_main, "a")
fp_all  <<  "     #################  total cost time    => #{cost_time} \n"
fp_all  <<  "     ########################################################################## \n"
fp_all.close
