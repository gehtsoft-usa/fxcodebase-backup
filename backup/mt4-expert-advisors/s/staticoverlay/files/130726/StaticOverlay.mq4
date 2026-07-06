// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=27&t=69311
//+------------------------------------------------------------------+
//|                                                StaticOverlay.mq4 |
//|                      Copyright � 2009, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright � 2009, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"

extern string  sSymbol = "EURCHF";
extern int     iPeriod = 330;
extern bool    bMirror = true;
extern bool    bUseAutoCorr = true;
extern color   Color = Red;

#property indicator_separate_window
#property indicator_buffers 8
#property indicator_color1 Red
#property indicator_color2 Blue
#property indicator_color3 Yellow
#property indicator_color4 Green
#property indicator_color5 White
#property indicator_color6 White
#property indicator_color7 Red
#property indicator_color8 Red
//---- buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
double ExtMapBuffer3[];
double ExtMapBuffer4[];
double ExtMapBuffer5[];
double ExtMapBuffer6[];
double ExtMapBuffer7[];
double ExtMapBuffer8[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_LINE,EMPTY,EMPTY,Color);
   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,ExtMapBuffer2);
   SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(2,ExtMapBuffer3);
   SetIndexStyle(3,DRAW_LINE);
   SetIndexBuffer(3,ExtMapBuffer4);
   SetIndexStyle(4,DRAW_LINE);
   SetIndexBuffer(4,ExtMapBuffer5);
   SetIndexStyle(5,DRAW_LINE);
   SetIndexBuffer(5,ExtMapBuffer6);
   SetIndexStyle(6,DRAW_LINE);
   SetIndexBuffer(6,ExtMapBuffer7);
   SetIndexStyle(7,DRAW_LINE);
   SetIndexBuffer(7,ExtMapBuffer8);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----

//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   //Initialize Buffers
	RefreshRates();
if(bUseAutoCorr)
{
   if(GetCorrType(Symbol(), sSymbol) == -1)bMirror = true;
   if(GetCorrType(Symbol(), sSymbol) == 1)bMirror = false;
}

   for(int i = 0; i < 2000; i++)
   {
      ExtMapBuffer1[i] = OverlayValue(Symbol(),sSymbol,0,bMirror,iPeriod, i);
   }
   
   return(0);
  }
double OverlayValue(string sSymbol1, string sSymbol2,int iTimeFrame, bool bMirror,int iPeriod, int i)
{
sSymbol1 = MiniCheck(sSymbol1);
sSymbol2 = MiniCheck(sSymbol2);
int iLastBar =  i; 
int iFirstBar = i + iPeriod;
int iBarsVisible = iFirstBar - iLastBar ;

   if ( iLastBar < 0 ) 
   {
      iLastBar = 0;
      iBarsVisible = iFirstBar;
   }
   datetime TimeBarsVisible = iTime(sSymbol1,iTimeFrame,iBarsVisible);
   datetime TimeLastBar = iTime(sSymbol1,iTimeFrame,iLastBar);

   double   dCurRangeHigh = High[iHighest(sSymbol1, iTimeFrame, MODE_HIGH, iBarShift(sSymbol1,iTimeFrame,TimeBarsVisible), iBarShift(sSymbol1,iTimeFrame,TimeLastBar))];
   double   dCurRangeLow = Low[iLowest(sSymbol1, iTimeFrame, MODE_LOW, iBarShift(sSymbol1,iTimeFrame,TimeBarsVisible), iBarShift(sSymbol1,iTimeFrame,TimeLastBar))];
   double   dCurRangeCenter = ( dCurRangeHigh + dCurRangeLow ) / 2;  
   
   int iShiftBarsVisible = iBarShift(sSymbol2,iTimeFrame,TimeBarsVisible);
   int iShiftLastBar = iBarShift(sSymbol2,iTimeFrame,TimeLastBar);
      
   double dSubRangeHigh = 0;
   double dSubRangeLow  = 0;
   if ( bMirror ) 
   {
      dSubRangeHigh = iLow( sSymbol2, 0, iLowest( sSymbol2, iTimeFrame, MODE_LOW,iShiftBarsVisible,iShiftLastBar ) );
      dSubRangeLow = iHigh( sSymbol2, 0, iHighest( sSymbol2, iTimeFrame, MODE_HIGH, iShiftBarsVisible,iShiftLastBar ) );
   } 
   else 
   {
      dSubRangeHigh = iHigh( sSymbol2, 0, iHighest( sSymbol2, iTimeFrame, MODE_HIGH, iShiftBarsVisible,iShiftLastBar  ) );
      dSubRangeLow = iLow( sSymbol2, 0, iLowest( sSymbol2, iTimeFrame, MODE_LOW, iShiftBarsVisible,iShiftLastBar  ) );
   }
   
   double dSubRangeCenter = ( dSubRangeHigh + dSubRangeLow ) / 2;
   
   double dPipsRatio = dSubRangeHigh - dSubRangeLow == 0 ? 0 : (dCurRangeHigh - dCurRangeLow) / (dSubRangeHigh - dSubRangeLow);
   double dSubClose = iClose( sSymbol2, iTimeFrame, iBarShift(sSymbol2,iTimeFrame,iTime(sSymbol1,iTimeFrame,i)) ) - dSubRangeCenter;
   return( dCurRangeCenter + dSubClose * dPipsRatio);
   
}  
//To see how symbols are corrlelated to each other
int GetCorrType(string sSymbol1, string sSymbol2)
{
if( StringSubstr(sSymbol1, 0, 3) == StringSubstr(sSymbol2, 3, 3) || StringSubstr(sSymbol2, 0, 3) == StringSubstr(sSymbol1, 3, 3))
return(-1);
if( StringSubstr(sSymbol1, 0, 3) == StringSubstr(sSymbol2, 0, 3) || StringSubstr(sSymbol2, 0, 3) == StringSubstr(sSymbol1, 0, 3))
return(1);

if( StringSubstr(sSymbol1, 3, 3) == StringSubstr(sSymbol2, 0, 3) || StringSubstr(sSymbol2, 3, 3) == StringSubstr(sSymbol1, 0, 3))
return(-1);
if( StringSubstr(sSymbol1, 3, 3) == StringSubstr(sSymbol2, 3, 3) || StringSubstr(sSymbol2, 3, 3) == StringSubstr(sSymbol1, 3, 3))
return(1);

return(0);
}
//Check for prefix and adjust symbol if needed
string MiniCheck(string sSymbol)
{
  if(StringLen(sSymbol) > 6 && (StringLen(Symbol()) > 6) )return(sSymbol);
  if(StringLen(sSymbol) > 6 && !(StringLen(Symbol()) > 6) )return(StringSubstr(sSymbol, 0, 6));
  if( !(StringLen(sSymbol) > 6) && (StringLen(Symbol()) > 6) )return(sSymbol+""+StringSubstr(Symbol(), 6, StringLen(Symbol()) -6 ));
  return (sSymbol);
}

//+------------------------------------------------------------------+