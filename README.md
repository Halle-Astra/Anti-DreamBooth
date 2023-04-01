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
