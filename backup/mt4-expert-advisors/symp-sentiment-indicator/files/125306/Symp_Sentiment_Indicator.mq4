// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=68168


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
#property indicator_buffers 3
#property indicator_color1 clrGreen
#property indicator_color2 clrRed
#property indicator_color3 clrBlue
 
#property indicator_width1 1
#property indicator_width2 1
 
extern int Look_Back_Length=20;

extern string Custom_Indicator = "Symp_Sentiment_Indicator";
 
double Up[];
double Down[]; 
double St[];  
double Data[];  

int init() {
 
 
   IndicatorBuffers(4);
	
   SetIndexBuffer(0, Up);
   SetIndexLabel(0, "Up"); 
   SetIndexStyle(0, DRAW_HISTOGRAM); 
   SetIndexBuffer(1, Down);
   SetIndexLabel(1, "Down");
   SetIndexStyle(1, DRAW_HISTOGRAM); 
 
   SetIndexBuffer(2, Data);
   SetIndexLabel(2, "Line");
   SetIndexStyle(2, DRAW_LINE); 
   
   SetIndexBuffer(3, St);
 
   
 
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
   
   double Min,Max ,median;
   
   for (int pos = Bars - gi_116 - 1; pos >= 0; pos--) {
    
    median=(High[pos] + Low[pos]) / 2;	
	Max=High[iHighest(NULL, 0, MODE_HIGH, Look_Back_Length, pos)];
	Min=Low[iLowest(NULL, 0, MODE_LOW, Look_Back_Length, pos)];    
	  
	
	St[pos]=0.66*((median-Min)/(Max-Min)-0.5)+0.67*St[pos+1];
	St[pos]= MathMin(St[pos], 1);
	St[pos]= MathMax(St[pos], -1);
	
	
	Data[pos]=(MathLog((1+St[pos])/(1-St[pos]))+Data[pos+1])/2;
	
	if (Data[pos]>0)
	{
	Up[pos]=Data[pos];
	Down[pos]=NULL;
	}
	else
	{
	Down[pos]=Data[pos];
	Up[pos]=NULL;
	}
	
	
	
	   
   }
   return (0);
}