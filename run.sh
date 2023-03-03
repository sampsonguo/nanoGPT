#!/bin/bash

helpFunction()
{
   echo ""
   echo "Usage: $0 -m parameter"
   echo -e "\t-m train, predict"
   exit 1 # Exit script after printing help
}

while getopts "m:" opt
do
   case "$opt" in
      m ) parameter="$OPTARG" ;;
      ? ) helpFunction ;; # Print helpFunction in case parameter is non-existent
   esac
done

# Print helpFunction in case parameters are empty
if [ -z "$parameter" ] 
then
   echo "Some or all of the parameters are empty";
   helpFunction
fi

# Begin script in case all parameters are correct
echo "$parameter"

predict() 
{
   python sample.py --out_dir=out-shakespeare-char \
        --dtype=float32 
}

prepare() 
{
   python data/shakespeare_char/prepare.py
}

train() 
{
       python train.py config/train_shakespeare_char.py \
        --dtype=float32 \
        --init_from=gpt2 \
        --compile=False \
        --batch_size=4 \
        --max_iters=30 
}

if [ "$parameter" == "prepare" ]; then
   prepare
fi

if [ "$parameter" == "train" ]; then
   train
fi

if [ "$parameter" == "predict" ]; then
   predict
fi

if [ "$parameter" == "all" ]; then
   prepare
   train
   predict
fi

if [ "$parameter" == "clean" ]; then 
   rm -rf out-*
   rm -rf data/shakespeare_char/*.bin 
   rm -rf data/shakespeare_char/*.pkl
   rm -rf data/shakespeare_char/*.txt
   rm -rf __pycache__
fi 

