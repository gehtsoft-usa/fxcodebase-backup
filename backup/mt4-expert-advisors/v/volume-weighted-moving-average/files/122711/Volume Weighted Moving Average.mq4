// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=67144

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

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Green
#property indicator_color2 Red

#property indicator_label1 "Oscillator"

enum MA_Types{ SMA=1,  EMA=2, SMMA=3,LWMA=4 };
 
input  MA_Types MA_Type = SMA;
 

 
extern int Price_MA_Period = 50; 
extern int Volume_MA_Period = 70; 
 
double PV[]; 
double VWMA[];
double PMA[];
double VolumeArray[];
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
  

   IndicatorName = GenerateIndicatorName("Volume Weighted Moving Average");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   
   IndicatorBuffers(4);
   
   
   IndicatorDigits(Digits);
   
    
   
   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(0, VWMA);
   SetIndexLabel(0,"VWMA");
   SetIndexDrawBegin(0,Volume_MA_Period);
   
   
   SetIndexStyle(1, DRAW_LINE);
   SetIndexBuffer(1, PMA);
   SetIndexLabel(1,"PMA");
   SetIndexDrawBegin(1,Price_MA_Period);
   
   SetIndexStyle(2, DRAW_NONE);
   SetIndexBuffer(2, PV);
   
   SetIndexStyle(3, DRAW_NONE);
   SetIndexBuffer(3, VolumeArray);
   
   
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
      PV[pos]=Close[pos]*Volume[pos];
	  PMA[pos]= iMA(NULL,0,Price_MA_Period,0,(MA_Type-1),PRICE_CLOSE,pos);
	  
	  VolumeArray[pos]=Volume[pos];
	  
      pos--;
   } 
   
   double VSum=0;
   double PVSum=0;
     
   
   pos = limit;
   while (pos >= 0)
   {  
   
   
        
		PVSum=iMAOnArray(PV,0,Volume_MA_Period,0,MODE_SMA,pos)*Volume_MA_Period;
		VSum =iMAOnArray(VolumeArray,0,Volume_MA_Period,0,MODE_SMA,pos)*Volume_MA_Period;
 
			
		
	   
   
      if (VSum != 0 ) 
	 {
	 VWMA[pos]=PVSum / VSum;
	 } 
	 
	  
      pos--;
   } 
   
 
   return(0);
}



 
