# adi_adrv9371_zc706

## What is this?
Analog Device's adrv9371 HDL Reference Design with DVB-S2 integration. A processor side c code example (dmatest.c) for register reads and writes is included. 

## How do I use it?

Clone this repository.

cd into the directory created.

```git submodule update --init --recursive```

```git submodule update --recursive```

This should intialize both dvb_fpga and hdl, and the nested submodules within dvb_fpga. 

cd to the directory corresponding to adrv9371/zc706.

type make

