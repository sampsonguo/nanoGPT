#!/bin/bash

helpFunction()
{
   echo ""
   echo "Usage: $0 -m mode -t task"
   echo -e "\t-m train, predict"
   echo -e "\t-t shake, sms"
   exit 1 # Exit script after printing help
}

while getopts "m:t:" opt
do
   case "$opt" in
      m ) mode="$OPTARG" ;;
      t ) task="$OPTARG" ;;
      ? ) helpFunction ;; # Print helpFunction in case mode is non-existent
   esac
done

# Print helpFunction in case modes are empty
if [ -z "$mode" ] || [ -z "$task" ]
then
   echo "Some or all of the modes are empty";
   helpFunction
fi

# Begin script in case all modes are correct
echo "$mode"
echo "$task"

prepare() 
{
   if [ "$task" == "shake" ]; then
      python data/shakespeare_char/prepare.py
   fi

   if [ "$task" == "sms" ]; then
      python data/sms_char/prepare.py
   fi
}

train() 
{
   if [ "$task" == "shake" ]; then
      python train.py config/train_shakespeare_char.py \
         --dtype=float32 \
         --init_from=gpt2 \
         --compile=False \
         --batch_size=4 \
         --max_iters=30 
   fi

   if [ "$task" == "sms" ]; then
      python train.py config/train_sms_char.py \
         --dtype=float32 \
         --init_from=gpt2 \
         --compile=False \
         --batch_size=4 \
         --max_iters=30 
   fi
}

predict() 
{
   python sample.py --out_dir=out-shakespeare-char \
        --dtype=float32 
}

if [ "$mode" == "prepare" ]; then
   prepare "$task"
fi

if [ "$mode" == "train" ]; then
   train "$task"
fi

if [ "$mode" == "predict" ]; then
   predict "$task"
fi

if [ "$mode" == "all" ]; then
   prepare "$task"
   train "$task"
   predict "$task"
fi

if [ "$mode" == "clean" ]; then 
   rm -rf out-*
   rm -rf data/shakespeare_char/*.bin 
   rm -rf data/shakespeare_char/*.pkl
   rm -rf data/shakespeare_char/*.txt
   rm -rf __pycache__
fi 

