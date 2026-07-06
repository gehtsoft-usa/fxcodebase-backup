// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=68174

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
#property indicator_buffers 1
#property indicator_color1 clrLawnGreen
 
#property indicator_levelcolor clrYellow
#property indicator_levelwidth 1
#property indicator_levelstyle STYLE_DOT

 
 
 
#property indicator_width1 1
 
 
extern int ADX_Period=14;
extern int RSI_Period=14;
extern double weightingPC=80;
extern int ADX_Min=23;
extern int ADX_Max=70; 
 
extern double OB_Level     = 70;
extern double OS_Level     = 30;

extern string Custom_Indicator = "ADX Weighted RSI";
 
double Data[];  
double adxRange;
double weighting;

int init() {
 
 
   IndicatorBuffers(1);
	
   adxRange = (ADX_Max-ADX_Min);
   weighting = weightingPC / 100;
   
   SetIndexBuffer(0, Data); 
   SetIndexStyle(0, DRAW_LINE); 
 
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
   
   double ADX, RSI,ADXR,ADX_Shift,rZero,a,aNorm;
   
   
   for (int pos = Bars - gi_116 - 1; pos >= 0; pos--) {
    
   
	ADX= iADX(NULL,0,ADX_Period,0,MODE_MAIN,pos);
	ADX_Shift= iADX(NULL,0,ADX_Period,0,MODE_MAIN,pos+ADX_Period);
	RSI=iRSI(NULL,0,RSI_Period,PRICE_CLOSE,pos);
	ADXR = (ADX + ADX_Shift) / 2;
	
		if (ADX< ADXR)
		{
		 Data[pos]=RSI;
		}
		else
		{
			rZero = RSI-50;                                            
			a = MathMin(ADX_Max, MathMax(ADX_Min, ADX));  
			if(adxRange!=0)
			{		
			aNorm = 1- ( (((a-ADX_Min)/adxRange) / 1.5  ) * weighting );  
			}
			
			Data[pos] = (rZero * aNorm) + 50;              
	    }
	   
   }
   return (0);
}