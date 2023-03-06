#!/bin/bash

helpFunction()
{
   echo ""
   echo "Usage: $0 -m mode -t task -e encoder"
   echo -e "\t-m train, predict, finetune"
   echo -e "\t-t shake, sms"
   echo -e "\t-e bpe, char"
   exit 1 # Exit script after printing help
}

while getopts "m:t:e:" opt
do
   case "$opt" in
      m ) mode="$OPTARG" ;;
      t ) task="$OPTARG" ;;
      e ) encoder="$OPTARG" ;;
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
echo "$encoder"

prepare() 
{
   if [ "$task" == "shake" ]; then

      if [ "$encoder" == "bpe" ]; then
         python data/shakespeare/prepare.py
      fi

      if [ "$encoder" == "char" ]; then
         python data/shakespeare_char/prepare.py
      fi
   fi

   if [ "$task" == "sms" ]; then

      if [ "$encoder" == "bpe" ]; then
         python data/sms/prepare.py
      fi

   fi
}

finetune()
{
   if [ "$task" == "shake"]; then 
      python train.py config/finetune_shakespeare.py \
         --dtype=float32 \
         --init_from=gpt2 \
         --compile=False 
   fi

   if [ $"task" == "sms" ]; then
      python train.py config/finetune_sms.py \
         --dtype=float16 \
         --init_from=gpt2 \
         --compile=False
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
         --max_iters=1 \
         --eval_interval=1
   fi

   if [ "$task" == "sms" ]; then
      python train.py config/train_sms_char.py \
         --dtype=float32 \
         --init_from=gpt2 \
         --compile=False \
         --batch_size=4 \
         --max_iters=30 \
         --eval_interval=30
   fi
}

predict() 
{
   if [ "$task" == "shake" ]; then

      if [ "$encoder" == "bpe" ]; then
         python sample.py --out_dir=out-shakespeare \
            --model_name='origin' \
            --dtype=float32 \
            --init_from='resume'
      fi

      if [ "$encoder" == "char" ]; then
         python sample.py --out_dir=out-shakespeare-char \
            --model_name='origin' \
            --dtype=float32 \
            --init_from='resume'
      fi


   fi
   if [ "$task" == "sms" ]; then
      python sample.py --out_dir=out-sms \
         --dtype=float32 \
         --start="腾讯科技】验证码：******，**分钟内" \
         --model_name='final' 
   fi
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

if [ "$mode" == "finetune" ]; then
   finetune "$task"
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

