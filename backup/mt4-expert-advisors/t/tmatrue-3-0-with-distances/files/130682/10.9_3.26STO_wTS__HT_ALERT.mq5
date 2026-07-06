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
#property	indicator_maximum			102
#property	indicator_minimum			-2
#property	indicator_buffers			4
#property	indicator_plots			4
#property	indicator_color1			DodgerBlue
#property	indicator_width1			1
#property	indicator_width2			3
#property	indicator_color2			Gold
#property	indicator_width3			2
#property	indicator_color3			Red
#property	indicator_width4			4
#property	indicator_color4			Green

// user-defined parameters
input bool     ShowOnlyBuyEntryAlerts=false;
input bool     ShowOnlySellEntryAlerts=false;
input bool    ShowCounterTrend=false;//gives too CT alerts
input bool    ShowDaily2_1=false;//setting this to true the indicator shows to the D1 2.1.1 Stoch
input bool    ShowMonthly2_1=true;//setting this to true the indicator shows to the M1 2.1.1 Stoch
input bool   UseD1StochforAlert=false;// setting this to true the indicator uses D1 2.1.1 Stoch in combination with 7.2.2 you must set UseW1StochforAlert to false
input bool   UseW1StochforAlert=true;// setting this to true the indicator uses W1 2.1.1 Stoch in combination with 7.2.2 you must set UseD1StochforAlert to false
input bool   UseOnly7_2forEntryAlert=false;// this setting will only use the Stoch 7.2.2 for the enrty alerts the HigherTF Stoch 2.1.1 is not used independend from the above setting
input bool      PopupAlert=true; // ALERTS WHEN WHENEVER PRICE GOES BELOW 90&70 AND ABOVE 10&30 AND HT STOCH CONFIRMS 
input bool      EmailAlert= false;
input bool      PushAlert=false;
input bool    GiveStoch2_1_ExitAlerts=false;//set this to false if you have set ShowCounterTrend to true, because it will give you an immediatly exit alert in that case
input bool    GiveStoch7ExitAlerts=false;//gives Stoch 7.2.2 exits alerts for BUY if we have Stoch 7.2.2 >=90 and for SELL if we have  Stoch 7.2.2<=10
input bool    GiveTMASlopeExitAlert=false;
input ENUM_TIMEFRAMES HigherTF_Used = PERIOD_D1; // Timeframe 1
input ENUM_TIMEFRAMES HigherTF2_Used = PERIOD_W1; // Timeframe 2
input ENUM_TIMEFRAMES HigherTF3_Used = PERIOD_MN1; // Timeframe 3
input string  Set_Stoch_Alert_Levels="Default = 10, 30, 70, 90";
input int     LevelOne   = 10;  // default = 20
input int     LevelTwo   = 30; //CHANGE TO 10 IF YOU ONLY WANT 1 ALERT // default = 40
input int     LevelThree = 70; //CHANGE TO 90 IF YOU ONLY WANT 1 ALERT // default = 60
input int     LevelFour  = 90;  // default = 80

input string  Stoch_Settings="Default = 7, 2, 2, 2, 1";

input int   KPeriod = 7;
input int   DPeriod = 2;
input int   Slowing = 2;
input ENUM_MA_METHOD Method = MODE_SMMA; // Smoothing method
input ENUM_STO_PRICE Price = STO_CLOSECLOSE;
input int K_period_HT = 2;
input int D_period_HT = 1;
input int S_period_HT = 1;
input ENUM_STO_PRICE STOCH_MAIN_Price_HT = STO_CLOSECLOSE;
input ENUM_STO_PRICE STOCH_SIGNAL_Price_HT = STO_CLOSECLOSE;
input ENUM_MA_METHOD STOCH_MAIN_Ma_HT = MODE_SMMA;
input ENUM_MA_METHOD STOCH_SIGNAL_Ma_HT = MODE_SMMA;
input int STOCH_MAIN_Line_Style_HT  =2;
input int STOCH_SIGNAL_Line_Style_HT=2;
input string  Level_Styles            = "0 Solid, 1 Dash, 2 Dot, 3 Dashdot, 4 Dashdotdot";
input int     LevelOneStyle           = 0;
input color   LevelOneColor           = DodgerBlue;
input int     LevelTwoStyle           = 2;
input color   LevelTwoColor           = DodgerBlue;
input int     LevelThreeStyle         = 2; 
input color   LevelThreeColor         = Gold;
input int     LevelFourStyle          = 0;
input color   LevelFourColor          = Gold;
input string   slp="--TMA-SlopeSettings--";
input ENUM_TIMEFRAMES TMASlopeTF = PERIOD_H4;
input double   TMASlopeCloseBuyAlertLevel=-0.3;
input double   TMASlopeCloseSellAlertLevel=0.3;
// object parameters
int      verticalShift = 14;
int      verticalOffset = 30;
int      horizontalShift = 100;
int      horizontalOffset = 10;
string showText;
   color StochColour=Gold;
    string objectName = "Stoch_7_2_2_Value";
  
   int tableOffset = -100;
double          TMASlopeVal[8];
bool     BrokerHasSundayCandle=false;
int count_var=0;
// indicator buffers
double dStochMain[];
double HTStochMain[];
double HT2StochMain[];
double HT3StochMain[];

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
int stoch1, stoch2, stoch, atr, stoch3, stoch4;
int OnInit(void)
{
   count_var=0;
   if (ShowOnlyBuyEntryAlerts==true && ShowOnlySellEntryAlerts==true)
   {
      Alert("As you can only one set to true!!");
      return INIT_FAILED;
   }
   if (UseD1StochforAlert==true && UseW1StochforAlert==true)
   {
      Alert("As you can only one set to true!!");
      return INIT_FAILED;
   }
   IndicatorName = GenerateIndicatorName("10.9 STOCH7wHTSTOCH_Alert");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorSetString(INDICATOR_SHORTNAME, IndicatorName);
   IndicatorSetInteger(INDICATOR_DIGITS, Digits());

   stoch = iStochastic(NULL, 0, KPeriod, DPeriod, Slowing, Method, Price);
   stoch1 = iStochastic(_Symbol, HigherTF_Used, K_period_HT, D_period_HT, S_period_HT, STOCH_MAIN_Ma_HT, STOCH_MAIN_Price_HT);
   stoch2 = iStochastic(_Symbol, HigherTF2_Used, K_period_HT, D_period_HT, S_period_HT, STOCH_MAIN_Ma_HT, STOCH_MAIN_Price_HT);
   stoch3 = iStochastic(_Symbol, HigherTF3_Used, K_period_HT, D_period_HT, S_period_HT, STOCH_MAIN_Ma_HT, STOCH_MAIN_Price_HT);
   stoch4 = iStochastic(_Symbol, PERIOD_H4, K_period_HT, D_period_HT, S_period_HT, STOCH_MAIN_Ma_HT, STOCH_MAIN_Price_HT);
   atr = iATR(_Symbol, TMASlopeTF, 60);

   SetIndexBuffer(0, dStochMain, INDICATOR_DATA);
   PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetString(0, PLOT_LABEL, "Stoch Main");
   if(ShowDaily2_1==true)
   {
      SetIndexBuffer(1, HTStochMain, INDICATOR_DATA);
      PlotIndexSetInteger(1, PLOT_DRAW_TYPE, DRAW_LINE);
      PlotIndexSetString(1, PLOT_LABEL, "HTStochMain");
   }
   else
   {
      SetIndexBuffer(1, HTStochMain, INDICATOR_CALCULATIONS);
   }
   SetIndexBuffer(2, HT2StochMain, INDICATOR_DATA);
   PlotIndexSetInteger(2, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetString(2, PLOT_LABEL, "HT2StochMain");
   if(ShowMonthly2_1==true)
   {
      SetIndexBuffer(3, HT3StochMain, INDICATOR_DATA);
      PlotIndexSetInteger(3, PLOT_DRAW_TYPE, DRAW_LINE);
      PlotIndexSetString(3, PLOT_LABEL, "HT3StochMain");
   }
   else
   {
      SetIndexBuffer(3, HT3StochMain, INDICATOR_CALCULATIONS);
   }

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
  
   ObjectCreate(0, IndicatorObjPrefix +  objectName, OBJ_LABEL, indiWindow, 0, 0 ) ;
   ObjectSetInteger(0, IndicatorObjPrefix +  objectName, OBJPROP_CORNER, 1 );
   ObjectSetInteger(0, IndicatorObjPrefix +  objectName, OBJPROP_XDISTANCE, horizontalShift * 0 + horizontalOffset + 120 + tableOffset );
   ObjectSetInteger(0, IndicatorObjPrefix +  objectName, OBJPROP_YDISTANCE, verticalOffset - 28 );

   return INIT_SUCCEEDED;//INIT_FAILED
}

void OnDeinit(const int reason)
{
   count_var=0;
   ObjectsDeleteAll(0, IndicatorObjPrefix);
   IndicatorRelease(atr);
   IndicatorRelease(stoch);
   IndicatorRelease(stoch1);
   IndicatorRelease(stoch2);
   IndicatorRelease(stoch3);
   IndicatorRelease(stoch4);
}

void ObjectSetText(string id, string text, int fontSize, string font, color clr)
{
   ObjectSetString(0, id, OBJPROP_TEXT, text);
   ObjectSetString(0, id, OBJPROP_FONT, font);
   ObjectSetInteger(0, id, OBJPROP_FONTSIZE, fontSize);
   ObjectSetInteger(0, id, OBJPROP_COLOR, clr);
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
   int BrokerHour=TimeHour(TimeCurrent());
   BrokerHasSundayCandle=false;
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
   double HigherTFSTOCH;
   if (UseD1StochforAlert == true) 
      HigherTFSTOCH = HigherTF1STOCH[0];
   else if(UseW1StochforAlert==true) 
      HigherTFSTOCH = HigherTF2STOCH[0];
   else
      HigherTFSTOCH = HigherTF2STOCH[0];

   static datetime tLastAlert=0;
   static datetime tLastAlert_exit=0;
   static datetime tLastAlert_fastexit= 0;
   static datetime tLastAlert_cssexit = 0;

   int i=0;
   int y2=0,y3=0,y4=0,y5=0;
   for(i=0,y2=0,y3=0,y4=0,y5=0; i < rates_total; i++)
   {
      if (time[rates_total - 1 - i] < time[rates_total - 1 - y2])
         y2++;
      if(time[rates_total - 1 - i] < iTime(_Symbol, HigherTF_Used, y3)) 
         y3++;
      if(time[rates_total - 1 - i] < iTime(_Symbol, HigherTF2_Used, y4)) 
         y4++;
      if(time[rates_total - 1 - i] < iTime(_Symbol, HigherTF3_Used, y5)) 
         y5++;
      if(d == 1 && BrokerHasSundayCandle && Period()==1440 && i==0)
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
         dStochMain[rates_total - 1]=(buffer1[0] + BrokerHour * buffer2[0]) / (1 + BrokerHour);
      }
      if(d == 1 && BrokerHasSundayCandle && HigherTF_Used==1440 && i==0)
      {
         double buffer1[1];
         if (CopyBuffer(stoch1, MAIN_LINE, 1, 1, buffer1) != 1)
         {
            continue;
         }
         HTStochMain[rates_total - 1 -0] = (buffer1[0] + BrokerHour * buffer1[0]) / (1 + BrokerHour);
      }
      if(d == 1 && BrokerHasSundayCandle && HigherTF2_Used==1440 && i==0)
      {
         double buffer1[1];
         if (CopyBuffer(stoch2, MAIN_LINE, 1, 1, buffer1) != 1)
         {
            continue;
         }
         HT2StochMain[rates_total - 1 -0] = (buffer1[0] + BrokerHour * buffer1[0]) / (1 + BrokerHour);
      }
      double buffer[1];
      if (CopyBuffer(stoch, MAIN_LINE, y2, 1, buffer) != 1)
      {
         continue;
      }
      dStochMain[rates_total - 1 - i] = buffer[0];
    
      double buffer1[1];
      if (CopyBuffer(stoch1, MAIN_LINE, y3, 1, buffer1) != 1)
      {
         continue;
      }
      HTStochMain[rates_total - 1 -i] = buffer1[0];
    
      double buffer2[1];
      if (CopyBuffer(stoch2, MAIN_LINE, y4, 1, buffer2) != 1)
      {
         continue;
      }
      HT2StochMain[rates_total - 1 -i] = buffer2[0];
      double buffer3[1];
      if (CopyBuffer(stoch3, MAIN_LINE, y5, 1, buffer3) != 1)
      {
         continue;
      }
      HT3StochMain[rates_total - 1 -i] = buffer3[0];
   }
   if(d == 1 && BrokerHasSundayCandle && TMASlopeTF==1440)  
      tma_bar=tma_bar+1;
     
   double HT4Stoch[2];
   string tendenza=" neutrale";
   if (CopyBuffer(stoch4, MAIN_LINE, 0, 2, HT4Stoch) != 2)
   {
      return 0;
   }
   if (HT4Stoch[0] < HT4Stoch[1])
   {
      StochColour=Red;
      tendenza=" moving down";
   }
   if (HT4Stoch[0] > HT4Stoch[1])
   {
      StochColour=Green;
      tendenza=" moving up";
   }
    
   TMASlopeVal[0]= GetSlope(Symbol(),TMASlopeTF,tma_bar);
   TMASlopeVal[1]= GetSlope(Symbol(),TMASlopeTF,tma_bar+1);
   ObjectSetText ( objectName, "H4Stoch(7/2/2)"+DoubleToString(HT4Stoch[0],3)+tendenza, 10, "Lucida Console",StochColour );
   if(tLastAlert<time[rates_total - 1])
   {
      if((ShowCounterTrend==true && UseOnly7_2forEntryAlert==false && ShowOnlyBuyEntryAlerts==false))
      {
         if(dStochMain[rates_total - 1 - 1]>=LevelFour && dStochMain[rates_total - 1 - 0]<LevelFour && HigherTFSTOCH >=99)
         {
            fireAlerts(" 10.10 (CT) TRADE SELL ALERT "+Symbol()+" Stoch dipped below "+LevelFour+"(CHECK CHART)");
            tLastAlert=time[rates_total - 1];
         }
         if(dStochMain[rates_total - 1 - 1]>=LevelThree && dStochMain[rates_total - 1 - 0]<LevelThree && HigherTFSTOCH >=99)
         {
            fireAlerts(" LAST CALL(CT)TRADE SELL "+Symbol()+" Stoch dipped below "+LevelThree+" (CHECK CHART)");
            tLastAlert=time[rates_total - 1];
         }
      }
      if((ShowCounterTrend==true && UseOnly7_2forEntryAlert==false && ShowOnlySellEntryAlerts==false))
      {
         if(dStochMain[rates_total - 1 - 1]<=LevelOne && dStochMain[rates_total - 1 - 0]>LevelOne && HigherTFSTOCH <=1)
         {
            fireAlerts(" 10.10(CT)TRADE BUY ALERT "+Symbol()+" Stoch pushed up above "+LevelOne+"(CHECK CHART)");
            tLastAlert=time[rates_total - 1];
         }
         if(dStochMain[rates_total - 1 - 1]<=LevelTwo && dStochMain[rates_total - 1 - 0]>LevelTwo && HigherTFSTOCH <=1)
         {
            fireAlerts(" LAST CALL(CT)TRADE BUY "+Symbol()+" Stoch pushed up above "+LevelTwo+"(CHECK CHART)");
            tLastAlert=time[rates_total - 1];
         }
      }
   }
   if(tLastAlert<time[rates_total - 1])
   {
      if((UseOnly7_2forEntryAlert==false && ShowOnlyBuyEntryAlerts==false))
      {
         if(dStochMain[rates_total - 1 - 1]>=LevelFour && dStochMain[rates_total - 1 - 0]<LevelFour && HigherTFSTOCH < 99)
         {
            fireAlerts("10.7 SELL OR CLOSE BUY ALERT "+Symbol()+" Stoch dipped below "+LevelFour+"(CHECK CHART)");
            tLastAlert=time[rates_total - 1];
         }
         if(dStochMain[rates_total - 1 - 1]>=LevelThree && dStochMain[rates_total - 1 - 0]<LevelThree && HigherTFSTOCH < 99)
         {
            fireAlerts(" 10.7 SELL "+Symbol()+" Stoch dipped below "+LevelThree+"(CHECK CHART)");
            tLastAlert=time[rates_total - 1];
         }
      }
      if((UseOnly7_2forEntryAlert==false && ShowOnlySellEntryAlerts==false))
      {
         if(dStochMain[rates_total - 1 - 1]<=LevelOne && dStochMain[rates_total - 1 - 0]>LevelOne && HigherTFSTOCH > 1)
         {
            fireAlerts(" 10.7 BUY OR CLOSE SELL ALERT "+Symbol()+" Stoch pushed up above "+LevelOne+"(CHECK CHART)");
            tLastAlert=time[rates_total - 1];
         }
         if(dStochMain[rates_total - 1 - 1]<=LevelTwo && dStochMain[rates_total - 1 - 0]>LevelTwo && HigherTFSTOCH > 1)
         {
            fireAlerts(" 10.7 BUY "+Symbol()+" Stoch pushed up above "+LevelTwo+"(CHECK CHART)");
            tLastAlert=time[rates_total - 1];
         }
      }
   }
   if(tLastAlert<time[rates_total - 1])
   {
      if((UseOnly7_2forEntryAlert==true && ShowOnlyBuyEntryAlerts==false))
      {
         if(dStochMain[rates_total - 1 - 1]>=LevelFour && dStochMain[rates_total - 1 - 0]<LevelFour)
         {
            fireAlerts("10.9 SELL OR CLOSE BUY ALERT  "+Symbol()+" Stoch dipped below "+LevelFour+"(CHECK CHART)");
            tLastAlert=time[rates_total - 1];
         }
         if(dStochMain[rates_total - 1 - 1]>=LevelThree && dStochMain[rates_total - 1 - 0]<LevelThree)
         {
            fireAlerts(" 10.9 SELL "+Symbol()+" Stoch dipped below "+LevelThree+"(CHECK CHART)");
            tLastAlert=time[rates_total - 1];
         }
      }
      if((UseOnly7_2forEntryAlert==true && ShowOnlySellEntryAlerts==false))
      {
         if(dStochMain[rates_total - 1 - 1]<=LevelOne && dStochMain[rates_total - 1 - 0]>LevelOne)
         {
            fireAlerts(" 10.9 BUY OR CLOSE SELL ALERT "+Symbol()+" Stoch pushed up above "+LevelOne+"(CHECK CHART)");
            tLastAlert=time[rates_total - 1];
         }
         if(dStochMain[rates_total - 1 - 1]<=LevelTwo && dStochMain[rates_total - 1 - 0]>LevelTwo)
         {
            fireAlerts(" 10.9 BUY "+Symbol()+" Stoch pushed up above "+LevelTwo+"(CHECK CHART)");
            tLastAlert=time[rates_total - 1];
         }
      }
   }

   if(GiveStoch7ExitAlerts==true)
   {
      if(tLastAlert_fastexit<time[rates_total - 1])
      {
         if(CountSells(Symbol())>0 && dStochMain[rates_total - 1 - 0]<=LevelOne)
         {
            fireAlerts(" CLOSE YOUR SELL "+Symbol()+" Stoch7 dipped below "+LevelOne);
            tLastAlert_fastexit=time[rates_total - 1];
         }
         if(CountBuys(Symbol())>0 && dStochMain[rates_total - 1 - 0]>=LevelFour )
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
         if(CountSells(Symbol())>0 && HigherTFSTOCH >=99)
         {
            fireAlerts(" CLOSE YOUR SELL "+Symbol()+" HTStoch changed to 100 ");
            tLastAlert_exit=time[rates_total - 1];
         }
         if(CountBuys(Symbol())>0 && HigherTFSTOCH <=1 )
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
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void fireAlerts(string sMsg)
  {

   if(PopupAlert)
      Alert(sMsg);

   if(EmailAlert)
      SendMail("Stoch Alert On "+Symbol(),sMsg);
      if(PushAlert)
SendNotification(sMsg);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
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
//+------------------------------------------------------------------+
//| calcTma()                                                        |
//+------------------------------------------------------------------+
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