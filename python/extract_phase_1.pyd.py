#!c:\python\python.exe
# injects Phase1.pyd into phase_1.mf in parts because 
# the file size is too large for python to manipulate 
# in memory as a string.    

pyd = file('Phase1.pyd', 'rb').read()
old_mf = file('phase_1.mf', 'rb')
    
foo = old_mf.read(1770) # index of PYD within MF
foo += pyd

old_mf.seek(1770+len(pyd))
bar = old_mf.read()
    
result = foo + bar
    
old_mf.close()
    
new_mf = file('phase_1.mf', 'wb')
new_mf.write(result)