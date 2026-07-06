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
#property link "http://fxcodebase.com"
#property version "1.0"
#property strict

#property indicator_chart_window
#property indicator_buffers 1 // just a dummy buffer, to allow "SetIndexLabel(1, NULL)" to hide the indicator in the Data Window.

#define DEBUG 0

// Error codes:
#define NO_ERR 0
#define ERR -1
#define ERR_RANGE -2
#define ERR_FORMAT -3
// Data for the font-space functions:
#define MAX_SPACES 500
string gasSpaces[MAX_SPACES + 1];
// Other define's:
#define MAX_SESSIONS 5										  // This should be equal to the number of input colors \
															  //   and >= the number of sessions in $SESS_NAMES_DEFAULT.
#define SESS_NAMES_DEFAULT "Sydney/Tokyo/Frankfurt/London/NY" // These should all be unique.

//enum eTimeMethod {Broker_Eastern_offset, Broker_GMT_offset, Manual};
enum eTimeMethod
{
	Broker_Eastern_offset,
	Manual
};
enum eBoxFill
{
	Fill,
	Frame
};

input string SessionNames = SESS_NAMES_DEFAULT;
input string ShowBoxes = "0/0/0/1/1";
input string ShowNames = "0/0/0/0/0";
input string ShowPips = "0/0/0/1/1";
input eTimeMethod TimeMethod = Broker_Eastern_offset;
input string __OffsetNote = "..exactly *5* sessions above.";						 // If using Eastern offset, setup..
input string __OffsetNote2 = "https://www.timeanddate.com/worldclock/usa/new-york"; // May check Eastern local time here:
input int BrokerEasternOffset = 7;
//input int         BrokerGMTOffset      = 3;
input string Manual_SessionBegins = "00:00/02:00/09:00/10:00/15:00";
input string Manual_SessionEnds = "09:00/11:00/18:00/19:00/24:00";
input color Color1 = CLR_NONE;
input color Color2 = CLR_NONE;
input color Color3 = CLR_NONE;
// (The following two colors have been optimized for WhiteSmoke.  White works almost as well with them):
input color Color4 = C'228,210,186';
input color Color5 = C'200,253,204';
// ^ The number of colors should equal $MAX_SESSIONS.
input eBoxFill FillBoxes = Fill;
input int FrameWidth = 1;
input int FrameStyle = 1;
input bool ShowTooltips = false; // Show tooltip, when "show name & pips" are off:
input bool PipsRounded = true;
// ^ Round to nearest pip?  If not, display to as many points as the broker gives.
input int PipsFontSize = 8;
input string PipsFont = "Arial Bold";
input color PipsColor = clrGray;
input bool PipsFontIsFixedWidth = false;
input bool PipsWord = true; // Display " pips" after pips.
input int MaxBars = 8000;
input int MinTimeframe = 1;
input int MaxTimeframe = 120;
input bool DeleteObjectsUponRemoval = true;
int giRedraw_DelaySec = 4;
int giRedraw_DelayTicks = 2;
int giRedraw_NumTimes = 4;
// ^ This 4x stretching gives time for new bars to finish downloading, while keeping the screen looking neat and
//     tidy in the meantime without using too many resources (e.g., by redrawing every single tick).
//   For a custom timeframe (using File-->Open Offline), MT4 for some reason reports all bars changed *on every
//     tick*, instead of only after downloading new bars.  This makes it hard to reliably know when to redraw after
//     the initial short downloading period after connection.
//   So for custom timeframes, instead of redrawing after MT4 says new bars were downloaded, we will simply:  only
//     redraw *after connection/reconnection* (which very likely are the only times when new bars are downloaded).
//   UPDATE 2019-APR-01: After adding an $InitDraw() call right before the $for loop at the end of $OnCalculate,
//     this is no longer necessary!!  This was simply a long-standing bug.
//   UPDATE 2019-APR-02: On custom timeframes, MT4 is still returning some weird numbers, and I can't figure out a
//     way to get the charts to look correct both before and after downloading new bars.  So the redrawing scheme
//     needs to be done still, only on custom timeframes.
//     Hide these settings from the user (for simplicity; and because they're fairly rarely used; and because
//     these settings are fairly optimal in all situations except possibly millions of bars).
input uchar ObjectPrefixCode = 127;
input string TooltipPrefix = "";
input bool ShowInObjectsList = true;
input int button_x = 20;
input int button_y = 30;

//Visibility controller v1.3
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

const datetime glTIME_BEGIN = 0;
const string gsTIME_BEGIN = TimeToStr(glTIME_BEGIN, TIME_DATE);
const datetime glTIME_END = D'2999.01.01';

double gdPip;
int giPointsPerPip;
bool gbCustTf;

int giNumSess;
string gasNames[MAX_SESSIONS];
bool gabShowSess[MAX_SESSIONS],
	gabShowBox[MAX_SESSIONS],
	gabShowName[MAX_SESSIONS],
	gabShowPips[MAX_SESSIONS];

datetime glCurBarDate,
	glLastBarDate[MAX_SESSIONS],
	glTimeBegin[MAX_SESSIONS],
	glTimeEnd[MAX_SESSIONS];
bool gabMidnightCross[MAX_SESSIONS]; // Do any of the start to end times cross midnight
double gadSessLow[MAX_SESSIONS],
	gadSessHigh[MAX_SESSIONS];
color gaoColors[MAX_SESSIONS];
int giPipsPrecision;

bool gbFillBoxes;
bool gbShowTooltips;
bool gbTfValid;
long glTickNum;

bool gbRedrawUponConnect;
long glTimer_RedrawAll;
int giNumTicksBeforeRedrawAll,
	giNumRedrawAllsLeft;
int giLastRedrawDelayTicks,
	giLastRedrawDelaySec;
datetime glEarliestDate; // The earliest date that has objects.
string gsObjectPrefix;

string IndicatorObjPrefix;

bool NamesCollision(const string name)
{
   for (int k = ObjectsTotal(); k >= 0; k--)
   {
      if (StringFind(ObjectName(0, k), name) == 0)
      {
         return true;
      }
   }
   return false;
}

string GenerateIndicatorPrefix(const string target)
{
   for (int i = 0; i < 1000; ++i)
   {
      string prefix = target + "_" + IntegerToString(i);
      if (!NamesCollision(prefix))
      {
         return prefix;
      }
   }
   return target;
}

void OnInit()
{
   IndicatorObjPrefix = GenerateIndicatorPrefix("as");
   IndicatorShortName("Auto_Sessions");
	Comment(""); // Clear the global, on-screen "comment" before initializing anything, since it is sometimes used to
				 //   communicate important messages while initializing.

	SetIndexLabel(0, NULL); // Do not show in the Data Window.  (Or could manually uncheck in the "Visualization" tab).

	const string asEASTERN_BEGINS[MAX_SESSIONS] = {"17:00", "19:00", "02:00", "03:00", "08:00"};
	const string asEASTERN_ENDS[MAX_SESSIONS] = {"02:00", "04:00", "11:00", "12:00", "17:00"};

	string asManualBegins[MAX_SESSIONS],
		asManualEnds[MAX_SESSIONS];

	int g;

	if ((uchar)ObjectPrefixCode == 0)
		gsObjectPrefix = StringSetChar(gsObjectPrefix, 0, (ushort)127);
	else
		gsObjectPrefix = StringSetChar(gsObjectPrefix, 0, (ushort)((uchar)ObjectPrefixCode));

	glTickNum = 0;

	// Custom timeframe or not?
	if (_Period == PERIOD_M1 || _Period == PERIOD_M5 || _Period == PERIOD_M15 || _Period == PERIOD_M30 || _Period == PERIOD_H1 || _Period == PERIOD_H4 || _Period == PERIOD_D1 || _Period == PERIOD_W1 || _Period == PERIOD_MN1)
		gbCustTf = false;
	else
		gbCustTf = true;

	// Setup "spaces" table.
	SpacesCreate();

	// Deal with fractional pips.
	if (Digits == 3 || Digits == 5)
	{
		gdPip = Point * 10;
		giPointsPerPip = 10;
	}
	else if (Digits > 5)
	{
		gdPip = 0.0001; //  = Point*MathPow(10, Digits-4);
		giPointsPerPip = (int)MathPow(10, Digits - 4);
	}
	else
	{
		gdPip = Point;
		giPointsPerPip = 1;
	}

	// Check if user wants to display on this timframe.
	gbTfValid = true;
	if (Period() < MinTimeframe || Period() > MaxTimeframe)
	{
		gbTfValid = false;
		return;
	}

	// The redrawing will only done on custom timeframes:
	if (gbCustTf)
	{
		gbRedrawUponConnect = true;
		glTimer_RedrawAll = 0;			// No value is necessary actually.
		giNumTicksBeforeRedrawAll = -1; // -1 means deactivated.
		giLastRedrawDelayTicks = 0;		// [not necessary].
		giLastRedrawDelaySec = 0;		// [not necessary].
	}
	else
		gbRedrawUponConnect = false;

	// Get sessions info.
	giNumSess = StringsExtract(SessionNames, '/', gasNames, MAX_SESSIONS);
	//   Ensure no duplicate session names, for the object names.
	if (!StringsUnique(gasNames, giNumSess))
		giNumSess = StringsExtract(SESS_NAMES_DEFAULT, '/', gasNames, MAX_SESSIONS);
	if (DEBUG)
		Print("giNumSess=", giNumSess);

	ArrayInitialize(gabShowBox, 1);
	BoolsExtract(ShowBoxes, gabShowBox, giNumSess);
	if (DEBUG)
		Print("giNumSess=", giNumSess, " (after $BoolsExtract for sessions).");

	ArrayInitialize(gabShowName, 1);
	BoolsExtract(ShowNames, gabShowName, giNumSess);
	if (DEBUG)
		Print("giNumSess=", giNumSess, " (after $BoolsExtract for names).");

	ArrayInitialize(gabShowPips, 1);
	BoolsExtract(ShowPips, gabShowPips, giNumSess);
	if (DEBUG)
		Print("giNumSess=", giNumSess, " (after $BoolsExtract for pips).");

	if (PipsRounded)
		giPipsPrecision = 0;
	else
	{
		if (Digits == 3 || Digits == 5)
			giPipsPrecision = 1;
		else if (Digits > 5)
			giPipsPrecision = Digits - 4;
		else
			giPipsPrecision = 0;
	}

	// Load the beginning and end times for the sessions.
	if (TimeMethod == Broker_Eastern_offset)
	{
		if (DEBUG)
			Print("Using Eastern offset.");
		for (g = 0; g < giNumSess; g++)
		{
			if (gabShowBox[g] || gabShowName[g] || gabShowPips[g])
			{
				glTimeBegin[g] = TimeHHMMtoMin(asEASTERN_BEGINS[g]) * 60 + BrokerEasternOffset * 3600;
				if (glTimeBegin[g] >= 86400)
					glTimeBegin[g] = glTimeBegin[g] % 86400;

				glTimeEnd[g] = TimeHHMMtoMin(asEASTERN_ENDS[g]) * 60 + BrokerEasternOffset * 3600;
				if (glTimeEnd[g] >= 86400)
					glTimeEnd[g] = glTimeEnd[g] % 86400;

				if (glTimeBegin[g] > glTimeEnd[g])
				{
					glTimeEnd[g] += 86400;
					gabMidnightCross[g] = true;
				}
				else
					gabMidnightCross[g] = false;
				if (DEBUG)
					Print("Session ", g, " is from ", TimeToStr(glTimeBegin[g] | TIME_MINUTES), " to ", TimeToStr(glTimeEnd[g] | TIME_MINUTES), ". Midnight Cross ", gabMidnightCross[g], ".");
			}
		}
	}
	else
	{ // Manual; load from the strings.
		if (DEBUG)
			Print("Using Manual session times.");
		// Only load these two strings if using Manual time mode:
		giNumSess = StringsExtract(Manual_SessionBegins, '/', asManualBegins, MAX_SESSIONS); // Let the function shrink $giNumSess if there are not enough strings.
		giNumSess = StringsExtract(Manual_SessionEnds, '/', asManualEnds, MAX_SESSIONS);	 // Let the function shrink $giNumSess if there are not enough strings.

		for (g = 0; g < giNumSess; g++)
		{
			if (gabShowBox[g] || gabShowName[g] || gabShowPips[g])
			{
				glTimeBegin[g] = TimeHHMMtoMin(asManualBegins[g]) * 60;
				if (glTimeBegin[g] >= 86400)
					glTimeBegin[g] = glTimeBegin[g] % 86400;

				glTimeEnd[g] = TimeHHMMtoMin(asManualEnds[g]) * 60;
				if (glTimeEnd[g] >= 86400)
					glTimeEnd[g] = glTimeEnd[g] % 86400;

				if (glTimeBegin[g] > glTimeEnd[g])
				{
					glTimeEnd[g] += 86400;
					gabMidnightCross[g] = true;
				}
				else
					gabMidnightCross[g] = false;
				if (DEBUG)
					Print("Session ", g, " is from ", TimeToStr(glTimeBegin[g] | TIME_MINUTES), " to ", TimeToStr(glTimeEnd[g] | TIME_MINUTES), ". Midnight Cross ", gabMidnightCross[g], ".");
			}
		}
	}

	gaoColors[0] = Color1;
	gaoColors[1] = Color2;
	gaoColors[2] = Color3;
	gaoColors[3] = Color4;
	gaoColors[4] = Color5;
	// If a "Color" is "None", then the session's "box" should not show.
	for (g = 0; g < giNumSess; g++)
	{
		if (gaoColors[g] == clrNONE)
			gabShowBox[g] = false;
	}

	// Keep a "ShowSess" array, which will be on if the box, name, or pips shows, and off otherwise.  This is better than checking every time.
	for (g = 0; g < giNumSess; g++)
	{
		if (gabShowBox[g] || gabShowName[g] || gabShowPips[g])
			gabShowSess[g] = true;
		else
			gabShowSess[g] = false;
	}

	InitDraw();
	glEarliestDate = glTIME_END; // Keep track of the left-most boxes that we draw on the chart, so that when a lot of
								 //   new bars are downloaded the excess on the left may be removed.

	if (FillBoxes == Fill)
		gbFillBoxes = true;
	else
		gbFillBoxes = false;

	if (ShowTooltips)
		gbShowTooltips = true;
	else
		gbShowTooltips = false;

	visibility.Init("show_hide_as", "AS", "Show/Hide", button_x, button_y);
}

void OnDeinit(const int reason)
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   visibility.DeInit();
}

void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
   if (visibility.HandleButtonClicks())
   {
      ChartRedraw();
   }
}

void InitDraw()
{
	if (!gbTfValid)
		return;

	ArrayInitialize(gadSessLow, 99999999.0);
	ArrayInitialize(gadSessHigh, 0.0);
	glCurBarDate = 0;

	for (int g = 0; g < giNumSess; g++)
		glLastBarDate[g] = 0;
}

int OnCalculate(const int rates_total,	   // size of input time series
				const int prev_calculated, // bars handled in previous call
				const datetime &time[],	   // Time
				const double &open[],	   // Open
				const double &high[],	   // High
				const double &low[],	   // Low
				const double &close[],	   // Close
				const long &tick_volume[], // Tick Volume
				const long &volume[],	   // Real Volume
				const int &spread[])	   // Spread
{
   visibility.HandleButtonClicks();
   
	int i;
	if (!gbTfValid)
		return NO_ERR;

	if (IndicatorCounted() < 0)
	{
		Comment("IndicatorCounted() returned < 0.");
		return ERR_RANGE;
	}
	int iNumChangedBars, iBarMax;

   if (visibility.IsRecalcNeeded())
   {
      if (visibility.IsVisible())
      {
         iNumChangedBars = Bars;
      }
      else
      {
         ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
         visibility.ResetRecalc();
         return 0;
      }
      visibility.ResetRecalc();
   }
   else
   {
      iNumChangedBars = Bars - IndicatorCounted();
   }
	glTickNum++;
	// If we ever are given more than 1 bar (the current bar) to update, then wait X seconds and at least Y ticks and
	//   then redraw everything from scratch.  This fixes the visualization problems that occurred regularly when one
	//   or more new candles were downloaded, which occurs after terminal startup or reconnection.
	

	if (!gbCustTf)
		iBarMax = MathMin(iNumChangedBars, MaxBars) - 1;
	else
	{
		if (IndicatorCounted() == 0 && glTickNum > 1) // On a custom timeframe, $IndicatorCounted() == 0 occurs on virtually every normal bar; it actually means $IndicatorCounted() == Bars.
			iBarMax = 0;
		else
			iBarMax = MathMin(iNumChangedBars, MaxBars) - 1;
	}

	if (DEBUG)
		Print("Tick=", glTickNum, ".  Changed bars=", iNumChangedBars, ".  $IndicatorCounted=", IndicatorCounted());

	if (gbRedrawUponConnect)
	{
		if (IsRedrawSignal(iNumChangedBars))
		{
			glTimer_RedrawAll = TimeLocal() + giRedraw_DelaySec;
			giNumTicksBeforeRedrawAll = giRedraw_DelayTicks;
			giNumRedrawAllsLeft = giRedraw_NumTimes;
			giLastRedrawDelaySec = giRedraw_DelaySec;
			giLastRedrawDelayTicks = giRedraw_DelayTicks;
			if (DEBUG)
				Print("Activated RedrawAll (then ", giNumRedrawAllsLeft, " left to do)...");
		}
		else
		{
			if (giNumTicksBeforeRedrawAll > 0)
				giNumTicksBeforeRedrawAll--;
			else if (giNumTicksBeforeRedrawAll == 0)
			{
				if (TimeLocal() >= glTimer_RedrawAll && giNumRedrawAllsLeft > 0)
				{
					if (DEBUG)
						Print("Redrawing All.");
					DeleteAllExcessObjects();
					InitDraw(); // Reset all arrays.
					iBarMax = MathMin(Bars - 0 - 1, MaxBars);
					giNumRedrawAllsLeft--;
					if (giNumRedrawAllsLeft > 0)
					{
						// Reset the signal.
						glTimer_RedrawAll = TimeLocal() + giLastRedrawDelaySec * 2;
						giLastRedrawDelaySec *= 2;
						giNumTicksBeforeRedrawAll = giLastRedrawDelayTicks * 2;
						giLastRedrawDelayTicks *= 2;
						if (DEBUG)
							Print("Reactivated RedrawAll (", giNumRedrawAllsLeft, " left to do)...");
					}
					else
						giNumTicksBeforeRedrawAll = -1; // Do not deactivate the "RedrawAll" signal until it has been done.
				}
			}
		}
	}

	datetime lMidnight = 0;
	i = iBarMax;
	if (StripToDate(Time[iBarMax]) < glEarliestDate)
	{ // If we are starting before our currently earliest date..
		// ..then skip up to the first midnight at or beyond $iBarMax, (to avoid processing only parts of sessions on the otherwise-earliest day).
		lMidnight = RoundUpToMidnight(Time[iBarMax]);
		for (; Time[i] < lMidnight; i--)
		{
			if (i == 0)
				break;
		}
		InitDraw();
	}
	else if (StripToDate(Time[iBarMax]) < StripToDate(Time[0]))
	{ // If $iBarMax is somewhere between..
		// ..then skip *back* to the first midnight at or beyond $iBarMax, (to avoid processing only parts of sessions, and to ensure we process this day).
		lMidnight = StripToDate(Time[iBarMax]);
		for (; Time[i] > lMidnight; i++)
		{
			if (i == Bars - 1)
				break;
		}
		InitDraw();
	}
	for (; i >= 0; i--)
	{
		glCurBarDate = StripToDate(Time[i]);
		for (int g = 0; g < giNumSess; g++)
		{
			if (gabShowSess[g])
				DoBarForSess(glCurBarDate, gaoColors[g], g, i);
		}
	}

	return NO_ERR;
}

inline bool
IsRedrawSignal(int iNumChangedBars)
{
	if (!gbCustTf)
	{
		// Use old method: only signal on new bars apparently downloaded).
		if (iNumChangedBars > 1)
			return true;
		else
			return false;
	}
	else
	{
		// Use new method: only signal on connection.
		static int iLastTick_NumBars = -1,
				   iThisTick_NumBars = -1;

		iLastTick_NumBars = iThisTick_NumBars;
		iThisTick_NumBars = Bars;

		if (glTickNum <= 1) // Initial connection.
			return true;
		else if (iNumChangedBars == 1 || Bars > iLastTick_NumBars + 1) // Reconnection.  After downloading new bar(s), I observe that it always does this $iNumChangedBars == 1 thing for one tick.
			return true;
		else
			return false;
	}
}

// Assumes $gabShowSess[g] is on.
inline void
DoBarForSess(datetime lCurBarDate, color col1, int g, int iBar)
{
	bool TimeOk = false;

	// Check to see if the bar time is in the current session's range, taking into consideration sessions crossing midnight.
	if (Time[iBar] >= (lCurBarDate + glTimeBegin[g]) && Time[iBar] < (lCurBarDate + glTimeEnd[g]))
	{
		// Time is within the current session's time range.
		TimeOk = true;
	}
	else if (gabMidnightCross[g] && (Time[iBar] < (lCurBarDate - 86400 + glTimeEnd[g])))
	{
		// Time is within the current session's time range, but the session began on the previous day.
		lCurBarDate = lCurBarDate - 86400;

		if (lCurBarDate > glEarliestDate)
		{	// Do not draw any midnight-crossing sessions on the otherwise-earliest day;
			//   these would generally not be the full height since their bars of the
			//   previous day are not checked.
			TimeOk = true;
		}
	}

	// If we are in the given time bracket, draw or update the session rectangles and pips count
	if (TimeOk)
	{
		//if (Time[iBar] == StartTime)
		if (lCurBarDate > glLastBarDate[g])
		{
			// Create a new session and associated objects as the session has started
			glLastBarDate[g] = lCurBarDate;
			gadSessLow[g] = Low[iBar];
			gadSessHigh[g] = High[iBar];
			DrawBox(g, lCurBarDate);
			//	   	if (_Symbol=="NZDJPY_" && lCurBarDate==D'2019.04.01' && g==4) Print("  Drawing session ", g, " at bar ", iBar, " from ", High[iBar], " down to ", Low[iBar], ".");
			DrawNameOrPip(g, lCurBarDate);
		}
		else
		{
			if (Low[iBar] < gadSessLow[g])
			{
				//		   	if (_Symbol=="NZDJPY_" && lCurBarDate==D'2019.04.01' && g==4) Print("  New low   at bar ", iBar, ": ", Low[iBar]);
				// A new low has been reached, so update the visual objects.
				gadSessLow[g] = Low[iBar];
				RedrawBox(g, lCurBarDate);
				RedrawNameOrPip(g, lCurBarDate);
			}
			if (High[iBar] > gadSessHigh[g])
			{
				//		   	if (_Symbol=="NZDJPY_" && lCurBarDate==D'2019.04.01' && g==4) Print("  New high at bar ", iBar, ": ", High[iBar]);
				// A new high has been reached, so update the visual objects.
				gadSessHigh[g] = High[iBar];
				RedrawBox(g, lCurBarDate);
				RedrawNameOrPip(g, lCurBarDate);
			}
		}
	}
}

inline void
DrawBox(int g, datetime lCurBarDate)
{
	if (!gabShowBox[g])
		return;

	string sName = IndicatorObjPrefix + GetBoxObjName(g, lCurBarDate);
	if (ObjectFind(sName) < 0)
	{ // If object doesn't exist..
		ObjectCreate(sName, OBJ_RECTANGLE, 0, lCurBarDate + glTimeBegin[g], gadSessHigh[g], lCurBarDate + glTimeEnd[g], gadSessLow[g]);
		ObjectSet(sName, OBJPROP_COLOR, gaoColors[g]);
		ObjectSet(sName, OBJPROP_BACK, gbFillBoxes);
		ObjectSet(sName, OBJPROP_STYLE, FrameStyle);
		ObjectSet(sName, OBJPROP_WIDTH, FrameWidth);
		ObjectSet(sName, OBJPROP_SELECTABLE, false);
		ObjectSet(sName, OBJPROP_HIDDEN, !ShowInObjectsList);
		if (gbShowTooltips)
			ObjectSetString(0, sName, OBJPROP_TOOLTIP, GetTooltip(g, lCurBarDate));
		else
			ObjectSetString(0, sName, OBJPROP_TOOLTIP, "\n");
		// Update "earliest object."
		if (lCurBarDate < glEarliestDate)
		{
			glEarliestDate = lCurBarDate;
			if (DEBUG)
				Print("Earliest Date changed to ", TimeToStr(glEarliestDate));
		}
	}
	else
	{
		// ..else just adjust its prices.
		ObjectSet(sName, OBJPROP_PRICE1, gadSessHigh[g]);
		ObjectSet(sName, OBJPROP_PRICE2, gadSessLow[g]);
	}
}

inline void
RedrawBox(int g, datetime lCurBarDate)
{
	if (!gabShowBox[g])
		return;

	string sName = IndicatorObjPrefix + GetBoxObjName(g, lCurBarDate);
	ObjectSet(sName, OBJPROP_PRICE1, gadSessHigh[g]);
	ObjectSet(sName, OBJPROP_PRICE2, gadSessLow[g]);
}

inline void
DrawNameOrPip(int g, datetime lCurBarDate)
{
	if (!gabShowName[g] && !gabShowPips[g])
		return;

	string sName = IndicatorObjPrefix + GetNameOrPipsObjName(g, lCurBarDate);
	double dPrice = gadSessHigh[g];

	string sStr = "";
	if (gabShowName[g])
		sStr = gasNames[g] + "  ";
	if (gabShowPips[g])
		sStr = sStr + GetPipsStr(g);

	if (ObjectFind(sName) < 0)
	{ // If object doesn't exist..
		ObjectCreate(sName, OBJ_TEXT, 0, lCurBarDate + glTimeBegin[g], dPrice);
		ObjectSet(sName, OBJPROP_BACK, false);
		ObjectSet(sName, OBJPROP_SELECTABLE, false);
		ObjectSet(sName, OBJPROP_HIDDEN, !ShowInObjectsList);
		//		if (gbShowTooltips)
		//			ObjectSetString(0, sName, OBJPROP_TOOLTIP,    GetTooltip(g, lCurBarDate));
		ObjectSetString(0, sName, OBJPROP_TOOLTIP, "\n"); // "\n" to disable the tooltip.  It would be "caught" (or start) too far to the left of the session
														  //   box, because of all the prefixed spaces.
		// Update "earliest object."
		if (lCurBarDate < glEarliestDate)
		{
			glEarliestDate = lCurBarDate;
			if (DEBUG)
				Print("Earliest Date changed to ", TimeToStr(glEarliestDate));
		}
	}

	ObjectSetText(sName, GetEqualSpacesPlusMargin(sStr) + sStr, PipsFontSize, PipsFont, PipsColor);
	ObjectSet(sName, OBJPROP_PRICE1, dPrice);
}

// Assumes $gabShowSess[g] and $gabShowPips[g] are on.
inline void
RedrawNameOrPip(int g, datetime lCurBarDate)
{
	if (!gabShowName[g] && !gabShowPips[g])
		return;

	string sName = IndicatorObjPrefix + GetNameOrPipsObjName(g, lCurBarDate);
	double dPrice = gadSessHigh[g];

	string sStr = "";
	if (gabShowName[g])
		sStr = gasNames[g] + "  ";
	if (gabShowPips[g])
		sStr = sStr + GetPipsStr(g);

	ObjectSetText(sName, GetEqualSpacesPlusMargin(sStr) + sStr, PipsFontSize, PipsFont, PipsColor);
	ObjectSet(sName, OBJPROP_PRICE1, dPrice);
}

inline string
GetBoxObjName(int g, datetime lCurBarDate)
{
	return gsObjectPrefix + TimeToString(lCurBarDate, TIME_DATE) + " " + gasNames[g];
}

inline string
GetNameOrPipsObjName(int g, datetime lCurBarDate)
{
	return gsObjectPrefix + TimeToString(lCurBarDate, TIME_DATE) + " " + gasNames[g] + " Pips"; // " Pips"  looks better than  " NameAndPips".
}

// Returns "X.Y[ pips]", where $X.Y is a double equal to the number of pips (using $gdPip and rounded to
//   $giPipsPrecision places) and where " pips" will only be appended if $PipsWord is true and will instead be " pip"
//   (singular) when the number is <=1 .
inline string
GetPipsStr(int g)
{
	double dPips = NormalizeDouble((gadSessHigh[g] - gadSessLow[g]) / gdPip, giPipsPrecision);

	if (PipsWord)
	{
		if (MathAbs(dPips) > 1.0)
			return DoubleToStr(dPips, giPipsPrecision) + " pips";
		else
			return DoubleToStr(dPips, giPipsPrecision) + " pip";
	}
	else
		return DoubleToStr(dPips, giPipsPrecision);
}

inline string
GetTooltip(int g, datetime lCurBarDate)
{
	return TooltipPrefix + gasNames[g] + " " + TimeToString(lCurBarDate, TIME_DATE);
}

// Reads and stores up to $iMax substrings from $sSrc (delimited by $ucDelimChr) into $sDest.
//   Virtually any string should be valid for $sSrc.
// *Does* accept blank sub-strings; for example, "///" (with $sDelimChr == "/") will store 4 blank strings into $sDest
//   and return the value 4.
// $asDest is not explicitly allocated; it must be big enough to hold all found strings.
int StringsExtract(string sSrc, ushort uhDelimChr, string &asDest[], int iMax)
{
	int aiSubstrBegin[],
		iLen = StringLen(sSrc),
		iPos,
		iNumStr = 0;
	string sDelimChr = " ";

	sDelimChr = StringSetChar(sDelimChr, 0, uhDelimChr);
	//	Print("$StringsExtract (\"" + sSrc + "\", \'" + sDelimChr + "\' or \'", CharToStr((uchar)uhDelimChr), "\', $asDest, ", iMax, "):");

	if (iLen <= 0)
	{
		asDest[0] = "";
		return 1;
	}

	if (iMax < 1)
		return 0;

	ArrayResize(aiSubstrBegin, iLen + 1);
	aiSubstrBegin[0] = 0;
	iNumStr = 1; // The first string always exists and begins at index 0.
	for (iPos = 0; iPos < iLen;)
	{
		//		Print("  Substring at: ", iPos);
		if (iNumStr >= iMax)
			break;

		iPos = StringFind(sSrc, sDelimChr, iPos) + 1; // "+ 1" because the loop always begins with $iPos at the first character of a substring.
		if (iPos <= 0)
			break; // No [more] substring found.
		aiSubstrBegin[iNumStr] = iPos;
		iNumStr++;
	}

	aiSubstrBegin[iNumStr] = iLen + 1; // That's where the next string would begin, if it existed.
	int len;
	for (int j = 0; j < iNumStr; j++)
	{
		len = (aiSubstrBegin[j + 1] - aiSubstrBegin[j]) - 1;
		if (len > 0)
			asDest[j] = StringSubstr(sSrc, aiSubstrBegin[j], len);
		else
			asDest[j] = "";
		//		Print("  j=", j, ".  len=", len, ".  \"", asDest[j], "\".");
	}

	return iNumStr;
}

// Reads and stores up to $iMax bools (which should be "0" or "1") from $sSrc (ignoring all other characters) into $abDest.
//   For example, "0/0/1" is valid for $sSrc and will return 3;
//   "0/0/2" is valid and will return 2;
//   and "0101" is valid and will return 4.
// $abDest is not explicitly allocated; it must be big enough to hold all found bools.
int BoolsExtract(string sSrc, bool &abDest[], int iMax)
{
	int iLen = StringLen(sSrc),
		iPos;
	ushort uhChr;
	int iNumBool = 0;
	if (iLen <= 0)
		return 0;

	if (iMax < 1)
		return 0;

	for (iPos = 0; iPos < iLen; iPos++)
	{
		uhChr = StringGetChar(sSrc, iPos);
		if (uhChr == '0')
		{
			abDest[iNumBool] = false;
			iNumBool++;
			if (iNumBool >= iMax)
				break;
		}
		else if (uhChr == '1')
		{
			abDest[iNumBool] = true;
			iNumBool++;
			if (iNumBool >= iMax)
				break;
		}
	}

	return iNumBool;
}

bool StringsUnique(string &asSrc[], int iNumStr)
{
	for (int i = 0; i < iNumStr - 1; i++)
	{
		for (int j = i + 1; j < iNumStr; j++)
		{
			if (asSrc[i] == asSrc[j])
				return false;
		}
	}
	return true;
}

// Could also be called "Round down to midnight", but the contexts in which it's used are focused more on the date.
inline datetime
StripToDate(datetime lTime)
{
	return (lTime - (datetime)MathMod(lTime, 86400));
}

inline datetime
RoundUpToMidnight(datetime lTime)
{
	if (MathMod(lTime, 86400) > 0)
		return (StripToDate(lTime) + 86400);
	else
		return lTime;
}

// Given that we can only do sessions up to $MaxBars bars, delete any sessions from the current earliest date, up to
//   and including the max bar's date (since we cannot do a partial day; and not including it if it happens to be midnight).
int DeleteAllExcessObjects()
{
	datetime lDate;
	string sName;
	datetime lDateNewMaxBar;
	int g;
	datetime lOrigEarliestDate = glEarliestDate;

	// Error check.
	if (glEarliestDate < StripToDate(Time[Bars - 1]))
	{
		Comment("AutoSessions: ERR_RANGE in $DeleteAllExcessObjects.");
		return ERR_RANGE;
	}

	// Start at the current max bar and go backwards.
	lDateNewMaxBar = RoundUpToMidnight(Time[MathMin(MaxBars, Bars) - 1]);
	for (lDate = lDateNewMaxBar - 86400; lDate >= glEarliestDate; lDate -= 86400)
	{
		// Delete all the objects for that date, if they exist.
		for (g = 0; g < giNumSess; g++)
		{
			if (gabShowBox[g])
			{
				sName = IndicatorObjPrefix + GetBoxObjName(g, lDate);
				ObjectDelete(sName);
			}
			if (gabShowName[g] || gabShowPips[g])
			{
				sName = IndicatorObjPrefix + GetNameOrPipsObjName(g, lDate);
				ObjectDelete(sName);
			}
		}
	}
	if (DEBUG)
	{
		if (glEarliestDate <= lDateNewMaxBar - 86400)
			Print("Deleting all objects from ", TimeToStr(glEarliestDate), " through ", TimeToStr(lDateNewMaxBar - 86400 + 86400 - 60), ".");
	}
	if (glEarliestDate != lOrigEarliestDate)
	{
		glEarliestDate = lDateNewMaxBar; // Just assume all objects were successfully deleted.
		if (DEBUG)
			Print("Earliest Date changed to ", TimeToStr(glEarliestDate));
	}

	return NO_ERR;
}

// Same as $NormalizeDouble, except default is 0 digits.
inline double
Round(double dIn, int iDig = 0)
{
	return (NormalizeDouble(dIn, iDig));
}

// $sTimeStr may be in the format "HHMM" or "HH:MM".
// The "MM" may be in the range 0-59.
// The "HH" may be in the range 0-99.
// Returns $ERR_FORMAT on error.
int TimeHHMMtoMin(string sTimeStr)
{
	int iHour,
		iMin;
	bool bLen5;

	if (StringLen(sTimeStr) == 4)
		bLen5 = FALSE;
	else if (StringLen(sTimeStr) == 5)
		bLen5 = TRUE;
	else
		return (ERR_FORMAT);

	iHour = atoi(StringSubstr(sTimeStr, 0, 2));
	if (iHour < 0)
		return (ERR_FORMAT);

	iMin = atoi(StringSubstr(sTimeStr, 2 + bLen5, 2));
	if (iMin < 0 || iMin > 59)
		return (ERR_FORMAT);

	return (iHour * 60 + iMin);
}

// Same as $StringToInteger, except always returns $int and uses the classic C function name.
inline int
atoi(string sIn)
{
	return ((int)StringToInteger(sIn));
}

inline string
StringRepeat(string sIn, int param_iNum)
{
	string sOut = "";
	int dup;

	for (dup = 0; dup < param_iNum; dup++)
		sOut = sOut + sIn;

	return (sOut);
}

//--------------------------------------------------------------------------------------------------------------------
//            Font-related functions:
//--------------------------------------------------------------------------------------------------------------------

// Create an array where the k'th element contains a string of k spaces.
void SpacesCreate()
{
	gasSpaces[0] = "";
	for (int k = 1; k <= MAX_SPACES; k++)
		gasSpaces[k] = gasSpaces[k - 1] + " ";
}

// Return how many spaces (exactly for a fixed-width font and approximately for others) are the same pixels of width as $sIn, plus a standard margin.
inline string
GetEqualSpacesPlusMargin(string sIn)
{
	int iNumSpaces;
	if (!PipsFontIsFixedWidth)
		iNumSpaces = StringLen(sIn) * 2 + 1;
	else
		iNumSpaces = StringLen(sIn) + 1;

	if (iNumSpaces <= MAX_SPACES)
		return gasSpaces[iNumSpaces];
	else
	{
		return StringRepeat(" ", iNumSpaces);
	}
}
