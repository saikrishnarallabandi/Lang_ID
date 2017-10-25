
# This file basically reads the parsed files from miami corpus and segments them based on time stamps

import os, sys

miami_dir = '/home/srallaba/data/Spanish_English_data/train'
dest_dir = miami_dir + '/../segments'
#os.makedirs(dest_dir)

files = sorted(os.listdir(miami_dir))

for file in files:
 if file.endswith('_parsed.txt'):
   fname = file.split('.')[0].split('_')[0]
   print "Processing ", fname
   count = 0
   f = open(miami_dir + '/' + file)
   for line in f:
      count += 1
      line = line.split('\n')[0].split()
      #print line 
      start = float(line[0])
      end = float(line[1])
      cmd = 'sox ' + miami_dir + '/' + fname + '.wav ' + dest_dir + '/' + fname + '_' + str(count).zfill(5) + '.wav trim ' + str(start) + ' ' + str(end - start) 
      os.system(cmd)
