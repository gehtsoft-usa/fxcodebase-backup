//+------------------------------------------------------------------+
//|                                         Range_Volume_Ratio_S.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 4
#property indicator_color1 Yellow
#property indicator_color2 Blue

#property indicator_color3 Green
#property indicator_color4 Red

extern int Method=0; // 0 - Open/Close method
                     // 1 - High/Low method
extern int MA_Length=15;                     
extern int MA_Method=1;  // 0 - SMA
                         // 1 - EMA
                         // 2 - SMMA
                         // 3 - LWMA
extern bool PreviousBarPosition=true; 						 
						 

double RVR[], Signal[];
double UP[], DN[];
int init()
{
 IndicatorShortName("Range Volume Ratio smoothed oscillator");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_HISTOGRAM);
 SetIndexBuffer(0,RVR);
 SetIndexStyle(1,DRAW_LINE);
 SetIndexBuffer(1,Signal);
 
  if (PreviousBarPosition )
 {
 
 SetIndexStyle(2,DRAW_HISTOGRAM);
 SetIndexBuffer(2,UP);
 SetIndexStyle(3,DRAW_HISTOGRAM);
 SetIndexBuffer(3,DN);
 }
 
 return(0);
}

int deinit()
{

 return(0);
}

int start()
{
 if(Bars<=3) return(0);
 int ExtCountedBars=IndicatorCounted();
 if (ExtCountedBars<0) return(-1);
 int limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 int pos;
 pos=limit;
 while(pos>=0)
 {
  if (Method==0)
  {
   RVR[pos]=MathAbs(Open[pos]-Close[pos])/(Volume[pos]*Point);
  }
  else
  {
   RVR[pos]=(High[pos]-Low[pos])/(Volume[pos]*Point);
  }
  
  pos--;
 } 
 
 pos=limit;
 while(pos>=0)
 {
  Signal[pos]=iMAOnArray(RVR, 0, MA_Length, 0, MA_Method, pos);
  pos--;
 }
 
 if (PreviousBarPosition )
 {
 
		  pos=limit-1;
		 while(pos>=0)
		 {
		   if ( RVR[pos+1] > Signal[pos+1] ) 
		   {
		   UP[pos]= RVR[pos];
		   DN[pos]=EMPTY_VALUE;
		   }   
		   else
		   {
		   DN[pos]= RVR[pos];
		   UP[pos]=EMPTY_VALUE;
		   }
		  pos--;
		 }
 
 }
   
 return(0);
}

