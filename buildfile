./: {*/ -build/} manifest lib{repro}

# Common part
lib{repro} : hxx{public private}

#########
# Case 1
#
# hxx{private} : install = false
#

#########
# Case 2
# 
# hxx{public} : install = true
# 

#########
# Case 3
# 
# hxx{public} : install = true
# hxx{private} : install = false
# 

#########
# Case 4
#
# hxx{foruseronly} : install = true
# 

#########
# Case 5
#
# lib{repro} : file{someapi.hpp}
# file{someapi.hpp} : install = include/
# 

