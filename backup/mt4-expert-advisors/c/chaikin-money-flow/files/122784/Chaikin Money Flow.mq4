// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=67159

//+------------------------------------------------------------------+
//|                               Copyright © 2018, Gehtsoft USA LLC | 
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

#property copyright "Copyright © 2018, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.0"
#property strict

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Green

#property indicator_level1 0
      
#property indicator_levelcolor Red
#property indicator_levelwidth 2
#property indicator_levelstyle STYLE_DOT
 

#property indicator_label1 "Chaikin Money Flow" 
 
extern int Indicator_Period = 21; 
 
 
double AD[];
double CMF[];
double VOLUME[]; 

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
  

   IndicatorName = GenerateIndicatorName("Chaikin Money Flow");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   
   IndicatorBuffers(3);
   
   
   IndicatorDigits(Digits);
   
    
   
   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(0, CMF);
   SetIndexLabel(0,"Chaikin Money Flow");
   SetIndexDrawBegin(0,Indicator_Period);
   
   
 
   
   SetIndexStyle(1 ,DRAW_NONE);
   SetIndexBuffer(1, AD);
   
   SetIndexStyle(2 ,DRAW_NONE);
   SetIndexBuffer(2, VOLUME);
   
   
  // SetLevelValue(1,0);
   
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
   int limit = Bars - 1;
   if(ExtCountedBars > 1) limit = Bars - ExtCountedBars - 1;
   int pos = limit;
   while (pos >= 0)
   {
      AD[pos]=iAD(NULL, 0, pos); 
	  VOLUME[pos]=Volume[pos]; 
	  
      pos--;
   } 
   
   
  
   pos = limit;
   while (pos >= 0)
   {  
   
   
        
		double a=iMAOnArray(AD,0,Indicator_Period,0,MODE_SMA,pos)*Indicator_Period;
		double b=iMAOnArray(VOLUME,0,Indicator_Period,0,MODE_SMA,pos)*Indicator_Period;
		
		if (b != 0)
		{
            CMF[pos] = a / b;
		}	
        else
		{
            CMF[pos] = 0;
        }
  
      pos--;
   } 
   
 
   return(0);
}



 
