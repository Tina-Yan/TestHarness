
cfg = {
   'test_suites' => [
        "test_suite_1.rb",
        "test_suite_2.rb",
    ],

    'testsets'         => {
        "smoke"       => "smoke",
        "regression"  => "regression",
        "integration" => "int",
    },
    'environments'     => {
        "smoke" => { # smoke
                     'test_host'          => '10.10.10.10',
                     'build_id'           => '443',
                     'expect_result'      => 'expect_result_smk.json' ##This is the expected result for smoke testset. It defined cases and its returned expected value
        },
        "regression" => { # regression
                     'test_host'          => '10.10.10.1',
                     'port'               => '443',
                     'expect_result'      => 'expect_result.json' ##This is the expected result for regression testset. It defined cases and its returned expected value
        },
        "int" => { # integration
                     'test_host'          => '10.10.10.2',
                     'port'               => '443',
                     'expect_result'      => 'expect_result_int.json' ##This is the expected result for integration testset. It defined cases and its returned expected value
        },

     },
}


