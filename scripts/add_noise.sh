export EXPERIMENT_NAME="ASPL"
export MODEL_PATH="stabilityai/stable-diffusion-2-1-base"
export CLEAN_TRAIN_DIR="data/n000050/set_A" 
export CLEAN_ADV_DIR="data/n000050/set_B"
export OUTPUT_DIR="outputs/$EXPERIMENT_NAME/n000050_ADVERSARIAL"
export CLASS_DIR="data/class-person"
export ETA=5e-2

# ------------------------- Train ASPL on set B -------------------------
mkdir -p $OUTPUT_DIR
cp -r $CLEAN_TRAIN_DIR $OUTPUT_DIR/image_clean
cp -r $CLEAN_ADV_DIR $OUTPUT_DIR/image_before_addding_noise

echo "attacks is beginning"

accelerate launch attacks/aspl.py \
  --pretrained_model_name_or_path=$MODEL_PATH  \
  --instance_data_dir_for_train=$CLEAN_TRAIN_DIR \
  --instance_data_dir_for_adversarial=$CLEAN_ADV_DIR \
  --instance_prompt="a photo of sks person" \
  --class_data_dir=$CLASS_DIR \
  --num_class_images=200 \
  --class_prompt="a photo of person" \
  --output_dir=$OUTPUT_DIR \
  --resolution=512 \
  --center_crop \
  --with_prior_preservation \
  --prior_loss_weight=1.0 \
  --train_text_encoder \
  --train_batch_size=1 \
  --max_train_steps=50 \
  --max_f_train_steps=3 \
  --max_adv_train_steps=6 \
  --checkpointing_iterations=10 \
  --learning_rate=5e-7 \
  --pgd_alpha=5e-3 \
  --pgd_eps=$ETA \
  --enable_xformers_memory_efficient_attention \
  --mixed_precision=bf16

#  --resolution=512 \
#  --num_class_images=200 \
#  --max_train_steps=50 \
#  --enable_xformers_memory_efficient_attention \
