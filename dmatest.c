#include <stdio.h>
#include <fcntl.h>
#include <unistd.h>
#include <string.h>
#include <termios.h>
#include <sys/mman.h>

#define TX_DMAC_CONTROL_REGISTER 0x00
#define TX_DMAC_STATUS_REGISTER 0x04
#define TX_DMAC_IDENTIFICATION 0x000c
#define TX_DMAC_SCRATCH 0x0008
#define TX_DMAC_INTERFACE 0x0010
#define TX_DMAC_DEST_ADDRESS 0x0410
#define TX_DMAC_SRC_ADDRESS 0x0414

#define ENCODER_CONTROL_REGISTER 0x00

unsigned int read_dma(unsigned int *virtual_addr, int offset)
{
	return virtual_addr[offset>>2];
}

unsigned int write_dma(unsigned int *virtual_addr, int offset, unsigned int value)
{

	virtual_addr[offset>>2] = value;
	return 0;

}

void  dma_interface(unsigned int *virtual_addr)
{
	unsigned int interface = read_dma(virtual_addr, TX_DMAC_INTERFACE);
	printf("TX DMAC Interface Description (0x%08x@0x%02x):\n", interface, TX_DMAC_INTERFACE);
	//break out and parse the fields in human readable format
}


int main()
{
	printf("Hello World! Running TX-DMA access tests.\n");

	printf("Opening a character device file in DDR memory.\n");
	int ddr_memory = open("/dev/mem", O_RDWR | O_SYNC);


	printf("Memory map the address of the TX-DMAC via its AXI lite control interface register block.\n");
	unsigned int *dma_virtual_addr = mmap(NULL, 65535, PROT_READ | PROT_WRITE, MAP_SHARED, ddr_memory, 0x7c420000);
	
	printf("Memory map the address of the DVB-ENCODER via its AXI lite control interface.\n");
	unsigned int *encoder_virtual_addr = mmap(NULL, 65535, PROT_READ | PROT_WRITE, MAP_SHARED, ddr_memory, 0x44ac0000);

	printf("Create a buffer for the transmitted data.\n");
	unsigned int transmit_data[4*100];
	


	dma_interface(dma_virtual_addr);

	printf("Writing to scratch register.\n");
	write_dma(dma_virtual_addr, TX_DMAC_SCRATCH, 0x5555AAAA);
	printf("Reading from scratch register. We see: (0x%08x@%02x)\n", read_dma(dma_virtual_addr, TX_DMAC_SCRATCH), TX_DMAC_SCRATCH);

	printf("Reading from the encoder to see what's there: (0x%08x@%02x)\n", read_dma(encoder_virtual_addr, ENCODER_CONTROL_REGISTER), ENCODER_CONTROL_REGISTER);

	printf("-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-\n");
	printf("Configure a direct memory access test.\n");
	//write_dma(dma_virtual_addr, TX_DMC_SRC_ADDRESS, 


}
