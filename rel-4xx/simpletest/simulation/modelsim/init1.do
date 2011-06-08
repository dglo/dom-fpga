restart -f
force -drive -repeat 50ns /simpletest/clk_ref 0 0ns, 1 25ns
force -drive -repeat 50ns /simpletest/clk4p 0 0ns, 1 25ns
force -drive /simpletest/npor 0 0ns, 1 500ns
force -drive /simpletest/nreset 0 0ns, H 500ns
