/*
  ===========================================================================

  Copyright (C) 2022 Evariste F5OEO


  PLUTO_DVB is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  This software  is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License LIMfor more details.

  You should have received a copy of the GNU General Public License
  along with PLUTO_DVB.  If not, see <http://www.gnu.org/licenses/>.

  ===========================================================================
*/
 
//#define PLUTO
 
#include <stdbool.h>
#include <stdint.h>
#include <string.h>
#include <signal.h>
#include <stdio.h>
#include <ctype.h>
#include <iio.h>

#include <sys/mman.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/ioctl.h>
 #include <unistd.h>
#include <fcntl.h>

/* RX is input, TX is output */
enum iodev
{
    RX,
    TX
};


//************************ Global variables  ************************************** 

static struct iio_context *m_ctx = NULL;
static struct iio_device *m_dev = NULL;
//Channels variable

static struct iio_buffer *m_txbuf = NULL;
struct iio_device *m_tx = NULL;
static struct iio_channel *m_tx0_i = NULL;
static struct iio_channel *m_tx0_q = NULL;

static char tmpstr[255];

static int want_quit = 0;

static int fdregister=NULL;
    static unsigned page_addr, page_offset;
	static void *ptr=NULL;
static unsigned page_size;

void InitDevMem(size_t Address)
{
    

    page_size=sysconf(_SC_PAGESIZE);

    fdregister = open ("/dev/mem", O_RDWR);
    unsigned gpio_addr = Address; //Fixme if high mem
    page_addr = (gpio_addr & (~(page_size-1)));
	
	ptr = mmap(NULL, page_size, PROT_READ|PROT_WRITE, MAP_SHARED, fdregister, page_addr);
    
}    


size_t ReadRegister( size_t Address)
{
   // writeiiohex(sPath, Address);
   // size_t Value = readiiohex(sPath);
    InitDevMem(Address);
    page_offset = Address - page_addr;
    size_t value = *((unsigned *)(ptr + page_offset));

    munmap(ptr, page_size);
    close(fdregister);
    return value;
}

void WriteRegister(size_t Address, size_t RegisterValue)
{
     InitDevMem(Address);
     page_offset = Address - page_addr;
     *((unsigned *)(ptr + page_offset)) = RegisterValue;
     munmap(ptr, page_size);
    close(fdregister);
    //writeiiohex(sPath, Address, RegisterValue);
}

bool SendCommand(char *skey, char *svalue)
{
    FILE *fdwrite = NULL;
    fdwrite = fopen(skey, "w");
    char tempvalue[255];
    strcpy(tempvalue,svalue);

    if (fdwrite == NULL)
    {
        fprintf(stderr,"Invalid key %s\n",skey);
        return false;
    }    
    if (tempvalue[strlen(tempvalue) - 1] == 'M')
    {
        tempvalue[strlen(tempvalue) - 1] = 0;
        float value = atof(tempvalue) * 1e6;
        sprintf(tempvalue, "%.0f", value);
    }
    if (tempvalue[strlen(tempvalue) - 1] == 'K')
    {
        tempvalue[strlen(tempvalue) - 1] = 0;
        float value = atof(tempvalue) * 1e3;
        sprintf(tempvalue, "%.0f", value);
    }
    //fprintf(stderr, "%s\n", tempvalue);
    fprintf(fdwrite, "%s", tempvalue);
    fclose(fdwrite);
    return true;
}

/* helper function generating channel names */
static char *get_ch_name(const char *type, int id)
{
    snprintf(tmpstr, sizeof(tmpstr), "%s%d", type, id);
    return tmpstr;
}

/* finds streaming IIO channels */
static bool get_stream_ch(enum iodev d, struct iio_device *dev, int chid, struct iio_channel **chn)
{
    *chn = iio_device_find_channel(dev, get_ch_name("voltage", chid), d == TX);
    if (!*chn)
        *chn = iio_device_find_channel(dev, get_ch_name("altvoltage", chid), d == TX);
    return *chn != NULL;
}

static bool get_stream_dev(struct iio_context *ctx, enum iodev d, struct iio_device **dev)
{
    switch (d)
    {
    case TX:
        #ifdef PLUTO
        *dev = iio_context_find_device(ctx, "cf-ad9361-dds-core-lpc");
        #else
        *dev = iio_context_find_device(ctx, "axi-ad9371-tx-hpc");
        #endif
        return *dev != NULL;
    default:
        return false;
    }
}

void InitTxChannel(size_t len, unsigned int nbBuffer)
{
    if (m_ctx == NULL)
        m_ctx = iio_create_local_context();
    if (m_ctx == NULL)
        fprintf(stderr, "Init context failed\n");
    iio_context_set_timeout(m_ctx, 0);

    get_stream_dev(m_ctx, TX, &m_tx);
   
    get_stream_ch(TX, m_tx, 0, &m_tx0_i);
    get_stream_ch(TX, m_tx, 1, &m_tx0_q);

    fprintf(stderr, "Tx Stream with %u buffers of %d samples\n", nbBuffer, len);
    // Change the size of the buffer
    //m_max_len = len;

    if (m_txbuf)
    {
        iio_channel_disable(m_tx0_i); // Fix the bug https://github.com/analogdevicesinc/libiio/commit/02527e69ab57aa2eac995e964b58421b0f5af5ad
        iio_channel_disable(m_tx0_q);
        iio_buffer_destroy(m_txbuf);
        m_txbuf = NULL;
    }

    iio_device_set_kernel_buffers_count(m_tx, nbBuffer); // SHould be called BEFORE create_buffer (else not setting)

    //	printf("* Enabling IIO streaming channels\n");
    iio_channel_enable(m_tx0_i);
    iio_channel_enable(m_tx0_q);

    m_txbuf = iio_device_create_buffer(m_tx, len, false);

    if (m_txbuf == NULL)
    {
        fprintf(stderr, "Could not allocate iio mem tx\n");
        exit(1);
    }

    iio_buffer_set_blocking_mode(m_txbuf, true);
    
}

ssize_t write_byte_from_buffer_burst(unsigned char *Buffer, int len)
{
  static int cur_idx=0;
      
    unsigned char *buffpluto = (unsigned char *)iio_buffer_start(m_txbuf);

    memcpy(buffpluto+cur_idx,Buffer,len);
    cur_idx+=len;        
    size_t sent=0;
    if(cur_idx%4==0)
    {
        sent=iio_buffer_push_partial(m_txbuf,cur_idx/4);
        cur_idx=0;
       
    }    
    else
        sent=0;    
   
   
    return sent;
}

// Global signal handler for trapping SIGINT, SIGTERM, and SIGQUIT
static void signal_handler(int signal)
{
    if(signal==SIGPIPE) fprintf(stderr,"Sigpipe close\n");
	want_quit = 1;
	
}



 debug_dvbs2_register()
 {
     #ifdef PLUTO
        uint32_t BaseAdress=0x43C10000;
     #else   
        uint32_t BaseAdress=0x44ac0000;
    #endif     
    //fprintf(stderr,"Depth %d\n",ReadRegister(BaseAdress+0x8));
    fprintf(stderr,"Frame Length  : input %d bbscrambler %d bch %d \n",ReadRegister(BaseAdress+0xD08),ReadRegister(BaseAdress+0xE08),ReadRegister(BaseAdress+0xF08));
    
 }
int main(int argc, char **argv)
{
    signal(SIGINT, signal_handler);
	signal(SIGTERM, signal_handler);
	signal(SIGQUIT, signal_handler);
	signal(SIGPIPE, signal_handler);
    
    #ifdef PLUTO
    //Set SymbolRate
    SendCommand("/sys/bus/iio/devices/iio:device0/in_voltage_sampling_frequency", "10M");
    //Set Frequency
    SendCommand("/sys/bus/iio/devices/iio:device0/out_altvoltage1_TX_LO_frequency", "950M");
    //Set Tx Gain 
    SendCommand("/sys/bus/iio/devices/iio:device0/out_voltage0_hardwaregain", "-30");
    //TX On
    SendCommand("/sys/bus/iio/devices/iio:device0/out_altvoltage1_TX_LO_powerdown", "0");
    #else
    //Set SymbolRate
    SendCommand("/sys/bus/iio/devices/iio:device3/out_voltage_sampling_frequency", "50M");
    //Set Frequency
    SendCommand("/sys/bus/iio/devices/iio:device3/out_altvoltage1_TX_LO_frequency", "1200M");
    //Set Tx Gain 
    SendCommand("/sys/bus/iio/devices/iio:device3/out_voltage0_hardwaregain", "-10");
   
    #endif

     size_t BufferLentx=(1+(58192)/8)*16; //MAX BBFRAME LENGTH*4
     InitTxChannel(BufferLentx, 2);

    

    // A QPSK FEC 2/3 BBFrame patern
    unsigned char *pattern23 = (unsigned char *)malloc(43040/8+4);

    pattern23[0]=0x31;
    pattern23[1]=0x00;
    pattern23[2]=0x00;
    pattern23[3]=0x00; 
    for (int i = 4; i < 43040/8+4; i++)
    {
        pattern23[i ] = 0;
        
    }

    while(!want_quit)
    {
        ssize_t written = write_byte_from_buffer_burst(pattern23,43040/8+4);
        
        if(written!=0) 
        {
            debug_dvbs2_register();
            //fprintf(stderr,"*");
            fflush(stderr);
        }
    }    


}