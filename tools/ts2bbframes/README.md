# MPEG Transport Stream to BBFRAMEs Converter

We need canned BBFRAMEs to feed into the downlink encoder for two
scenarios:

* testing of the FPGA-based encoder block
* generation of the "Default Digital Downlink" or "Triple-D" stream that
is to be transmitted when no other traffic is available for the downlink.

For convenience in the short term, we will use MPEG Transport Streams
(TS) instead of a full video stream running via IP over GSE. This enables
the use of a variety of off-the-shelf commercial test equipment to validate
the transmitted downlink signal.

It's relatively easy to convert any editable video program into a TS file,
using ```ffmpeg```. Here's an example command line:

```
TBD
```

The TS file is made up of fixed-length 188-byte packets. These form the
payload of the BBFRAMEs. In the nomenclature of the DVB-S2 specification,
they are User Packets or ```UP```. The first byte of each UP is a Sync
byte, which is always 0x47 (ASCII 'G').

According to 5.1.4 of the DVB-S2 spec, the Sync byte is to be moved into
the BBHEADER SYNC field and replaced inline by the CRC-8 computed over
the 187 other bytes of the previous UP. 

The payload length of a BBFRAME is not an integer multiple of the length
of a UP. There are two ways of packing UPs into BBFRAMEs. Per 5.1.5 of
the DVB-S2 spec, you can either use all the bits available in the payload,
and thus be forced to break up UPs across BBFRAME boundaries, or you can
just put an integer number of UPs into a BBFRAME, and allow the rest of
the bits in the BBFRAME to be padded with zeroes by Stream Adaptation
(5.2). The choice of strategy is supposed to be governed by the type of
application, according to Table 4 or Table D.2. Table 4 is for single
transport stream broadcast services, which is the most common case and
most like what we're doing. It specifies a slicing policy of "Break",
which is defined as "break packets in subsequent DATAFIELDs". This is
perhaps subject to interpretation, but I take it to mean that we should
fill up the BBFRAME with data and not use padding.

In that case we are also required to compute the SYNCD field of the
BBHEADER. This field identifies where in the BBFRAME the first whole
UP starts.