
//Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=73414

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2023, Gehtsoft USA LLC  | 
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


#property copyright "Copyright © 2023, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"

enum manager
  {
   P = 0, // Primary
   B = 1, // Secondary
  };

extern manager TradeManager = 0;
extern string TradeComment = "MonkeyPips v3.05";
extern int MagicNumber = 33431;
extern int Slippage = 3;
extern int MaxSpread = 18;
extern double FixedLot = 0;
extern int RiskPercent = 30;
extern int MaxDrawdown = 90;
extern int TradeDeviation = 3;
extern int TradeDelta = 12;
extern int Trailing = 3;
extern int TrailingLoss = 7;
extern int VelocityTrigger = 70;
extern int VelocityStop = 40;
extern int VelocityTime = 7;
//
input string startTime = "00:00";            // Start time GMT (hh:mm)
input string finishTime = "23:00";           // Finish time GMT (hh:mm)
input int dailyAction = 1000;                  // Open or Modify per day
int DeleteRatio = 30;

int OrderExpiry = 15;
int TickSample = 100;
int r, gmt, brokerOffset, size, digits, stoplevel;

double marginRequirement, maxLot, minLot, lotSize, points, currentSpread, avgSpread, maxSpread, initialBalance, rateChange, rateTrigger, deleteRatio, commissionPoints;

double spreadSize[];
double tick[];
double avgtick[];
int tickTime[];

string testerStartDate, testerEndDate;

int lastBuyOrder, lastSellOrder;

bool calculateCommission = true;

double max = 0;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int init()
  {
   marginRequirement = MarketInfo(Symbol(), MODE_MARGINREQUIRED) * 0.01;
   maxLot = (double) MarketInfo(Symbol(), MODE_MAXLOT);
   minLot = (double) MarketInfo(Symbol(), MODE_MINLOT);
   currentSpread = NormalizeDouble(Ask - Bid, Digits);
   stoplevel = (int) MathMax(MarketInfo(Symbol(), MODE_FREEZELEVEL), MarketInfo(Symbol(), MODE_STOPLEVEL));
   if(stoplevel > TradeDelta)
      TradeDelta = stoplevel;
   if(stoplevel > Trailing)
      Trailing = stoplevel;
   avgSpread = currentSpread;
   size = TickSample;
   ArrayResize(spreadSize, size);
   ArrayFill(spreadSize, 0, size, avgSpread);
   maxSpread = NormalizeDouble(MaxSpread * Point, Digits);
   deleteRatio = NormalizeDouble((double) DeleteRatio / 100, 2);
   rateTrigger = NormalizeDouble((double) VelocityTrigger * Point, Digits);
   testerStartDate = StringConcatenate(Year(), "-", Month(), "-", Day());
   initialBalance = AccountBalance();
   display();
   return (0);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void commission()
  {
   if(!IsTesting())
     {
      double rate = 0;
      for(int pos = OrdersHistoryTotal() - 1; pos >= 0; pos--)
        {
         if(OrderSelect(pos, SELECT_BY_POS, MODE_HISTORY))
           {
            if(OrderProfit() != 0.0)
              {
               if(OrderClosePrice() != OrderOpenPrice())
                 {
                  if(OrderSymbol() == Symbol())
                    {
                     calculateCommission = false;
                     rate = MathAbs(OrderProfit() / MathAbs(OrderClosePrice() - OrderOpenPrice()));
                     commissionPoints = (-OrderCommission()) / rate;
                     break;
                    }
                 }
              }
           }
        }
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {
   int totalBuyStop = 0;
   int totalSellStop = 0;
   int ticket;
   int totalTrades = 0;
   int totalUnprotected = 0;
   if(calculateCommission)
      commission();
   prepareSpread();
   manageTicks();
   if(!actionCount(false) || !checkTime())
      return(0);
   for(int pos = 0; pos < OrdersTotal(); pos++)
     {
      r = OrderSelect(pos, SELECT_BY_POS, MODE_TRADES);
      if(OrderSymbol() != Symbol())
         continue;
      if(OrderMagicNumber() == MagicNumber)
        {
         totalTrades++;
         switch(OrderType())
           {
            case OP_BUYSTOP:
               if((int) TimeCurrent() - lastBuyOrder > VelocityTime && iRSI(NULL, 0, 7, PRICE_CLOSE, 0) < 70)
                 {
                  r = OrderDelete(OrderTicket());
                  if(r)
                     actionCount(true);
                 }
               totalBuyStop++;
               totalUnprotected++;
               break;
            case OP_SELLSTOP:
               if((int) TimeCurrent() - lastSellOrder > VelocityTime && iRSI(NULL, 0, 7, PRICE_CLOSE, 0) > 30)
                 {
                  r = OrderDelete(OrderTicket());
                  if(r)
                     actionCount(true);
                 }
               totalSellStop++;
               totalUnprotected++;
               break;
            case OP_BUY:
               if(OrderStopLoss() == 0 || (OrderStopLoss() > 0 && OrderStopLoss() < OrderOpenPrice()))
                  totalUnprotected++;
               if(Bid - OrderOpenPrice() + commissionPoints > Trailing * Point)
                 {
                  if(OrderStopLoss() == 0.0 || Bid - OrderStopLoss() > Trailing * Point)
                     if(NormalizeDouble(Bid - (Trailing * Point), Digits) != OrderStopLoss())
                       {
                        r = OrderModify(OrderTicket(), OrderOpenPrice(), NormalizeDouble(Bid - (Trailing * Point), Digits), OrderTakeProfit(), 0);
                        if(r)
                           actionCount(true);
                       }
                 }
               else
                 {
                  if(AccountEquity() > max || AccountEquity() / AccountBalance() < (double) MaxDrawdown / 100)
                    {
                     if(rateChange < -VelocityStop * Point && Bid < OrderOpenPrice() - (VelocityTrigger * Point))
                        if(OrderStopLoss() == 0.0 || Bid - OrderStopLoss() > (Trailing * Point * TrailingLoss))
                           if(NormalizeDouble(Bid - (Trailing * Point * TrailingLoss), Digits) != OrderStopLoss())
                             {
                              r = OrderModify(OrderTicket(), OrderOpenPrice(), NormalizeDouble(Bid - (Trailing * Point * TrailingLoss), Digits), OrderTakeProfit(), 0);
                              if(r)
                                 actionCount(true);
                             }
                    }
                 }
               break;
            case OP_SELL:
               if(OrderStopLoss() == 0 || (OrderStopLoss() > 0 && OrderStopLoss() > OrderOpenPrice()))
                  totalUnprotected++;
               if(OrderOpenPrice() - commissionPoints - Ask > Trailing * Point)
                 {
                  if(OrderStopLoss() == 0.0 || OrderStopLoss() - Ask > Trailing * Point)
                     if(NormalizeDouble(Ask + (Trailing * Point), Digits) != OrderStopLoss())
                       {
                        r = OrderModify(OrderTicket(), OrderOpenPrice(), NormalizeDouble(Ask + (Trailing * Point), Digits), OrderTakeProfit(), 0);
                        if(r)
                           actionCount(true);
                       }
                 }
               else
                 {
                  if(AccountEquity() > max || AccountEquity() / AccountBalance() < (double) MaxDrawdown / 100)
                    {
                     if(rateChange > VelocityStop * Point  && Ask > OrderOpenPrice() + (VelocityTrigger * Point))
                        if(OrderStopLoss() == 0.0 || OrderStopLoss() - Ask > (Trailing * Point * TrailingLoss))
                           if(NormalizeDouble(Ask + (Trailing * Point * TrailingLoss), Digits) != OrderStopLoss())
                             {
                              r = OrderModify(OrderTicket(), OrderOpenPrice(), NormalizeDouble(Ask + (Trailing * Point * TrailingLoss), Digits), OrderTakeProfit(), 0);
                              if(r)
                                 actionCount(true);
                             }
                    }
                 }
               break;
           }
        }
     }
   if(totalTrades == 0)
     {
      if(AccountBalance() > max)
         max = AccountBalance();
     }
   bool buy = true;
   bool sell = true;
   for(int i = 0; i < 3; i++)
     {
      if(iRSI(NULL, 0, 7, PRICE_CLOSE, i) < 80)
        {
         buy = false;
        }
      if(iRSI(NULL, 0, 7, PRICE_CLOSE, i) > 20)
        {
         sell = false;
        }
     }
   if(TradeManager == 0)
     {
      if(totalUnprotected < TradeDeviation)
        {
         if(buy && avgSpread <= maxSpread && totalBuyStop < TradeDeviation)
           {
            ticket = OrderSend(Symbol(), OP_BUYSTOP, lotSize(), Ask + (totalBuyStop + 1.0) * (Point * TradeDelta), Slippage, 0, 0, TradeComment, MagicNumber, 0);
            lastBuyOrder = (int) TimeCurrent();
            if(ticket > 0)
               actionCount(true);
           }
         if(sell && avgSpread <= maxSpread && totalSellStop < TradeDeviation)
           {
            ticket = OrderSend(Symbol(), OP_SELLSTOP, lotSize(), Bid - (totalSellStop + 1.0) * (Point * TradeDelta), Slippage, 0, 0, TradeComment, MagicNumber, 0);
            lastSellOrder = (int) TimeCurrent();
            if(ticket > 0)
               actionCount(true);
           }
        }
     }
   display();
   return (0);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double lotSize()
  {
   if(FixedLot > 0)
     {
      lotSize = NormalizeDouble(FixedLot, 2);
     }
   else
     {
      if(marginRequirement > 0)
         lotSize = MathMax(MathMin(NormalizeDouble((AccountBalance() * ((double) RiskPercent / 1000) * 0.01 / marginRequirement), 2), maxLot), minLot);
     }
   return (NormalizeLots(lotSize));
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double NormalizeLots(double p)
  {
   double ls = MarketInfo(Symbol(), MODE_LOTSTEP);
   return(MathRound(p / ls) * ls);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void prepareSpread()
  {
   if(!IsTesting())
     {
      double spreadSize_temp[];
      ArrayResize(spreadSize_temp, size - 1);
      ArrayCopy(spreadSize_temp, spreadSize, 0, 1, size - 1);
      ArrayResize(spreadSize_temp, size);
      spreadSize_temp[size - 1] = NormalizeDouble(Ask - Bid, Digits);
      ArrayCopy(spreadSize, spreadSize_temp, 0, 0);
      avgSpread = iMAOnArray(spreadSize, size, size, 0, MODE_LWMA, 0);
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void manageTicks()
  {
   double tick_temp[], tickTime_temp[], avgtick_temp[];
   ArrayResize(tick_temp, size - 1);
   ArrayResize(tickTime_temp, size - 1);
   ArrayCopy(tick_temp, tick, 0, 1, size - 1);
   ArrayCopy(tickTime_temp, tickTime, 0, 1, size - 1);
   ArrayResize(tick_temp, size);
   ArrayResize(tickTime_temp, size);
   tick_temp[size - 1] = Bid;
   tickTime_temp[size - 1] = (int) TimeCurrent();
   ArrayCopy(tick, tick_temp, 0, 0);
   ArrayCopy(tickTime, tickTime_temp, 0, 0);
   int timeNow = tickTime[size - 1];
   double priceNow = tick[size - 1];
   double priceThen = 0;
   int period = 0;
   for(int i = size - 1; i >= 0; i--)
     {
      period++;
      if(timeNow - tickTime[i] > VelocityTime)
        {
         priceThen = tick[i];
         break;
        }
     }
   rateChange = (priceNow - priceThen);
   if(rateChange / Point > 5000)
      rateChange = 0;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void display()
  {
   if(!IsTesting())
     {
      string display = "  Monkey Pips v3.05\n";
      display = StringConcatenate(display, " ----------------------------------------\n");
      if(TradeManager == 0)
         display = StringConcatenate(display, "  TradeManager: Primary\n");
      else
         display = StringConcatenate(display, "  TradeManager: Secondary\n");
      display = StringConcatenate(display, " ----------------------------------------\n");
      display = StringConcatenate(display, "  Leverage: ", DoubleToStr(AccountLeverage(), 0), " Lots: ", DoubleToStr(lotSize, 2), ", \n");
      display = StringConcatenate(display, "  Avg. Spread: ", DoubleToStr(avgSpread / Point, 0), " of ", MaxSpread, ", \n");
      display = StringConcatenate(display, "  Commission: ", DoubleToStr(commissionPoints / Point, 0), " \n");
      display = StringConcatenate(display, " ----------------------------------------\n");
      display = StringConcatenate(display, "  Set: ", TradeComment, " \n");
      display = StringConcatenate(display, " ----------------------------------------\n");
      display = StringConcatenate(display, "  Velocity: ", DoubleToStr(rateChange / Point, 0), " \n");
      Comment(display);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool checkTime()
  {
   datetime curTime = TimeGMT();
   datetime s_time = StringToTime(TimeToString(curTime, TIME_DATE) + " " + startTime);
   datetime f_time = StringToTime(TimeToString(curTime, TIME_DATE) + " " + finishTime);
   if((startTime == "00:00" || startTime == "0") && (finishTime == "00:00" || finishTime == "0"))
      return true;
   if(curTime >=  s_time && curTime < f_time)
      return true;
   return false;
  }
//+------------------------------------------------------------------+
bool actionCount(bool add)
  {
   string LastDayName = "MonkeyPipLastDay_" + (string)MagicNumber;
   string CountName = "MonkeyPipCount_" + (string)MagicNumber;
   int currDay = iTime(Symbol(), PERIOD_D1, 0);
   if(!GlobalVariableCheck(LastDayName))
      GlobalVariableSet(LastDayName, currDay);
   if(!GlobalVariableCheck(CountName))
      GlobalVariableSet(CountName, 0);
   int prevDay = GlobalVariableGet(LastDayName);
   int CountVal = GlobalVariableGet(CountName);
   if(prevDay == currDay)
     {
      if(add)
        {
         GlobalVariableSet(CountName, CountVal + 1);
        }
     }
   else
     {
      GlobalVariableSet(LastDayName, currDay);
      GlobalVariableSet(CountName, 0);
     }
   if(GlobalVariableGet(CountName) >= dailyAction)
     {
      return false;
     }
   else
     {
      return true;
     }
  }
//+------------------------------------------------------------------+
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
