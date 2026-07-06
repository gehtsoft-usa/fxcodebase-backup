// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=68922

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
#property indicator_color1 Green

#property indicator_level1 0
      
#property indicator_levelcolor Red
#property indicator_levelwidth 2
#property indicator_levelstyle STYLE_DOT
 
extern int Length = 20;
enum AveragesMethod
{
   SMA = MODE_SMA, // SMA
   EMA = MODE_EMA, // EMA
   SMMA = MODE_SMMA, // SMMA
   LWMA = MODE_LWMA, // LWMA
   WMA,
   SineWMA,
   TriMA,
   LSMA,
   HMA,
   ZeroLagEMA,
   DEMA,
   T3MA,
   ITrend,
   Median,
   GeoMean,
   REMA,
   ILRS,
   IE2,
   TriMAgen,
   JSmooth
};
input AveragesMethod avg_method = SMA; // Method

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
   double temp = iCustom(NULL, 0, "averages", 0, 0);
   if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
   {
      Alert("Please, install the 'averages' indicator");
      return INIT_FAILED;
   }
   IndicatorName = GenerateIndicatorName("% Avobe average");
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
    while (pos >= 0)
   {
  
 
      double aboveCount = 0;
      double value = 0;
      for (int index = 0; index < ArraySize(Symbols); index++)
      {
         SymbolData* symbolData = Symbols[index];
         int index = iBarShift(symbolData.Symbol, _Period, Time[pos]);
         double value = iCustom(symbolData.Symbol, _Period, "averages", Length, avg_method, 0, index);
         bool above = iClose(symbolData.Symbol, _Period, index) > value;
         if ((above && symbolData.Side == 1) || (!above && symbolData.Side == -1))
            ++aboveCount;
      }
      Line[pos] = aboveCount / ArraySize(Symbols) * 100;
      pos--;
    } 
 
   return(0);
}

void CreateSymbolList()
{
   string Currencies[] = {"AED", "AUD", "BHD", "BRL", "CAD", "CHF", "CNY", "CYP", "CZK", "DKK", "DZD", "EEK", "EGP", "EUR", "GBP", "HKD", "HRK", "HUF", "IDR", "ILS", "INR", "IQD", "IRR", "ISK", "JOD", "JPY", "KRW", "KWD", "LBP", "LTL", "LVL", "LYD", "MAD", "MXN", "MYR", "NOK", "NZD", "OMR", "PHP", "PLN", "QAR", "RON", "RUB", "SAR", "SEK", "SGD", "SKK", "SYP", "THB", "TND", "TRY", "TWD", "USD", "VEB", "XAG", "XAU", "YER", "ZAR"};
   int CurrencyCount = ArrayRange(Currencies, 0);
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
               int SymbolCount = ArraySize(Symbols);
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
   
