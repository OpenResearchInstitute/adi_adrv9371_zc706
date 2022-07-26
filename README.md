# adi_adrv9371_zc706

## What is this?
Analog Device's adrv9371 HDL Reference Design with DVB-S2 integration. A processor side c code example (dmatest.c) for register reads and writes is included. 

## How do I use it?

Clone this repository.

cd into the directory created.

git submodule init

git submodule update

cd into dvb-fpga.

git submodule init

git submodule update
_
This set of commands gives you the nested "third party" submodule. _It might be better to use --recursive._

cd to the directory corresponding to adrv9371/zc706.

type make

