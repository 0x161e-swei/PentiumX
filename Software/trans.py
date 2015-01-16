import re

if __name__ == '__main__':
	filename = "Syscallb.txt"
	fin = open(filename, 'r')
	fout = open(filename.replace('.', '_fix.'), 'w')
	coe = re.sub(r'[.].+', '.coe', filename)
	#print coe
	fout2 = open(coe, 'w')
	lines = fin.readlines()

	for line in lines:
		pattern = re.compile(r':\t[0-9a-f]{8}')
		#print line
		match = pattern.search(line)
		if match :
			tmp = match.group().replace(':\t', '')
			#print tmp
			tmp2 = tmp[6:8]+tmp[4:6]+tmp[2:4]+tmp[0:2]
			fout.write(line.replace(tmp, tmp2))
			#print tmp2
			fout2.write(tmp2+'\n')
		else:
			fout.write(line)

	fin.close()
	fout.close()
	fout2.close()