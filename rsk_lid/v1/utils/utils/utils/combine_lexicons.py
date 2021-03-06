# author:  Mohammad Gowayyed, CMU, 2015

import sys
from os import path
import ntpath

combine_option=sys.argv[1]
dst_dir=sys.argv[2]
src_dirs=sys.argv[3:]


src_units = []
src_lex = []

units = []
lex = []

startIndex=0

mappings = []

for i in range(len(src_dirs)):
    lang = src_dirs[i]
    src_units.append(open(path.join(lang, "units.txt")).readlines())
    src_lex.append(open(path.join(lang, "lexicon_numbers.txt")).readlines())
    print "Language " + lang + " has " + str(len(src_units[-1])) + " units and " + str(len(src_lex[-1])) + " words in the lexicon"

if combine_option == 'agg':
    for i in range(len(src_dirs)):
        mapping = []
	for unit in src_units[i]:
	    units.append("l" + str(i+1) + "_" + unit.split(' ')[0] + " " + str(startIndex + int(unit.split(' ')[1])))
	    mapping.append(len(units))

	for line in src_lex[i]:
            tkns = line.strip().split(' ')
	    lex.append("l" + str(i+1) + "_" + tkns[0] + " ")

	    for l in range(1, len(tkns)):
		if tkns[l] == ".":
		    lex[-1] = lex[-1] + tkns[l] + " "
		else:
		    lex[-1] = lex[-1] + str(startIndex + int(tkns[l])) + " "

	    mappings.append(mapping)
	    startIndex = startIndex + len(src_units[i])

elif combine_option == 'block':
    for i in range(len(src_dirs)):
	mapping = []
	for unit in src_units[i]:
	    units.append("l" + str(i+1) + "_" + unit.split(' ')[0] + " " + str(startIndex + int(unit.split(' ')[1])))
	    mapping.append(len(units)+i)
	
	for line in src_lex[i]:
            tkns = line.strip().split(' ')
	    lex.append("l" + str(i+1) + "_" + tkns[0] + " ")

	    for l in range(1, len(tkns)):
		if tkns[l] == ".":
		    lex[-1] = lex[-1] + tkns[l] + " "
		else:
	            lex[-1] = lex[-1] + str(startIndex + int(tkns[l])) + " "

        mappings.append(mapping)	
	startIndex = startIndex + len(src_units[i])	+ 1

elif combine_option == 'share':
    for i in range(len(src_dirs)):
	mapping = []        
	for unit in src_units[i]:
            u = unit.split(' ')[0]
	    if not u in units:
		units.append(str(u))
	    mapping.append(units.index(u) + 1)
						
	for line in src_lex[i]:
	    tkns = line.strip().split(' ')
	    lex.append(tkns[0] + " ")

	    for l in range(1, len(tkns)):
		if tkns[l] == ".":
		    lex[-1] = lex[-1] + tkns[l] + " "
		else:
		    lex[-1] = lex[-1] + str(mapping[int(tkns[l])-1]) + " "

	mappings.append(mapping)

print "LEN: "+ str(len(mappings))

for i in range(len(src_dirs)):
    mapping_file=open(path.join(dst_dir, path.basename(path.normpath(src_dirs[i] + "../../..")) + str(i) + "-mapping.txt"), 'w+');
    mapping = mappings[i]
    for i in range(len(mapping)):
	m = mapping[i]
	m = str(i+1) + " " + str(m)
	mapping_file.write("%s\n" % m)


units_file=open(path.join(dst_dir, "units.txt"), "w")
i = 1
for u in units:
    if combine_option == 'share':
	u = u + " " + str(i)
    units_file.write("%s\n" % u)
    i = i + 1

lex_file=open(path.join(dst_dir, "lexicon_numbers.txt"), "w")
for l in lex:
    lex_file.write("%s\n" % l)

units_file.close()
lex_file.close()
