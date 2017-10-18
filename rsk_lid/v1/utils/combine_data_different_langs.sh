# Author: [2015] Mohammad Gowayyed

# This script reads sequence of eesen recipe folders and train one system on all the languages provided

. ./path.sh
. ./cmd.sh

data_name=$1
data="$2" # colon separated
comb_lex=$3


res_fname="data/${data_name}"
#[ -d $res_fname ] && echo 'Data folder already there! Please, delete it if you want to recombine the data, or rerun this script after commenting some scripts' && exit 1

# First, validate the data provided

if [ $comb_lex == "block" ]; then
	block_softmax_dims=""
fi

#echo "" > $res_fname/langs

while IFS=':' read -ra ADDR; do
	count=0   
	base=1
	for i in "${ADDR[@]}"; do
		utils/validate_data_dir.sh "$i" || exit 1;
		f=`cat "$i"/feats.scp | awk '{print $2}' | tr '/' ' ' | awk  '{NF-=2; OFS="/"; print}' | sort | uniq | awk '{print "/"$0}'`
		echo ORIGINAL DATA IS IN $f
		all_f="$f:${all_f}"
		(( COUNT += base ))
		des=`echo "$i"| sed 's/.$//'`
		#des=${des}_TMP_`date +%s`
		#rm $des -r
		des=`mktemp -d`
		echo	"$COUNT copying $i to ${des}"
		rmdir $des && cp "$i" "${des}" -r

		# de-duplicate		
		awk -v c=$COUNT '{$1="l"c"_"$1; print $0}' "${i}/text" > "${des}/text"
		awk -v c=$COUNT '{$1="l"c"_"$1; print $0}' "${i}/wav.scp" > "${des}/wav.scp"
		awk -v c=$COUNT '{$1="l"c"_"$1; print $0}' "${i}/cmvn.scp" > "${des}/cmvn.scp"
		awk -v c=$COUNT '{$1="l"c"_"$1; print $0}' "${i}/feats.scp" > "${des}/feats.scp"
		awk -v c=$COUNT '{$1="l"c"_"$1; $2="l"c"_"$2; print $0}' "${i}/segments" > "${des}/segments"
		awk -v c=$COUNT '{$1="l"c"_"$1; $2="l"c"_"$2; print $0}' "${i}/utt2spk" > "${des}/utt2spk"
		utils/utt2spk_to_spk2utt.pl "${des}/utt2spk" > "${des}/spk2utt"

		cp "${i}/../lang_phn/lexicon_numbers.txt" "${i}/../lang_phn/units.txt" "${des}"
		if [ $comb_lex == "share" ]; then
			cat "$des"/text > "$des"/text_2
		else
			cat "$des"/text | awk -v count=$COUNT '{printf $1; for(j = 2; j < NF; j++) { printf " l" count "_" $j; }  ;   print " l" count "_" $NF }'> "$des"/text_2
		fi
		cat "$des"/lexicon_numbers.txt | awk -v count=$COUNT '{printf "l" count "_" $1 " "; for(j = 2; j < NF; j++) { printf $j " "; }  ;   print $NF }'> "$des"/lexicon_numbers_2.txt
		mv "$des"/text_2 "$des"/text
		data_folders="$data_folders ${des}"
		if [ $comb_lex == "block" ]; then
			coun=`cat "${i}/../lang_phn/units.txt" | wc -l`
			coun=$((coun+1))
			block_softmax_dims="${block_softmax_dims}:$coun"
		fi
	done
done <<< "$data"

block_softmax_dims=${block_softmax_dims:1}

# then we combine the folders to store in one folder if we have not already done so

utils/combine_data.sh data/$data_name $data_folders

python utils/combine_lexicons.py $comb_lex data/$data_name $data_folders

if [ $comb_lex == "block" ]; then
    echo ${block_softmax_dims}
    echo ${block_softmax_dims} > data/${data_name}/dims
fi
echo ${all_f} | tr ':' '\n' | grep -v '^$' > data/${data_name}/langs

rm -rf $data_folders
