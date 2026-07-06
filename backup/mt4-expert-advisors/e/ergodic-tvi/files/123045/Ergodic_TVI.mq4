// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=67206

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
#property indicator_buffers 2
#property indicator_color1 C'255, 255, 0'
#property indicator_label1 "ETVI"
#property indicator_color2 C'255, 0, 0'
#property indicator_label2 "Signal"

extern int Period1 = 12; // Period 1
extern int Period2 = 12; // Period 2
extern int Period3 = 1; // Period 3
extern int EPeriod1 = 5; // Ergodic period 1
extern int EPeriod2 = 5; // Ergodic period 2
extern int EPeriod3 = 5; // Ergodic period 3

double ETVI[], Signal[];

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

double UpTicks[], DnTicks[], TV[], TVI[], EMA_Up1[], EMA_Dn1[], EMA_TVI1[];

int init()
{
   IndicatorName = GenerateIndicatorName("Ergodic Tick volume indicator");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   IndicatorDigits(Digits);
   IndicatorBuffers(9);
   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(0, ETVI);
   SetIndexStyle(1, DRAW_LINE);
   SetIndexBuffer(1, Signal);

   SetIndexBuffer(2, UpTicks);
   SetIndexBuffer(3, DnTicks);
   SetIndexBuffer(4, TV);
   SetIndexBuffer(5, TVI);
   SetIndexBuffer(6, EMA_Up1);
   SetIndexBuffer(7, EMA_Dn1);
   SetIndexBuffer(8, EMA_TVI1);

   return(0);
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return(0);
}

// Instrument info v.1.1
class InstrumentInfo
{
   string _symbol;
   double _mult;
   double _point;
   double _pipSize;
   int _digits;
   double _tickSize;
public:
   InstrumentInfo(const string symbol)
   {
      _symbol = symbol;
      _point = MarketInfo(symbol, MODE_POINT);
      _digits = (int)MarketInfo(symbol, MODE_DIGITS); 
      _mult = _digits == 3 || _digits == 5 ? 10 : 1;
      _pipSize = _point * _mult;
      _tickSize = MarketInfo(_symbol, MODE_TICKSIZE);
   }
   
   static double GetBid(const string symbol) { return MarketInfo(symbol, MODE_BID); }
   double GetBid() { return GetBid(_symbol); }
   static double GetAsk(const string symbol) { return MarketInfo(symbol, MODE_ASK); }
   double GetAsk() { return GetAsk(_symbol); }
   double GetPipSize() { return _pipSize; }
   string GetSymbol() { return _symbol; }
   double GetSpread() { return (GetAsk() - GetBid()) / GetPipSize(); }
   int GetDigits() { return _digits; }
   double GetTickSize() { return _tickSize; }

   double RoundRate(const double rate)
   {
      return NormalizeDouble(MathCeil(rate / _tickSize + 0.5) * _tickSize, _digits);
   }
};


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
   InstrumentInfo instrument(_Symbol);
   int pos = limit;
   while (pos >= 0)
   {
      UpTicks[pos] = (Volume[pos] + (Close[pos] - Open[pos]) / instrument.GetPipSize()) / 2;
      DnTicks[pos] = Volume[pos] - UpTicks[pos];
      EMA_Up1[pos] = iMAOnArray(UpTicks, 0, Period1, 0, MODE_EMA, pos);
      EMA_Dn1[pos] = iMAOnArray(DnTicks, 0, Period1, 0, MODE_EMA, pos);
      double EMA_Up2 = iMAOnArray(EMA_Up1, 0, Period2, 0, MODE_EMA, pos);
      double EMA_Dn2 = iMAOnArray(EMA_Dn1, 0, Period2, 0, MODE_EMA, pos);
      double sum = EMA_Up2 + EMA_Dn2;
      TV[pos] = sum != 0 ? 100 * (EMA_Up2 - EMA_Dn2) / sum : 0;
      TVI[pos] = iMAOnArray(TV, 0, Period3, 0, MODE_EMA, pos);
      EMA_TVI1[pos] = iMAOnArray(TVI, 0, EPeriod1, 0, MODE_EMA, pos);
      ETVI[pos] = iMAOnArray(EMA_TVI1, 0, EPeriod2, 0, MODE_EMA, pos);
      Signal[pos] = iMAOnArray(ETVI, 0, EPeriod3, 0, MODE_EMA, pos);

      pos--;
   } 
   return 0;
}

