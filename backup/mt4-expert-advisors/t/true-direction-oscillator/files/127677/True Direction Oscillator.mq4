// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=68732

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
#property indicator_buffers 4
#property indicator_color1 clrBlue
#property indicator_color2 clrGreen
#property indicator_color3 clrRed
#property indicator_color4 clrGray
 
#property indicator_width1 1
#property indicator_width2 1
#property indicator_width3 1
#property indicator_width4 1

#property indicator_levelcolor clrYellow
#property indicator_levelwidth 1
#property indicator_levelstyle STYLE_DOT

  
extern int Period_1=10;
extern int Period_2=20;
extern int Period_3=40;
extern int Period_4=80;
extern int Period_5=160;
 
 
 

extern string Custom_Indicator = "True Direction Oscillator";
 
double Up[];   
double Down[];
double Neutral[];
double TDO[];

double Data1[];
double Data2[];
double Data3[];
double Data4[];
double Data5[];

int init() {
 
 
   IndicatorBuffers(9);
   
 

   SetIndexBuffer(0, TDO); 
   SetIndexStyle(0, DRAW_LINE); 
   
   SetIndexBuffer(1, Up); 
   SetIndexStyle(1, DRAW_HISTOGRAM); 

   SetIndexBuffer(2, Down); 
   SetIndexStyle(2, DRAW_HISTOGRAM); 
   
   SetIndexBuffer(3, Neutral); 
   SetIndexStyle(3, DRAW_HISTOGRAM); 
   

   
   SetIndexBuffer(4, Data1);
   SetIndexBuffer(5, Data2);
   SetIndexBuffer(6, Data3);
   SetIndexBuffer(7, Data4);
   SetIndexBuffer(8, Data5); 
   
 
   
   
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
 
   int pos;
   
   
   for (pos = Bars - gi_116 - 1; pos >= 0; pos--) {
    
 

       Data1[pos]=100*(Close[pos]-Close[pos+Period_1-1])/((Close[pos] + Close[pos+Period_1-1])/2);
	   Data2[pos]=100*(Close[pos]-Close[pos+Period_2-1])/((Close[pos] + Close[pos+Period_2-1])/2);
	   Data3[pos]=100*(Close[pos]-Close[pos+Period_3-1])/((Close[pos] + Close[pos+Period_3-1])/2);
	   Data4[pos]=100*(Close[pos]-Close[pos+Period_4-1])/((Close[pos] + Close[pos+Period_4-1])/2);
	   Data5[pos]=100*(Close[pos]-Close[pos+Period_5-1])/((Close[pos] + Close[pos+Period_5-1])/2);
	
	   
   }
   
   
    for (pos = Bars - gi_116 - 1; pos >= 0; pos--) {
	
	TDO[pos]=Data1[pos];
	Up[pos]=NULL;
	Down[pos]=NULL;
	Neutral[pos]=Data1[pos];
	
			if (Data1[pos] > 0 && Data2[pos] > 0  && Data3[pos] > 0 && Data4[pos] > 0  && Data5[pos] > 0)
			{
			Neutral[pos]=NULL;
			Up[pos]=Data1[pos];
			}
			
			if (Data1[pos] < 0 && Data2[pos] < 0  && Data3[pos] < 0 && Data4[pos] < 0  && Data5[pos] < 0)
			{
			Neutral[pos]=NULL;
			Down[pos]=Data1[pos];
			}
	
	 }
 
   return (0);
}

 
