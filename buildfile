./: {*/ -build/} manifest lib{repro}

lib{repro} : hxx{public private}

# hxx{private} : install = false        # Case 1
# hxx{public} : install = true          # Case 2
# hxx{foruseronly} : install = true     # Case 3