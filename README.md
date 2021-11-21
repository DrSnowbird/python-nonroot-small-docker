# python-nonroot-small-docker
Python 3.9 + Non-Root user (/home/developer) + venv (setup) + small size docker

# To change Python version:
* Modify ./environment.yml file to change as below.
* To add more default package lib, e.g., pandas, as below.
* Remember, this base (really base Python) Contain is meant to be very small. Any package you add will bloating up the size of the base container image. Only add PIP package in this base image if you really want to make the PIP libs into the base image..
```
name: example
channels:
  - conda-forge
dependencies:
  - python=3.8
  - numpy
  - pandas
```
