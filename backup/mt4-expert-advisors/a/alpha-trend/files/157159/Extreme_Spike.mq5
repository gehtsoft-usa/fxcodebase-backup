//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=75333

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2024, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                https://appliedmachinelearning.systems/contact/ | 
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|                                           Our work would not be possible without your support. |
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal:  https://goo.gl/9Rj74e   |
//|                                                             Patreon :  http://tiny.cc/1ybwxz   |   
//|                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
//+------------------------------------------------------------------------------------------------+

#property copyright "Copyright © 2024, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
 
#property strict

#property indicator_separate_window

#property indicator_minimum - 1.2
#property indicator_maximum + 1.2
#property indicator_buffers 5
#property indicator_plots 5

#property indicator_color1 Red
#property indicator_width1 3
#property indicator_style1 STYLE_SOLID
#property indicator_label1 "Major Up"

#property indicator_color2 DodgerBlue
#property indicator_width2 3
#property indicator_style2 STYLE_SOLID
#property indicator_label2 "Major Down"

#property indicator_color3 DimGray
#property indicator_width3 0
#property indicator_label3 "Shadow"

#property indicator_color4 White
#property indicator_width4 1
#property indicator_style4 STYLE_SOLID
#property indicator_label4 "Stable"

#property indicator_color5 White
#property indicator_width5 2
#property indicator_style5 STYLE_SOLID
#property indicator_label5 "Minor"

#define ALERT_TOP 1
#define ALERT_BOTTOM 2
#define ALERT_STABLE 3

#define LINE_MINOR 1
#define LINE_MAJOR 2
#define LINE_SHADOW 3
#define LINE_STABLE 4

#define LINE_VALUE_UP 1.0
#define LINE_VALUE_FLAT 0.0
#define LINE_VALUE_DOWN -1.0

#define MODE_LOOKING_FOR_BOTTOM 1
#define MODE_LOOKING_FOR_TOP -1
#define MODE_UNDETERMINED 0

//---- input parameters
input bool NoRepaint = false;
input double MinorMinExtremeHeightATRs = 2.0;
input double MajorToMinorHeightRatio = 2.5;
input int MinorMinExtremeWidth = 2;
input int MajorMinExtremeWidth = 2;
input bool AlertMajorBottomEnabled = false;
input bool AlertMajorTopEnabled = false;
input bool AlertMinorTopEnabled = false;
input bool AlertMinorBottomEnabled = false;
input bool AlertStableEnabled = false;
//Signaler v 4.0

#ifdef ADVANCED_ALERTS
// AdvancedNotificationsLib.dll could be downloaded here: http://profitrobots.com/Home/TelegramNotificationsMT4
//#import "AdvancedNotificationsLib.dll"
//void AdvancedAlert(string key, string text, string instrument, string timeframe);
//#import
#endif

class Signaler
{
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
   string _prefix;
   bool _popupAlert;
   bool _emailAlert;
   bool _playSound;
   string _soundFile;
   bool _notificationAlert;
   bool _advancedAlert;
   string _advancedKey;
public:
   Signaler(const string symbol, ENUM_TIMEFRAMES timeframe)
   {
      _symbol = symbol;
      _timeframe = timeframe;
      _popupAlert = false;
      _emailAlert = false;
      _playSound = false;
      _notificationAlert = false;
      _advancedAlert = false;
   }

   void SetPopupAlert(bool isEnabled) { _popupAlert = isEnabled; }
   void SetEmailAlert(bool isEnabled) { _emailAlert = isEnabled; }
   void SetPlaySound(bool isEnabled, string fileName) 
   { 
      _playSound = isEnabled;
      _soundFile = fileName;
   }
   void SetNotificationAlert(bool isEnabled) { _notificationAlert = isEnabled; }
   void SetAdvancedAlert(bool isEnabled, string key)
   {
      _advancedAlert = isEnabled;
      _advancedKey = key;
   }

   void SendNotifications(string message, string subject = NULL, string symbol = NULL, string timeframe = NULL)
   {
      if (subject == NULL)
         subject = message;

      if (_prefix != "" && _prefix != NULL)
         message = _prefix + message;
      if (symbol == NULL)
         symbol = _symbol;
      if (timeframe == NULL)
         timeframe = GetTimeframeStr();

      if (_popupAlert)
         Alert(message);
      if (_emailAlert)
         SendMail(subject, message);
      if (_playSound)
         PlaySound(_soundFile);
      if (_notificationAlert)
         SendNotification(message);
#ifdef ADVANCED_ALERTS
      if (_advancedAlert && _advancedKey != "")
         AdvancedAlert(_advancedKey, message, symbol, timeframe);
#endif
   }

   void SetMessagePrefix(string prefix)
   {
      _prefix = prefix;
   }

   string GetSymbol()
   {
      return _symbol;
   }

   ENUM_TIMEFRAMES GetTimeframe()
   {
      return _timeframe;
   }

   string GetTimeframeStr()
   {
      switch (_timeframe)
      {
         case PERIOD_M1: return "M1";
         case PERIOD_M2: return "M2";
         case PERIOD_M3: return "M3";
         case PERIOD_M4: return "M4";
         case PERIOD_M5: return "M5";
         case PERIOD_M6: return "M6";
         case PERIOD_M10: return "M10";
         case PERIOD_M12: return "M12";
         case PERIOD_M15: return "M15";
         case PERIOD_M20: return "M20";
         case PERIOD_M30: return "M30";
         case PERIOD_D1: return "D1";
         case PERIOD_H1: return "H1";
         case PERIOD_H2: return "H2";
         case PERIOD_H3: return "H3";
         case PERIOD_H4: return "H4";
         case PERIOD_H6: return "H6";
         case PERIOD_H8: return "H8";
         case PERIOD_H12: return "H12";
         case PERIOD_MN1: return "MN1";
         case PERIOD_W1: return "W1";
      }
      return "M1";
   }
};

//---- buffers
double line1[]; // lineMajorUp
double line2[]; // lineMajorDown
double line3[]; // lineShadowUp, lineShadowDown
double line4[]; // lineStableUp,  lineStableDown
double line5[]; // lineMinorUp, lineMinorDown

int MinorLowExtremeIdx = 1;
bool MinorFirstLow = true;
int MinorHiExtremeIdx = 1;
bool MinorFirstHigh = true;
int MinorExtremeMode = 0;
double MinorLowExtremePrice;
double MinorHiExtremePrice;

int MajorLowExtremeIdx = 1;
bool MajorFirstLow = true;
int MajorHiExtremeIdx = 1;
bool MajorFirstHigh = true;
int MajorExtremeMode = 0;
double MajorLowExtremePrice;
double MajorHiExtremePrice;

double MinorMinExtremeHeight;
double MajorMinExtremeHeight;

datetime AlertMinorTopIdx;
datetime AlertMinorBottomIdx;
datetime AlertMajorTopIdx;
datetime AlertMajorBottomIdx;
datetime AlertStableIdx;

string periodName;

#define RANGE_AVERAGING_PERIOD 250

Signaler *signaler;

int OnInit(void)
{
	int line = 0;

	// order of these calls is important - for example the 'spike' line is last - it will be drawn last and therefore will be on top of all other lines
	SetIndexBuffer(line, line1, INDICATOR_DATA);
	PlotIndexSetInteger(line, PLOT_DRAW_TYPE, DRAW_HISTOGRAM);
	line++;

	SetIndexBuffer(line, line2, INDICATOR_DATA);
	PlotIndexSetInteger(line, PLOT_DRAW_TYPE, DRAW_HISTOGRAM);
	line++;

	SetIndexBuffer(line, line3, INDICATOR_DATA);
	PlotIndexSetInteger(line, PLOT_ARROW, 108);
	PlotIndexSetInteger(line, PLOT_ARROW_SHIFT, 5);
	line++;

	SetIndexBuffer(line, line4, INDICATOR_DATA);
	PlotIndexSetInteger(line, PLOT_DRAW_TYPE, DRAW_HISTOGRAM);
	line++;

	SetIndexBuffer(line, line5, INDICATOR_DATA);
	PlotIndexSetInteger(line, PLOT_DRAW_TYPE, DRAW_HISTOGRAM);
	line++;

	ENUM_TIMEFRAMES timeframe = (ENUM_TIMEFRAMES)_Period;
	signaler = new Signaler(_Symbol, timeframe);
	signaler.SetMessagePrefix(_Symbol + "/" + signaler.GetTimeframeStr() + ": ");
	atr = iATR(_Symbol, _Period, RANGE_AVERAGING_PERIOD);
	return (0);
}

int atr;

void OnDeinit(const int reason)
{
	IndicatorRelease(atr);
	delete signaler;
	signaler = NULL;
}

int OnCalculate(const int rates_total,	   // size of input time series
				const int prev_calculated, // number of handled bars at the previous call
				const datetime &time[],	   // Time array
				const double &open[],	   // Open array
				const double &high[],	   // High array
				const double &low[],	   // Low array
				const double &close[],	   // Close array
				const long &tick_volume[], // Tick Volume array
				const long &volume[],	   // Real Volume array
				const int &spread[]		   // Spread array
)
{
	if (prev_calculated <= 0 || prev_calculated > rates_total)
	{
		periodName = getPeriodName();
		AlertMinorTopIdx = time[0];
		AlertMinorBottomIdx = time[0];
		AlertMajorTopIdx = time[0];
		AlertMajorBottomIdx = time[0];
		MinorLowExtremePrice = low[0];
		MinorHiExtremePrice = high[0];
		MajorLowExtremePrice = low[0];
		MajorHiExtremePrice = high[0];
      ArrayInitialize(line1, EMPTY_VALUE);
      ArrayInitialize(line2, EMPTY_VALUE);
      ArrayInitialize(line3, EMPTY_VALUE);
      ArrayInitialize(line4, EMPTY_VALUE);
      ArrayInitialize(line5, EMPTY_VALUE);
	}
	int first = 0;
	for (int pos = MathMax(first, prev_calculated - 1); pos < rates_total; ++pos)
	{
		int oldIndex = rates_total - 1 - pos;
		double atrVal[1];
		if (CopyBuffer(atr, 0, oldIndex, 1, atrVal) != 1)
		{
			continue;
		}
		MinorMinExtremeHeight = atrVal[0] * MinorMinExtremeHeightATRs;
		MajorMinExtremeHeight = MinorMinExtremeHeight * MajorToMinorHeightRatio;
		checkForExtremes(time, rates_total, low, high, pos, MinorLowExtremeIdx, MinorLowExtremePrice, MinorFirstLow,
						 MinorHiExtremeIdx, MinorHiExtremePrice, MinorFirstHigh,
						 MinorExtremeMode, MinorMinExtremeHeight, MinorMinExtremeWidth, LINE_MINOR);
		checkForExtremes(time, rates_total, low, high, pos, MajorLowExtremeIdx, MajorLowExtremePrice, MajorFirstLow,
						 MajorHiExtremeIdx, MajorHiExtremePrice, MajorFirstHigh,
						 MajorExtremeMode, MajorMinExtremeHeight, MajorMinExtremeWidth, LINE_MAJOR);
	}
	return rates_total;
}

void checkForExtremes(const datetime &time[], int rates_total, const double &low[], const double &high[], int pos, int &lowExtremeIdx, double &lowExtremePrice, bool &firstLow,
					  int &hiExtremeIdx, double &hiExtremePrice, bool &firstHigh,
					  int &extremeMode, double MinExtremeHeight, int MinExtremeWidth, int lineType)
{
	// ----------- check for Bottom ----------------
	if (extremeMode > -1)
	{
		if (low[pos] < lowExtremePrice)
		{
			if (!firstLow)
				eraseExtreme(lineType, lowExtremeIdx, LINE_VALUE_DOWN); // to repaint (erase) the spike
			lowExtremePrice = low[pos];									// set LowestLow to this low (getLow)
			lowExtremeIdx = pos;									// remember the LL bar number
			firstLow = false;											// the was a Bottom
		}
		else if (low[pos] > lowExtremePrice)
		{ // higher low (getLow) - not necesserally higher than the last bar - could be lower than the last bar, but still higher than the bottom
			// there was bottom (lower low then higher low) - final or intermediate
			drawExtreme(lineType, lowExtremeIdx, LINE_VALUE_DOWN); // update LowestLow bar with the spike DOWN and mark it as unstable

			alert(time, rates_total, ALERT_BOTTOM, lineType, lowExtremeIdx);

			firstLow = false;

			if (((low[pos] - lowExtremePrice) >= MinExtremeHeight) // the bottom was distinct enough (difference between it and price is big enough)
				&& ((pos - lowExtremeIdx) >= MinExtremeWidth))
			{					  // and the bottom was long enough ago in the past (there was no another bottom since)
				extremeMode = -1; // set flags to start looking for top
				hiExtremePrice = high[pos];
				hiExtremeIdx = pos;
				firstHigh = true;
				firstLow = true;

				if (NoRepaint) // only draw extreme when it is not going to be repainted (WILL in troduce a lag)
					draw(lineType, lowExtremeIdx, LINE_VALUE_DOWN);
				if (drawStableLine(lineType, lowExtremeIdx, LINE_VALUE_FLAT)) // this spike will not repaint
					alert(time, rates_total, ALERT_STABLE, lineType, lowExtremeIdx);
			}
		}
	}

	// ----------- check for Top ----------------
	if (extremeMode < 1)
	{ // extremeMode could have been MinExtremeHeighted in the code above so can't really put "Else" here; initial goes here as well (0)
		if (high[pos] > hiExtremePrice)
		{
			if (!firstHigh)
				eraseExtreme(lineType, hiExtremeIdx, LINE_VALUE_UP); // to repaint (erase) the spike
			hiExtremePrice = high[pos];
			hiExtremeIdx = pos;
			firstHigh = false;
		}
		else if (high[pos] < hiExtremePrice)
		{
			drawExtreme(lineType, hiExtremeIdx, LINE_VALUE_UP);

			alert(time, rates_total, ALERT_TOP, lineType, hiExtremeIdx);

			firstHigh = false;

			if (((hiExtremePrice - high[pos]) >= MinExtremeHeight) && ((pos - hiExtremeIdx) >= MinExtremeWidth))
			{
				extremeMode = 1;
				lowExtremePrice = low[pos];
				lowExtremeIdx = pos;
				firstHigh = true;
				firstLow = true;

				if (NoRepaint) // only draw extreme when it is not going to be repainted (WILL in troduce a lag)
					draw(lineType, hiExtremeIdx, LINE_VALUE_UP);
				if (drawStableLine(lineType, hiExtremeIdx, LINE_VALUE_FLAT)) // this spike will not repaint
					alert(time, rates_total, ALERT_STABLE, lineType, hiExtremeIdx);
			}
		}
	}

	draw(lineType, pos, LINE_VALUE_FLAT);
}

void eraseExtreme(int lineType, int barIdx, double value)
{
	bool drawShadow = (lineType == LINE_MAJOR) && (NoRepaint // in non-repainting mode always alert of the possible extreme
												   || ((value == LINE_VALUE_UP) && (line1[barIdx] != 0)) || ((value == LINE_VALUE_DOWN) && (line2[barIdx] != 0)));
	drawExtreme(lineType, barIdx, LINE_VALUE_FLAT);
	if (drawShadow)
		draw(LINE_SHADOW, barIdx, value);
}

void drawExtreme(int lineType, int barIdx, double value)
{
	if (!NoRepaint)
	{ // only draw extreme when it is not going to be repainted (WILL in troduce a lag)
		draw(lineType, barIdx, value);
		drawStableLine(lineType, barIdx, value);
	}
}

bool drawStableLine(int lineType, int barIdx, double value)
{
	if (lineType == LINE_MAJOR)
		return false;
	draw(LINE_STABLE, barIdx, value);
	return true;
}

void draw(int lineType, int barIdx, double value)
{
	switch (lineType)
	{
	case LINE_MAJOR:
      if (value == LINE_VALUE_FLAT || value == LINE_VALUE_UP)
      {
		   line1[barIdx] = value;
         line5[barIdx] = EMPTY_VALUE;
         line4[barIdx] = EMPTY_VALUE;
      }
	   if (value == LINE_VALUE_FLAT || value == LINE_VALUE_DOWN)
      {
		   line2[barIdx] = value;
         line5[barIdx] = EMPTY_VALUE;
         line4[barIdx] = EMPTY_VALUE;
      }
		break;
	case LINE_MINOR:
      line5[barIdx] = value;
		break;
	case LINE_SHADOW:
      line3[barIdx] = value;
		break;
	case LINE_STABLE:
      line4[barIdx] = value;
		break;
	}
}

void alert(const datetime &time[], int rates_total, int alertType, int lineType, int barIdx)
{
	if (barIdx != rates_total - 1)
		return;
	datetime barTime = time[barIdx];

	switch (alertType)
	{
	case ALERT_TOP:
		switch (lineType)
		{
		case LINE_MAJOR:
			if (AlertMajorTopEnabled && (barTime != AlertMajorTopIdx))
			{
				signaler.SendNotifications("Major Top Detected");
				AlertMajorTopIdx = barTime;
			}
			break;
		case LINE_MINOR:
			if (AlertMinorTopEnabled && (barTime != AlertMinorTopIdx))
			{
				signaler.SendNotifications("Minor Top Detected");
				AlertMinorTopIdx = barTime;
			}
			break;
		}
		break;
	case ALERT_BOTTOM:
		switch (lineType)
		{
		case LINE_MAJOR:
			if (AlertMajorBottomEnabled && (barTime != AlertMajorBottomIdx))
			{
				signaler.SendNotifications("Major Bottom Detected");
				AlertMajorBottomIdx = barTime;
			}
			break;
		case LINE_MINOR:
			if (AlertMinorBottomEnabled && (barTime != AlertMinorBottomIdx))
			{
				signaler.SendNotifications("Minor Bottom Detected");
				AlertMinorBottomIdx = barTime;
			}
			break;
		}
		break;
	case ALERT_STABLE:
		if (AlertStableEnabled && (barTime != AlertStableIdx))
		{
			signaler.SendNotifications("Latest extreme will not repaint anymore");
			AlertStableIdx = barTime;
		}
		break;
	}
}

string getPeriodName()
{
	switch (Period())
	{
	case PERIOD_M1:
		return ("M1");
	case PERIOD_M5:
		return ("M5");
	case PERIOD_M15:
		return ("M15");
	case PERIOD_M30:
		return ("M30");
	case PERIOD_H1:
		return ("H1");
	case PERIOD_H4:
		return ("H4");
	case PERIOD_D1:
		return ("D1");
	case PERIOD_W1:
		return ("W1");
	case PERIOD_MN1:
		return ("MN1");
	}
	return "";
}
//+------------------------------------------------------------------------------------------------+
//|                                                                    We appreciate your support. | 
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal:  https://goo.gl/9Rj74e   |
//|                                                             Patreon :  http://tiny.cc/1ybwxz   |   
//|                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
//+------------------------------------------------------------------------------------------------+
//|  Cryptocurrency  |  Network                    |  Address                                      |
//+------------------------------------------------+-----------------------------------------------+
//|  USDT            |  ERC20 (ETH Ethereum)       |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   | 
//|  USDT            |  TRC20 (Tron)               |  TTBXsfuPm2rk36AkdemY7muNXGjyziC86g           |
//|  USDT            |  BEP20 (BSC BNB Smart Chain)|  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//|  USDT            |  Matic Polygon              |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//|  USDT            |  SOL Solana                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2 |
//|  USDT            |  ARBITRUM Arbitrum One      |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//+------------------------------------------------+-----------------------------------------------+ 