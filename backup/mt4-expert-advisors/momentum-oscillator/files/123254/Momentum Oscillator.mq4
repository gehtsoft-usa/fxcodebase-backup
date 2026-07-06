// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=67247

//+------------------------------------------------------------------+
//|                               Copyright © 2019, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |
//|                                          mario.jemic@gmail.com   |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  |
//|                                  Paypal : https://goo.gl/9Rj74e  |
//+------------------------------------------------------------------+
//|                                Patreon :  https://goo.gl/GdXWeN  |
//|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
//|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
//|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
//|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2019, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.0"
#property strict

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Green
#property indicator_color2 Red

#property indicator_level1 0
      
	  
	  
#property indicator_levelcolor Red
#property indicator_levelwidth 2
#property indicator_levelstyle STYLE_DOT
 

#property indicator_label1 "Momentum Oscillator" 
 
enum MA_Types1{ SMA1=1,  EMA1=2, SMMA1=3,LWMA1=4,VWMA=5 };
enum MA_Types2{ SMA2=1,  EMA2=2, SMMA2=3,LWMA2=4 }; 
input  MA_Types1 Short_MA_Type = SMA1;
extern int Short_MA_Period       = 2;

input  MA_Types1 Long_MA_Type = SMA1; 
extern int Long_MA_Period       = 10;

input  MA_Types2 Signal_MA_Type = SMA2;  
extern int Signal_MA_Period       = 10;

 
double Oscillator[];
double Signal[];
 
string IndicatorName;
string IndicatorObjPrefix;

string GenerateIndicatorName(const string target)
{
   string name = target;
   int try = 2;
   while (WindowFind(name) != -1)
   {
      name = target + " #" + IntegerToString(try++);
   }
   return name;
}

int init()
{
  

   IndicatorName = GenerateIndicatorName("Momentum Oscillator");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   
   IndicatorBuffers(2);
   
   
   IndicatorDigits(Digits);
   
    
   
   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(0, Oscillator);
   SetIndexLabel(0,"Oscillator");
   
   
 
   SetIndexStyle(1, DRAW_LINE);
   SetIndexBuffer(1, Signal);
   SetIndexLabel(1,"Signal");
   
   
             if (Short_MA_Type == 5 || Long_MA_Type == 5)	
			{
					double temp = iCustom(NULL, 0, "Volume Weighted Moving Average", 0, 0);
				if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
				{
				   Alert("Please, install the 'Volume Weighted Moving Average' indicator: http://fxcodebase.com/code/viewtopic.php?f=38&t=67144");
				   return INIT_FAILED;
				}
			}
			 
		 
 
 
    
   return(0);
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return(0);
}

int start()
{
   if (Bars <= 1) return(0);
   int ExtCountedBars = IndicatorCounted();
   if (ExtCountedBars < 0) return(-1);
   //int limit = Bars - 1;
   int limit = Bars - 2;
   
   if(ExtCountedBars > 1) limit = Bars - ExtCountedBars;
   int pos = limit;
 
   while (pos >= 0)
   {
   
    double Short_MA=0;
	double Long_MA=0;
	
            if (Short_MA_Type == 5)
			{
			Short_MA = iCustom(NULL, 0, "Volume Weighted Moving Average", 1, Short_MA_Period,Short_MA_Period,0,pos);
			}
			else
			{			
			Short_MA = iMA(NULL,0,Short_MA_Period,0,(Short_MA_Type-1),PRICE_CLOSE,pos);
			}
			
			 if (Long_MA_Type == 5)
			{
			Long_MA = iCustom(NULL, 0, "Volume Weighted Moving Average", 1, Long_MA_Period,Long_MA_Period,0,pos);
			}
			else
			{	
            Long_MA =  iMA(NULL,0,Long_MA_Period,0,(Long_MA_Type-1),PRICE_CLOSE,pos);
			}
			
			Oscillator[pos]=Short_MA-Long_MA;
	     
		 
	  
      pos--;
   } 
   
   pos = limit;
 
   while (pos >= 0)
   {
   
   
            double MA =iMAOnArray(Oscillator,0, Signal_MA_Period ,0,(Signal_MA_Type-1),pos);     
			 
			
			Signal[pos]=MA;
			 
		 
	  
      pos--;
   } 
   
 
  
 
   return(0);
}


 
