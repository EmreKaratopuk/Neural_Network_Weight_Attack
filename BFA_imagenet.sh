#!/usr/bin/env sh

############### Host   ##############################
HOST=$(hostname)
echo "Current host is: $HOST"

# Automatic check the host and configure
case $HOST in
"victus")
    PYTHON="/home/$USER/miniconda3/envs/bfa/bin/python" # python environment path
    TENSORBOARD="/home/$USER/miniconda3/envs/bfa/bin/tensorboard" # tensorboard environment path
    data_path="/home/$USER/Documents/taltech/thesis/Neural_Network_Weight_Attack/datasets/" # dataset path
    ;;
esac

DATE=`date +%Y-%m-%d`

if [ ! -d "$DIRECTORY" ]; then
    mkdir ./save/${DATE}/ -p
fi

############### Configurations ########################
enable_tb_display=false # enable tensorboard display
model=resnet34_quan
dataset=cifar10
test_batch_size=256

attack_sample_size=128 # number of data used for BFA
n_iter=13 # number of iteration to perform BFA
k_top=10 # only check k_top weights with top gradient ranking in each layer

save_path=./save/${DATE}/${dataset}_${model}
tb_path=./save/${DATE}/${dataset}_${model}_${epochs}_${optimizer}_${quantize}/tb_log  #tensorboard log path

echo "The value of PYTHON is: $PYTHON" 
############### Neural network ############################
{
$PYTHON main.py --dataset ${dataset} \
    --data_path ${data_path}   \
    --arch ${model} --save_path ${save_path}  \
    --test_batch_size ${test_batch_size} --workers 8 --ngpu 0 --gpu_id 0 \
    --print_freq 50 \
    --reset_weight --bfa --n_iter ${n_iter} --k_top ${k_top} \
    --attack_sample_size ${attack_sample_size}
} &
############## Tensorboard logging ##########################
{
if [ "$enable_tb_display" = true ]; then 
    sleep 30 
    wait
    $TENSORBOARD --logdir $tb_path  --port=6006
fi
} &
{
if [ "$enable_tb_display" = true ]; then
    sleep 45
    wait
    case $HOST in
    "Hydrogen")
        firefox http://0.0.0.0:6006/
        ;;
    "alpha")
        google-chrome http://0.0.0.0:6006/
        ;;
    esac
fi 
} &
wait
