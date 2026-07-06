// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=65882

//+------------------------------------------------------------------+
//|                               Copyright © 2018, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  | 
//|                                    Paypal: https://goo.gl/9Rj74e |
//+------------------------------------------------------------------+
//|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
//|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
//|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
//|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
//+------------------------------------------------------------------+


#property copyright "Copyright © 2018, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Blue

 
extern int Period=14; 
 

double Line[] ;
double Temp[];


int init()
{
 IndicatorShortName("Time Segmented Volume");
 IndicatorDigits(Digits);
 
 IndicatorBuffers(2);
	
 
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,Line);

 
 
SetIndexStyle(1,DRAW_NONE);
SetIndexBuffer(1,Temp);

 
 

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
   
   Temp[pos]=0;
	
   if(Close[pos]> Close[pos+1]) 
  {
  Temp[pos]=  Volume[pos] * (Close[pos]- Close[pos+1]);
  }
  
    if(Close[pos]< Close[pos+1]) 
  {
  Temp[pos]=  -1* Volume[pos] * (Close[pos+1]- Close[pos]);
  }
  
  
  Line[pos]=iMAOnArray(Temp,0,Period,0,MODE_SMA,pos)*Period;
  
  pos--;
 } 
 
 

   
  

 return(0);
}

