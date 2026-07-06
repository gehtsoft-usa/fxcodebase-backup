//+------------------------------------------------------------------+
//|                               Copyright © 2020, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |
//|                                          mario.jemic@gmail.com   |
//|                         https://AppliedMachineLearning.systems   |
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

#property copyright "Copyright © 2020, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.0"
#property strict

#property indicator_chart_window

input bool is_buy = true; // Is buy?
input int Magic = -1;
// Trading calculator v.1.3

// Position size type

#ifndef PositionSizeType_IMP
#define PositionSizeType_IMP

enum PositionSizeType
{
   PositionSizeAmount, // $
   PositionSizeContract, // In contracts
   PositionSizeEquity, // % of equity
   PositionSizeRisk, // Risk in % of equity
   PositionSizeMoneyPerPip // $ per pip
};

#endif
// Stop/limit type v1.0

#ifndef StopLimitType_IMP
#define StopLimitType_IMP

enum StopLimitType
{
   StopLimitDoNotUse, // Do not use
   StopLimitPercent, // Set in %
   StopLimitPips, // Set in Pips
   StopLimitDollar, // Set in $
   StopLimitRiskReward // Set in % of stop loss
};
// Order side v1.0

#ifndef OrderSide_IMP
#define OrderSide_IMP

enum OrderSide
{
   BuySide,
   SellSide
};

#endif
// Symbol info v.1.2
class InstrumentInfo
{
   string _symbol;
   double _mult;
   double _point;
   double _pipSize;
   int _digit;
   double _ticksize;
public:
   InstrumentInfo(const string symbol)
   {
      _symbol = symbol;
      _point = SymbolInfoDouble(symbol, SYMBOL_POINT);
      _digit = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS); 
      _mult = _digit == 3 || _digit == 5 ? 10 : 1;
      _pipSize = _point * _mult;
      _ticksize = NormalizeDouble(SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_SIZE), _digit);
   }

   static double GetPipSize(const string symbol)
   {
      double point = SymbolInfoDouble(symbol, SYMBOL_POINT);
      double digit = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS); 
      double mult = digit == 3 || digit == 5 ? 10 : 1;
      return point * mult;
   }
   double GetPointSize() { return _point; }
   double GetPipSize() { return _pipSize; }
   int GetDigits() { return _digit; }
   string GetSymbol() { return _symbol; }
   double GetBid() { return SymbolInfoDouble(_symbol, SYMBOL_BID); }
   double GetAsk() { return SymbolInfoDouble(_symbol, SYMBOL_ASK); }
   double GetMinVolume() { return SymbolInfoDouble(_symbol, SYMBOL_VOLUME_MIN); }

   double RoundRate(const double rate)
   {
      return NormalizeDouble(MathRound(rate / _ticksize) * _ticksize, _digit);
   }
};
// Trades iterator v 1.2

// Compare type v1.0

#ifndef CompareType_IMP
#define CompareType_IMP

enum CompareType
{
   CompareLessThan
};

#endif

#ifndef TradesIterator_IMP

class TradesIterator
{
   bool _useMagicNumber;
   int _magicNumber;
   int _orderType;
   bool _useSide;
   bool _isBuySide;
   int _lastIndex;
   bool _useSymbol;
   string _symbol;
   bool _useProfit;
   double _profit;
   CompareType _profitCompare;
   string _comment;
public:
   TradesIterator()
   {
      _comment = NULL;
      _useMagicNumber = false;
      _useSide = false;
      _lastIndex = INT_MIN;
      _useSymbol = false;
      _useProfit = false;
   }

   TradesIterator* WhenComment(string comment)
   {
      _comment = comment;
      return &this;
   }

   void WhenSymbol(const string symbol)
   {
      _useSymbol = true;
      _symbol = symbol;
   }

   void WhenProfit(const double profit, const CompareType compare)
   {
      _useProfit = true;
      _profit = profit;
      _profitCompare = compare;
   }

   void WhenSide(const bool isBuy)
   {
      _useSide = true;
      _isBuySide = isBuy;
   }

   void WhenMagicNumber(const int magicNumber)
   {
      _useMagicNumber = true;
      _magicNumber = magicNumber;
   }
   
   ulong GetTicket() { return PositionGetTicket(_lastIndex); }
   double GetLots() { return PositionGetDouble(POSITION_VOLUME); }
   double GetOpenPrice() { return PositionGetDouble(POSITION_PRICE_OPEN); }
   double GetStopLoss() { return PositionGetDouble(POSITION_SL); }
   double GetTakeProfit() { return PositionGetDouble(POSITION_TP); }
   ENUM_POSITION_TYPE GetPositionType() { return (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE); }
   bool IsBuyOrder() { return GetPositionType() == POSITION_TYPE_BUY; }
   string GetSymbol() { return PositionGetSymbol(_lastIndex); }

   int Count()
   {
      int count = 0;
      for (int i = PositionsTotal() - 1; i >= 0; i--)
      {
         ulong ticket = PositionGetTicket(i);
         if (PositionSelectByTicket(ticket) && PassFilter(i))
         {
            count++;
         }
      }
      return count;
   }

   bool Next()
   {
      if (_lastIndex == INT_MIN)
      {
         _lastIndex = PositionsTotal() - 1;
      }
      else
         _lastIndex = _lastIndex - 1;
      while (_lastIndex >= 0)
      {
         ulong ticket = PositionGetTicket(_lastIndex);
         if (PositionSelectByTicket(ticket) && PassFilter(_lastIndex))
            return true;
         _lastIndex = _lastIndex - 1;
      }
      return false;
   }

   bool Any()
   {
      for (int i = PositionsTotal() - 1; i >= 0; i--)
      {
         ulong ticket = PositionGetTicket(i);
         if (PositionSelectByTicket(ticket) && PassFilter(i))
         {
            return true;
         }
      }
      return false;
   }

   ulong First()
   {
      for (int i = PositionsTotal() - 1; i >= 0; i--)
      {
         ulong ticket = PositionGetTicket(i);
         if (PositionSelectByTicket(ticket) && PassFilter(i))
         {
            return ticket;
         }
      }
      return 0;
   }

private:
   bool PassFilter(const int index)
   {
      if (_useMagicNumber && PositionGetInteger(POSITION_MAGIC) != _magicNumber)
         return false;
      if (_useSymbol && PositionGetSymbol(index) != _symbol)
         return false;
      if (_useProfit)
      {
         switch (_profitCompare)
         {
            case CompareLessThan:
               if (PositionGetDouble(POSITION_PROFIT) >= _profit)
                  return false;
               break;
         }
      }
      if (_useSide)
      {
         ENUM_POSITION_TYPE positionType = GetPositionType();
         if (_isBuySide && positionType != POSITION_TYPE_BUY)
            return false;
         if (!_isBuySide && positionType != POSITION_TYPE_SELL)
            return false;
      }
      if (_comment != NULL)
      {
         if (_comment != PositionGetString(POSITION_COMMENT))
            return false;
      }
      return true;
   }
};
#define TradesIterator_IMP
#endif

#ifndef TradingCalculator_IMP
#define TradingCalculator_IMP

class TradingCalculator
{
   InstrumentInfo *_symbolInfo;
public:
   static TradingCalculator* Create(string symbol)
   {
      return new TradingCalculator(symbol);
   }

   TradingCalculator(const string symbol)
   {
      _symbolInfo = new InstrumentInfo(symbol);
   }

   ~TradingCalculator()
   {
      delete _symbolInfo;
   }

   InstrumentInfo *GetSymbolInfo()
   {
      return _symbolInfo;
   }

   double GetBreakevenPrice(const bool isBuy, const int magicNumber)
   {
      string symbol = _symbolInfo.GetSymbol();
      double lotStep = SymbolInfoDouble(symbol, SYMBOL_VOLUME_STEP);
      double price = isBuy ? _symbolInfo.GetBid() : _symbolInfo.GetAsk();
      double totalPL = 0;
      double totalAmount = 0;
      TradesIterator it1();
      if (magicNumber != -1)
         it1.WhenMagicNumber(magicNumber);
      it1.WhenSymbol(symbol);
      it1.WhenSide(isBuy);
      while (it1.Next())
      {
         double orderLots = PositionGetDouble(POSITION_VOLUME);
         totalAmount += orderLots / lotStep;
         double openPrice = it1.GetOpenPrice();
         if (isBuy)
            totalPL += (price - openPrice) * (orderLots / lotStep);
         else
            totalPL += (openPrice - price) * (orderLots / lotStep);
      }
      if (totalAmount == 0.0)
         return 0.0;
      double shift = -(totalPL / totalAmount);
      return isBuy ? price + shift : price - shift;
   }
   
   double CalculateTakeProfit(const bool isBuy, const double takeProfit, const StopLimitType takeProfitType, const double amount, double basePrice)
   {
      int direction = isBuy ? 1 : -1;
      switch (takeProfitType)
      {
         case StopLimitPercent:
            return basePrice + basePrice * takeProfit / 100.0 * direction;
         case StopLimitPips:
            return basePrice + takeProfit * _symbolInfo.GetPipSize() * direction;
         case StopLimitDollar:
            return basePrice + CalculateSLShift(amount, takeProfit) * direction;
      }
      return 0.0;
   }
   
   double CalculateStopLoss(const bool isBuy, const double stopLoss, const StopLimitType stopLossType, const double amount, double basePrice)
   {
      int direction = isBuy ? 1 : -1;
      switch (stopLossType)
      {
         case StopLimitPercent:
            return basePrice - basePrice * stopLoss / 100.0 * direction;
         case StopLimitPips:
            return basePrice - stopLoss * _symbolInfo.GetPipSize() * direction;
         case StopLimitDollar:
            return basePrice - CalculateSLShift(amount, stopLoss) * direction;
      }
      return 0.0;
   }

   double GetLots(PositionSizeType lotsType, double lotsValue, const OrderSide orderSide, const double price, double stopDistance)
   {
      switch (lotsType)
      {
         case PositionSizeMoneyPerPip:
         {
            double unitCost = SymbolInfoDouble(_symbolInfo.GetSymbol(), SYMBOL_TRADE_TICK_VALUE);
            double mult = _symbolInfo.GetPipSize() / _symbolInfo.GetPointSize();
            double lots = RoundLots(lotsValue / (unitCost * mult));
            return LimitLots(lots);
         }
         case PositionSizeAmount:
            return GetLotsForMoney(orderSide, price, lotsValue);
         case PositionSizeContract:
            return LimitLots(RoundLots(lotsValue));
         case PositionSizeEquity:
            return GetLotsForMoney(orderSide, price, AccountInfoDouble(ACCOUNT_EQUITY) * lotsValue / 100.0);
         case PositionSizeRisk:
         {
            double affordableLoss = AccountInfoDouble(ACCOUNT_EQUITY) * lotsValue / 100.0;
            double unitCost = SymbolInfoDouble(_symbolInfo.GetSymbol(), SYMBOL_TRADE_TICK_VALUE);
            double tickSize = SymbolInfoDouble(_symbolInfo.GetSymbol(), SYMBOL_TRADE_TICK_SIZE);
            double possibleLoss = unitCost * stopDistance / tickSize;
            if (possibleLoss <= 0.01)
               return 0;
            return LimitLots(RoundLots(affordableLoss / possibleLoss));
         }
      }
      return lotsValue;
   }

   bool IsLotsValid(const double lots, PositionSizeType lotsType, string &error)
   {
      switch (lotsType)
      {
         case PositionSizeContract:
            return IsContractLotsValid(lots, error);
      }
      return true;
   }

   double NormilizeLots(double lots)
   {
      return LimitLots(RoundLots(lots));
   }

private:
   bool IsContractLotsValid(const double lots, string &error)
   {
      double minVolume = SymbolInfoDouble(_symbolInfo.GetSymbol(), SYMBOL_VOLUME_MIN);
      if (minVolume > lots)
      {
         error = "Min. allowed lot size is " + DoubleToString(minVolume);
         return false;
      }
      double maxVolume = SymbolInfoDouble(_symbolInfo.GetSymbol(), SYMBOL_VOLUME_MAX);
      if (maxVolume < lots)
      {
         error = "Max. allowed lot size is " + DoubleToString(maxVolume);
         return false;
      }
      return true;
   }

   double GetLotsForMoney(const OrderSide orderSide, const double price, const double money)
   {
      ENUM_ORDER_TYPE orderType = orderSide != BuySide ? ORDER_TYPE_BUY : ORDER_TYPE_SELL;
      string symbol = _symbolInfo.GetSymbol();
      double minVolume = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN);
      double marginRequired;
      if (!OrderCalcMargin(orderType, symbol, minVolume, price, marginRequired))
      {
         return 0.0;
      }
      if (marginRequired <= 0.0)
      {
         Print("Margin is 0. Server misconfiguration?");
         return 0.0;
      }
      double lots = RoundLots(money / marginRequired);
      return LimitLots(lots);
   }

   double RoundLots(const double lots)
   {
      double lotStep = SymbolInfoDouble(_symbolInfo.GetSymbol(), SYMBOL_VOLUME_STEP);
      if (lotStep == 0)
         return 0.0;
      return floor(lots / lotStep) * lotStep;
   }

   double LimitLots(const double lots)
   {
      double minVolume = SymbolInfoDouble(_symbolInfo.GetSymbol(), SYMBOL_VOLUME_MIN);
      if (minVolume > lots)
         return 0.0;
      double maxVolume = SymbolInfoDouble(_symbolInfo.GetSymbol(), SYMBOL_VOLUME_MAX);
      if (maxVolume < lots)
         return maxVolume;
      return lots;
   }

   double CalculateSLShift(const double amount, const double money)
   {
      double unitCost = SymbolInfoDouble(_symbolInfo.GetSymbol(), SYMBOL_TRADE_TICK_VALUE);
      double tickSize = SymbolInfoDouble(_symbolInfo.GetSymbol(), SYMBOL_TRADE_TICK_SIZE);
      return (money / (unitCost / tickSize)) / amount;
   }
};

#endif

string IndicatorName;
string IndicatorObjPrefix;
string GenerateIndicatorName(const string target)
{
   string name = target;
   return name;
}

TradingCalculator* tradingCalc;
int OnInit(void)
{
   tradingCalc = TradingCalculator::Create(_Symbol);
   IndicatorName = GenerateIndicatorName("Line of Zero");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorSetString(INDICATOR_SHORTNAME, IndicatorName);
   IndicatorSetInteger(INDICATOR_DIGITS, Digits());

   return INIT_SUCCEEDED;//INIT_FAILED
}

void OnDeinit(const int reason)
{
   ObjectsDeleteAll(0, IndicatorObjPrefix);
   delete tradingCalc;
   tradingCalc = NULL;
}

int OnCalculate(const int rates_total,       // size of input time series
                const int prev_calculated,   // number of handled bars at the previous call
                const datetime& time[],      // Time array
                const double& open[],        // Open array
                const double& high[],        // High array
                const double& low[],         // Low array
                const double& close[],       // Close array
                const long& tick_volume[],   // Tick Volume array
                const long& volume[],        // Real Volume array
                const int& spread[]          // Spread array
)
{
   double be = tradingCalc.GetBreakevenPrice(is_buy, Magic);
   if (be != 0)
      SetHLine(DarkOrange, IndicatorObjPrefix + "LineofZERO", be);
   return rates_total;
}

void SetHLine(color cl,string nm="",double p1=0,int st=0,int wd=1) 
{
   if (nm == "") 
      nm = DoubleToString(iTime(_Symbol, _Period, 0), 0);
   if (ObjectFind(0, nm) < 0) 
      ObjectCreate(0, nm, OBJ_HLINE, 0, 0, 0);
   ObjectSetDouble(0, nm, OBJPROP_PRICE, p1);
   ObjectSetInteger(0, nm, OBJPROP_COLOR, cl);
   ObjectSetInteger(0, nm, OBJPROP_STYLE, st);
   ObjectSetInteger(0, nm, OBJPROP_WIDTH, wd);
}
