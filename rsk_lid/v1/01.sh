lid/train_ivector_extractor.sh --cmd run.pl  --num-iters 5 exp/full_ubm_500_32/final.ubm data/train exp/extractor_1024
lid/extract_ivectors.sh --cmd "run.pl --nj 50 exp/extractor_1024 data/train exp/ivectors_train
