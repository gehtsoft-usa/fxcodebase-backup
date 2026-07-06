// Id:  
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
#property version   "1.1"
#property strict

#property indicator_separate_window
#property indicator_buffers 8
#property indicator_color1 Red
#property indicator_color2 Green
#property indicator_color3 Blue
#property indicator_color4 Yellow
#property indicator_color5 Brown
#property indicator_color6 Pink
#property indicator_color7 Lime
#property indicator_color8 Gold

class SymbolData
{
public:
   string Symbol;
   int Side;
};
class LineData
{
public:
   string Currency;
   double Line[];
   SymbolData* Symbols[];

   ~LineData()
   {
      for (int i = 0; i < ArraySize(Symbols); ++i)
      {
         delete Symbols[i];
      }
      ArrayResize(Symbols, 0);
   }
};
LineData* lines[];
 
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

LineData* CreateLine(int id, string name)
{
   LineData* line = new LineData();
   line.Currency = name;
   SetIndexStyle(id, DRAW_LINE);
   SetIndexBuffer(id, line.Line);
   SetIndexLabel(id, name);
   CreateSymbolList(line);
   return line;
}

int init()
{
   IndicatorName = GenerateIndicatorName("Symbol Strength");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   
   IndicatorBuffers(8);
   
   IndicatorDigits(Digits);

   int size = ArraySize(lines);
   ArrayResize(lines, size + 8);
   lines[0] = CreateLine(0, "USD");
   lines[1] = CreateLine(1, "EUR");
   lines[2] = CreateLine(2, "GBP");
   lines[3] = CreateLine(3, "JPY");
   lines[4] = CreateLine(4, "CHF");
   lines[5] = CreateLine(5, "AUD");
   lines[6] = CreateLine(6, "NZD");
   lines[7] = CreateLine(7, "CAD");
    
   return(0);
}

int deinit()
{
   for (int i = 0; i < ArraySize(lines); ++i)
   {
      delete lines[i];
   }
   ArrayResize(lines, 0);
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
      for (int i = 0; i < ArraySize(lines); ++i)
      {
         LineData* line = lines[i];
         double value = 0;
         int symbolsCount = ArraySize(line.Symbols);
         for (int index = 0; index < symbolsCount; index++)
         {
            SymbolData* symbolData = line.Symbols[index];
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
         line.Line[pos] = value / symbolsCount;
      }
      
      pos--;
   } 
 
   return(0);
}

void CreateSymbolList(LineData* line)
{
   string Currencies[] = {"AED", "AUD", "BHD", "BRL", "CAD", "CHF", "CNY", "CYP", "CZK", "DKK", "DZD", "EEK", "EGP", "EUR", "GBP", "HKD", "HRK", "HUF", "IDR", "ILS", "INR", "IQD", "IRR", "ISK", "JOD", "JPY", "KRW", "KWD", "LBP", "LTL", "LVL", "LYD", "MAD", "MXN", "MYR", "NOK", "NZD", "OMR", "PHP", "PLN", "QAR", "RON", "RUB", "SAR", "SEK", "SGD", "SKK", "SYP", "THB", "TND", "TRY", "TWD", "USD", "VEB", "XAG", "XAU", "YER", "ZAR"};
   int CurrencyCount = ArrayRange(Currencies, 0);
   int SymbolCount = 0;
   for (int Loop = 0; Loop < CurrencyCount; Loop++)
   {
      for (int SubLoop = 0; SubLoop < CurrencyCount; SubLoop++)
      {
         if (Currencies[Loop] == line.Currency
            || Currencies[SubLoop] == line.Currency)
         {
            string symbol = Currencies[Loop] + Currencies[SubLoop];
            if(MarketInfo(symbol, MODE_BID) > 0)
            {
               ArrayResize(line.Symbols, SymbolCount + 1);
               line.Symbols[SymbolCount] = new SymbolData();
               line.Symbols[SymbolCount].Symbol = symbol;
               line.Symbols[SymbolCount].Side = Currencies[Loop] == line.Currency ? 1 : -1;
               SymbolCount++;
            }
         }
      }
   }
 
   return;
}