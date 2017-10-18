test_lm_dir=$1
mapping=$2
new_test_lm_dir=$3
len_of_new_labels=$4
comb_type=$5

mkdir -p $new_test_lm_dir

cp ${test_lm_dir}/* $new_test_lm_dir

fstprint ${new_test_lm_dir}/TLG.fst > $new_test_lm_dir/TLG.txt

rm ${new_test_lm_dir}/TLG.fst

mv $new_test_lm_dir/TLG.txt $new_test_lm_dir/TLG_orig.txt

python utils/update_fst_archs.py $new_test_lm_dir/TLG_orig.txt $new_test_lm_dir/TLG.txt $mapping $len_of_new_labels $comb_type

fstcompile $new_test_lm_dir/TLG.txt > $new_test_lm_dir/TLG.fst
