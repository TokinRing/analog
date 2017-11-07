// fpga_dll.cpp : FPGA-based Fast Multisource Pulse Registration System 
// Simple Labview Driver
// by Sergey Polyakov

// The computer communicates with the FPGA via a USB 2 port and using a standard ezusb driver.
// The FPGA is a slave USB device. The protocol consists of 
// 1) a request sent by a computer (sends one byte via FIFO2, which is used for a primitive control of FPGA, see documentation)
// 2) a response of FPGA (replies with 2 bytes via FIFO5, reports the length of collected information in bytes)
// 3) data of a total length reported in step 2 is then availible for download via FIFO4

// This dll computes simple statistics of single pulses and pulse coincidences and provides for an option to write all timestamps and events.
// It provides a simple iterface for labview.

// Interface functions:
// HANDLE FPGA_Open() initializes the FPGA communication protocol. 
//		returns an integer "handle" to the device. -1 if not successful.
//
// void FPGA_Close(HANDLE XyloDeviceHandle) Closes communication session.
//
// int FPGA_Interface (int runs, char fpga_command, int saveclicks, char * filename, HANDLE XyloDeviceHandle, int * stats)
//		establishes the communication with the FPGA and returns statistics.
//              int runs: query the FPGA "runs" number of times, and accumulate statistics
//              char fpga_command: one byte to send to FPGA. Possible commands: 0b00000000 no command
//																				0bxxxxx001 input a new threshold, where xxxxx (translates to 0bxxxxx000) is a new threshold value 
//																				0b00000010 stop aquisition
//																				0b00000100 start aquisition
//				int saveclicks: if =1, save timestamped electronic events in a file; =0 do not save
//				char * filename: name of file to save events into
//				HANDLE XyloDeviceHandle: handle to FPGA device
//				int *stats: pointer to the output statistics array
//		returns 1 if successful, 0 upon an error
#include "stdafx.h"



//BOOL APIENTRY DllMain( HANDLE hModule, 
//                       DWORD  ul_reason_for_call, 
//                       LPVOID lpReserved
//					 )
// Defines the entry point for the DLL application.					 
//{
//    return TRUE;
//}


///////////////////////////////////////////////////
// Opens and closes the FPGA/USB driver
///////////////////////////////////////////////////
_declspec(dllexport) HANDLE FPGA_Open()
{
    HANDLE XyloDeviceHandle;
	//CStr a = ("\\\\.\\EzUSB-0");
	//char *dev = new char ("\\\\.\\EzUSB-0");
	XyloDeviceHandle = CreateFile("\\\\.\\EzUSB-0", GENERIC_WRITE, FILE_SHARE_WRITE, NULL, OPEN_EXISTING, 0, NULL);
	if (XyloDeviceHandle==INVALID_HANDLE_VALUE) return (HANDLE)-1;
	return XyloDeviceHandle;
}

_declspec(dllexport) void FPGA_Close(HANDLE XyloDeviceHandle)
{
	CloseHandle(XyloDeviceHandle);
}
///////////////////////////////////////////////////
// FPGA/USB interface (raw functions)
///////////////////////////////////////////////////
int USB_BulkWrite(ULONG pipe, void* buffer, ULONG buffersize, HANDLE XyloDeviceHandle)
{
	DWORD nBytes;
	int result; 
    result = 
           DeviceIoControl(XyloDeviceHandle, 0x222051, &pipe, sizeof(pipe), buffer, buffersize, &nBytes, NULL);
    if (nBytes== buffersize && result==1)
    return 1; //ok
    else
    return -1; //error
}

DWORD USB_BulkRead(ULONG pipe, void* buffer, ULONG buffersize, HANDLE XyloDeviceHandle)
{
	DWORD nBytes;
	int result;
	result = DeviceIoControl(XyloDeviceHandle, 0x22204E, &pipe, sizeof(pipe), buffer, buffersize, &nBytes, NULL);
//	bool DIC (...) If the operation completes successfully, the return value is nonzero.
//  If the operation fails or is pending, the return value is zero. To get extended error information, call GetLastError.

	if (result !=1 ) return -1; //error
	return nBytes;
}


///////////////////////////////////////////////////
// Communicates with FPGA
///////////////////////////////////////////////////
_declspec(dllexport) int FPGA_ANALOG_Interface (int runs, char fpga_command, int saveclicks, char * filename, HANDLE XyloDeviceHandle, int * length, unsigned char * data)
{
    static FILE * clicklog=0;
	//static int isclickfile;
    unsigned char buffer[65536];
    unsigned char*nbuffer;
    const int BSize = 0x8000;
	
	

//	FILE * fk;
//	fk = fopen ("c:\\debug111.txt", "wt");
//	fprintf (fk,"%s\n", filename);
//	fclose (fk);
    
    int i;

	// if communication resulted in less bytes than is necessary to define an event (4), the portion of the last event are saved for later    
    static int moredataflag=0; 
    static int moredata[8];
	// if the number of bytes availible for downloading is greater than we are ready to accept, they will be left until the next readout
	static unsigned int bufferleft=0;
	int shortpacketflag;
    
    
//    for (i=0; i<15; i++ )
//    {
//        stats[i] = 0;
//    }
    if (saveclicks)
    {
		if (!clicklog)
		{
			clicklog = fopen(filename, "at");
			if (!clicklog) return -3; // error: can not open the file for writing
		}
    }

	*length = 0;
    for (i=0; i<runs; i++)
    {
		//step 1: use bytes downloaded previously, that did not define the event.
        if (moredataflag)
        {
                         int kk;
                         for (kk=0; kk<moredataflag; kk++)
                         {
                             buffer[kk] = moredata[kk];
                         }
                         nbuffer = buffer + moredataflag;

        }
        else nbuffer = buffer;
        //step 2: write a command into FPGA and request data
        int nb_bytes_received;
        if ( USB_BulkWrite(2, &fpga_command, 1, XyloDeviceHandle)== -1 ) 
        {
             return -1; //error: unable to bulk-write
        }
		//step 3: recieve 2 bytes defining the length of transmission
		if ( (nb_bytes_received = USB_BulkRead(5, nbuffer, 512, XyloDeviceHandle) )== -1)
		{
			return -2; //error: unable to bulk-read
		}
		//calculate the length of data availible for download
		unsigned int size = (int)nbuffer[1]+256*(int)nbuffer[0];
		
		printf ( "size reported: %d\n", size );
		
		//because a full USB frame is 512 bytes, download an integer number of frames, and leave everthing else for a next session
		size += bufferleft;
		bufferleft = size%512;
		size -=bufferleft;	
		//however, if there was too little data availible (i.e. less than <512 bytes), the FPGA will force sending a short packet to keep us informed
		shortpacketflag = 0;
		if (!size) 
		{
			shortpacketflag = 1;
			size = 1024;
		}
		//step 4: recieve a bulk of data
        if ( (nb_bytes_received = USB_BulkRead(4, nbuffer, size, XyloDeviceHandle) )== -1) 
	    {
		     return 0; //error
		}  
		printf ( "Actually collected: %d\n", nb_bytes_received );
		if ( shortpacketflag )
		{
			shortpacketflag = 0;
			bufferleft -= nb_bytes_received;
		}		
		//step 5: check if the information on the last event has to be stored for later
        if (moredataflag)
	    {
			nb_bytes_received += moredataflag;
	        moredataflag=0;
	    }
		if ( (moredataflag=nb_bytes_received%8)!=0)
	    {
                                  int k;
                                  for (k=0; k<moredataflag; k++)
                                  {
                                      moredata[k] = buffer[nb_bytes_received-moredataflag+1+k];
                                  }
                                  nb_bytes_received -= moredataflag;
		}
		if (fpga_command == 2) moredataflag = 0;

		//step 6: prepare the ouptut and save a file, if needed
		
        for (int j=0; j<nb_bytes_received - nb_bytes_received%8; j+=8)
        {
            for (int jj=0; jj<8; jj++)
				*(data+(*length)+j+jj) = buffer[j+jj];
			if (clicklog)
				fprintf(clicklog,"%X %X %X %X %X %X %X %X\n", buffer[j+7], buffer[j+6], buffer[j+5], buffer[j+4], buffer[j+3], buffer[j+2], buffer[j+1], buffer[j]);
        }
		*length += nb_bytes_received - nb_bytes_received%8;
		if (!saveclicks || fpga_command == 2)
	    {
			if (clicklog)
			{
				fclose (clicklog);
				clicklog = NULL;
			}
		}
		//step 7: compute the simple statistics
		//REALTIME_FUNCTION (buffer,nb_bytes_received,stats);
		//if ( ct!=(int)time(NULL) ) break;
//		*length = 80;
//		for (int j=0; j<80; j++)
//		{
//			data[j] = (unsigned char) j;
//		}

    }


	return 1; //no error
}



_declspec(dllexport)  int outputdata(HANDLE XyloDeviceHandle, unsigned char * data, int * length)

//int main()

{
//FILE *out;
	
	int res;
//	int length;
//	unsigned char data [65535];

//HANDLE fpga = XyloDeviceHandle;
//	out = fopen ("test.txt","wt");

	HANDLE fpga = FPGA_Open();
	if ( fpga == (HANDLE)-1 ) printf ( "!!!!!!!!!!!!! FPGA INIT ERROR" );

	res = FPGA_ANALOG_Interface (1, 4, 0, "test.txt", fpga, length, data);
	if ( res != 1 ) printf ( "!!!!!!!!!!!!! ERROR %d", res );

	//for (int i =0; i<1; i++)
	//{
	//	res = FPGA_ANALOG_Interface (1, 4, 0, "test.txt", fpga, &length, data);
	//	if ( res != 1 ) printf ( "!!!!!!!!!!!!! ERROR %d", res );
		//this is for a code that spits event information: length, integral & peak amp.
		//for (int j=0; j<length; j+=8)
		//	fprintf(out,"%X %X %X %X %X %X %X %X\n", data[j+7], data[j+6], data[j+5], data[j+4], data[j+3], data[j+2], data[j+1], data[j]);
		//this is for a simple "scope-like" code
		//for (int j=0; j<length; j++)
		//	fprintf(out,"%X\n", data[j]);
	//}

	//FPGA_Close(fpga);
	
	//fclose (out);
	return 1;
}