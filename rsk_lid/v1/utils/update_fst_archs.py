import sys
from os import path


fst_txt=sys.argv[1]
fst_txt_new=sys.argv[2]
mapping=sys.argv[3]
#number_of_new_l=sys.argv[4]
combine_type=sys.argv[4]

# load mapping

mapping_file=open(mapping, 'r')
map = []
for f in mapping_file.readlines():
	map.append(f.strip().split(' ')[1])

#print "MAP LENGTH " + str(len(map))
#if combine_type == "block":
#	print "we are good"

fst_txt_file=open(fst_txt, 'r')
new_fst_txt=[]
for f in fst_txt_file.readlines():
	tkns = f.strip().split('\t')
	new_fst_txt.append(tkns[0])

	if len(tkns) > 1:
		new_fst_txt[-1] = new_fst_txt[-1] + "\t" + tkns[1]
		if len(tkns) > 2:
			tknIdx = int(tkns[2])
			if tknIdx == 0: # means that is is <eps>
					new_fst_txt[-1] = new_fst_txt[-1] + "\t0"
			else:
				if tknIdx == 1: # means that is is <blk>
					if combine_type == "block":
						new_fst_txt[-1] = new_fst_txt[-1] + "\t" + str(int(map[0]))
					else:
						new_fst_txt[-1] = new_fst_txt[-1] + "\t1"
				else:
					if map[tknIdx-2] != -1:
						new_fst_txt[-1] = new_fst_txt[-1] + "\t" + str(int(map[tknIdx-2]) + 1)
					else:
						new_fst_txt[-1] = new_fst_txt[-1] + "\t1"
		if len(tkns) > 3:
			new_fst_txt[-1] = new_fst_txt[-1] + "\t" + tkns[3]
		if len(tkns) > 4:
			new_fst_txt[-1] = new_fst_txt[-1] + "\t" + tkns[4]

#print new_fst_txt

new_fst_txt_file=open(fst_txt_new, 'w+')
for f in new_fst_txt:
	new_fst_txt_file.write("%s\n" % f)

