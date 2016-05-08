# TestHarness

Author:
-------------------------------------------------

Tina Yan
-------------------------------------------------

Description: 
-------------------------------------------------

This is a light-weighted test automation framework written in Ruby. It contains both test harness and example test cases. The test harness provides test execution, result validation and build-in pre-setup and tear-down functionalities.  With this test harness, you are able to develop your test cases with any flexible style, and don't need to worry about how to execute them and how to validate test results.

The test harness is very suitable for but not limit to restful API test. We also add http_wrapper_lib to support restful API test. Please see examples under test_examples\rest_api_test folder for details.

A handy tool, run_multi_tests, can help you execute multiple test in parallel. Please run 'ruby run_multi_tests.rb --help' to see its usage.


Files Explanation:
-------------------------------------------------

Test Harness:

1, /test_harness/test_harness.rb: This is the light-weighted test automation framework. It provides test execution, result validation and build-in pre-setup and tear-down functionalities.

2, /test_harness/http_wrapper_lib.rb: This is http request wrapper for testing restful API. It could be included in your test suite.

3, /test_harness/run_multi_tests.rb: This is a handy tool to run multiple tests in parallel. Please run 'ruby run_multi_tests.rb --help' to see its usage

Test Examples:

1, /test_examples/common_lib.rb: This is common function library which contains all functions shared by test suites.

2, /test_examples/test_suite_1.rb, test_suite_2.rb: These two files are example test suites for you test. They defined some simple test cases need to be execute. Apart from those assistant methods: pre_setup, tear_down and \<testset\>_test methods, each public method in test suite class is a test case. \<testset\> could be smoke, regression or integration.

3, /test_examples/config.rb: This file defines the parameters for different test set (smoke/regression/integration)

4, /test_examples/main.rb:  This is the entry to run your test cases. You could run 'ruby main.rb' with defined options.

5, /test_examples/expect_result_smk.json, expect_result_smk.json, expect_result_int.json. These three files contains all expected result for your test cases. They are mapping to 3 different test set: regression, smoke or integration.

6, /test_examples/rest_api_test/: This folder contains example test files to test restful API. Files explanation is just similar to 1~5 above.

Documentation:

1, /documentation/Light-weighted Test Harness introduction.pptx: The introduction ppt.

Output:
---------------------------------------------------
After main.rb is executed, 2 files will be generated. 

1, main.log: This file has detail log for your test cases execution.
2, actual_result.json: This file contains all actual execution results for all test cases.

Help:
---------------------------------------------------
Options:

           -h, --help                    show help  
           -t, --testset                 smoke (default), regression or integration
           -r, --run                     an array of indexes of test cases, which will be executed

Examples:

           ruby main.rb --help
           
           ruby main.rb --testset integration --run 1,2,3
           
           ruby main.rb --run 1-7
