#
#  test.py
#  dimage
#
#  Created by Adrian Price-Whelan on 7/17/09.
#  Copyright (c) 2009 __MyCompanyName__. All rights reserved.
#

def convertArray(arr):
	ret = ""
	list = []
	
	if isinstance(arr, type([]) ):		## If the instance is an array
		
		for ele in arr:
			if isinstance(ele, ( type([]), type({})) ):	## If the instance is an array
				list.append( convertArray(ele))					## recursive it
			
			elif isinstance(ele, (type(1), type(1.0))):	
				list.append(str(ele))		## if an int or float, no quotes
			else:
				list.append("'%s'" % str(ele))
	
	elif isinstance(arr, type({}) ):		## If the instance is an array
		for (k,v) in arr.items():
			item = "'" + str(k) + "'=>"
			if isinstance(v, ( type([]), type({})) ):
				item += ( convertArray(v))
			else:
				if isinstance(v, (type(1), type(1.0))):	
					item += (str(v))		## if an int or float, no quotes
				else:
					item += ("'%s'" % str(v))
			list.append(item)
	else:
		raise NameError, "Error - neither a array or a dictionary was passed to this function"
	
	
	if len(list) > 0:
		ret = "array(" + ", ".join(list) + ")"
	else:
		ret = "array()"
		
	return ret

a = {0:"/ahh/ahhh/hahahaha/ls",1:"ohno/this/is/a/path",2:"dfgdfg"}

print convertArray(a)