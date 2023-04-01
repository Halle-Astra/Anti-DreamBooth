# Anti-DreamBooth

This is the program revised by me. 

Especially to adapt the [original project](README.me.orig) for autodl.com . ('Cause the triton package cannot be installed on the Windows platform [described by the triton project]).

So, I will put the file revised here (such as, the requirements[2023, 3, 31]).

On the other hand, ...

## Beginning Recording 

For reading without the problem with relative paths, my folder structure is attached as following with the command `tree .` :

<pre>
.
├── assets
│   └── Teaser.png
├── attacks
│   ├── aspl.py
│   ├── ensemble_aspl.py
│   ├── ensemble_fsmg.py
│   └── fsmg.py
├── data
│   ├── n000050
│   │   ├── set_A
│   │   │   ├── 0003_01.png
│   │   │   ├── 0010_01.png
│   │   │   ├── 0075_01.png
│   │   │   └── 0408_01.png
│   │   ├── set_B
│   │   │   ├── 0012_01.png
│   │   │   ├── 0071_01.png
│   │   │   ├── 0114_01.png
│   │   │   └── 0398_01.png
│   │   └── set_C
│   │       ├── 0118_01.png
│   │       ├── 0211_01.png
│   │       ├── 0409_01.png
│   │       └── 0417_01.png
│   └── target.jpg
├── infer.py
├── LICENSE
├── README.md
├── requirements.txt
├── scripts
│   ├── attack_with_aspl.sh
│   ├── attack_with_ensemble_aspl.sh
│   ├── attack_with_ensemble_fsmg.sh
│   ├── attack_with_fsmg.sh
│   ├── attack_with_targeted_aspl.sh
│   ├── attack_with_targeted_fsmg.sh
│   └── train_dreambooth_alone.sh
└── train_dreambooth.py

8 directories, 30 files
</pre>


1. wget the model file (e.g. stable-diffusion-v2.1)
	1. `wget https://huggingface.co/stabilityai/stable-diffusion-2-1-base/resolve/main/v2-1_512-ema-pruned.ckpt`
	2. `cd Anti-DreamBooth`
	3. `mkdir stable-diffusion`
	4. `mv v2-1_ema-pruned.ckpt stable-diffusion/stable-diffusion-2-1-base.ckpt`

2. 
