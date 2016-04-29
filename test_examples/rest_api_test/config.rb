
cfg = {
   'test_suites' => [
        "rest_test_suite.rb",
    ],

    'testsets'         => {
        "smoke"       => "smoke",
        "regression"  => "regression",
        "integration" => "int",
    },
    'environments'     => {
        "smoke" => { # smoke
                     'test_host'          => 'httpbin.org',
                     'port'               => '443',
                     'expect_result'      => 'expect_result_smk.json' ##This is the expected result for smoke testset. It defined cases and its returned expected value
        },
        "regression" => { # regression
                     'test_host'          => 'httpbin.org',
                     'port'               =>  '443',
                     'expect_result'      => 'expect_result.json' ##This is the expected result for regression testset. It defined cases and its returned expected value
        },
        "int" => { # integration
                     'test_host'          => 'httpbin.org',
                     'port'               => '443',
                     'expect_result'      => 'expect_result.json' ##This is the expected result for integration testset. It defined cases and its returned expected value
        },

     },
}


