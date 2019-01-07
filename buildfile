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
# hxx{public} : install = include/repro/
# 

#########
# Case 3
# 
# hxx{public} : install = include/repro/
# hxx{private} : install = false
# 

#########
# Case 4
#
# hxx{foruseronly} : install = include/repro/
# 

#########
# Case 5
#
# lib{repro} : file{someapi.hpp}
# file{someapi.hpp} : install = include/repro/
# 

#########
# Case 6
#
# lib{repro} : file{someapi.hpp}
# lib{repro} : file{someapi.hpp} : install = include/repro/
# 



