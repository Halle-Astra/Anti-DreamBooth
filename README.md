# Anti-DreamBooth

This is the program revised by me. 

Especially to adapt the [original project](https://github.com/VinAIResearch/Anti-DreamBooth) for autodl.com . ('Cause the triton package cannot be installed on the Windows platform [described by the triton project]).

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


## Notes when I learning 

### the way to get stable-diffusion config and source code needed

We can know the way to get it from its [example](https://huggingface.co/stabilityai/stable-diffusion-2-1-base#examples).

`model_id = "stabilityai/stable-diffusion-2-1-base"` in its example. 

And the implementation of `diffusers.<MODEL>.from_pretrained` is 

<pre> 
aspl.py 
line:614 
func:main

pipeline = DiffusionPipeline.from_pretrained(
                args.pretrained_model_name_or_path,
                torch_dtype=torch_dtype,
                safety_checker=None,
                revision=args.revision,
            )

</pre>

---------------------->

<pre>
diffusers/pipelines/pipeline_utils.py 
line:617 
func:DiffusionPipeline.from_pretrained

# download all allow_patterns
            cached_folder = snapshot_download(
                pretrained_model_name_or_path,
                cache_dir=cache_dir,
                resume_download=resume_download,
                proxies=proxies,
                local_files_only=local_files_only,
                use_auth_token=use_auth_token,
                revision=revision,
                allow_patterns=allow_patterns,
                ignore_patterns=ignore_patterns,
                user_agent=user_agent,
            )

</pre>

------------------------->

The default params are what I want to show for you.

<pre> 
huggingface_hub/_snapshot_downlaod.py 
line:24
func:snapshot_download


@validate_hf_hub_args
def snapshot_download(
    repo_id: str,
    *,
    revision: Optional[str] = None,
    repo_type: Optional[str] = None,
    cache_dir: Union[str, Path, None] = None,
    local_dir: Union[str, Path, None] = None,

</pre>

Tips: Func as below is a son func of `snapshot_download`, so the codes written 
after `_inner_hf_hub_download` will be executed by `snapshot_download`, too. So, some params like `repo_id, repo_type, commit_hash` is copied from `snapshot_download`, though these params are not be passed by `_inner_hf_hub_download` explicitly.

<pre>
huggingface_hub/_snapshot_download.py
line:211 
func:snapshot_download/_inner_hf_hub_download


    def _inner_hf_hub_download(repo_file: str):
        return hf_hub_download(
            repo_id,
            filename=repo_file,
            repo_type=repo_type,
            revision=commit_hash,
            cache_dir=cache_dir,
            local_dir=local_dir,

</pre>

Also, let we see the example of this api on the [hugging face tutorial](https://huggingface.co/docs/huggingface_hub/v0.13.3/guides/download) as following.

<pre>
from huggingface_hub import hf_hub_download
hf_hub_download(repo_id="lysandre/arxiv-nlp", filename="config.json")

hf_hub_download(repo_id="google/fleurs", filename="fleurs.py", repo_type="dataset")
</pre>

Finally, you may find the param `filename` is not neccessary for `hf_hub_download` in [this blog](https://blog.csdn.net/YI_SHU_JIA/article/details/127490591).

In fact, in my experiment, this argument is required, may be the reason of different version of `huggingface_hub`.

So, we can find the source code is wrong after analyzing the arguments passing between `attack_with_aspl.sh` and `aspl.py: main`. Why is `pretrained_model_name_or_path`, will be the param `model_id`, written as `./stable-diffusion/stable-diffusion-2-1-base`? It should be `stabilityai/stable-diffusion-2-1-base` possibly! It must be `stabilityai/stable-diffusion-2-1-base`! After my revision, the part of downloading works!

### the environment problems on AutoDL.com 

When I ran the command `bash scripts/attack_with_aspl.sh`, the error as following occured.

`ImportError: cannot import name 'PILLOW_VERSION' from 'PIL' (/root/miniconda3/envs/asd/lib/python3.9/site-packages/PIL/__init__.py)`

But it was no any problem when I run the same command on my PC of ExtremeVision.Inc. It must be the problem of dependencies. So, I put the dependency lists of two machines here. It may help me and you in the future's reinstalling for this project. 

The `conda list` in the machine with Error:

<pre>

# packages in environment at /root/miniconda3/envs/asd:
#
# Name                    Version                   Build  Channel
_libgcc_mutex             0.1                        main    https://mirrors.ustc.edu.cn/anaconda/pkgs/main
_openmp_mutex             5.1                       1_gnu    https://mirrors.ustc.edu.cn/anaconda/pkgs/main
absl-py                   1.2.0                    pypi_0    pypi
accelerate                0.16.0                   pypi_0    pypi
aiohttp                   3.8.4                    pypi_0    pypi
aiosignal                 1.3.1                    pypi_0    pypi
async-timeout             4.0.2                    pypi_0    pypi
attrs                     22.2.0                   pypi_0    pypi
ca-certificates           2023.01.10           h06a4308_0    https://mirrors.ustc.edu.cn/anaconda/pkgs/main
cachetools                5.1.0                    pypi_0    pypi
certifi                   2022.12.7        py39h06a4308_0    https://mirrors.ustc.edu.cn/anaconda/pkgs/main
charset-normalizer        2.1.1                    pypi_0    pypi
cmake                     3.25.2                   pypi_0    pypi
datasets                  2.7.1                    pypi_0    pypi
diffusers                 0.9.0                    pypi_0    pypi
dill                      0.3.5.1                  pypi_0    pypi
filelock                  3.9.0                    pypi_0    pypi
frozenlist                1.3.3                    pypi_0    pypi
fsspec                    2022.11.0                pypi_0    pypi
ftfy                      6.1.1                    pypi_0    pypi
google-auth               2.16.1                   pypi_0    pypi
google-auth-oauthlib      0.4.6                    pypi_0    pypi
grpcio                    1.51.1                   pypi_0    pypi
huggingface-hub           0.13.2                   pypi_0    pypi
idna                      3.4                      pypi_0    pypi
importlib-metadata        5.1.0                    pypi_0    pypi
jinja2                    3.1.2                    pypi_0    pypi
ld_impl_linux-64          2.38                 h1181459_1    https://mirrors.ustc.edu.cn/anaconda/pkgs/main
libffi                    3.4.2                h6a678d5_6    https://mirrors.ustc.edu.cn/anaconda/pkgs/main
libgcc-ng                 11.2.0               h1234567_1    https://mirrors.ustc.edu.cn/anaconda/pkgs/main
libgomp                   11.2.0               h1234567_1    https://mirrors.ustc.edu.cn/anaconda/pkgs/main
libstdcxx-ng              11.2.0               h1234567_1    https://mirrors.ustc.edu.cn/anaconda/pkgs/main
lit                       15.0.7                   pypi_0    pypi
markdown                  3.4.1                    pypi_0    pypi
markupsafe                2.1.2                    pypi_0    pypi
multidict                 6.0.2                    pypi_0    pypi
multiprocess              0.70.12.2                pypi_0    pypi
mypy-extensions           1.0.0                    pypi_0    pypi
ncurses                   6.4                  h6a678d5_0    https://mirrors.ustc.edu.cn/anaconda/pkgs/main
numpy                     1.24.2                   pypi_0    pypi
nvidia-cublas-cu11        11.10.3.66               pypi_0    pypi
nvidia-cuda-nvrtc-cu11    11.7.99                  pypi_0    pypi
nvidia-cuda-runtime-cu11  11.7.99                  pypi_0    pypi
nvidia-cudnn-cu11         8.5.0.96                 pypi_0    pypi
oauthlib                  3.2.2                    pypi_0    pypi
openssl                   1.1.1t               h7f8727e_0    https://mirrors.ustc.edu.cn/anaconda/pkgs/main
packaging                 23.0                     pypi_0    pypi
pandas                    1.5.2                    pypi_0    pypi
pillow                    9.3.0                    pypi_0    pypi
pip                       23.0.1           py39h06a4308_0    https://mirrors.ustc.edu.cn/anaconda/pkgs/main
protobuf                  3.20.3                   pypi_0    pypi
psutil                    5.9.4                    pypi_0    pypi
pyarrow                   10.0.1                   pypi_0    pypi
pyasn1                    0.4.8                    pypi_0    pypi
pyasn1-modules            0.2.8                    pypi_0    pypi
pyre-extensions           0.0.23                   pypi_0    pypi
python                    3.9.16               h7a1cb2a_2    https://mirrors.ustc.edu.cn/anaconda/pkgs/main
python-dateutil           2.8.2                    pypi_0    pypi
pytz                      2022.6                   pypi_0    pypi
pyyaml                    6.0                      pypi_0    pypi
readline                  8.2                  h5eee18b_0    https://mirrors.ustc.edu.cn/anaconda/pkgs/main
regex                     2022.10.31               pypi_0    pypi
requests                  2.28.1                   pypi_0    pypi
requests-oauthlib         1.3.1                    pypi_0    pypi
responses                 0.18.0                   pypi_0    pypi
rsa                       4.9                      pypi_0    pypi
setuptools                65.6.3           py39h06a4308_0    https://mirrors.ustc.edu.cn/anaconda/pkgs/main
six                       1.16.0                   pypi_0    pypi
sqlite                    3.41.1               h5eee18b_0    https://mirrors.ustc.edu.cn/anaconda/pkgs/main
tensorboard               2.11.2                   pypi_0    pypi
tensorboard-data-server   0.6.1                    pypi_0    pypi
tensorboard-plugin-wit    1.8.1                    pypi_0    pypi
tk                        8.6.12               h1ccaba5_0    https://mirrors.ustc.edu.cn/anaconda/pkgs/main
tokenizers                0.13.2                   pypi_0    pypi
torch                     1.13.1                   pypi_0    pypi
torchvision               0.2.2.post3              pypi_0    pypi
tqdm                      4.64.1                   pypi_0    pypi
transformers              4.26.1                   pypi_0    pypi
triton                    2.0.0                    pypi_0    pypi
typing-extensions         4.5.0                    pypi_0    pypi
typing-inspect            0.7.1                    pypi_0    pypi
tzdata                    2022g                h04d1e81_0    https://mirrors.ustc.edu.cn/anaconda/pkgs/main
urllib3                   1.26.13                  pypi_0    pypi
wcwidth                   0.2.5                    pypi_0    pypi
werkzeug                  2.2.3                    pypi_0    pypi
wheel                     0.38.4           py39h06a4308_0    https://mirrors.ustc.edu.cn/anaconda/pkgs/main
xformers                  0.0.16                   pypi_0    pypi
xxhash                    3.0.0                    pypi_0    pypi
xz                        5.2.10               h5eee18b_1    https://mirrors.ustc.edu.cn/anaconda/pkgs/main
yarl                      1.8.1                    pypi_0    pypi
zipp                      3.15.0                   pypi_0    pypi
zlib                      1.2.13               h5eee18b_0    https://mirrors.ustc.edu.cn/anaconda/pkgs/main
</pre>

The system version of the machine mentioned above:

<pre>
uname -a


Linux autodl-container-1350118f3c-4fd20867 5.4.0-107-generic #121-Ubuntu SMP Thu Mar 24 16:04:27 UTC 2022 x86_64 x86_64 x86_64 GNU/Linux
</pre>


The `conda list` of the machine which is perfect:

<pre>
# packages in environment at /home/ubuntu/miniconda3/envs/asd:
#
# Name                    Version                   Build  Channel
_libgcc_mutex             0.1                        main  
_openmp_mutex             5.1                       1_gnu  
absl-py                   1.4.0                    pypi_0    pypi
accelerate                0.16.0                   pypi_0    pypi
aiohttp                   3.8.4                    pypi_0    pypi
aiosignal                 1.3.1                    pypi_0    pypi
async-timeout             4.0.2                    pypi_0    pypi
attrs                     22.2.0                   pypi_0    pypi
ca-certificates           2023.01.10           h06a4308_0  
cachetools                5.3.0                    pypi_0    pypi
certifi                   2022.12.7        py39h06a4308_0  
charset-normalizer        3.1.0                    pypi_0    pypi
cmake                     3.26.0                   pypi_0    pypi
datasets                  2.10.1                   pypi_0    pypi
diffusers                 0.13.1                   pypi_0    pypi
dill                      0.3.6                    pypi_0    pypi
filelock                  3.10.0                   pypi_0    pypi
frozenlist                1.3.3                    pypi_0    pypi
fsspec                    2023.3.0                 pypi_0    pypi
ftfy                      6.1.1                    pypi_0    pypi
google-auth               2.16.2                   pypi_0    pypi
google-auth-oauthlib      0.4.6                    pypi_0    pypi
grpcio                    1.51.3                   pypi_0    pypi
huggingface-hub           0.13.2                   pypi_0    pypi
idna                      3.4                      pypi_0    pypi
importlib-metadata        6.1.0                    pypi_0    pypi
jinja2                    3.1.2                    pypi_0    pypi
ld_impl_linux-64          2.38                 h1181459_1  
libffi                    3.4.2                h6a678d5_6  
libgcc-ng                 11.2.0               h1234567_1  
libgomp                   11.2.0               h1234567_1  
libstdcxx-ng              11.2.0               h1234567_1  
lit                       15.0.7                   pypi_0    pypi
markdown                  3.4.1                    pypi_0    pypi
markupsafe                2.1.2                    pypi_0    pypi
multidict                 6.0.4                    pypi_0    pypi
multiprocess              0.70.14                  pypi_0    pypi
mypy-extensions           1.0.0                    pypi_0    pypi
ncurses                   6.4                  h6a678d5_0  
numpy                     1.24.2                   pypi_0    pypi
oauthlib                  3.2.2                    pypi_0    pypi
openssl                   1.1.1t               h7f8727e_0  
packaging                 23.0                     pypi_0    pypi
pandas                    1.5.3                    pypi_0    pypi
pillow                    9.4.0                    pypi_0    pypi
pip                       23.0.1           py39h06a4308_0  
protobuf                  4.22.1                   pypi_0    pypi
psutil                    5.9.4                    pypi_0    pypi
pyarrow                   11.0.0                   pypi_0    pypi
pyasn1                    0.4.8                    pypi_0    pypi
pyasn1-modules            0.2.8                    pypi_0    pypi
pyre-extensions           0.0.23                   pypi_0    pypi
python                    3.9.16               h7a1cb2a_2  
python-dateutil           2.8.2                    pypi_0    pypi
pytz                      2022.7.1                 pypi_0    pypi
pyyaml                    6.0                      pypi_0    pypi
readline                  8.2                  h5eee18b_0  
regex                     2022.10.31               pypi_0    pypi
requests                  2.28.2                   pypi_0    pypi
requests-oauthlib         1.3.1                    pypi_0    pypi
responses                 0.18.0                   pypi_0    pypi
rsa                       4.9                      pypi_0    pypi
setuptools                65.6.3           py39h06a4308_0  
six                       1.16.0                   pypi_0    pypi
sqlite                    3.41.1               h5eee18b_0  
tensorboard               2.12.0                   pypi_0    pypi
tensorboard-data-server   0.7.0                    pypi_0    pypi
tensorboard-plugin-wit    1.8.1                    pypi_0    pypi
tk                        8.6.12               h1ccaba5_0  
tokenizers                0.13.2                   pypi_0    pypi
torch                     1.13.1+cu116             pypi_0    pypi
torchvision               0.14.1+cu116             pypi_0    pypi
tqdm                      4.65.0                   pypi_0    pypi
transformers              4.26.0                   pypi_0    pypi
triton                    2.0.0                    pypi_0    pypi
typing-extensions         4.5.0                    pypi_0    pypi
typing-inspect            0.8.0                    pypi_0    pypi
tzdata                    2022g                h04d1e81_0  
urllib3                   1.26.15                  pypi_0    pypi
wcwidth                   0.2.6                    pypi_0    pypi
werkzeug                  2.2.3                    pypi_0    pypi
wheel                     0.38.4           py39h06a4308_0  
xformers                  0.0.16                   pypi_0    pypi
xxhash                    3.2.0                    pypi_0    pypi
xz                        5.2.10               h5eee18b_1  
yarl                      1.8.2                    pypi_0    pypi
zipp                      3.15.0                   pypi_0    pypi
zlib                      1.2.13               h5eee18b_0  

</pre>

The system information of the machine mentioned above:

<pre>
uname -a 

Linux ubuntu-MS-7C81 5.4.0-144-generic #161~18.04.1-Ubuntu SMP Fri Feb 10 15:55:22 UTC 2023 x86_64 x86_64 x86_64 GNU/Linux
</pre>

Fine! When I run `pip install pillow==9.4.0` after the comparison between two machines. An error says no version 9.4.0 occured. 

But, I find the command `pip install pillow==9.4.0 -i https://pypi.tuna.tsinghua.edu.cn/simple` can resolve this problem. May since the different resources have different package versions. The Qinghua Resource is the the pip resource of the my PC, and the Huawei Resource is the pip resource of AutoDL.com.

Ok, fine again! New pillow version still have the same error. 

<pre>
  File "/root/miniconda3/envs/asd/lib/python3.9/site-packages/torchvision/datasets/__init__.py", line 9, in <module>
    from .fakedata import FakeData
  File "/root/miniconda3/envs/asd/lib/python3.9/site-packages/torchvision/datasets/fakedata.py", line 3, in <module>
    from .. import transforms
  File "/root/miniconda3/envs/asd/lib/python3.9/site-packages/torchvision/transforms/__init__.py", line 1, in <module>
    from .transforms import *
  File "/root/miniconda3/envs/asd/lib/python3.9/site-packages/torchvision/transforms/transforms.py", line 17, in <module>
    from . import functional as F
  File "/root/miniconda3/envs/asd/lib/python3.9/site-packages/torchvision/transforms/functional.py", line 5, in <module>
    from PIL import Image, ImageOps, ImageEnhance, PILLOW_VERSION
ImportError: cannot import name 'PILLOW_VERSION' from 'PIL' (/root/miniconda3/envs/asd/lib/python3.9/site-packages/PIL/__init__.py)
</pre>

Finally, I find this behaviour is written in the torchvision and the trouble machine has a bad version of torchvision which is too low as 0.2.2.post3.

The origin of error is `/root/miniconda3/envs/asd/lib/python3.9/site-packages/torchvision/transforms/functional.py`.

So, run 

`pip install torchvision==0.14.1 --extra-index-url https://download.pytorch.org/whl/cu116` 

to resolve it. 

Since the cuda version is fixed on the docker of AutoDL.com, we must make the versions of the torch and torchvision be the same version. Additionally, the pytorch can only be installed when the GPU is existed, or the installing process will be killed by the AutoDL.com platform. So, turn off the machine which is the mode of no GPU, turn on it and run the installing command when the GPU resources is not zero.  

`pip install torchvision==0.14.1 torch==1.13 --extra-index-url https://download.pytorch.org/whl/cu116`
