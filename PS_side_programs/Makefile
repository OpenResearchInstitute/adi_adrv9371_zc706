CROSS_COMPILE=arm-linux-gnueabihf-
CC=$(CROSS_COMPILE)gcc
#Change HOST_DIR and SYSèROOT according to your environment
SYSROOT=/home/linuxdev/prog/pluto/firm033/pluto_radar/plutosdr-fw/buildroot/output/staging
#HOST_DIR=/home/linuxdev/prog/pluto/firm033/pluto_radar/plutosdr-fw/buildroot/output/host
FLAGS = -Wall -Wno-write-strings -Wno-unused-function -Wno-unused-variable -Wno-unused-but-set-variable -liio -g -O2 -mfpu=neon --sysroot=$(SYSROOT) -mfloat-abi=hard


all: zc706_test pluto_test
zc706_test: minimaldvbs2.c
	$(CC) $(FLAGS) -o zc706_test minimaldvbs2.c -lm -lrt -lpthread 

pluto_test: minimaldvbs2.c
	$(CC) -DPLUTO $(FLAGS) -o pluto_test minimaldvbs2.c -lm -lrt -lpthread 	
clean:
	rm -f  zc706_test pluto_test
