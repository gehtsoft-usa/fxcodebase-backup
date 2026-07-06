// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=68433

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

#property indicator_chart_window
#property indicator_buffers 11
#property indicator_color1 clrGray
#property indicator_color2 clrRed
#property indicator_color3 clrGray
#property indicator_color4 clrGray
#property indicator_color5 clrGray
#property indicator_color6 clrBlue
#property indicator_color7 clrGray
#property indicator_color8 clrGray
#property indicator_color9 clrGray
#property indicator_color10 clrGreen
#property indicator_color11 clrGray
 
#property indicator_width1 1
#property indicator_width2 1
#property indicator_width3 1
#property indicator_width4 1
#property indicator_width5 1
#property indicator_width6 1
#property indicator_width7 1
#property indicator_width8 1
#property indicator_width9 1
#property indicator_width10 1
#property indicator_width11 1
 

 

 
 
extern int Length=64; 
 

extern string Custom_Indicator = "Murray math levels";
 
double L1[];
double L2[];
double L3[];
double L4[];
double L5[];
double L6[];
double L7[];
double L8[]; 
double L9[];
double L10[];
double L11[]; 

int init() {
 
 
   IndicatorBuffers(11);
	
   SetIndexBuffer(0, L1); 
   SetIndexStyle(0, DRAW_LINE); 

   SetIndexBuffer(1, L2); 
   SetIndexStyle(1, DRAW_LINE); 
   
   SetIndexBuffer(2, L3); 
   SetIndexStyle(2, DRAW_LINE); 
   
   SetIndexBuffer(3, L4); 
   SetIndexStyle(3, DRAW_LINE); 
   
 
   SetIndexBuffer(4, L5); 
   SetIndexStyle(4, DRAW_LINE); 

   SetIndexBuffer(5, L6); 
   SetIndexStyle(5, DRAW_LINE); 
   
   SetIndexBuffer(6, L7); 
   SetIndexStyle(6, DRAW_LINE); 
   
   SetIndexBuffer(7, L8); 
   SetIndexStyle(7, DRAW_LINE);
   
    SetIndexBuffer(8, L9); 
   SetIndexStyle(8, DRAW_LINE);
   
   SetIndexBuffer(9, L10); 
   SetIndexStyle(9, DRAW_LINE);
   
    SetIndexBuffer(10, L11); 
   SetIndexStyle(10, DRAW_LINE);
   
   
   return (0);
}

int deinit() {
   return (0);
}

int start() {
 
 
   if (Bars <= Length) return (0);
   double gi_116 = IndicatorCounted();
   if (gi_116 < 0) return (-1);
   if (gi_116 > 0) gi_116--;
 
   int pos;
   double Min, Max;
   int Min_Index, Max_Index;
   double Delta;
   
   for (pos = Bars - gi_116 - 1; pos >= 0; pos--) {
    
    Max_Index=iHighest(NULL,0,MODE_CLOSE,Length,pos);
	Min_Index=iLowest(NULL,0,MODE_CLOSE,Length,pos);
	
	Min= Close[Min_Index];
	Max= Close[Max_Index];
	
	Delta=(Max-Min)/8;
	
	L2[pos]= Min;
	L10[pos]= Max;
	
	L1[pos]= Min-Delta;
	L2[pos]= Min;
	L3[pos]= Min+1*Delta;
	L4[pos]= Min+2*Delta;
	L5[pos]= Min+3*Delta;
	L6[pos]= Min+4*Delta;
	L7[pos]= Min+5*Delta;
	L8[pos]= Min+6*Delta;
	L9[pos]= Min+7*Delta;
	L10[pos]= Min+8*Delta;
	L11[pos]= Min+9*Delta;
	
	L11[pos]= Max+Delta;
	

	   
   }
   
   
   return (0);
}
 