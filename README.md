# python-nonroot-small-docker
Python 3.9 + Non-Root user (/home/developer) + venv (setup) + small size docker

# Build (`Do this first!`)
Due to Docker Hub not allowing free host of pre-built images, you have to make local build to use!
```
make build

or

./build.sh
```

# Run (GPU/Nvidia - Auto Enable)
* For the **HOST / VM** (not Docker):
  * To run GPU/Nvidia, you need to install the `Nvidia Driver` in your `HOST machine` first and then install `nvidia-docker2`.
  * Please refer to [`Nvidia Container Toolkit`](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html#docker) documentation for how to install properly
  * You also need to setup environment variables once you have successfully install `Nvidia driver` and `Nvidia-docker2` Container Toolkit `before you run Docker` (trying to use nvidia-docker2). 
It's recommended to setup in your **HOST / VM Machine's user account's** `.bashrc` profile.
```
export PATH=/usr/local/cuda/bin${PATH:+:${PATH}}
export LD_LIBRARY_PATH=/usr/local/cuda/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}

./run.sh -g
or, let it auto check and use Nvidia GPU if available:
./run.sh
```

## Run (If choose only CPU!)
* It will download 'yolov5s.pt' on-the-fly to use if not existing.
```
./run.sh
or, explicitly disable GPU to use CPU.
./run.sh -c
```
# Create your own image from this
```
FROM openkbs/python-non-root
```
# Quick commands
* build.sh - build local image
* logs.sh - see logs of container
* run.sh - run the container
* shell.sh - shell into the container
* stop.sh - stop the container

# To change Python version:
* Modify ./environment.yml file to change as below.
* To add more default package lib, e.g., pandas, as below.
* Remember, this base Contain is meant to be very small. Any package you add will bloating up the size of the base container image. Only add PIP package in this base image if you really want to make the PIP libs into the base image..
```
name: example
channels:
  - conda-forge
dependencies:
  - python=3.8
  - numpy
  - pandas
```
