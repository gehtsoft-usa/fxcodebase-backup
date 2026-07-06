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
#property indicator_buffers 2
#property indicator_color1 Green
#property indicator_color2 Red

 
extern int Period=14; 
 

double UP[], DN[] ;
double Temp[];
double Raw[];

int init()
{
 IndicatorShortName("Time Segmented Volume");
 IndicatorDigits(Digits);
 
 IndicatorBuffers(4);
	
 
 SetIndexStyle(0,DRAW_HISTOGRAM);
 SetIndexBuffer(0,UP);
 SetIndexStyle(1,DRAW_HISTOGRAM);
 SetIndexBuffer(1,DN);
 
 
SetIndexStyle(2,DRAW_NONE);
SetIndexBuffer(2,Temp);

SetIndexStyle(3,DRAW_NONE);
SetIndexBuffer(3,Raw);
 
 

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
  
  
  Raw[pos]=iMAOnArray(Temp,0,Period,0,MODE_SMA,pos)*Period;
  
  pos--;
 } 
 
 
 
  pos=limit;
 while(pos>=0)
 {
 
 if (Raw[pos]> Raw[pos+1] )
 {
 UP[pos]=Raw[pos];
 DN[pos]=0;
 }
 else
 {
 DN[pos]=Raw[pos];
 UP[pos]=0;
 }
 
  pos--; 
 }
   
  

 return(0);
}

