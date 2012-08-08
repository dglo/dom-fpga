restart -f
force -drive -repeat 20ns /simpletest/clk_ref 0 0ns, 1 10ns
force -drive -repeat 50ns /simpletest/clk4p 0 0ns, 1 25ns
force -drive /simpletest/npor 0 0ns, 1 100ns
force -drive /simpletest/nreset 0 0ns, 1 100ns
