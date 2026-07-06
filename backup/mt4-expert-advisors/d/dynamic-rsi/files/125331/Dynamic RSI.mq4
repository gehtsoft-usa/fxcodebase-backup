// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=68175

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
#property indicator_color1 clrRed
#property indicator_color2 clrRed
#property indicator_color3 clrGreen
#property indicator_color4 clrBlue
 
#property indicator_width1 1
#property indicator_width2 1
#property indicator_width3 1
#property indicator_width4 1

#property indicator_levelcolor clrYellow
#property indicator_levelwidth 1
#property indicator_levelstyle STYLE_DOT
 
 
extern int Look_Back_Length=60;
extern int RSI_Period=14;
extern double Buy_Zone_Probability=0.1;
extern double Sell_Zone_Probability=0.1; 

enum MA_Types{ SMA=1,  EMA=2, SMMA=3,LWMA=4 };
 
input  MA_Types MA_Type = SMA;
 
extern double OB_Level     = 70;
extern double OS_Level     = 30;
 

extern string Custom_Indicator = "Dynamic RSI";
 
double Top[];
double Bottom[];
double Central[]; 
double RSI[]; 
double Min_Data[];
double Range_Data[];   
double RSI_Data[]; 

int init() {
 
 
   IndicatorBuffers(7);
	
   SetIndexBuffer(0, Top); 
   SetIndexStyle(0, DRAW_LINE); 

   SetIndexBuffer(1, Bottom); 
   SetIndexStyle(1, DRAW_LINE); 
   
   SetIndexBuffer(2, Central); 
   SetIndexStyle(2, DRAW_LINE); 
   
   SetIndexBuffer(3, RSI); 
   SetIndexStyle(3, DRAW_LINE); 
   
   SetIndexBuffer(4, Min_Data);
   SetIndexBuffer(5, Range_Data);
   SetIndexBuffer(6, RSI_Data);
   
   SetLevelValue(1,OB_Level);
   SetLevelValue(2,OS_Level);
   
   
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
    
    RSI_Data[pos]=iRSI(NULL,0,RSI_Period,PRICE_CLOSE,pos); 
	   
   }
   
   double maxValue, minValue,MA_Range, MA_Min;
   for (pos = Bars - gi_116 - 1; pos >= 0; pos--) {
  
    maxValue=maxValue(RSI_Data,Look_Back_Length, pos); 
	minValue=minValue(RSI_Data,Look_Back_Length, pos);
	
	Min_Data[pos]=minValue;
	Range_Data[pos]=maxValue-minValue;
	
	MA_Min= iMAOnArray(Min_Data,0,RSI_Period,0,(MA_Type-1),pos);
	MA_Range=iMAOnArray(Range_Data,0,RSI_Period,0,(MA_Type-1),pos);
	
	Central[pos] = (MA_Range*0.50)+MA_Min;
    Top[pos] = maxValue-Central[pos]*Buy_Zone_Probability;
    Bottom[pos] = minValue+Central[pos]*Sell_Zone_Probability;
    
    RSI[pos]=( 4 * RSI_Data[pos] + 3 * RSI_Data[pos+1] + 2 * RSI_Data[pos+2] + RSI_Data[pos+3] ) / 10	;
	
	
	   
   }
   return (0);
}

double maxValue(double &arrayToSearch[], int count, int start){  
 
   int indexMaxValueOfArray = ArrayMaximum(arrayToSearch, count, start);  
 
   return(arrayToSearch[indexMaxValueOfArray]); 
 
}

double minValue(double &arrayToSearch[], int count, int start){  
 
   int indexMinValueOfArray = ArrayMinimum(arrayToSearch, count, start);  
 
   return(arrayToSearch[indexMinValueOfArray]); 
 
}