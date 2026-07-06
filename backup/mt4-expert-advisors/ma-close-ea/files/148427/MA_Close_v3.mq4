// More information about this indicator can be found at:
// //https://fxcodebase.com/code/viewtopic.php?f=38&t=72964

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2022, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                        https://AppliedMachineLearning.systems  |
//|                                                                       https://mario-jemic.com/ |
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|                                           Our work would not be possible without your support. |
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal: https://goo.gl/9Rj74e    |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |  
//+------------------------------------------------------------------------------------------------+


#property copyright "Copyright © 2022, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
 

#property strict
#include <stderror.mqh>
#include <stdlib.mqh>

string file_custom_indicator = "Hull.ex4";
#define CONTROL_CUSTOM_INDICATOR_FILE

enum MA_METHOD {
   Simple,
   Exponential,
   Smoothed,
   Weighted,
   Hull
};

input string             Iema1                  = "== MA Setup ==";     // ————————————
input ENUM_TIMEFRAMES    ma_tf                  = PERIOD_CURRENT;       // Time frame:
input int                ma_Period       = 13;                          // Period
int                      ma_Shift        = 0;                           // Ma Shift
input MA_METHOD          ma_Method       = Hull;                        // Method
input ENUM_APPLIED_PRICE ma_AppliedPrice = PRICE_CLOSE;                 // Applied Price
input int                maSpeed         = 2;                           // Ma Speed (for HULL):
int    TimeFrame     = 0; // EA Operation timeframe (in minutes)
string TimeFrameInfo = "1=M1,5=M5,15=M15,30=M30,60=H1,240=H4,1440=D1,10080=W1,43200=MN,0=variable";
int    MAType        = 1;
string MATypeInfo    = "0=SMA,1=EMA,2=SMMA,3=LWMA";
int    MAPeriod      = 13;
int    MAPrice       = 0;
string MAPriceInfo   = "0=Close,1=Open,2=High,3=Low,4=Median,5=Typical,6=Weighted";
input bool   BarCheck      = true;
input string BarCheckInfo  = "true=checking previous bar close, false=checking latest price";
input bool   AlertMessage  = false; // shows alert message before closing a trade

double Tolerance     = 0.0000;
string ToleranceInfo = "How far the price is tolerated to break the MA";
int    Slippage      = 30000;
string SlippageInfo  = "Maximum deviation from the market price when closing the order (in points)";
double lastClose = -1;

// ------------------------------------------------------------------
interface iMovingAverages
{
  double index(int shift);
};
class MovingAverage : public iMovingAverages
{
  iMovingAverages* _ma;

 public:
  MovingAverage(iMovingAverages* inpEMA) { _ma = inpEMA; }
  ~MovingAverage() {delete _ma;}

  double index(int shift) { return _ma.index(shift); }
};
class MaSelector : public iMovingAverages
{
   iMovingAverages* _ma;

  public:
   MaSelector(MA_METHOD method, string symbol, ENUM_TIMEFRAMES tf, int Period, ENUM_APPLIED_PRICE AppliedPrice, double Speed=0)
   {
      switch(method)
      {
         case Simple:      _ma = new SMA_algo     (symbol, tf, Period, AppliedPrice); break;
         case Exponential: _ma = new EMA_algo     (symbol, tf, Period, AppliedPrice); break;
         case Smoothed:    _ma = new Smoothed_algo(symbol, tf, Period, AppliedPrice); break;
         case Weighted:    _ma = new Weighted_algo(symbol, tf, Period, AppliedPrice); break;
         case Hull:        _ma = new HULL_algo    (symbol, tf, Period, AppliedPrice, Speed); break;
      }
   }
   ~MaSelector() { ;}

   double index(int shift) { return _ma.index(shift); }   
};
class SMA_algo : public iMovingAverages
{
  string             _symbol;
  ENUM_TIMEFRAMES    _tf;
  int                _Period;        //  Period
  int                _MaShift;       //  Ma Shift
  ENUM_APPLIED_PRICE _AppliedPrice;  //  Applied Price

 public:
  SMA_algo(string symbol, ENUM_TIMEFRAMES tf, int Period, ENUM_APPLIED_PRICE AppliedPrice)
  {
    _symbol       = symbol;
    _tf           = tf;
    _Period       = Period;
    _MaShift      = 0;
    _AppliedPrice = AppliedPrice;
  }
  ~SMA_algo() { ; }

  double index(int shift)
  {
    return iMA(_symbol, _tf, _Period, _MaShift, MODE_SMA, _AppliedPrice, shift);
  }
};
class EMA_algo : public iMovingAverages
{
  string             _symbol;
  ENUM_TIMEFRAMES    _tf;
  int                _Period;        //  Period
  int                _MaShift;       //  Ma Shift
  ENUM_APPLIED_PRICE _AppliedPrice;  //  Applied Price

 public:
  EMA_algo(string symbol, ENUM_TIMEFRAMES tf, int Period, ENUM_APPLIED_PRICE AppliedPrice)
  {
    _symbol       = symbol;
    _tf           = tf;
    _Period       = Period;
    _MaShift      = 0;
    _AppliedPrice = AppliedPrice;
  }
  ~EMA_algo() { ; }

  double index(int shift)
  {
    return iMA(_symbol, _tf, _Period, _MaShift, MODE_EMA, _AppliedPrice, shift);
  }
};
class Smoothed_algo : public iMovingAverages
{
  string             _symbol;
  ENUM_TIMEFRAMES    _tf;
  int                _Period;        //  Period
  int                _MaShift;       //  Ma Shift
  ENUM_APPLIED_PRICE _AppliedPrice;  //  Applied Price

 public:
  Smoothed_algo(string symbol, ENUM_TIMEFRAMES tf, int Period, ENUM_APPLIED_PRICE AppliedPrice)
  {
    _symbol       = symbol;
    _tf           = tf;
    _Period       = Period;
    _MaShift      = 0;
    _AppliedPrice = AppliedPrice;
  }
  ~Smoothed_algo() { ; }

  double index(int shift)
  {
    return iMA(_symbol, _tf, _Period, _MaShift, MODE_SMMA, _AppliedPrice, shift);
  }
};
class Weighted_algo : public iMovingAverages
{
  string             _symbol;
  ENUM_TIMEFRAMES    _tf;
  int                _Period;        //  Period
  int                _MaShift;       //  Ma Shift
  ENUM_APPLIED_PRICE _AppliedPrice;  //  Applied Price

 public:
  Weighted_algo(string symbol, ENUM_TIMEFRAMES tf, int Period, ENUM_APPLIED_PRICE AppliedPrice)
  {
    _symbol       = symbol;
    _tf           = tf;
    _Period       = Period;
    _MaShift      = 0;
    _AppliedPrice = AppliedPrice;
  }
  ~Weighted_algo() { ; }

  double index(int shift)
  {
    return iMA(_symbol, _tf, _Period, _MaShift, MODE_LWMA, _AppliedPrice, shift);
  }
};
class HULL_algo : public iMovingAverages
{
   string             _symbol;
   ENUM_TIMEFRAMES    _tf;
   int                _Period;        //  Period
   int                _MaShift;       //  Ma Shift
   ENUM_APPLIED_PRICE _AppliedPrice;  //  Applied Price
   double             _Speed;

  public:
   HULL_algo(string symbol, ENUM_TIMEFRAMES tf, int Period, ENUM_APPLIED_PRICE AppliedPrice, double Speed)
   {
      _symbol                  = symbol;
      _tf                      = tf;
      _Period                  = Period;
      _MaShift                 = 0;
      _Speed                   = Speed;
      _AppliedPrice            = AppliedPrice;    
   }
    ~HULL_algo() { ;}

    double index(int shift)
    {
       return iCustom(_symbol, _tf, "Hull.ex4", _Period, _Speed, _AppliedPrice, 0, shift);
    }
};

MovingAverage* ma;

int OnInit()
{
	#ifdef CONTROL_CUSTOM_INDICATOR_FILE
  double temp = iCustom(NULL, 0, file_custom_indicator, 0, 0);
  if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
  {
    Alert("Please, install the: " + file_custom_indicator + " indicator");
    return INIT_FAILED;
  }
	#endif
	
	ma = new MovingAverage(new MaSelector(ma_Method, _Symbol, 0, ma_Period, ma_AppliedPrice, maSpeed));	

	return (INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{
	delete ma;
}

// ------------------------------------------------------------------
void OnTick()
{
   if(BarCheck) { if(iClose(NULL,TimeFrame,1) != lastClose) check(); }
   else         { if(Close[0] != lastClose) check(); }
}

void check()
{
   if(BarCheck) lastClose = iClose(NULL,TimeFrame,1);
   else         lastClose = Close[0];

  //  double lastMA = iMA(NULL,TimeFrame,MAPeriod,0,MAType,MAPrice,1);
   double lastMA = ma.index(1);

   int OrderAnzahl = OrdersTotal();
   for(int pos=0; pos<OrderAnzahl; pos++)
   {
      if(OrderSelect(0,SELECT_BY_POS)==false) continue;
      if(OrderSymbol() != Symbol()) continue;
      if(OrderType() == OP_BUY && lastClose < lastMA-Tolerance)
      {
         if(AlertMessage) Alert("Closing Buy Order #" + (string)OrderTicket());
         if(!OrderClose(OrderTicket(), OrderLots(), Bid, Slippage))
            Alert("Unable to close Order #" + (string)OrderTicket() + ": " + ErrorDescription(GetLastError()));
         else pos--;
      }
      if(OrderType() == OP_SELL && lastClose > lastMA+Tolerance)
      {
         if(AlertMessage) Alert("Closing Sell Order #" + (string)OrderTicket());
         if(!OrderClose(OrderTicket(), OrderLots(), Ask, Slippage))
            Alert("Unable to close Order #" + (string)OrderTicket() + ": " + ErrorDescription(GetLastError()));
         else pos--;
      }
   }
}

//+------------------------------------------------------------------------------------------------+
//|                                                                    We appreciate your support. | 
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal: https://goo.gl/9Rj74e    |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |  
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                        https://AppliedMachineLearning.systems  |
//|                                                                       https://mario-jemic.com/ |
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|BitCoin                    : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |  
//|Ethereum                   : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |  
//|SOL Address                : 4tJXw7JfwF3KUPSzrTm1CoVq6Xu4hYd1vLk3VF2mjMYh                       |
//|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
//|Dogecoin Address           : DBGXP1Nc18ZusSRNsj49oMEYFQgAvgBVA8                                 |
//|SHIB Address               : 0x1817D9ebb000025609Bf5D61E269C64DC84DA735                         |              
//|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         | 
//|BitCoin Cash               : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg                                 | 
//|LiteCoin                   : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD                                 |  
//+------------------------------------------------------------------------------------------------+