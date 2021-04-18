#!/bin/bash
set -eu  # Exit on error

storage_dir=$1
librispeech_dir=$storage_dir/LibriSpeech
wham_dir=$storage_dir/wham_noise
librimix_outdir=$storage_dir/

function LibriSpeech_dev_clean() {
	if ! test -e $librispeech_dir/dev-clean; then
		echo "Download LibriSpeech/dev-clean into $storage_dir"
		# If downloading stalls for more than 20s, relaunch from previous state.
		wget -nc -c --tries=0 --read-timeout=20 http://www.openslr.org/resources/12/dev-clean.tar.gz -P $storage_dir
		tar -xzf $storage_dir/dev-clean.tar.gz -C $storage_dir
		rm -rf $storage_dir/dev-clean.tar.gz
	fi
}

function LibriSpeech_test_clean() {
	if ! test -e $librispeech_dir/test-clean; then
		echo "Download LibriSpeech/test-clean into $storage_dir"
		# If downloading stalls for more than 20s, relaunch from previous state.
		wget -nc -c --tries=0 --read-timeout=20 http://www.openslr.org/resources/12/test-clean.tar.gz -P $storage_dir
		tar -xzf $storage_dir/test-clean.tar.gz -C $storage_dir
		rm -rf $storage_dir/test-clean.tar.gz
	fi
}

function LibriSpeech_clean100() {
	if ! test -e $librispeech_dir/train-clean-100; then
		echo "Download LibriSpeech/train-clean-100 into $storage_dir"
		# If downloading stalls for more than 20s, relaunch from previous state.
		wget -nc -c --tries=0 --read-timeout=20 http://www.openslr.org/resources/12/train-clean-100.tar.gz -P $storage_dir
		tar -xzf $storage_dir/train-clean-100.tar.gz -C $storage_dir
		rm -rf $storage_dir/train-clean-100.tar.gz
	fi
}

function LibriSpeech_clean360() {
	if ! test -e $librispeech_dir/train-clean-360; then
		echo "Download LibriSpeech/train-clean-360 into $storage_dir"
		# If downloading stalls for more than 20s, relaunch from previous state.
		wget -nc -c --tries=0 --read-timeout=20 http://www.openslr.org/resources/12/train-clean-360.tar.gz -P $storage_dir
		tar -xzf $storage_dir/train-clean-360.tar.gz -C $storage_dir
		rm -rf $storage_dir/train-clean-360.tar.gz
	fi
}

function wham() {
	if ! test -e $wham_dir; then
		echo "Download wham_noise into $storage_dir"
		# If downloading stalls for more than 20s, relaunch from previous state.
		wget -nc -c --tries=0 --read-timeout=20 https://storage.googleapis.com/whisper-public/wham_noise.zip -P $storage_dir
		# only unzips dev data (in subdirectory cv) "wham_noise/cv/*" 
                unzip -qn $storage_dir/wham_noise.zip -d $storage_dir
		rm -rf $storage_dir/wham_noise.zip
	fi
}

# LibriSpeech_dev_clean &
# LibriSpeech_test_clean &
# LibriSpeech_clean100 &
# # LibriSpeech_clean360 &
# wham &

wait

# Path to python
python_path=python

# If you wish to rerun this script in the future please comment this line out.
# only augments wham training data
# echo augmenting training noise
# $python_path scripts/augment_train_noise.py --wham_dir $wham_dir

# echo creating librispeech metadata in $librispeech_dir
# $python_path scripts/create_librispeech_metadata.py --librispeech_dir $librispeech_dir
# echo creating wham metadata in $wham_dir
# $python_path scripts/create_wham_metadata.py --wham_dir $wham_dir
 
for n_src in 2; do
  
  metadata_dir=metadata_smaller/Libri$n_src"Mix"

  # librispeech_md_dir=$librispeech_dir"/metadata"
  # wham_md_dir=$wham_dir"/metadata"
 
  # echo creating Libri$n_src"Mix metadata in "$metadata_dir 
  # $python_path scripts/create_librimix_metadata.py \
  #   --librispeech_dir $librispeech_dir \
  #   --librispeech_md_dir $librispeech_md_dir \
  #   --wham_dir $wham_dir \
  #   --wham_md_dir $wham_md_dir \
  #   --metadata_outdir $metadata_dir \
  #   --n_src $n_src
   
  types="mix_clean mix_both"
  if [ $n_src -eq 2 ]; then
  	types="${types} mix_single"
  fi
  echo generating Libri${n_src}Mix from metadata file ${metadata_dir}  
  $python_path scripts/create_librimix_from_metadata.py --librispeech_dir $librispeech_dir \
    --wham_dir $wham_dir \
    --metadata_dir $metadata_dir \
    --librimix_outdir $librimix_outdir \
    --n_src $n_src \
    --freqs 8k \
    --modes min \
    --types $types
done
