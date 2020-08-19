#!/bin/bash

url=$1

if [ "x${url}" != 'x' ]; then
    filename_with_extension="${url##*/}"
    filename_naked="${filename_with_extension%.tar.gz}"

    if [ ! -f "./${filename_with_extension}" ]; then
        wget $url

        if [ $? -ne 0 ]; then
            echo "Could not download ${url}"
            exit 0
        fi
    fi

    if [ -d data ]; then
        rm -rf ./data
    fi

    if [ ! -d "./${filename_naked}" ]; then
        tar -xvf "${filename_with_extension}"
    fi

    mv "${filename_naked}" data
fi

if [ ! -d data ]; then
    echo "Error: Data folder missing, either create or specify a url to download data"
    exit 0
fi

if [ ! -d convert2Yolo ]; then
	git clone https://github.com/WildflowerSchools/convert2Yolo
    pip install -r ./convert2Yolo/requirements.txt
fi

if [ ! -f ./coco.names ]; then
	wget https://raw.githubusercontent.com/pjreddie/darknet/master/data/coco.names
fi

echo "Clearing Output folder"
if [ -d ./output ]; then
    rm -rf ./output/*
fi

mkdir -p output/wf

cp ./coco.names ./output/wf/.
cp ./wf_yolo.data ./output/wf/.

class_count=$(sed '/^\s*$/d' ./coco.names | wc -l)
class_count="$(echo -e "${class_count}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"

sed -i'.bak' -E "s/classes=[[:digit:]]+/classes=${class_count}/g" ./output/wf/wf_yolo.data  && rm ./output/wf/wf_yolo.data.bak

echo "Copying Images to YOLO labels folder"
cp -R ./data/images/ ./output/wf/labels

echo "Converting Training to YOLO format"
python ./convert2Yolo/example.py --dataset COCO --img_path ./output/wf/labels/ --label ./data/wf-train.json --convert_output_path ./output/wf/labels --img_type ".png" --manifest_path ./output/wf/manifest_train.txt --cls_list_file ./coco.names --relative_image_path ./data/wf/labels/

echo "Converting Validation to YOLO format"
python ./convert2Yolo/example.py --dataset COCO --img_path ./output/wf/labels/ --label ./data/wf-val.json --convert_output_path ./output/wf/labels --img_type ".png" --manifest_path ./output/wf/manifest_val.txt --cls_list_file ./coco.names --relative_image_path ./data/wf/labels/

echo "Done! Copy 'data/wf' to your Darknet repo's data folder"