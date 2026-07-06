// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=68576

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
 

#property indicator_label1 "Accumulation Distribution" 
 
 
extern double Up_Value       = 0.0001;
extern double Down_Value       = -0.0001;


 
double Accumulation[];
double Distribution[];
 
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
  

   IndicatorName = GenerateIndicatorName("Accumulation Distribution");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   
   IndicatorBuffers(2);
   
   
   IndicatorDigits(Digits);
   
    
   
   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(0, Accumulation);
   SetIndexLabel(0,"Accumulation");
   
   
 
   SetIndexStyle(1, DRAW_LINE);
   SetIndexBuffer(1, Distribution);
   SetIndexLabel(1,"Distribution");
   
   
 
 
    
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
   
   
   
    if (Close[pos] > Close[pos+1] )
	{
	Accumulation[pos]=MathAbs( Accumulation[pos+1]+Up_Value);
	}
	else
	{
	Accumulation[pos]=MathAbs( Accumulation[pos+1]+Down_Value);
	}
	
	if (Close[pos] < Close[pos+1]) 
	{
	Distribution[pos]=MathAbs( Distribution[pos+1]+Up_Value);
	}
	else
	{
	Distribution[pos]=MathAbs( Distribution[pos+1]+Down_Value);
	}
		 
	  
      pos--;
   } 
   
  
 
  
 
   return(0);
}


 
