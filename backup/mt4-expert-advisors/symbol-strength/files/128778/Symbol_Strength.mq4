// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=68939

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
#property indicator_buffers 1
#property indicator_color1 Red

enum CurrencyPairs
{ 
   USD = 1,
   EUR = 2,
   GBP = 3,
   JPY = 4,
   CHF = 5,
   AUD = 6,
   NZD = 7,
   CAD = 8,
   ANY = 9
};
string Default[] = { "USD", "EUR", "GBP","JPY", "CHF",  "AUD", "NZD", "CAD", "Any" };

input  CurrencyPairs Selected = USD; // Currency
 
double Line[];
class SymbolData
{
public:
   string Symbol;
   int Side;
};
SymbolData* Symbols[];
 
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
   IndicatorName = GenerateIndicatorName("Symbol Strength");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   
   IndicatorBuffers(1);
   
   IndicatorDigits(Digits);
   
   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(0, Line);
   SetIndexLabel(0, Default[Selected - 1]);
   
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
   if (Bars <= 1) 
      return 0;
   int ExtCountedBars = IndicatorCounted();
   if (ExtCountedBars < 0) 
      return -1;
   int limit = Bars - 2;
   if (ExtCountedBars > 1) 
      limit = Bars - ExtCountedBars;
   int pos = limit;
   int symbolsCount = ArraySize(Symbols);
   while (pos >= 0)
   {
      double value = 0;
      for (int index = 0; index < symbolsCount; index++)
      {
         SymbolData* symbolData = Symbols[index];
         double day_high = iHigh(symbolData.Symbol, _Period, pos);
         double day_low = iLow(symbolData.Symbol, _Period, pos);
         double curr_bid = iClose(symbolData.Symbol, _Period, pos);
         double bid_ratio = day_high - day_low == 0 ? 0 : (curr_bid - day_low) / (day_high - day_low);
         int strength = 0;
         if (bid_ratio >= 0.97)
            strength = 9;
         else if (bid_ratio >= 0.90)
            strength = 8;
         else if (bid_ratio >= 0.75)
            strength = 7;
         else if (bid_ratio >= 0.60)
            strength = 6;
         else if (bid_ratio >= 0.50)
            strength = 5;
         else if (bid_ratio >= 0.40)
            strength = 4;
         else if (bid_ratio >= 0.25)
            strength = 3;
         else if (bid_ratio >= 0.10)
            strength = 2;
         else if (bid_ratio >= 0.03)
            strength = 1;
         value += symbolData.Side == 1 ? strength : 9 - strength;
      }
      Line[pos] = value / symbolsCount;
      pos--;
   } 
 
   return(0);
}

void CreateSymbolList()
{
   string Currencies[] = {"AED", "AUD", "BHD", "BRL", "CAD", "CHF", "CNY", "CYP", "CZK", "DKK", "DZD", "EEK", "EGP", "EUR", "GBP", "HKD", "HRK", "HUF", "IDR", "ILS", "INR", "IQD", "IRR", "ISK", "JOD", "JPY", "KRW", "KWD", "LBP", "LTL", "LVL", "LYD", "MAD", "MXN", "MYR", "NOK", "NZD", "OMR", "PHP", "PLN", "QAR", "RON", "RUB", "SAR", "SEK", "SGD", "SKK", "SYP", "THB", "TND", "TRY", "TWD", "USD", "VEB", "XAG", "XAU", "YER", "ZAR"};
   int CurrencyCount = ArrayRange(Currencies, 0);
   int SymbolCount = 0;
   for (int Loop = 0; Loop < CurrencyCount; Loop++)
   {
      for (int SubLoop = 0; SubLoop < CurrencyCount; SubLoop++)
      {
         if (Currencies[Loop] == Default[Selected - 1] 
            || Currencies[SubLoop] == Default[Selected - 1] 
            || Default[Selected - 1] == "Any")
         {
            string symbol = Currencies[Loop] + Currencies[SubLoop];
            if(MarketInfo(symbol, MODE_BID) > 0)
            {
               ArrayResize(Symbols, SymbolCount + 1);
               Symbols[SymbolCount] = new SymbolData();
               Symbols[SymbolCount].Symbol = symbol;
               Symbols[SymbolCount].Side = Currencies[Loop] == Default[Selected - 1] ? 1 : -1;
               SymbolCount++;
            }
            
			}
      }
   }
 
   return;
}