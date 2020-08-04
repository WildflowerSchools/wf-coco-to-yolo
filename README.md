## wf-coco-to-yolo

Simple script to convert coco data to yolo trainable data

### Setup

This script will pip install, so make sure you have your preferred python environment setup

If you use pyenv, you could setup a new env:

```
pyenv virtualenv 3.8.2 wf-coco-to-yolo
echo 'wf-coco-to-yolo' > .python-version
``` 

### Run

`./convert.sh <<WF_COCO_DATA_URL>>`

Copy the `output/wf` folder to the Darknet projects `data` folder
 
### Clean

Remove all cloned projects, downloaded data, and generated output

`./clean.sh`