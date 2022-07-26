# adi_adrv9371_zc706

## What is this?
Analog Device's adrv9371 HDL Reference Design with DVB-S2 integration. A processor side c code example (dmatest.c) for register reads and writes is included. 

## How do I use it?

Clone this repository.

cd into the directory created.

git submodule init

git submodule update

_checkout the hdl_2021_r1 branch of the HDL_ We are trying to make this happen automatically, but double-check it with git status to make sure you have the right branch. 

cd into dvb-fpga.

git submodule init

git submodule update

This set of commands gives you the nested "third party" submodule. 

cd to the directory corresponding to adrv9371/zc706.

type make

