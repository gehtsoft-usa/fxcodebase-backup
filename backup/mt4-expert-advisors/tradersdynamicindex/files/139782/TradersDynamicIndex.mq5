// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=70751

//+------------------------------------------------------------------+
//|                               Copyright © 2020, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |
//|                                           mario.jemic@gmail.com  |
//|                          https://AppliedMachineLearning.systems  |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  |
//|                                  Paypal : https://goo.gl/9Rj74e  |
//|                                 Patreon : https://goo.gl/GdXWeN  |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2020, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.0"
 

#property description "Shows trend direction, strength, and volatility."
#property description "Green line  - RSI Price line."
#property description "Red line    - Trade Signal line."
#property description "Blue lines  - Volatility Band."
#property description "Yellow line - Market Base line."

#property indicator_separate_window
#property indicator_buffers 7
#property indicator_plots   5
#property indicator_level1 32
#property indicator_level2 50
#property indicator_level3 68
#property indicator_minimum 0
#property indicator_maximum 100
#property indicator_levelcolor clrDimGray
#property indicator_levelstyle STYLE_DOT
#property indicator_levelwidth 1
#property indicator_color1 clrMediumBlue
#property indicator_label1 "VB High"
#property indicator_type1  DRAW_LINE
#property indicator_width1 1
#property indicator_style1 STYLE_SOLID
#property indicator_color2 clrYellow
#property indicator_label2 "Market Base Line"
#property indicator_type2  DRAW_LINE
#property indicator_width2 2
#property indicator_style2 STYLE_SOLID
#property indicator_color3 clrMediumBlue
#property indicator_label3 "VB Low"
#property indicator_type3  DRAW_LINE
#property indicator_width3 1
#property indicator_style3 STYLE_SOLID


#property indicator_color4 clrGreen, Red
#property indicator_label4 "RSI Price Line"
#property indicator_type4  DRAW_COLOR_HISTOGRAM2
#property indicator_width4 2
#property indicator_style4 STYLE_SOLID

enum ENUM_TRIGGER_CANDLE
{
   Currrent_Candle,
   Wait_for_Close
};

enum SourceMode
{
   SourceRSI, // RSI
   SourceDMI, // ADX
   SourceDemarker, // Demarker
   SourceStochastic // Stochastic
};

enum ChannelMode
{
   ChannelBB, // Bollinger bands
   ChannelStDev, // Standard deviation
   ChannelDonchian, // Donchian
   ChannelKeltner // Keltner
};

input SourceMode source_mode = SourceRSI; // Source
input ChannelMode channel_mode = ChannelBB; // Channel
input int RSI_Period = 13; // RSI_Period: 8-25
input ENUM_APPLIED_PRICE RSI_Price = PRICE_CLOSE;
input int Volatility_Band = 34; // Volatility_Band: 20-40
input double StdDev = 1.6185; // Standard Deviations: 1-3
input int RSI_Price_Line = 2;      
input ENUM_MA_METHOD RSI_Price_Type = MODE_SMA;
input int Trade_Signal_Line = 7;   
input ENUM_MA_METHOD Trade_Signal_Type = MODE_SMA;
input bool AlertNative = false; // AlertNative: Alert popup inside platform.
input bool AlertSound = false; // AlertSound: Play a sound on alert.
input bool AlertEmail = false; // AlertEmail: Send an email on alert.
input bool AlertNotification = false; // AlertNotification: Send a push notification on alert.
input bool EnableHookAlert = false; // EnableHookAlert: Enable green line hook alerts.
input ENUM_TRIGGER_CANDLE AlertOnCandle = Wait_for_Close; // Alert on Candle
input int bars_limit = 10000; // Bars limit

double RSIBuf[], UpZone[], MdZone[], DnZone[], MaBuf[], MbBuf[], BarColor[];

int MaxPeriod = 0, TriggerCandle;

datetime AlertPlayed = 0, HookAlertPlayed = 0;

int RSI_handle;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
{
   IndicatorSetString(INDICATOR_SHORTNAME, "TDI(" + IntegerToString(RSI_Period) + "," + IntegerToString(Volatility_Band) + "," + IntegerToString(RSI_Price_Line) + "," + IntegerToString(Trade_Signal_Line) +  ")");

   SetIndexBuffer(0, UpZone, INDICATOR_DATA);
   SetIndexBuffer(1, MdZone, INDICATOR_DATA);
   SetIndexBuffer(2, DnZone, INDICATOR_DATA);
   SetIndexBuffer(3, MaBuf, INDICATOR_DATA);
   SetIndexBuffer(4, MbBuf, INDICATOR_DATA);
   SetIndexBuffer(5, BarColor, INDICATOR_COLOR_INDEX);
   SetIndexBuffer(6, RSIBuf, INDICATOR_CALCULATIONS);
   
   ArraySetAsSeries(UpZone, true);
   ArraySetAsSeries(MdZone, true);
   ArraySetAsSeries(DnZone, true);
   ArraySetAsSeries(MaBuf, true);
   ArraySetAsSeries(MbBuf, true);
   ArraySetAsSeries(RSIBuf, true);
   
   PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, 0);
   PlotIndexSetDouble(1, PLOT_EMPTY_VALUE, 0);
   PlotIndexSetDouble(2, PLOT_EMPTY_VALUE, 0);
   PlotIndexSetDouble(3, PLOT_EMPTY_VALUE, 0);
   PlotIndexSetDouble(4, PLOT_EMPTY_VALUE, 0);

   IndicatorSetInteger(INDICATOR_DIGITS, 1);
   
 	switch (source_mode)
   {
      case SourceRSI:
         RSI_handle = iRSI(Symbol(), Period(), RSI_Period, RSI_Price);
         break;
      case SourceDMI:
         RSI_handle = iADX(_Symbol, _Period, RSI_Period);
         break;
      case SourceDemarker:
         RSI_handle = iDeMarker(_Symbol, _Period, RSI_Period);
         break;
      case SourceStochastic:
         RSI_handle = iStochastic(_Symbol, _Period, RSI_Period, 3, 3, MODE_SMA, STO_LOWHIGH);
         break;
   }

   MaxPeriod = Volatility_Band + RSI_Period;

   PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, MaxPeriod);
   PlotIndexSetInteger(1, PLOT_DRAW_BEGIN, MaxPeriod);
   PlotIndexSetInteger(2, PLOT_DRAW_BEGIN, MaxPeriod);
   PlotIndexSetInteger(3, PLOT_DRAW_BEGIN, MaxPeriod + RSI_Price_Line);
   PlotIndexSetInteger(4, PLOT_DRAW_BEGIN, MaxPeriod + Trade_Signal_Line);
   
   if (AlertOnCandle == Currrent_Candle)
   {
      TriggerCandle = 0;
   }
   else // Wait for close.
   {
      TriggerCandle = 1;
   }
}

//+------------------------------------------------------------------+
//| Traders Dynamic Index                                            |
//+------------------------------------------------------------------+
int OnCalculate(const int        rates_total,
                const int        prev_calculated,
                const datetime&  Time[],
                const double&    open[],
                const double&    high[],
                const double&    low[],
                const double&    close[],
                const long&      tick_volume[],
                const long&      volume[],
                const int&       spread[]
)
{
   ArraySetAsSeries(Time, true);

   int i;
   int counted_bars = prev_calculated;

   // Too few bars to work with.
   if (rates_total < MaxPeriod) 
      return(0);

   i = rates_total - counted_bars;
   if (i > rates_total - MaxPeriod - 1) 
      i = rates_total - MaxPeriod - 1;
 
   int RSI_bars = CopyBuffer(RSI_handle, 0, 0, i + Volatility_Band, RSIBuf); // No need to copy all RSI for too old bars.
   if (RSI_bars == -1) 
      return(0);
	
   switch (channel_mode)
   {
      case ChannelBB:
         {
            double MA, RSI[];
            ArrayResize(RSI, Volatility_Band);
            while (i >= 0) 
            {
               MA = 0;
               for (int x = i; x < i + Volatility_Band; x++)
               {
                  RSI[x - i] = RSIBuf[x];
                  MA += RSIBuf[x] / Volatility_Band;
               }
               double SD = StdDev * StDev(RSI, Volatility_Band);
               UpZone[i] = MA + SD;
               DnZone[i] = MA - SD;
               MdZone[i] = (UpZone[i] + DnZone[i]) / 2;
            
               i--;
            }
         }
         break;
      case ChannelStDev:
         {
            int first = Volatility_Band;
            for (int pos = MathMax(rates_total - 1 - bars_limit, MathMax(first, prev_calculated - 1)); pos < rates_total; ++pos)
            {
               int oldPos = rates_total - pos - 1;
               double SD = StDev(RSIBuf, Volatility_Band, pos);
               UpZone[i] = RSIBuf[pos] + SD;
               DnZone[i] = RSIBuf[pos] - SD;
               MdZone[i] = RSIBuf[pos];
            }
         }
         break;
      case ChannelDonchian:
         {
            double Max_High = 0;
            double Min_Low = 0;
            int first = Volatility_Band;
            for (int pos = MathMax(rates_total - 1 - bars_limit, MathMax(first, prev_calculated - 1)); pos < rates_total; ++pos)
            {
               int oldPos = rates_total - pos - 1;
               int highestIndex = ArrayMaximum(RSIBuf, pos - Volatility_Band, Volatility_Band);
               UpZone[pos] = RSIBuf[highestIndex];
               int lowestIndex = ArrayMinimum(RSIBuf, pos - Volatility_Band, Volatility_Band);
               DnZone[pos] = RSIBuf[lowestIndex];
               MdZone[pos] = (UpZone[pos] + DnZone[pos]) / 2;
            }
         }
         break;
      case ChannelKeltner:
         {
            int first = Volatility_Band;
            for (int pos = MathMax(rates_total - 1 - bars_limit, MathMax(first, prev_calculated - 1)); pos < rates_total; ++pos)
            {
               int oldPos = rates_total - pos - 1;
               double summ = 0;
               for (int i = 0; i < Volatility_Band; ++i)
               {
                  summ += RSIBuf[i];
               }
               MdZone[pos] = summ / Volatility_Band;
               DnZone[pos] = MdZone[pos] - MdZone[pos] * StdDev;
               UpZone[pos] = MdZone[pos] + MdZone[pos] * StdDev;
            }
         }
         break;
   }

   i = rates_total - counted_bars;
   if (i > rates_total - MaxPeriod - 1) i = rates_total - MaxPeriod - 1;
 
   // Calculate MAs of RSI.
   while (i >= 0)
   {
      MaBuf[i] = iMAOnArray(RSIBuf, 0, RSI_Price_Line, 0, RSI_Price_Type, i);
      MbBuf[i] = iMAOnArray(RSIBuf, 0, Trade_Signal_Line, 0, Trade_Signal_Type, i);
      BarColor[i] = MaBuf[i] > MbBuf[i] ? 0 : 1;
   	
   	i--;
   }
   
   if ((MbBuf[TriggerCandle] > MdZone[TriggerCandle]) && (MbBuf[TriggerCandle + 1] <= MdZone[TriggerCandle + 1]) && (AlertPlayed != Time[0]))
   {
      if (AlertNative) Alert("Bullish cross");
      if (AlertSound) PlaySound("alert.wav");
      if (AlertEmail)
      {
         SendMail("TDI Alert: BUY " + _Symbol + " @ " + PeriodToString(_Period), "Current rate = " + DoubleToString(SymbolInfoDouble(_Symbol, SYMBOL_BID), _Digits) + "/" + DoubleToString(SymbolInfoDouble(_Symbol, SYMBOL_ASK), _Digits) + "\nIndicator buffers:\nVB High = " + DoubleToString(UpZone[TriggerCandle], 1) + "\nMarket Base Line = " + DoubleToString(MdZone[TriggerCandle], 1) + "\nVB Low = " + DoubleToString(DnZone[TriggerCandle], 1) + "\nRSI Price Line = " + DoubleToString(MaBuf[TriggerCandle], 1) + "\nTrade Signal Line = " + DoubleToString(MbBuf[TriggerCandle], 1));
      }
      if (AlertNotification) SendNotification("TDI Alert: BUY " + _Symbol + " @ " + PeriodToString(_Period));
      AlertPlayed = Time[0];
   }
   if ((MbBuf[TriggerCandle] < MdZone[TriggerCandle]) && (MbBuf[TriggerCandle + 1] >= MdZone[TriggerCandle + 1]) && (AlertPlayed != Time[0]))
   {
      if (AlertNative) Alert("Bearish cross");
      if (AlertSound) PlaySound("alert.wav");
      if (AlertEmail)
      {
         SendMail("TDI Alert: SELL " + _Symbol + " @ " + PeriodToString(_Period), "Current rate = " + DoubleToString(SymbolInfoDouble(_Symbol, SYMBOL_BID), _Digits) + "/" + DoubleToString(SymbolInfoDouble(_Symbol, SYMBOL_ASK), _Digits) + "\nIndicator buffers:\nVB High = " + DoubleToString(UpZone[TriggerCandle], 1) + "\nMarket Base Line = " + DoubleToString(MdZone[TriggerCandle], 1) + "\nVB Low = " + DoubleToString(DnZone[TriggerCandle], 1) + "\nRSI Price Line = " + DoubleToString(MaBuf[TriggerCandle], 1) + "\nTrade Signal Line = " + DoubleToString(MbBuf[TriggerCandle], 1));
      }
      if (AlertNotification) SendNotification("TDI Alert: SELL " + _Symbol + " @ " + PeriodToString(_Period));
      AlertPlayed = Time[0];
   }
   
   if (EnableHookAlert)
   {
      // Green line crosses upper blue line from above when both are above level 68.
      if ((MaBuf[TriggerCandle] < UpZone[TriggerCandle]) && (MaBuf[TriggerCandle + 1] >= UpZone[TriggerCandle + 1]) && ((MaBuf[TriggerCandle] > 68) || (MaBuf[TriggerCandle + 1] > 68)) && ((UpZone[TriggerCandle] > 68) || (UpZone[TriggerCandle + 1] > 68)) && (HookAlertPlayed != Time[0]))
      {
         if (AlertNative) Alert("Bearish Hook");
         if (AlertSound) PlaySound("alert.wav");
         if (AlertEmail)
         {
            SendMail("TDI Hook Alert: SELL " + _Symbol + " @ " + PeriodToString(_Period), "Current rate = " + DoubleToString(SymbolInfoDouble(_Symbol, SYMBOL_BID), _Digits) + "/" + DoubleToString(SymbolInfoDouble(_Symbol, SYMBOL_ASK), _Digits) + "\nIndicator buffers:\nVB High = " + DoubleToString(UpZone[TriggerCandle], 1) + "\nMarket Base Line = " + DoubleToString(MdZone[TriggerCandle], 1) + "\nVB Low = " + DoubleToString(DnZone[TriggerCandle], 1) + "\nRSI Price Line = " + DoubleToString(MaBuf[TriggerCandle], 1) + "\nTrade Signal Line = " + DoubleToString(MbBuf[TriggerCandle], 1));
         }
         if (AlertNotification) SendNotification("TDI Hook Alert: SELL " + _Symbol + " @ " + PeriodToString(_Period));
         HookAlertPlayed = Time[0];
      }
      // Green line crosses lower blue line from below when both are below level 32.
      else if ((MaBuf[TriggerCandle] > DnZone[TriggerCandle]) && (MaBuf[TriggerCandle + 1] <= DnZone[TriggerCandle + 1]) && ((MaBuf[TriggerCandle] < 32) || (MaBuf[TriggerCandle + 1] < 32)) && ((DnZone[TriggerCandle] < 32) || (DnZone[TriggerCandle + 1] < 32)) && (HookAlertPlayed != Time[0]))
      {
         if (AlertNative) Alert("Bullish Hook");
         if (AlertSound) PlaySound("alert.wav");
         if (AlertEmail)
         {
            SendMail("TDI Hook Alert: BUY " + _Symbol + " @ " + PeriodToString(_Period), "Current rate = " + DoubleToString(SymbolInfoDouble(_Symbol, SYMBOL_BID), _Digits) + "/" + DoubleToString(SymbolInfoDouble(_Symbol, SYMBOL_ASK), _Digits) + "\nIndicator buffers:\nVB High = " + DoubleToString(UpZone[TriggerCandle], 1) + "\nMarket Base Line = " + DoubleToString(MdZone[TriggerCandle], 1) + "\nVB Low = " + DoubleToString(DnZone[TriggerCandle], 1) + "\nRSI Price Line = " + DoubleToString(MaBuf[TriggerCandle], 1) + "\nTrade Signal Line = " + DoubleToString(MbBuf[TriggerCandle], 1));
         }
         if (AlertNotification) SendNotification("TDI Hook Alert: BUY " + _Symbol + " @ " + PeriodToString(_Period));
         HookAlertPlayed = Time[0];
      }
   }
   
   return(rates_total);
}

double StDev(double& data[], int period, int pos)
{
   return MathSqrt(Variance(data, period, pos));
}
double Variance(double& data[], int period, int pos)
{
   double sum = 0;
   double ssum = 0;
   for (int i = 0; i < period; i++)
   {
      sum += data[pos - i];
      ssum += MathPow(data[pos - i], 2);
   }
   return (ssum * period - sum * sum) / (period * (period - 1));
}

// Standard Deviation function.
double StDev(double& Data[], int Per)
{
	return(MathSqrt(Variance(Data, Per)));
}

// Math Variance function.
double Variance(double& Data[], int Per)
{
	double sum = 0, ssum = 0;
	for (int i = 0; i < Per; i++)
	{
		sum += Data[i];
		ssum += MathPow(Data[i], 2);
	}
	return((ssum * Per - sum * sum) / (Per * (Per - 1)));
}

//+------------------------------------------------------------------+
//| Based on http://www.mql5.com/en/articles/81                      |
//| Simplified SMA calculation.			                              |
//+------------------------------------------------------------------+
double iMAOnArray(double &Array[], int total, int iMAPeriod, int ma_shift, ENUM_MA_METHOD ma_method, int Shift)
{
	double buf[];
	if ((total > 0) && (total <= iMAPeriod)) return(0);
	if (total == 0) total = ArraySize(Array);
	if (ArrayResize(buf, total) < 0) return(0);
	
	switch(ma_method)
	{
		// Simplified SMA. No longer works with ma_shift parameter.
		case MODE_SMA:
		{
			double sum = 0;
			for (int i = Shift; i < Shift + iMAPeriod; i++)
				sum += Array[i] / iMAPeriod;
			return(sum);
		}
		case MODE_EMA:
		{
			double pr = 2.0 / (iMAPeriod + 1);
			int pos = total - 2;
			while (pos >= 0)
			{
				if (pos == total - 2) buf[pos + 1] = Array[pos + 1];
				buf[pos] = Array[pos] * pr + buf[pos + 1] * (1 - pr);
				pos--;
			}
			return(buf[Shift + ma_shift]);
		}
		case MODE_SMMA:
		{
			double sum = 0;
			int i, k, pos;
			pos = total - iMAPeriod;
			while (pos >= 0)
			{
				if (pos == total - iMAPeriod)
				{
					for (i = 0, k = pos; i < iMAPeriod; i++, k++)
					{
						sum += Array[k];
						buf[k] = 0;
					}
				}
				else sum = buf[pos + 1] * (iMAPeriod - 1) + Array[pos];
				buf[pos] = sum / iMAPeriod;
				pos--;
			}
			return(buf[Shift + ma_shift]);
		}
		case MODE_LWMA:
		{
			double sum = 0.0, lsum = 0.0;
			double price;
			int i, weight = 0, pos = total - 1;
			for (i = 1; i <= iMAPeriod; i++, pos--)
			{
				price = Array[pos];
				sum += price * i;
				lsum += price;
				weight += i;
			}
			pos++;
			i = pos + iMAPeriod;
			while (pos >= 0)
			{
				buf[pos] = sum / weight;
				if (pos == 0) break;
				pos--;
				i--;
				price = Array[pos];
				sum = sum - lsum + price * iMAPeriod;
				lsum -= Array[i];
				lsum += price;
			}
			return(buf[Shift + ma_shift]);
		}
		default: return(0);
	}
	return(0);
}

// For alerts.
string PeriodToString(const ENUM_TIMEFRAMES per)
{
   return(StringSubstr(EnumToString(per), 7));
}
//+------------------------------------------------------------------+