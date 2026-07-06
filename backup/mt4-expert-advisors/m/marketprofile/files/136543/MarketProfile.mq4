// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=70257

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

#property strict
 
#property description "Displays the Market Profile indicator for daily, weekly, or monthly trading sessions."
#property description "Daily - should be attached to M5, M15, or M30 timeframes. M30 is recommended."
#property description "Weekly - should be attached to M30, H1, or H4 timeframes. H1 is recommended."
#property description "Weeks start on Sunday."
#property description "Monthly - should be attached to H1, H4, or D1 timeframes. H4 is recommended."
#property description "" 
#property description "Designed for standard currency pairs. May work incorrectly with very exotic pairs, CFDs or commodities."

#property indicator_chart_window
#property indicator_plots 0

enum color_scheme
{
   Blue_to_Red,
   Red_to_Green,
   Green_to_Blue
};

enum session_period
{
	Daily,
	Weekly,
	Monthly
};

input session_period Session	 = Daily;
input datetime  StartFromDate  = __DATE__;  // StartFromDate - lower priority
input bool 	 	 StartFromCurrentSession = true; // StartFromCurrentSession - higher priority
input int 		 SessionsToCount    = 2; // SessionsToCount - Number of sessions for which to count the Market Profile
input color_scheme ColorScheme = Blue_to_Red;
input color 	 MedianColor 	 = clrWhite;
input color 	 ValueAreaColor = clrWhite;
input int button_x = 20;
input int button_y = 30;

class VisibilityCotroller
{
   string buttonId;
   string visibilityId;
   bool show_data;
   bool recalc;
public:
   void Init(string id, string indicatorName, string caption, int x, int y)
   {
      recalc = false;
      visibilityId = indicatorName + "_visibility";
      double val;
      if (GlobalVariableGet(visibilityId, val))
         show_data = val != 0;
         
      buttonId = id;
      ChartSetInteger(0, CHART_EVENT_MOUSE_MOVE, 1);
      createButton(buttonId, caption, 65, 20, "Impact", 8, clrDarkRed, clrBlack, clrWhite);
      ObjectSetInteger(0, buttonId, OBJPROP_YDISTANCE, y);
      ObjectSetInteger(0, buttonId, OBJPROP_XDISTANCE, x);
   }

   void DeInit()
   {
      ObjectDelete(ChartID(), buttonId);
   }

   bool HandleButtonClicks()
   {
      if (ObjectGetInteger(0, buttonId, OBJPROP_STATE))
      {
         ObjectSetInteger(0, buttonId, OBJPROP_STATE, false);
         show_data = !show_data;
         GlobalVariableSet(visibilityId, show_data ? 1.0 : 0.0);
         recalc = true;
         return true;
      }
      return false;
   }

   bool IsRecalcNeeded()
   {
      return recalc;
   }

   void ResetRecalc()
   {
      recalc = false;
   }

   bool IsVisible()
   {
      return show_data;
   }

private:
   void createButton(string buttonID,string buttonText,int width,int height,string font,int fontSize,color bgColor,color borderColor,color txtColor)
   {
      ObjectDelete(0,buttonID);
      ObjectCreate(0,buttonID,OBJ_BUTTON,0,0,0);
      ObjectSetInteger(0,buttonID,OBJPROP_COLOR,txtColor);
      ObjectSetInteger(0,buttonID,OBJPROP_BGCOLOR,bgColor);
      ObjectSetInteger(0,buttonID,OBJPROP_BORDER_COLOR,borderColor);
      ObjectSetInteger(0,buttonID,OBJPROP_BORDER_TYPE,BORDER_RAISED);
      ObjectSetInteger(0,buttonID,OBJPROP_XDISTANCE,9999);
      ObjectSetInteger(0,buttonID,OBJPROP_YDISTANCE,9999);
      ObjectSetInteger(0,buttonID,OBJPROP_XSIZE,width);
      ObjectSetInteger(0,buttonID,OBJPROP_YSIZE,height);
      ObjectSetString(0,buttonID,OBJPROP_FONT,font);
      ObjectSetString(0,buttonID,OBJPROP_TEXT,buttonText);
      ObjectSetInteger(0,buttonID,OBJPROP_FONTSIZE,fontSize);
      ObjectSetInteger(0,buttonID,OBJPROP_SELECTABLE,0);
      ObjectSetInteger(0,buttonID,OBJPROP_CORNER,2);
      ObjectSetInteger(0,buttonID,OBJPROP_HIDDEN,1);
   }
};

VisibilityCotroller visibility;

int DigitsM; 					// Amount of digits normalized for standard 4 and 2 digits after dot
datetime StartDate; 			// Will hold either StartFromDate or Time[0]
double onetick; 				// One normalized pip
bool FirstRunDone = false; // If true - OnCalculate() was already executed once
string Suffix = "";			// Will store object name suffix depending on timeframe.

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
{
   visibility.Init("show_hide_mp", "mp", "Show/Hide", button_x, button_y);
	if (Session == Daily)
	{
		Suffix = "_D";
		if ((Period() != PERIOD_M5) && (Period() != PERIOD_M15) && (Period() != PERIOD_M30))
		{
			Alert("Timeframe should be set to M30, M15, or M5 for Daily session.");
			return;
		}
	}
	else if (Session == Weekly)
	{
		Suffix = "_W";
		if ((Period() != PERIOD_M30) && (Period() != PERIOD_H1) && (Period() != PERIOD_H4))
		{
			Alert("Timeframe should be set to M30, H1, or H4 for Weekly session.");
			return;
		}
	}
	else if (Session == Monthly)
	{
		Suffix = "_M";
		if ((Period() != PERIOD_H1) && (Period() != PERIOD_H4) && (Period() != PERIOD_D1))
		{
			Alert("Timeframe should be set to H1, H4, or D1 for Monthly session.");
			return;
		}
	}
	
   IndicatorShortName("MarketProfile " + EnumToString(Session));

	// Normalizing the digits to standard 4- and 2-digit quotes.
	if (Digits == 5) DigitsM = 4;
	else if (Digits == 3) DigitsM = 2;
	else DigitsM = Digits;
	
	onetick = NormalizeDouble(1 / (MathPow(10, DigitsM)), DigitsM);
}

//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   visibility.DeInit();
	// Delete all rectangles with set prefix.
	ObjectsDeleteAll(0, "MP" + Suffix, EMPTY, OBJ_RECTANGLE);
	ObjectsDeleteAll(0, "Median" + Suffix, EMPTY, OBJ_RECTANGLE);
	ObjectsDeleteAll(0, "Value Area" + Suffix, EMPTY, OBJ_RECTANGLE);
}


void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
   if (visibility.HandleButtonClicks())
   {
      //start();
   }
}

//+------------------------------------------------------------------+
//| Custom Market Profile main iteration function                    |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                 const int prev_calculated,
                 const datetime& time[],
                 const double& open[],
                 const double& high[],
                 const double& low[],
                 const double& close[],
                 const long& tick_volume[],
                 const long& volume[],
                 const int& spread[]
)
{
   visibility.HandleButtonClicks();
	if (Session == Daily)
	{
		if ((Period() != PERIOD_M5) && (Period() != PERIOD_M15) && (Period() != PERIOD_M30))
		{
			Print("Timeframe should be set to M30, M15, or M5 for Daily session.");
			return(0);
		}
	}
	else if (Session == Weekly)
	{
		if ((Period() != PERIOD_M30) && (Period() != PERIOD_H1) && (Period() != PERIOD_H4))
		{
			Print("Timeframe should be set to M30, H1, or H4 for Weekly session.");
			return(0);
		}
	}
	else if (Session == Monthly)
	{
		if ((Period() != PERIOD_H1) && (Period() != PERIOD_H4) && (Period() != PERIOD_D1))
		{
			Print("Timeframe should be set to H1, H4, or D1 for Monthly session.");
			return(0);
		}
	}

   if (visibility.IsRecalcNeeded())
   {
      if (visibility.IsVisible())
      {
      }
      else
      {
         ObjectsDeleteAll(0, "MP" + Suffix, EMPTY, OBJ_RECTANGLE);
         ObjectsDeleteAll(0, "Median" + Suffix, EMPTY, OBJ_RECTANGLE);
         ObjectsDeleteAll(0, "Value Area" + Suffix, EMPTY, OBJ_RECTANGLE);
         visibility.ResetRecalc();
         return 0;
      }
      visibility.ResetRecalc();
   }
   else if (!visibility.IsVisible())
   {
      return 0;
   }

	if (StartFromCurrentSession) StartDate = Time[0];
	else StartDate = StartFromDate;
	
	// If we calculate profiles for the past sessions, no need to rerun it.
	if ((FirstRunDone) && (StartDate != Time[0])) return(0);

	// Get start and end bar numbers of the given session.
	int sessionend = FindSessionEndByDate(StartDate);
	int sessionstart = FindSessionStart(sessionend);

	int SessionToStart = 0;
	// If all sessions have already been counted, jump to the current one.
	if (FirstRunDone) SessionToStart = SessionsToCount - 1;
	else
	{
		// Move back to the oldest session to count to start from it.
		for (int i = 1; i < SessionsToCount; i++)
		{
			sessionend = sessionstart + 1;
			sessionstart = FindSessionStart(sessionend);
		}
	}

	// We begin from the oldest session coming to the current session or to StartFromDate.
	for (int i = SessionToStart; i < SessionsToCount; i++)
	{
		double SessionMax = DBL_MIN, SessionMin = DBL_MAX;
	
		// Find the session's high and low. 
		for (int bar = sessionstart; bar >= sessionend; bar--)
		{
			if (High[bar] > SessionMax) SessionMax = High[bar];
			if (Low[bar] < SessionMin) SessionMin = Low[bar];
		}
		SessionMax = NormalizeDouble(SessionMax, DigitsM);
		SessionMin = NormalizeDouble(SessionMin, DigitsM);
				
		int TPOperPrice[];
		// Possible price levels if multiplied to integer.
		int max = (int)MathRound(SessionMax / onetick + 2); // + 2 because further we will be possibly checking array at SessionMax + 1.
		ArrayResize(TPOperPrice, max);
		ArrayInitialize(TPOperPrice, 0);
	
		int MaxRange = 0; // Maximum distance from session start to the drawn dot.
		double PriceOfMaxRange = 0; // Level of the maximum range, required to draw Median.
		double DistanceToCenter = 99999999; // Closest distance to center for the Median.
		
		int TotalTPO = 0; // Total amount of dots (TPO's).
		
		// Going through all possible quotes from session's High to session's Low.
		for (double price = SessionMax; price >= SessionMin; price -= onetick)
		{
			int range = 0; // Distance from first bar to the current bar.

			// Going through all bars of the session to see if the price was encoutered here.
			for (int bar = sessionstart; bar >= sessionend; bar--)
			{
				// Price is encountered in the given bar
				if ((price >= Low[bar]) && (price <= High[bar]))
				{
					// Update maximum distance from session's start to the found bar (needed for Median).
					if ((MaxRange < range) || ((MaxRange == range) && (MathAbs(price - (SessionMin + (SessionMax - SessionMin) / 2)) < DistanceToCenter)))
					{
						MaxRange = range;
						PriceOfMaxRange = price;
						DistanceToCenter = MathAbs(price - (SessionMin + (SessionMax - SessionMin) / 2));
					}
					// Draws rectangle.
					PutDot(price, sessionstart, range, bar - sessionstart);
					// Remember the number of encountered bars for this price.
					int index = (int)MathRound(price / onetick);
					TPOperPrice[index]++;
					range++;
					TotalTPO++;
				}
			}
		}
	
		double TotalTPOdouble = TotalTPO;
		// Calculate amount of TPO's in the Value Area.
		int ValueControlTPO = (int)MathRound(TotalTPOdouble * 0.7);
		// Start with the TPO's of the Median.
		int index = (int)(PriceOfMaxRange / onetick);
		int TPOcount = TPOperPrice[index];

		// Go through the price levels above and below median adding the biggest to TPO count until the 70% of TPOs are inside the Value Area.
		int up_offset = 1;
		int down_offset = 1;
		while (TPOcount < ValueControlTPO)
		{
			double abovePrice = PriceOfMaxRange + up_offset * onetick;
			double belowPrice = PriceOfMaxRange - down_offset * onetick;
			// If belowPrice is out of the session's range then we should add only abovePrice's TPO's, and vice versa.
			index = (int)MathRound(abovePrice / onetick);
			int index2 = (int)MathRound(belowPrice / onetick);
			if (((TPOperPrice[index] >= TPOperPrice[index2]) || (belowPrice < SessionMin)) && (abovePrice <= SessionMax))
			{
				TPOcount += TPOperPrice[index];
				up_offset++;
			}
			else
			{
				TPOcount += TPOperPrice[index2];
				down_offset++;
			}
		}
		string LastName = " " + TimeToStr(Time[sessionstart], TIME_DATE);
		// Delete old Median.
		if (ObjectFind("Median" + Suffix + LastName) >= 0) ObjectDelete("Median" + Suffix + LastName);
		// Draw a new one.
		index = MathMax(sessionstart - MaxRange - 5, 0);
		ObjectCreate("Median" + Suffix + LastName, OBJ_RECTANGLE, 0, Time[sessionstart + 16], PriceOfMaxRange, Time[index], PriceOfMaxRange + onetick);
		ObjectSet("Median" + Suffix + LastName, OBJPROP_COLOR, MedianColor);
		ObjectSet("Median" + Suffix + LastName, OBJPROP_STYLE, STYLE_SOLID);
   	ObjectSet("Median" + Suffix + LastName, OBJPROP_BACK, false);
   	ObjectSet("Median" + Suffix + LastName, OBJPROP_SELECTABLE, false);
		
		// Protection from 'Array out of range' error.
		if (sessionstart - (MaxRange + 1) < 0) return(0);
		
		// Delete old Value Area.
		if (ObjectFind("Value Area" + Suffix + LastName) >= 0) ObjectDelete("Value Area" + Suffix + LastName);
		// Draw a new one.
		ObjectCreate("Value Area" + Suffix + LastName, OBJ_RECTANGLE, 0, Time[sessionstart], PriceOfMaxRange + up_offset * onetick, Time[sessionstart - (MaxRange + 1)], PriceOfMaxRange - down_offset * onetick);
		ObjectSet("Value Area" + Suffix + LastName, OBJPROP_COLOR, ValueAreaColor);
		ObjectSet("Value Area" + Suffix + LastName, OBJPROP_STYLE, STYLE_SOLID);
   	ObjectSet("Value Area" + Suffix + LastName, OBJPROP_BACK, false);
   	ObjectSet("Value Area" + Suffix + LastName, OBJPROP_SELECTABLE, false);

		// Go to the newer session only if there is one or more left.
		if (SessionsToCount - i > 1)
		{
			sessionstart = sessionend - 1;
			sessionend = FindSessionEndByDate(Time[sessionstart]);
		}
	}
	FirstRunDone = true;

	return(0);
}

//+------------------------------------------------------------------+
//| Finds the session's starting bar number for any given bar number.|
//| n - bar number for which to find starting bar. 					   |
//+------------------------------------------------------------------+
int FindSessionStart(int n)
{
	if (Session == Daily) return(FindDayStart(n));
	else if (Session == Weekly) return(FindWeekStart(n));
	else if (Session == Monthly) return(FindMonthStart(n));
	
	return(-1);
}

//+------------------------------------------------------------------+
//| Finds the day's starting bar number for any given bar number.    |
//| n - bar number for which to find starting bar. 					   |
//+------------------------------------------------------------------+
int FindDayStart(int n)
{
	int x = n;
	
	while ((x < Bars) && (TimeDayOfYear(Time[n]) == TimeDayOfYear(Time[x])))
		x++;

	return(x - 1);
}

//+------------------------------------------------------------------+
//| Finds the week's starting bar number for any given bar number.   |
//| n - bar number for which to find starting bar. 					   |
//+------------------------------------------------------------------+
int FindWeekStart(int n)
{
	int x = n;
	int day_of_week = TimeDayOfWeek(Time[n]);
	while ((x < Bars) && (SameWeek(Time[n], Time[x])))
		x++;

	return(x - 1);
}

//+------------------------------------------------------------------+
//| Finds the month's starting bar number for any given bar number.  |
//| n - bar number for which to find starting bar. 					   |
//+------------------------------------------------------------------+
int FindMonthStart(int n)
{
	int x = n;
	
	while ((x < Bars) && (TimeMonth(Time[n]) == TimeMonth(Time[x])))
		x++;

	return(x - 1);
}

//+------------------------------------------------------------------+
//| Finds the session's end bar by the session's date.					|
//+------------------------------------------------------------------+
int FindSessionEndByDate(datetime date)
{
	if (Session == Daily) return(FindDayEndByDate(date));
	else if (Session == Weekly) return(FindWeekEndByDate(date));
	else if (Session == Monthly) return(FindMonthEndByDate(date));
	
	return(-1);
}

//+------------------------------------------------------------------+
//| Finds the day's end bar by the day's date.								|
//+------------------------------------------------------------------+
int FindDayEndByDate(datetime date)
{
	int x = 0;

	while ((x < Bars) && (TimeDayOfYear(date) < TimeDayOfYear(Time[x])))
		x++;

	return(x);
}

//+------------------------------------------------------------------+
//| Finds the week's end bar by the week's date.							|
//+------------------------------------------------------------------+
int FindWeekEndByDate(datetime date)
{
	int x = 0;

	while ((x < Bars) && (SameWeek(date, Time[x]) != true))
		x++;

	return(x);
}

//+------------------------------------------------------------------+
//| Finds the month's end bar by the month's date.							|
//+------------------------------------------------------------------+
int FindMonthEndByDate(datetime date)
{
	int x = 0;

	while ((x < Bars) && (SameMonth(date, Time[x]) != true))
		x++;

	return(x);
}

//+------------------------------------------------------------------+
//| Check if two dates are in the same week.									|
//+------------------------------------------------------------------+
int SameWeek(datetime date1, datetime date2)
{
	int seconds_from_start = TimeDayOfWeek(date1) * 24 * 3600 + TimeHour(date1) * 3600 + TimeMinute(date1) * 60 + TimeSeconds(date1);
	
	if (date1 == date2) return(true);
	else if (date2 < date1)
	{
		if (date1 - date2 <= seconds_from_start) return(true);
	}
	// 604800 - seconds in a week.
	else if (date2 - date1 < 604800 - seconds_from_start) return(true);

	return(false);
}

//+------------------------------------------------------------------+
//| Check if two dates are in the same month.								|
//+------------------------------------------------------------------+
int SameMonth(datetime date1, datetime date2)
{
	if ((TimeMonth(date1) == TimeMonth(date2)) && (TimeYear(date1) == TimeYear(date2))) return(true);
	return(false);
}

//+------------------------------------------------------------------+
//| Puts a dot (rectangle) at a given position and color. 			   |
//| price and time are coordinates.								 			   |
//| range is for the second coordinate.						 			   |
//| bar is to determine the color of the dot.				 			   |
//+------------------------------------------------------------------+
void PutDot(double price, int start_bar, int range, int bar)
{
	string LastName = " " + TimeToString(Time[start_bar - range]) + " " + DoubleToString(price, 4);
	if (ObjectFind("MP" + Suffix + LastName) >= 0) return;

	// Protection from 'Array out of range' error.
	if (start_bar - (range + 1) < 0) return;

	ObjectCreate("MP" + Suffix + LastName, OBJ_RECTANGLE, 0, Time[start_bar - range], price, Time[start_bar - (range + 1)], price + onetick);
	
	// Color switching depending on the distance of the bar from the session's beginning.
	int colour, offset1, offset2;
	switch(ColorScheme)
	{
		case Blue_to_Red:
			colour = clrDarkBlue;
			offset1 = 0x020000;
			offset2 = 0x000002;
		break;
		case Red_to_Green:
			colour = clrDarkRed;
			offset1 = 0x000002;
			offset2 = 0x000200;
		break;
		case Green_to_Blue:
			colour = clrDarkGreen;
			offset1 = 0x000200;
			offset2 = 0x020000;
		break;
		default:
			colour = clrDarkBlue;
			offset1 = 0x020000;
			offset2 = 0x000002;
		break;
	}
	if (((Session == Daily) && (Period() == PERIOD_M30)) || ((Session == Weekly) && (Period() == PERIOD_H4)) || ((Session == Monthly) && (Period() == PERIOD_D1)))
	{
		colour += bar * offset1;
		colour -= bar * offset2;
	}
	else if (((Session == Daily) && (Period() == PERIOD_M15)) || ((Session == Weekly) && (Period() == PERIOD_H1)) || ((Session == Monthly) && (Period() == PERIOD_H4)))
	{
		colour += bar * (offset1 / 2);
		colour -= bar * (offset2 / 2);
	}
	else if (((Session == Daily) && (Period() == PERIOD_M5)) || ((Session == Weekly) && (Period() == PERIOD_M30)) || ((Session == Monthly) && (Period() == PERIOD_H1)))
	{
		colour += (bar / 3) * (offset1 / 2);
		colour -= (bar / 3) * (offset2 / 2);
	}
	
	ObjectSet("MP" + Suffix + LastName, OBJPROP_COLOR, colour);
	// Fills rectangle.
	ObjectSet("MP" + Suffix + LastName, OBJPROP_BACK, true);
	ObjectSet("MP" + Suffix + LastName, OBJPROP_SELECTABLE, false);
}
//+------------------------------------------------------------------+