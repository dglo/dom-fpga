BEGIN {
    types["config"] = 0;
    types["iceboot"] = 1;
    types["test"] = 2;
    types["domapp"] = 3;
    ntypes = 0;
    for (ii in types) ntypes++;
    
    comps["comm"] = 0;
    comps["acquisition"] = 1;
    comps["flasher"] = 2;
    comps["pulser"] = 3;
    comps["local"] = 4;

    ncomps = 0;
    for (ii in comps) ncomps++;
}


/[a-zA-Z]+[ \t]+[a-zA-Z]+[ \t]+[0-9]+$/ {
    versions[types[$1], comps[$2]] = $3;
}
