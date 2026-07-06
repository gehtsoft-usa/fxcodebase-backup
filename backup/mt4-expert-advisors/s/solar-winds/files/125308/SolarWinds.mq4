// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=68169

//+------------------------------------------------------------------+
//|                               Copyright © 2019, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  | 
//|                                    Paypal: https://goo.gl/9Rj74e |
//+------------------------------------------------------------------+
//|                                Patreon :  https://goo.gl/GdXWeN  |  
//|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
//|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
//|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
//|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
//+------------------------------------------------------------------+


#property copyright "Copyright © 2019, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0" 

#property indicator_separate_window
#property indicator_buffers 5
#property indicator_color1 clrLawnGreen
#property indicator_color2 clrDarkGreen
#property indicator_color3 clrRed
#property indicator_color4 clrMaroon
#property indicator_color5 clrBlue
 
#property indicator_width1 1
#property indicator_width2 1
#property indicator_width3 1
#property indicator_width4 1
#property indicator_width5 1
 
extern int Look_Back_Length=10;

extern string Custom_Indicator = "SolarWinds";
 
double UpUp[];
double UpDown[];
double DownUp[]; 
double DownDown[]; 
double Data[];  

int init() {
 
 
   IndicatorBuffers(5);
	
   SetIndexBuffer(0, UpUp); 
   SetIndexStyle(0, DRAW_HISTOGRAM); 

   SetIndexBuffer(1, UpDown); 
   SetIndexStyle(1, DRAW_HISTOGRAM); 
   
   SetIndexBuffer(2, DownUp); 
   SetIndexStyle(2, DRAW_HISTOGRAM); 
   
   SetIndexBuffer(3, DownDown); 
   SetIndexStyle(3, DRAW_HISTOGRAM); 
   
   SetIndexBuffer(4, Data); 
   SetIndexStyle(4, DRAW_LINE); 
 
   
 
   return (0);
}

int deinit() {
   return (0);
}

int start() {
 
 
   if (Bars <= 10) return (0);
   double gi_116 = IndicatorCounted();
   if (gi_116 < 0) return (-1);
   if (gi_116 > 0) gi_116--;
   
   double Min,Max ,median,Res;
   
   for (int pos = Bars - gi_116 - 1; pos >= 0; pos--) {
    
    median=(High[pos] + Low[pos]) / 2;	
	Max=High[iHighest(NULL, 0, MODE_HIGH, Look_Back_Length, pos)];
	Min=Low[iLowest(NULL, 0, MODE_LOW, Look_Back_Length, pos)];    
	Res=Max-Min;  
	
	if (Res!=0) 
	{
	Data[pos]=(((median-Min)/Res-0.5)+Data[pos+1])*2/3;
	}
	else
	{
	Data[pos]=0;
	}
	
	UpUp[pos]=NULL;
	UpDown[pos]=NULL;
	DownUp[pos]=NULL;
	DownDown[pos]=NULL;
	
	if (Data[pos]>0)
	{
	  
	  
	   if (Data[pos]>Data[pos+1])
	   {
	   UpUp[pos]=Data[pos];
	   }
	   else
	   {
	    UpDown[pos]=Data[pos];
	   }
	
	 
	}
	else
	{
	
	
	   if (Data[pos]>Data[pos+1])
	   {
	    DownUp[pos]=Data[pos];
	   }
	   else
	   {
	    DownDown[pos]=Data[pos];
	   }
	
	
	 
	}
	
	
	
	   
   }
   return (0);
}