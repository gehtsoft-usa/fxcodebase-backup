//+------------------------------------------------------------------+
//|                               Copyright © 2016, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//|                         Donate / Support:  http://goo.gl/cEP5h5  | 
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//|                     BitCoin: 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2016, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Blue


 
extern int MA_Period=14;
extern int MA_Method=0;

double POGO[];
double RAW[];
 

int init()
  {
   IndicatorBuffers(2);
   IndicatorShortName("POGO");
   IndicatorDigits(Digits);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,POGO);
    SetIndexStyle(1,DRAW_NONE);
   SetIndexBuffer(1,RAW);
  
   
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
	  RAW[pos]= Open[pos]-Close[pos]; 
	  pos--;
 } 
  
  
  pos=limit;
 while(pos>=0)
 { 
	  POGO[pos]= iMAOnArray(RAW,0,MA_Period,0,MA_Method,pos);
	  pos--;
 } 
  
   
 return(0);
}

