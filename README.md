# TestHarness

Author:  Tina Yan
-------------------------------------------------

Description: 
-------------------------------------------------

This is a light-weighted test automation framework. It contains both test harness and example test cases.

Files Explanation:
-------------------------------------------------

1, test_harness.rb: This is the light-weighted test automation framework. It provides test execution, result validation and build-in pre-setup and tear-down functionalities.

2, common_lib.rb: This is common function library which contains all functions shared by test suites.

3, test_suite_1.rb, test_suite_2.rb: These two files are example test suites for you test. They defined some simple test cases need to be execute. Each public method in test suite class is an test case except those assistant methods: pre_setup, tear_down and <testset>_test methods. <testset> could be smoke, regression or integration

4, config.rb: This file defined the parameters for different test set (smoke/regression/integration)

5, main.rb:  This is the entry to run your test cases. You could run 'ruby main.rb' with defined options to execute your test cases.

6, expect_result.json, expect_result_smk.json, expect_result_int.json. These three files contains all expected result for your test cases. They are mapping to 3 different test set: regression, smoke or integration.

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
