lang=$1

# Source the kaldi path
mfcc_folder=${KALDI_ROOT}/egs/voxforge/s5/mfcc_${lang}


rm -r ../data/${lang}/cleaned/*
rm -r ../data/${lang}/raw/*

mkdir -p ../data/${lang}
mkdir -p ../data/${lang}/cleaned
mkdir -p ../data/${lang}/raw

# Get the mfccs and accomodate in a single file
for file in ${mfcc_folder}/*.ark
do
 fname=$(basename "$file" .ark)
 cat ${mfcc_folder}/${fname}.scp | while read f
 do
   n=`echo "${f}" | cut -d ' ' -f 1`
   echo $f | copy-feats scp:- ark,t:- | add-deltas ark:- ark,t:- > ../data/${lang}/raw/${n}.mfcc
   cat ../data/${lang}/raw/${n}.mfcc | sed '/\[$/d' | sed 's/]//g' > ../data/${lang}/cleaned/${n}.mfcc
 done
done 

