// Id: 
// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=67145

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
#property indicator_label1 "CVI"

 
extern bool Invert  = false;
extern string Currency = "USD"; // Currency

double out[];

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
   IndicatorName = GenerateIndicatorName("CUMULATIVE VOLUME INDEX");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);

   IndicatorDigits(Digits);
   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(0, out);

   return 0;
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return(0);
}

int start()
{
   if (Bars <= 1) 
      return 0;
   int ExtCountedBars = IndicatorCounted();
   if (ExtCountedBars < 0) 
      return -1;
   int limit = Bars - 1;
   if(ExtCountedBars > 1) 
      limit = Bars - ExtCountedBars - 1;
   int pos = limit;
   while (pos >= 0)
   {
      double advancing = 0;
      double declining = 0;
      for (int i = 0; i < SymbolsTotal(false); ++i)
      {
         string symbol = SymbolName(i, false);
         int posInName = StringFind(symbol, Currency);
         if (posInName < 0)
            continue;
         int index = iBarShift(symbol, PERIOD_CURRENT, Time[pos], true);
         if (index < 0 || iBars(symbol, PERIOD_CURRENT) - 1 <= index)
            continue;
            
         if (posInName == 0)
         {
            if (iClose(symbol, PERIOD_CURRENT, index) > iClose(symbol, PERIOD_CURRENT, index + 1))
            {
               advancing += (double)iVolume(symbol, PERIOD_CURRENT, index);
            }
            else
            {
               declining += (double)iVolume(symbol, PERIOD_CURRENT, index);
            }
         }
         else
         {
            if (iClose(symbol, PERIOD_CURRENT, index) > iClose(symbol, PERIOD_CURRENT, index + 1))
            {
               declining += (double)iVolume(symbol, PERIOD_CURRENT, index);
            }
            else
            {
               advancing += (double)iVolume(symbol, PERIOD_CURRENT, index);
            }
         }
      }
      if (pos == limit)
	  {
	  
	     if (Invert) 
		 {
		  out[pos] = ( declining-advancing);
		 }
		 else
		 {
         out[pos] = (advancing - declining);
		 }
	  }
      else
	  { 
	      if (Invert) 
		 {
		 out[pos] = out[pos + 1] + (declining-advancing);
		 }
		 else
		 {
         out[pos] = out[pos + 1] + (advancing - declining);
		 }
	  }
		 
	 

      pos--;
	  
	  
   } 
   return 0;
}
