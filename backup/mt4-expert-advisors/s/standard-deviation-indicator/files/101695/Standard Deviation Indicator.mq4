//+------------------------------------------------------------------+
//|                                 Standard Deviation Indicator.mq4 |
//+------------------------------------------------------------------+
//|                               Copyright © 2015, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//|                         Donate / Support:  http://goo.gl/cEP5h5  | 
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//|                     BitCoin: 1MfUHS3h86MBTeonJzWdszdzF2iuKESCKU  |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2015, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_color1 Blue
#property indicator_buffers   1

//---- input parameters 
extern int ExtStdDevMAMethod=0;
extern int ShiftInMinutes = 200;
//---- buffers
double ExtStdDevBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   string sShortName;
//---- indicator buffer mapping
   SetIndexBuffer(0,ExtStdDevBuffer);
//---- indicator line
   SetIndexStyle(0,DRAW_LINE);
//---- line shifts when drawing
   
//---- name for DataWindow and indicator subwindow label
   sShortName="StdDev";
   IndicatorShortName(sShortName);
   SetIndexLabel(0,sShortName);
 
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Standard Deviation                                               |
//+------------------------------------------------------------------+
int start()
  {
  
  
if(Bars<=3) return(0);
 int ExtCountedBars=IndicatorCounted();
 if (ExtCountedBars<0) return(-1);
 
 int limit=Bars-2;
 int  pos=limit;
  
 double One= 60;
 double iShift = (One*ShiftInMinutes) ; 
 int x;
 double New;
 double Delta;
 while(pos>=0)
  {  

	 New = Time[pos] - iShift;
     x=iBarShift(NULL,0,New);	 
	 Delta= (Close[pos]-Close[x]);
	 ExtStdDevBuffer[pos]= iStdDev(NULL,0,(x-pos),0,ExtStdDevMAMethod,PRICE_CLOSE,pos)*Delta;
 	
	   
  pos--;
  }
//----
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
