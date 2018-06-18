## Docker Solution for Face Detection Using Faster R-CNN
<div align="center">
  <img src="http://i.imgur.com/2tdfLH5.jpg" width="300"><br><br>
</div>

**Dockerface** is a deep learning replacement for dlib and OpenCV non-deep face detection. It deploys a trained Faster R-CNN network on Caffe through an easy to use docker image. Bring your videos and images, run dockerface and obtain videos and images with bounding boxes of face detections and an easy to use face detection annotation text file.

The docker image is large for now because OpenCV has to be compiled and stored in the image to be able to use video and it takes up a lot of space.

Technical details and some experiments are described in the [Arxiv Tech Report](https://arxiv.org/abs/1708.04370).

### Citing Dockerface

If you find Dockerface useful in your research please consider citing:

```
@ARTICLE{2017arXiv170804370R,
   author = {{Ruiz}, N. and {Rehg}, J.~M.},
    title = "{Dockerface: an easy to install and use Faster R-CNN face detector in a Docker container}",
  journal = {ArXiv e-prints},
archivePrefix = "arXiv",
   eprint = {1708.04370},
 primaryClass = "cs.CV",
 keywords = {Computer Science - Computer Vision and Pattern Recognition},
     year = 2017,
    month = aug,
   adsurl = {http://adsabs.harvard.edu/abs/2017arXiv170804370R},
  adsnote = {Provided by the SAO/NASA Astrophysics Data System}
}
```

### Instructions

Install NVIDIA CUDA (8 - preferably) and cuDNN (v5 - preferably)
```
https://developer.nvidia.com/cuda-downloads
https://developer.nvidia.com/cudnn
```

Install docker
```
https://docs.docker.com/engine/installation/
```

Install nvidia-docker
```
wget -P /tmp https://github.com/NVIDIA/nvidia-docker/releases/download/v1.0.1/nvidia-docker_1.0.1-1_amd64.deb
sudo dpkg -i /tmp/nvidia-docker*.deb && rm /tmp/nvidia-docker*.deb
```

Go to your working folder and create a directory called data, **your videos and images should go here**. Also create a folder called output.

```
cd $WORKING_DIR
mkdir data
mkdir output
```

Run the docker container
```
sudo nvidia-docker run -it -v $PWD/data:/opt/py-faster-rcnn/edata -v $PWD/output/video:/opt/py-faster-rcnn/output/video -v $PWD/output/images:/opt/py-faster-rcnn/output/images natanielruiz/dockerface:latest
```

Now we have to recompile Caffe for it to work on your own machine.
```
cd caffe-fast-rcnn
rm -rf build
mkdir build
cd build
cmake -DUSE_CUDNN=1 ..
make -j20 && make pycaffe
cd ../..
```

Finally use this command to **process a video**
```
python tools/run_face_detection_on_video.py --gpu 0 --video edata/YOUR_VIDEO_FILENAME --output_string STRING_TO_BE_APPENDED_TO_OUTPUTFILE_NAME --conf_thresh CONFIDENCE_THRESHOLD_FOR_DETECTIONS
```

Use this command to **process an image**
```
python tools/run_face_detection_on_image.py --gpu 0 --image edata/YOUR_IMAGE_FILENAME --output_string STRING_TO_BE_APPENDED_TO_OUTPUTFILE_NAME --conf_thresh CONFIDENCE_THRESHOLD_FOR_DETECTIONS
```

Also if you are looking to conveniently **process all images in one folder** use this command
```
python tools/facedetection_images.py --gpu 0 --image_folder edata/IMAGE_FOLDER_NAME --output_folder OUTPUT_FOLDER_PATH --conf_thresh CONFIDENCE_THRESHOLD_FOR_DETECTIONS
```

The default confidence threshold is 0.85 which works for high quality videos or images where the faces are clearly visible. You can play around with this value.

The columns contained in the output text files are:

For **videos**:

*frame_number x_min y_min x_max y_max confidence_score*

For **images**:

*image_path x_min y_min x_max y_max confidence_score*

Where (x_min,y_min) denote the coordinates of the upper-left corner of the bounding box in image intrinsic coordinates and (x_max, y_max) denote the coordinates of the lower-right corner of the bounding box in image intrinsic coordinates. (ref. https://www.mathworks.com/help/images/image-coordinate-systems.html)
confidence_score denotes the probability output of the model that the detection is correct (it is a number included in [0,1])

Voila, that easy!

After you're done with the docker container you can exit.
```
exit
```

You want to restart and re-attach to this same docker container so as to avoid compiling Caffe again. To do this first get the id for that container.
```
sudo docker ps -a
```

It should be the last one that was launched. Take note of CONTAINER ID. Then start and attach to that container.
```
sudo docker start CONTAINER_ID
sudo docker attach CONTAINER_ID
```

You can now continue processing videos.

*Nataniel Ruiz and James M. Rehg<br>
Georgia Institute of Technology*

Credits:
Original **dockerface** logo made by [Freepik](http://www.freepik.com) from [Flaticon](http://www.flaticon.com) is licensed by [Creative Commons BY 3.0](http://creativecommons.org/licenses/by/3.0/), modified by Nataniel Ruiz.
