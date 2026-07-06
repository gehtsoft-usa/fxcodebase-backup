// Id: 23764
// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=67304

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

#property copyright "Copyright © 2018, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.1"
#property strict

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Green

#property indicator_level1 0
      
#property indicator_levelcolor Red
#property indicator_levelwidth 2
#property indicator_levelstyle STYLE_DOT
 
extern int Length = 20;

enum CurrencyPairs{ USD=1,  EUR=2, GBP=3,JPY=4, CHF=5,  AUD=6, NZD=7, CAD=8, ANY= 9};
 
input  CurrencyPairs Selected = USD;
 
#property indicator_label1 "Beta Coefficient" 
 
 
string Default[] ={"USD", "EUR", "GBP","JPY", "CHF",  "AUD", "NZD", "CAD", "Any"};
double Line[];
string Symbols[];
int SymbolCount;
 
string IndicatorName;
string IndicatorObjPrefix;
string AllPairs[]; 

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
   IndicatorName = GenerateIndicatorName("Beta Coefficient");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   
   IndicatorBuffers(1);
   
   IndicatorDigits(Digits);
   
   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(0, Line);
   SetIndexLabel(0,"Beta");
   SetIndexDrawBegin(0,0);
   
   CreateSymbolList();
    
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
   int limit = Bars - 2;
   
   if(ExtCountedBars > 1) limit = Bars - ExtCountedBars;
   int pos = limit;
   
   ArrayCopy(AllPairs, Symbols); 
 
   while (pos >= 0)
   {
      double Value=0;
      double Count=0;
 
      for(int x = 0; x < ArraySize(AllPairs); x++)
      {
         if (iBars(AllPairs[x], 0) - 1 < pos)
            continue;
         Value=Value+iStdDev(AllPairs[x],0,Length,0,MODE_SMA,PRICE_CLOSE,pos);
         Count=Count+1;
      }
      if (Count!=0 && Value!=0 )
         Line[pos]=iStdDev(NULL,0,Length,0,MODE_SMA,PRICE_CLOSE,pos)/(Value/Count);
      else
         Line[pos]=0;
      pos--;
   } 
 
   return(0);
}


 //+------------------------------------------------------------------+
//| Creates the array of pair symbols to check                       |
//+------------------------------------------------------------------+   
void CreateSymbolList()
  {
  
  //CurrencyPairs 
  // Selected ;
   string allsyms;
   string Currencies[] = {"AED", "AUD", "BHD", "BRL", "CAD", "CHF", "CNY", "CYP", "CZK", "DKK", "DZD", "EEK", "EGP", "EUR", "GBP", "HKD", "HRK", "HUF", "IDR", "ILS", "INR", "IQD", "IRR", "ISK", "JOD", "JPY", "KRW", "KWD", "LBP", "LTL", "LVL", "LYD", "MAD", "MXN", "MYR", "NOK", "NZD", "OMR", "PHP", "PLN", "QAR", "RON", "RUB", "SAR", "SEK", "SGD", "SKK", "SYP", "THB", "TND", "TRY", "TWD", "USD", "VEB", "XAG", "XAU", "YER", "ZAR"};
   int CurrencyCount = ArrayRange(Currencies, 0);
   int Loop, SubLoop;
   string TempSymbol;
   for(Loop = 0; Loop < CurrencyCount; Loop++)
       for(SubLoop = 0; SubLoop < CurrencyCount; SubLoop++)
         {
		 
		     if (Currencies[Loop]== Default[Selected-1] || Currencies[SubLoop]==  Default[Selected-1] ||     Default[Selected-1] == "Any")
			 {
				   TempSymbol = Currencies[Loop] + Currencies[SubLoop];
				   if(MarketInfo(TempSymbol, MODE_BID) > 0)
					 {
					   ArrayResize(Symbols, SymbolCount + 1);
					   Symbols[SymbolCount] = TempSymbol;
					   allsyms = allsyms + TempSymbol +"n";
					   SymbolCount++;
					 }
					 
				   TempSymbol = Currencies[Loop] + Currencies[SubLoop] +"m";
				   if(MarketInfo(TempSymbol, MODE_BID) > 0)
					 {
					   ArrayResize(Symbols, SymbolCount + 1);
					   Symbols[SymbolCount] = TempSymbol;
					   allsyms = allsyms + TempSymbol +"n";
					   SymbolCount++;
					 }
			}		 
         }
 
    return;
  }
   
