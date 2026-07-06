// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=69307&p=130682#p130682

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

#property	indicator_separate_window
#property	indicator_maximum			100
#property	indicator_minimum			0
#property	indicator_buffers			3
#property	indicator_color1			DodgerBlue
#property	indicator_width1			1
#property	indicator_width2			3
#property	indicator_color2			Gold
#property	indicator_width3			5
#property	indicator_color3			Red

input bool     ShowOnlyBuyEntryAlerts=false;
input bool     ShowOnlySellEntryAlerts=false;
input bool    ShowCounterTrend=false;//gives too CT alerts
input bool    ShowDaily2_1=true;//setting this to true the indicator shows to the D1 2.1.1 Stoch
input bool   UseOnly7_2forEntryAlert=false;// this setting will only use the Stoch 7.2.2 for the enrty alerts the HigherTF Stoch 2.1.1 is not used independend from the above setting
input bool      PopupAlert=true; // ALERTS WHEN WHENEVER PRICE GOES BELOW 90&70 AND ABOVE 10&30 AND HT STOCH CONFIRMS 
input bool      EmailAlert= false;
input bool      PushAlert=false;
input bool    GiveStoch2_1_ExitAlerts=false;//set this to false if you have set ShowCounterTrend to true, because it will give you an immediatly exit alert in that case
input bool    GiveStoch7ExitAlerts=false;//gives Stoch 7.2.2 exits alerts for BUY if we have Stoch 7.2.2 >=90 and for SELL if we have  Stoch 7.2.2<=10
input bool    GiveTMASlopeExitAlert=false;
input ENUM_TIMEFRAMES HigherTF_Used = PERIOD_D1; // Timeframe 1
input ENUM_TIMEFRAMES HigherTF2_Used = PERIOD_W1; // Timeframe 2
input string  Set_Stoch_Alert_Levels="Default = 20, 40, 60, 80";
input int     LevelOne=10;                                    // default = 20
input int     LevelTwo                = 30; //CHANGE TO 10 IF YOU ONLY WANT 1 ALERT // default = 40
input int     LevelThree              = 70; //CHANGE TO 90 IF YOU ONLY WANT 1 ALERT // default = 60
input int     LevelFour=90;                                    // default = 80

input string  Stoch_Settings="Default = 7, 2, 2, 2, 1";

input int   KPeriod                     = 7;
input int   DPeriod                     = 2;
input int   Slowing=2;
input ENUM_MA_METHOD Method = MODE_SMMA; // Smoothing method
input ENUM_STO_PRICE Price = STO_CLOSECLOSE;
input int K_period_HT = 2;
input int D_period_HT = 1;
input int S_period_HT = 1;
input int STOCH_MAIN_Line_Style_HT=2;
input int STOCH_SIGNAL_Line_Style_HT=2;
input ENUM_STO_PRICE STOCH_MAIN_Price_HT = STO_CLOSECLOSE;
input ENUM_STO_PRICE STOCH_SIGNAL_Price_HT = STO_CLOSECLOSE;
input ENUM_MA_METHOD STOCH_MAIN_Ma_HT = MODE_SMMA;
input ENUM_MA_METHOD STOCH_SIGNAL_Ma_HT = MODE_SMMA;
input string  Level_Styles            = "0 Solid, 1 Dash, 2 Dot, 3 Dashdot, 4 Dashdotdot";
input int     LevelOneStyle           = 0;
input color   LevelOneColor           = Blue;
input int     LevelTwoStyle           = 2;
input color   LevelTwoColor           = Blue;
input int     LevelThreeStyle         = 2; 
input color   LevelThreeColor         = Gold;
input int     LevelFourStyle          = 0;
input color   LevelFourColor          = Gold;
input string   slp="--TMA-SlopeSettings--";
input ENUM_TIMEFRAMES TMASlopeTF = PERIOD_H3;
input double   TMASlopeCloseBuyAlertLevel=-0.3;
input double   TMASlopeCloseSellAlertLevel=0.3;

double          TMASlopeVal[8];
bool     BrokerHasSundayCandle=false;
int count_var=0;
// indicator buffers
double dStochMain[];
double HTStochMain[];
double HT2StochMain[];

int indiWindow=0;

int TimeHour(datetime dt)
{
   MqlDateTime time;
   TimeToStruct(dt, time);
   return time.hour;
}

int TimeDayOfWeek(datetime dt)
{
   MqlDateTime time;
   TimeToStruct(dt, time);
   return time.day_of_week;
}

enum CompareType
{
   CompareLessThan
};

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

string IndicatorName;
string IndicatorObjPrefix;
string GenerateIndicatorName(const string target)
{
   string name = target;
   return name;
}
int stoch1, stoch2, stoch, atr;
int OnInit(void)
{
   IndicatorName = GenerateIndicatorName("STO_wTS HT Alert");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorSetString(INDICATOR_SHORTNAME, IndicatorName);
   IndicatorSetInteger(INDICATOR_DIGITS, Digits());

   stoch = iStochastic(NULL, 0, KPeriod, DPeriod, Slowing, Method, Price);
   stoch1 = iStochastic(_Symbol, HigherTF_Used, K_period_HT, D_period_HT, S_period_HT, STOCH_MAIN_Ma_HT, STOCH_MAIN_Price_HT);
   stoch2 = iStochastic(_Symbol, HigherTF2_Used, K_period_HT, D_period_HT, S_period_HT, STOCH_MAIN_Ma_HT, STOCH_MAIN_Price_HT);
   atr = iATR(_Symbol, TMASlopeTF, 60);
   
   count_var=0;
   if (ShowOnlyBuyEntryAlerts==true && ShowOnlySellEntryAlerts==true)
   {
      Alert("As you can only one set to true!!");
      return INIT_FAILED;
   }

   SetIndexBuffer(0, dStochMain, INDICATOR_DATA);
   PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetString(0, PLOT_LABEL, "Stoch Main");
   if (ShowDaily2_1 == true)
   {
      SetIndexBuffer(1, HTStochMain, INDICATOR_DATA);
      PlotIndexSetInteger(1, PLOT_DRAW_TYPE, DRAW_LINE);
      PlotIndexSetString(1, PLOT_LABEL, "HTStochMain");
   }
   SetIndexBuffer(2, HT2StochMain, INDICATOR_DATA);
   PlotIndexSetInteger(2, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetString(2, PLOT_LABEL, "HT2StochMain");

   ObjectCreate(0, IndicatorObjPrefix + "stolvl1",OBJ_HLINE,indiWindow,TimeCurrent(),NormalizeDouble(LevelOne,0));
   ObjectSetInteger(0, IndicatorObjPrefix + "stolvl1",OBJPROP_COLOR,LevelOneColor);
   ObjectSetInteger(0, IndicatorObjPrefix + "stolvl1",OBJPROP_STYLE,LevelOneStyle);
   ObjectSetInteger(0, IndicatorObjPrefix + "stolvl1",OBJPROP_WIDTH,1);

   ObjectCreate(0, IndicatorObjPrefix + "stolvl2",OBJ_HLINE,indiWindow,TimeCurrent(),NormalizeDouble(LevelTwo,0));
   ObjectSetInteger(0, IndicatorObjPrefix + "stolvl2",OBJPROP_COLOR,LevelTwoColor);
   ObjectSetInteger(0, IndicatorObjPrefix + "stolvl2",OBJPROP_STYLE,LevelTwoStyle);
   ObjectSetInteger(0, IndicatorObjPrefix + "stolvl2",OBJPROP_WIDTH,1);

   ObjectCreate(0, IndicatorObjPrefix + "stolvl3",OBJ_HLINE,indiWindow,TimeCurrent(),NormalizeDouble(LevelThree,0));
   ObjectSetInteger(0, IndicatorObjPrefix + "stolvl3",OBJPROP_COLOR,LevelThreeColor);
   ObjectSetInteger(0, IndicatorObjPrefix + "stolvl3",OBJPROP_STYLE,LevelThreeStyle);
   ObjectSetInteger(0, IndicatorObjPrefix + "stolvl3",OBJPROP_WIDTH,1);

   ObjectCreate(0, IndicatorObjPrefix + "stolvl4",OBJ_HLINE,indiWindow,TimeCurrent(),NormalizeDouble(LevelFour,0));
   ObjectSetInteger(0, IndicatorObjPrefix + "stolvl4",OBJPROP_COLOR,LevelFourColor);
   ObjectSetInteger(0, IndicatorObjPrefix + "stolvl4",OBJPROP_STYLE,LevelFourStyle);
   ObjectSetInteger(0, IndicatorObjPrefix + "stolvl4",OBJPROP_WIDTH,1);

   return INIT_SUCCEEDED;//INIT_FAILED
}

void OnDeinit(const int reason)
{
   ObjectsDeleteAll(0, IndicatorObjPrefix);
   IndicatorRelease(atr);
   IndicatorRelease(stoch);
   IndicatorRelease(stoch1);
   IndicatorRelease(stoch2);
}

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{

   if(rates_total<=KPeriod+DPeriod+Slowing)
      return(0);
   BrokerHasSundayCandle=false;
   int BrokerHour=TimeHour(TimeCurrent());
   for(int CC=0; CC<8; CC++)
   {
      if(TimeDayOfWeek(iTime(NULL,PERIOD_D1,CC))==0)
      {
         BrokerHasSundayCandle=true;
         break;
      }
   }
   int m_bar=0;//Need to deal with a Sunday candle
   int n_bar=0;//Need to deal with a Sunday candle
   int tma_bar=0;
   int d= TimeDayOfWeek(TimeCurrent());

   double HigherTF1STOCH[1];
   if (CopyBuffer(stoch1, MAIN_LINE, m_bar, 1, HigherTF1STOCH) != 1)
   {
      return 0;
   }
   double HigherTF2STOCH[1];
   if (CopyBuffer(stoch2, MAIN_LINE, n_bar, 1, HigherTF2STOCH) != 1)
   {
      return 0;
   }
   if(d == 1 && BrokerHasSundayCandle && HigherTF_Used==1440)
   {
      double buffer1[1];
      if (CopyBuffer(stoch1, MAIN_LINE, 1, 1, buffer1) != 1)
      {
         return 0;
      }
      HigherTF1STOCH[0] = (buffer1[0] + BrokerHour * buffer1[0]) / (1 + BrokerHour);
   }
   if(d == 1 && BrokerHasSundayCandle && HigherTF2_Used==1440)
   {
      double buffer1[1];
      if (CopyBuffer(stoch2, MAIN_LINE, 1, 1, buffer1) != 1)
      {
         return 0;
      }
      HigherTF2STOCH[0] = (buffer1[0] + BrokerHour * buffer1[0]) / (1 + BrokerHour);
   }
   static datetime tLastAlert=0;
   static datetime tLastAlert_exit=0;
   static datetime tLastAlert_fastexit= 0;
   static datetime tLastAlert_cssexit = 0;
   int i=0;
   int y2=0,y3=0,y4=0;
   for(i=0,y2=0,y3=0,y4=0;i<rates_total;i++)
   {
      if (time[rates_total - 1 - i] < time[rates_total - 1 - y2])
         y2++;
      if(time[rates_total - 1 - i] < iTime(_Symbol, HigherTF_Used, y3)) 
         y3++;
      if(time[rates_total - 1 - i] < iTime(_Symbol, HigherTF2_Used, y4)) 
         y4++;
      if (d == 1 && BrokerHasSundayCandle && Period()==1440 && i==0)
      {
         double buffer1[1];
         if (CopyBuffer(stoch, MAIN_LINE, 1, 1, buffer1) != 1)
         {
            continue;
         }
         double buffer2[1];
         if (CopyBuffer(stoch, MAIN_LINE, 0, 1, buffer2) != 1)
         {
            continue;
         }
         dStochMain[0]=(buffer1[0] + BrokerHour * buffer2[0]) / (1 + BrokerHour);
      }
      if(d == 1 && BrokerHasSundayCandle && HigherTF_Used==1440 && i==0)
      {
         double buffer1[1];
         if (CopyBuffer(stoch1, MAIN_LINE, 1, 1, buffer1) != 1)
         {
            continue;
         }
         HTStochMain[0] = (buffer1[0] + BrokerHour * buffer1[0]) / (1 + BrokerHour);
      }
      if(d == 1 && BrokerHasSundayCandle && HigherTF2_Used==1440 && i==0)
      {
         double buffer1[1];
         if (CopyBuffer(stoch2, MAIN_LINE, 1, 1, buffer1) != 1)
         {
            continue;
         }
         HT2StochMain[0] = (buffer1[0] + BrokerHour * buffer1[0]) / (1 + BrokerHour);
      }
      double buffer[1];
      if (CopyBuffer(stoch, MAIN_LINE, y2, 1, buffer) != 1)
      {
         continue;
      }
      dStochMain[i] = buffer[0];
    
      double buffer1[1];
      if (CopyBuffer(stoch1, MAIN_LINE, y3, 1, buffer1) != 1)
      {
         continue;
      }
      HTStochMain[i] = buffer1[0];
    
      double buffer2[1];
      if (CopyBuffer(stoch2, MAIN_LINE, y4, 1, buffer2) != 1)
      {
         continue;
      }
      HT2StochMain[i] = buffer2[0];
   }
   if(d == 1 && BrokerHasSundayCandle && TMASlopeTF==1440)
   {
      tma_bar=tma_bar+1;
   }
      
   TMASlopeVal[0]= GetSlope(Symbol(),TMASlopeTF,tma_bar);
   TMASlopeVal[1]= GetSlope(Symbol(),TMASlopeTF,tma_bar+1);
   if(tLastAlert<time[rates_total - 1])
   {
      if((ShowCounterTrend==true && UseOnly7_2forEntryAlert==false && ShowOnlyBuyEntryAlerts==false))
      {
         if(dStochMain[1]>=LevelFour && dStochMain[0]<LevelFour &&( HigherTF1STOCH[0] >=99 || HigherTF2STOCH[0] >=99))
         {
            fireAlerts(" 10.7 (CT) TRADE SELL ALERT "+Symbol()+" Stoch dipped below "+LevelFour+"(CHECK )");
            tLastAlert=time[rates_total - 1];
         }
         if(dStochMain[1]>=LevelThree && dStochMain[0]<LevelThree && (HigherTF1STOCH[0] >=99 || HigherTF2STOCH[0] >=99))
         {
            fireAlerts(" LAST CALL(CT)TRADE SELL "+Symbol()+" Stoch dipped below "+LevelThree+" (CHECK )");
            tLastAlert=time[rates_total - 1];
         }
      }
      if((ShowCounterTrend==true && UseOnly7_2forEntryAlert==false && ShowOnlySellEntryAlerts==false))
      {
         if(dStochMain[1]<=LevelOne && dStochMain[0]>LevelOne &&( HigherTF1STOCH[0] <=1 || HigherTF2STOCH[0] <=1))
         {
            fireAlerts(" 10.7(CT)TRADE BUY ALERT "+Symbol()+" Stoch pushed up above "+LevelOne+"(CHECK )");
            tLastAlert=time[rates_total - 1];
         }
         if(dStochMain[1]<=LevelTwo && dStochMain[0]>LevelTwo &&( HigherTF1STOCH[0] <=1 || HigherTF2STOCH[0] <=1))
         {
            fireAlerts(" LAST CALL(CT)TRADE BUY "+Symbol()+" Stoch pushed up above "+LevelTwo+"(CHECK )");
            tLastAlert=time[rates_total - 1];
         }
      }
   }
   if(tLastAlert<time[rates_total - 1])
   {
      if((UseOnly7_2forEntryAlert==false && ShowOnlyBuyEntryAlerts==false))
      {
         if(dStochMain[1]>=LevelFour && dStochMain[0]<LevelFour  &&( HigherTF1STOCH[0] < 99 && HigherTF2STOCH[0] < 99))
         {
            fireAlerts("10.7 TREND SELL ALERT "+Symbol()+" Stoch dipped below "+LevelFour+"(CHECK )");
            tLastAlert=time[rates_total - 1];
         }
         if(dStochMain[1]>=LevelThree && dStochMain[0]<LevelThree  &&( HigherTF1STOCH[0] < 99 && HigherTF2STOCH[0] < 99))
         {
            fireAlerts(" HEY SELL "+Symbol()+" Stoch dipped below "+LevelThree+"(CHECK )");
            tLastAlert=time[rates_total - 1];
         }
      }
      if((UseOnly7_2forEntryAlert==false && ShowOnlySellEntryAlerts==false))
      {
         if(dStochMain[1]<=LevelOne && dStochMain[0]>LevelOne &&( HigherTF1STOCH[0] > 1 && HigherTF2STOCH[0] > 1))
         {
            fireAlerts(" 10.7 TREND BUY ALERT "+Symbol()+" Stoch pushed up above "+LevelOne+"(CHECK )");
            tLastAlert=time[rates_total - 1];
         }
         if(dStochMain[1]<=LevelTwo && dStochMain[0]>LevelTwo &&( HigherTF1STOCH[0] > 1 && HigherTF2STOCH[0] > 1))
         {
            fireAlerts(" HEY BUY "+Symbol()+" Stoch pushed up above "+LevelTwo+"(CHECK )");
            tLastAlert=time[rates_total - 1];
         }
      }
   }
   if(tLastAlert<time[rates_total - 1])
   {
      if((UseOnly7_2forEntryAlert==true && ShowOnlyBuyEntryAlerts==false))
      {
         if(dStochMain[1]>=LevelFour && dStochMain[0]<LevelFour)
         {
            fireAlerts("10.7 TREND SELL ALERT "+Symbol()+" Stoch dipped below "+LevelFour+"(CHECK )");
            tLastAlert=time[rates_total - 1];
         }
         if(dStochMain[1]>=LevelThree && dStochMain[0]<LevelThree)
         {
            fireAlerts(" HEY SELL "+Symbol()+" Stoch dipped below "+LevelThree+"(CHECK )");
            tLastAlert=time[rates_total - 1];
         }
      }
      if((UseOnly7_2forEntryAlert==true && ShowOnlySellEntryAlerts==false))
      {
         if(dStochMain[1]<=LevelOne && dStochMain[0]>LevelOne)
         {
            fireAlerts(" 10.7 TREND BUY ALERT "+Symbol()+" Stoch pushed up above "+LevelOne+"(CHECK )");
            tLastAlert=time[rates_total - 1];
         }
         if(dStochMain[1]<=LevelTwo && dStochMain[0]>LevelTwo)
         {
            fireAlerts(" HEY BUY "+Symbol()+" Stoch pushed up above "+LevelTwo+"(CHECK )");
            tLastAlert=time[rates_total - 1];
         }
      }
   }
   if(GiveStoch7ExitAlerts==true)
   {
      if(tLastAlert_fastexit<time[rates_total - 1])
      {
         if(CountSells(Symbol())>0 &&  dStochMain[0]<=LevelOne)
         {
            fireAlerts(" CLOSE YOUR SELL "+Symbol()+" Stoch7 dipped below "+LevelOne);
            tLastAlert_fastexit=time[rates_total - 1];
         }
         if(CountBuys(Symbol())>0 && dStochMain[0]>=LevelFour )
         {
            fireAlerts(" CLOSE YOUR BUY "+Symbol()+" Stoch7 pushed up above "+LevelFour);
            tLastAlert_fastexit=time[rates_total - 1];
         }
      }
   }
   if (GiveStoch2_1_ExitAlerts==true)
   {
      if(tLastAlert_exit<time[rates_total - 1])
      {
         if(CountSells(Symbol())>0 && (HigherTF1STOCH[0] >=99  || HigherTF2STOCH[0] >=99) )
         {
            fireAlerts(" CLOSE YOUR SELL "+Symbol()+" HTStoch changed to 100 ");
            tLastAlert_exit=time[rates_total - 1];
         }
         if(CountBuys(Symbol())>0 && (HigherTF1STOCH[0] <=1  || HigherTF2STOCH[0] <=1) )
         {
            fireAlerts(" CLOSE YOUR BUY "+Symbol()+" HTStoch changed to 0 ");
            tLastAlert_exit=time[rates_total - 1];
         }
      }
   }
   if(GiveTMASlopeExitAlert==true)
   {
      if(tLastAlert_cssexit<time[rates_total - 1])
      {
         if(CountSells(Symbol())>0 && TMASlopeVal[0]>=TMASlopeCloseSellAlertLevel)
         {
            fireAlerts(" TMASlope CLOSE YOUR SELL "+Symbol()+" TMASlope is >="+TMASlopeCloseSellAlertLevel);
            tLastAlert_cssexit=time[rates_total - 1];
         }
         if(CountBuys(Symbol())>0 && TMASlopeVal[0]<=TMASlopeCloseBuyAlertLevel)
         {
            fireAlerts(" TMASlope CLOSE YOUR BUY "+Symbol()+" TMASlope is <="+TMASlopeCloseBuyAlertLevel);
            tLastAlert_cssexit=time[rates_total - 1];
         }
      }
   }
   return(rates_total);
}

void fireAlerts(string sMsg)
{
   if(PopupAlert)
      Alert(sMsg);

   if(EmailAlert)
      SendMail("Stoch Alert On "+Symbol(),sMsg);
   if(PushAlert)
      SendNotification(sMsg);
}

int CountSells(string strSymbol)
{
   TradesIterator trades;
   trades.WhenSide(false);
   trades.WhenSymbol(strSymbol);
   return trades.Count();
}

int CountBuys(string strSymbol)
{
   TradesIterator trades;
   trades.WhenSide(true);
   trades.WhenSymbol(strSymbol);
   return trades.Count();
}

bool CloseEnough(double num1,double num2)
{
   if(num1==0 && num2==0) return(true); //0==0
   if(MathAbs(num1 - num2) / (MathAbs(num1) + MathAbs(num2)) < 0.00000001) return(true);
   return(false);
}//End bool CloseEnough(double num1, double num2)

double GetSlope(string symbol,ENUM_TIMEFRAMES tf,int shift)
{
   double buffer[1];
   if (CopyBuffer(atr, 0, shift + 10, 1, buffer) != 1)
   {
      return 0;
   }
   double atrValue = buffer[0] / 10;
   double gadblSlope=0.0;
   if(atrValue != 0)
   {
      double dblTma = calcTma(symbol,tf,shift);
      double dblPrev = calcTma(symbol,tf,shift+1);
      gadblSlope = (dblTma-dblPrev) / atrValue;
   }

   return gadblSlope;
}

double calcTma(string symbol,ENUM_TIMEFRAMES tf,int shift)
{
   double dblSum  = iClose(symbol, tf, shift) * 21;
   double dblSumw = 21;
   int jnx,knx;

   for(jnx=1,knx=20; jnx<=20; jnx++,knx--)
   {
      dblSum  += ( knx * iClose(symbol, tf, shift + jnx) );
      dblSumw += knx;

      if(jnx<=shift)
      {
         dblSum  += ( knx * iClose(symbol, tf, shift - jnx) );
         dblSumw += knx;
      }
   }

   return( dblSum / dblSumw );
}
