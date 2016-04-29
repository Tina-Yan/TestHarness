################################################################################
##
## Description:
##     This is the entry file to run your test suites. It will run test cases defined in rest_test_suite.
##
## Author:
##     Tina Yan
##
## Revision:
##    March 19th, 2016    Create main.rb file to verify test_harness code.
##
## Examples:
##    ruby main.rb --help
##    ruby main.rb --testset intergation --run 1,2,3
##    ruby main.rb --run 1-7
##
################################################################################

minimum_ver  = "1.9.3"


require 'rubygems'    if RUBY_VERSION == "1.8.7"
require 'getoptlong'

### install gems
if RUBY_VERSION < minimum_ver
  puts "ruby version  = #{RUBY_VERSION}"
  puts "expected     >= #{minimum_ver}"
  exit 1
end


#-----------------------------------------------------------------
# parse and execute --gem command line switch
#-----------------------------------------------------------------
tmp    = Marshal.load( Marshal.dump( ARGV ) )

help_flag = false
help   = %"Options:
           -h, --help                    show help  "

parser = GetoptLong.new
parser.quiet = true
parser.set_options( ["--help", "-h", GetoptLong::NO_ARGUMENT])

while true
  begin
    opt,val = parser.get_option
    if not opt
      break
    end
    case opt
      when "--help"
        help_flag = true
        puts help
        break
      else
          puts help
          exit 1
      end
  rescue => err
    if err.class().to_s == "GetoptLong::MissingArgument"
      puts help
      puts "#{err.class()}: #{err.message}"
      exit 1
    end
  end
end


## Main logic to run your test cases

cur_dir         = File.expand_path( File.dirname( __FILE__ ))

## require the test_harness
require cur_dir + '/../../test_harness/test_harness.rb'
## require the http wrapper to test restful API
require cur_dir + '/../../test_harness/http_wrapper_lib.rb'

config_file = cur_dir   + "/config.rb"
log_file = cur_dir + "/main.log"

## Initialization
test_exe = TestHarness.new(config_file,log_file)

## Save testset value from console input
testset = test_exe.input_parm(tmp)

exit if help_flag


## Import configurations from config.rb file
@cfg,@log = test_exe.output_cfg_log
@cfg_env = test_exe.get_testset_cfg(testset)

## Include all test suites defined in config.rb file
@cfg['test_suites'].each do |test_suite|
  require cur_dir + "/" + test_suite
end
###################################################
## Usually you don't need to change code above

## You could customize below code according to your needs
## Execute your test suite 1
test_suite = SuiteOneClass.new(@cfg_env,@log)
test_exe.run_test(test_suite,testset )

## Validate your results
test_exe.validate_results("actual_result.json",@cfg_env['expect_result'])
