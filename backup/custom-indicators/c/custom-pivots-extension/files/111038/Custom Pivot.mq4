//+------------------------------------------------------------------+
//|                              Auto-Pivot Plotter Weekly V2-03.mq4 |
//|                                  Copyright © 2007, BundyRaider   |
//|                                                                  |
//|major update: voty 2016                                           |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2007, BundyRaider"
#property link      ""
#property description "Customized for Davit's thread Pivot Trading with TDI on ForexFactory"
#property description "Credit:"
#property description "BundyRaider for Auto-Pivot Plotter Weekly"
#property description "Griffinsoul for Davit's pivot look and feel"
#property indicator_chart_window
#property indicator_buffers 16
//CHANGELOG:
// 01-OCT-2016 voty - updated deinit (overriding line style during TF change ?!)
// 01-OCT-2016 voty - changed to Davit's colors + optional line style
// 01-OCT-2016 voty - added levels 78,131,168,200
// 24-OCT-2016 voty - e-mail/popup notification for specific pivot only (default:61,100)
// 26-OCT-2016 voty - hidden history mode added (killing eyes for D1,W1,MN1...), but not disabled - still sends e-mail/popup
// 27-OCT-2016 voty - added labels, prolonged pivot line = no more Davit's pivot dependency
// 28-OCT-2016 voty - custom colors, daily/weekly/monthly pivot TP customizable per Chart TF
// 28-OCT-2016 voty - issue with pivot price fixed: History enabled = label under pivot line, History disabled = label on right side
// 28-OCT-2016 voty - refresh issue fixed, TBD: optimization..
//initial = WP, 38,61,100
//added the rest + set Davit's colors + line style option
//SR38 - Magenta
//SR61 - Lime
//SR78 - Red
//SR100 - Aqua
//SR138 - Orange
//SR161 - Black
//SR200 - Brown
//---- input parameters
enum PivotTFChoice
  {
   Default=0,// Default
   D1=1440, // Daily
   W1=10080, // Weekly
   MN=43200 // Monthly
  };
extern PivotTFChoice DefaultPivotTF = 10080;
extern PivotTFChoice ChartM1PivotTF = 0;
extern PivotTFChoice ChartM5PivotTF = 0;
extern PivotTFChoice ChartM15PivotTF = 0;
extern PivotTFChoice ChartM30PivotTF = 0;
extern PivotTFChoice ChartH1PivotTF = 0;
extern PivotTFChoice ChartH4PivotTF = 0;
extern PivotTFChoice ChartD1PivotTF = 0;
extern PivotTFChoice ChartW1PivotTF = 0;
extern PivotTFChoice ChartMNPivotTF = 0;
extern bool ChartM1ShowHistory = false;
extern bool ChartM5ShowHistory = false;
extern bool ChartM15ShowHistory = false;
extern bool ChartM30ShowHistory = false;
extern bool ChartH1ShowHistory = false;
extern bool ChartH4ShowHistory = true;
extern bool ChartD1ShowHistory = true;
extern bool ChartW1ShowHistory = false;
extern bool ChartMN1ShowHistory = false;
extern string PivotPriceNotice  = "History=true, price under the pivot line";
extern string PivotPriceNotice2 = "History=false, price on the right side";
//extern bool ShowPivotLevelBelow = true; // Pivot level below the pivot line
//extern bool ShowPivotLevelRightAndLongLine = false; // Pivot level on the right side + long line!
extern ENUM_LINE_STYLE LineStyle = 0;
extern ENUM_LINE_STYLE LineStylePP = 4;
extern ENUM_LINE_STYLE HistoryLineStyle = 0;
extern ENUM_LINE_STYLE HistoryLineStylePP = 4;
extern bool ShowLegendPivotTF = false;
extern color ColorLegendPivotTF = clrWhiteSmoke;
extern bool ShowLabelPivotTF = true;
extern bool ShowPopup = true;
extern bool SendEMail = true;
extern bool SendNotify = true;
extern bool AlertP   = false;
extern bool Alert38  = false;
extern bool Alert61  = true;
extern bool Alert78  = false;
extern bool Alert100  = true;
extern bool Alert138  = false;
extern bool Alert161  = false;
extern bool Alert200  = false;
extern color ColorP = clrYellow;
extern color ColorR38 = clrMagenta;
extern color ColorS38 = clrMagenta;
extern color ColorR61 = clrLimeGreen;
extern color ColorS61 = clrLimeGreen;
extern color ColorR78 = clrRed;
extern color ColorS78 = clrRed;
extern color ColorR100 = clrAqua;
extern color ColorS100 = clrAqua;
extern color ColorR138 = clrOrange;
extern color ColorS138 = clrOrange;
extern color ColorR161 = clrBlack;
extern color ColorS161 = clrBlack;
extern color ColorR200 = clrBrown;
extern color ColorS200 = clrBrown;

//---- buffers
double Res100[];
double Res61[];
double Res38[];
double Pivot[];
double Supp38[];
double Supp61[];
double Supp100[];
double Extra1[];
double Res78[];
double Supp78[];
double Res138[];
double Supp138[];
double Res161[];
double Supp161[];
double Res200[];
double Supp200[];

datetime lastAlertP, lastAlertR38, lastAlertR61, lastAlertR100, lastAlertS38, lastAlertS61, lastAlertS100;
datetime lastAlertR78, lastAlertS78, lastAlertR138, lastAlertS138, lastAlertR161, lastAlertS161, lastAlertR200, lastAlertS200;

string lbl = "WeeklyPivot.";
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   //---- indicators
   InitializeIndicators();
   IndicatorDigits(Digits);
   lbl = lbl + Symbol() + ".";
   lastAlertP = GlobalVariableGet(lbl+"Pivot");
   lastAlertR38 = GlobalVariableGet(lbl+"R38"); lastAlertR61 = GlobalVariableGet(lbl+"R61"); lastAlertR100 = GlobalVariableGet(lbl+"R100");
   lastAlertS38 = GlobalVariableGet(lbl+"S38"); lastAlertS61 = GlobalVariableGet(lbl+"S61"); lastAlertS100 = GlobalVariableGet(lbl+"S100");
   lastAlertR78 = GlobalVariableGet(lbl+"R78"); lastAlertS78 = GlobalVariableGet(lbl+"S78");
   lastAlertR138 = GlobalVariableGet(lbl+"R138"); lastAlertS138 = GlobalVariableGet(lbl+"S138");
   lastAlertR161 = GlobalVariableGet(lbl+"R161"); lastAlertS161 = GlobalVariableGet(lbl+"S161");
   lastAlertR200 = GlobalVariableGet(lbl+"R200"); lastAlertS200 = GlobalVariableGet(lbl+"S200");
   DeletePivotEnd(); // delete needed for proper update !!!
   //if (!InvisibleIndicator()) {   
   ShowPivotEnd();
   start();
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   DeletePivotEnd();
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int    counted_bars=IndicatorCounted();
   
   if(counted_bars<0) return(-1);
   //---- last counted bar will be recounted
   if(counted_bars>0) counted_bars--;

   int limit=Bars-counted_bars;
//****************************
   //declare variables   
   for(int i=0; i<limit; i++)
   { 

      // *****************************************************
      //    Find previous day's opening and closing bars.
      // *****************************************************
      
      //Find Our Week date.

      datetime WeekDate    =  Time[i];
      int CurrentPivotTF = getCurrentPivotTF();
      int    WeeklyBar     =  iBarShift(NULL, CurrentPivotTF, WeekDate, false)+1; 
      double PreviousHigh  =  iHigh(NULL, CurrentPivotTF, WeeklyBar);
      double PreviousLow   =  iLow(NULL, CurrentPivotTF, WeeklyBar);
      double PreviousClose =  iClose(NULL, CurrentPivotTF, WeeklyBar);

      // ************************************************************************
      //    Calculate Pivot lines and map into indicator buffers.
      // ************************************************************************
      double P  =  (PreviousHigh+PreviousLow+PreviousClose)/3;
      double R38 = P + ((PreviousHigh-PreviousLow) * 0.382);
      double S38 = P - ((PreviousHigh-PreviousLow) * 0.382);
      double R61 = P + ((PreviousHigh-PreviousLow) * 0.618);
      double S61 = P - ((PreviousHigh-PreviousLow) * 0.618);
      double R100 = P + ((PreviousHigh-PreviousLow) * 1.000);
      double S100 = P - ((PreviousHigh-PreviousLow) * 1.000);
      double R78 = P + ((PreviousHigh-PreviousLow) * 0.786);
      double S78 = P - ((PreviousHigh-PreviousLow) * 0.786);
      double R138 = P + ((PreviousHigh-PreviousLow) * 1.382);
      double S138 = P - ((PreviousHigh-PreviousLow) * 1.382);
      double R161 = P + ((PreviousHigh-PreviousLow) * 1.618);
      double S161 = P - ((PreviousHigh-PreviousLow) * 1.618);
      double R200 = P + ((PreviousHigh-PreviousLow) * 2.000);
      double S200 = P - ((PreviousHigh-PreviousLow) * 2.000);
      //Pivot[i] = NormalizeDouble(P, Digits); 
      Pivot[i] = P;
      Res38[i]  = R38;    
      Res61[i]  = R61;  
      Res100[i]  = R100;
      Supp38[i] = S38;   
      Supp61[i] = S61;  
      Supp100[i] = S100;
      Res78[i] = R78; Supp78[i] = S78;
      Res138[i] = R138; Supp138[i] = S138;
      Res161[i] = R161; Supp161[i] = S161;
      Res200[i] = R200; Supp200[i] = S200;
   //
   }
   // ***************************************************************************************
   //                            End of Main Loop
   // ***************************************************************************************
   static double LastBid = 0; string msg;
   if (LastBid == 0) LastBid = Bid;
   else
   {
     if (lastAlertP != iTime(Symbol(), PERIOD_W1, 0))
     {
       if ((NormalizeDouble(LastBid-Pivot[0],_Digits)<0 && NormalizeDouble(Bid-Pivot[0],_Digits)>=0)
         ||(NormalizeDouble(LastBid-Pivot[0],_Digits)>0 && NormalizeDouble(Bid-Pivot[0],_Digits)<=0))
       {
         lastAlertP = iTime(Symbol(), PERIOD_W1, 0); GlobalVariableSet(lbl+"Pivot", lastAlertP);
         msg = TimeToStr(TimeCurrent(), TIME_SECONDS)+" weekly pivot line touched on "+Symbol();
         if (ShowPopup && AlertP) Alert(msg);
         if (SendEMail && AlertP) SendMail(msg, msg);
         if (SendNotify && AlertP) SendNotification(msg);
       }
     }  
     if (lastAlertR38 != iTime(Symbol(), PERIOD_W1, 0))
     {
       if ((NormalizeDouble(LastBid-Res38[0],_Digits)<0 && NormalizeDouble(Bid-Res38[0],_Digits)>=0)
         ||(NormalizeDouble(LastBid-Res38[0],_Digits)>0 && NormalizeDouble(Bid-Res38[0],_Digits)<=0))
       {
         lastAlertR38 = iTime(Symbol(), PERIOD_W1, 0); GlobalVariableSet(lbl+"R38", lastAlertR38);
         msg = TimeToStr(TimeCurrent(), TIME_SECONDS)+" R38 pivot line touched on "+Symbol();
         if (ShowPopup && Alert38) Alert(msg);
         if (SendEMail && Alert38) SendMail(msg, msg);
         if (SendNotify && Alert38) SendNotification(msg);
       }
     }  
     if (lastAlertR61 != iTime(Symbol(), PERIOD_W1, 0))
     {
       if ((NormalizeDouble(LastBid-Res61[0],_Digits)<0 && NormalizeDouble(Bid-Res61[0],_Digits)>=0)
         ||(NormalizeDouble(LastBid-Res61[0],_Digits)>0 && NormalizeDouble(Bid-Res61[0],_Digits)<=0))
       {
         lastAlertR61 = iTime(Symbol(), PERIOD_W1, 0); GlobalVariableSet(lbl+"R61", lastAlertR61);
         msg = TimeToStr(TimeCurrent(), TIME_SECONDS)+" R61 pivot line touched on "+Symbol();
         if (ShowPopup && Alert61) Alert(msg);
         if (SendEMail && Alert61) SendMail(msg, msg);
         if (SendNotify && Alert61) SendNotification(msg);
       }
     }  
     if (lastAlertR100 != iTime(Symbol(), PERIOD_W1, 0))
     {
       if ((NormalizeDouble(LastBid-Res100[0],_Digits)<0 && NormalizeDouble(Bid-Res100[0],_Digits)>=0)
         ||(NormalizeDouble(LastBid-Res100[0],_Digits)>0 && NormalizeDouble(Bid-Res100[0],_Digits)<=0))
       {
         lastAlertR100 = iTime(Symbol(), PERIOD_W1, 0); GlobalVariableSet(lbl+"R100", lastAlertR100);
         msg = TimeToStr(TimeCurrent(), TIME_SECONDS)+" R100 pivot line touched on "+Symbol();
         if (ShowPopup && Alert100) Alert(msg);
         if (SendEMail && Alert100) SendMail(msg, msg);
         if (SendNotify && Alert100) SendNotification(msg);
       }
     }  
     if (lastAlertS38 != iTime(Symbol(), PERIOD_W1, 0))
     {
       if ((NormalizeDouble(LastBid-Supp38[0],_Digits)<0 && NormalizeDouble(Bid-Supp38[0],_Digits)>=0)
         ||(NormalizeDouble(LastBid-Supp38[0],_Digits)>0 && NormalizeDouble(Bid-Supp38[0],_Digits)<=0))
       {
         lastAlertS38 = iTime(Symbol(), PERIOD_W1, 0); GlobalVariableSet(lbl+"S38", lastAlertS38);
         msg = TimeToStr(TimeCurrent(), TIME_SECONDS)+" S38 pivot line touched on "+Symbol();
         if (ShowPopup && Alert38) Alert(msg);
         if (SendEMail && Alert38) SendMail(msg, msg);
         if (SendNotify && Alert38) SendNotification(msg);
       }
     }  
     if (lastAlertS61 != iTime(Symbol(), PERIOD_W1, 0))
     {
       if ((NormalizeDouble(LastBid-Supp61[0],_Digits)<0 && NormalizeDouble(Bid-Supp61[0],_Digits)>=0)
         ||(NormalizeDouble(LastBid-Supp61[0],_Digits)>0 && NormalizeDouble(Bid-Supp61[0],_Digits)<=0))
       {
         lastAlertS61 = iTime(Symbol(), PERIOD_W1, 0); GlobalVariableSet(lbl+"S61", lastAlertS61);
         msg = TimeToStr(TimeCurrent(), TIME_SECONDS)+" S61 pivot line touched on "+Symbol();
         if (ShowPopup && Alert61) Alert(msg);
         if (SendEMail && Alert61) SendMail(msg, msg);
         if (SendNotify && Alert61) SendNotification(msg);
       }
     }  
     if (lastAlertS100 != iTime(Symbol(), PERIOD_W1, 0))
     {
       if ((NormalizeDouble(LastBid-Supp100[0],_Digits)<0 && NormalizeDouble(Bid-Supp100[0],_Digits)>=0)
         ||(NormalizeDouble(LastBid-Supp100[0],_Digits)>0 && NormalizeDouble(Bid-Supp100[0],_Digits)<=0))
       {
         lastAlertS100 = iTime(Symbol(), PERIOD_W1, 0); GlobalVariableSet(lbl+"S100", lastAlertS100);
         msg = TimeToStr(TimeCurrent(), TIME_SECONDS)+" S100 pivot line touched on "+Symbol();
         if (ShowPopup && Alert100) Alert(msg);
         if (SendEMail && Alert100) SendMail(msg, msg);
         if (SendNotify && Alert100) SendNotification(msg);
       }
     }
     if (lastAlertS78 != iTime(Symbol(), PERIOD_W1, 0))
     {
       if ((NormalizeDouble(LastBid-Supp78[0],_Digits)<0 && NormalizeDouble(Bid-Supp78[0],_Digits)>=0)
         ||(NormalizeDouble(LastBid-Supp78[0],_Digits)>0 && NormalizeDouble(Bid-Supp78[0],_Digits)<=0))
       {
         lastAlertS78 = iTime(Symbol(), PERIOD_W1, 0); GlobalVariableSet(lbl+"S78", lastAlertS78);
         msg = TimeToStr(TimeCurrent(), TIME_SECONDS)+" S78 pivot line touched on "+Symbol();
         if (ShowPopup && Alert78) Alert(msg);
         if (SendEMail && Alert78) SendMail(msg, msg);
         if (SendNotify && Alert78) SendNotification(msg);
       }
     }
     if (lastAlertS138 != iTime(Symbol(), PERIOD_W1, 0))
     {
       if ((NormalizeDouble(LastBid-Supp138[0],_Digits)<0 && NormalizeDouble(Bid-Supp138[0],_Digits)>=0)
         ||(NormalizeDouble(LastBid-Supp138[0],_Digits)>0 && NormalizeDouble(Bid-Supp138[0],_Digits)<=0))
       {
         lastAlertS138 = iTime(Symbol(), PERIOD_W1, 0); GlobalVariableSet(lbl+"S138", lastAlertS138);
         msg = TimeToStr(TimeCurrent(), TIME_SECONDS)+" S138 pivot line touched on "+Symbol();
         if (ShowPopup && Alert138) Alert(msg);
         if (SendEMail && Alert138) SendMail(msg, msg);
         if (SendNotify && Alert138) SendNotification(msg);
       }
     }
     if (lastAlertS161 != iTime(Symbol(), PERIOD_W1, 0))
     {
       if ((NormalizeDouble(LastBid-Supp161[0],_Digits)<0 && NormalizeDouble(Bid-Supp161[0],_Digits)>=0)
         ||(NormalizeDouble(LastBid-Supp161[0],_Digits)>0 && NormalizeDouble(Bid-Supp161[0],_Digits)<=0))
       {
         lastAlertS161 = iTime(Symbol(), PERIOD_W1, 0); GlobalVariableSet(lbl+"S161", lastAlertS161);
         msg = TimeToStr(TimeCurrent(), TIME_SECONDS)+" S161 pivot line touched on "+Symbol();
         if (ShowPopup && Alert161) Alert(msg);
         if (SendEMail && Alert161) SendMail(msg, msg);
         if (SendNotify && Alert161) SendNotification(msg);
       }
     }
     if (lastAlertS200 != iTime(Symbol(), PERIOD_W1, 0))
     {
       if ((NormalizeDouble(LastBid-Supp200[0],_Digits)<0 && NormalizeDouble(Bid-Supp200[0],_Digits)>=0)
         ||(NormalizeDouble(LastBid-Supp200[0],_Digits)>0 && NormalizeDouble(Bid-Supp200[0],_Digits)<=0))
       {
         lastAlertS200 = iTime(Symbol(), PERIOD_W1, 0); GlobalVariableSet(lbl+"S200", lastAlertS200);
         msg = TimeToStr(TimeCurrent(), TIME_SECONDS)+" S200 pivot line touched on "+Symbol();
         if (ShowPopup && Alert200) Alert(msg);
         if (SendEMail && Alert200) SendMail(msg, msg);
         if (SendNotify && Alert200) SendNotification(msg);
       }
     }
     
     if (lastAlertR78 != iTime(Symbol(), PERIOD_W1, 0))
     {
       if ((NormalizeDouble(LastBid-Res78[0],_Digits)<0 && NormalizeDouble(Bid-Res78[0],_Digits)>=0)
         ||(NormalizeDouble(LastBid-Res78[0],_Digits)>0 && NormalizeDouble(Bid-Res78[0],_Digits)<=0))
       {
         lastAlertR78 = iTime(Symbol(), PERIOD_W1, 0); GlobalVariableSet(lbl+"R78", lastAlertR78);
         msg = TimeToStr(TimeCurrent(), TIME_SECONDS)+" R78 pivot line touched on "+Symbol();
         if (ShowPopup && Alert78) Alert(msg);
         if (SendEMail && Alert78) SendMail(msg, msg);
         if (SendNotify && Alert78) SendNotification(msg);
       }
     }
     if (lastAlertR138 != iTime(Symbol(), PERIOD_W1, 0))
     {
       if ((NormalizeDouble(LastBid-Res138[0],_Digits)<0 && NormalizeDouble(Bid-Res138[0],_Digits)>=0)
         ||(NormalizeDouble(LastBid-Res138[0],_Digits)>0 && NormalizeDouble(Bid-Res138[0],_Digits)<=0))
       {
         lastAlertR138 = iTime(Symbol(), PERIOD_W1, 0); GlobalVariableSet(lbl+"R138", lastAlertR138);
         msg = TimeToStr(TimeCurrent(), TIME_SECONDS)+" R138 pivot line touched on "+Symbol();
         if (ShowPopup && Alert138) Alert(msg);
         if (SendEMail && Alert138) SendMail(msg, msg);
         if (SendNotify && Alert138) SendNotification(msg);
       }
     }
     if (lastAlertR161 != iTime(Symbol(), PERIOD_W1, 0))
     {
       if ((NormalizeDouble(LastBid-Res161[0],_Digits)<0 && NormalizeDouble(Bid-Res161[0],_Digits)>=0)
         ||(NormalizeDouble(LastBid-Res161[0],_Digits)>0 && NormalizeDouble(Bid-Res161[0],_Digits)<=0))
       {
         lastAlertR161 = iTime(Symbol(), PERIOD_W1, 0); GlobalVariableSet(lbl+"R161", lastAlertR161);
         msg = TimeToStr(TimeCurrent(), TIME_SECONDS)+" R161 pivot line touched on "+Symbol();
         if (ShowPopup && Alert161) Alert(msg);
         if (SendEMail && Alert161) SendMail(msg, msg);
         if (SendNotify && Alert161) SendNotification(msg);
       }
     }
     if (lastAlertR200 != iTime(Symbol(), PERIOD_W1, 0))
     {
       if ((NormalizeDouble(LastBid-Res200[0],_Digits)<0 && NormalizeDouble(Bid-Res200[0],_Digits)>=0)
         ||(NormalizeDouble(LastBid-Res200[0],_Digits)>0 && NormalizeDouble(Bid-Res200[0],_Digits)<=0))
       {
         lastAlertR200 = iTime(Symbol(), PERIOD_W1, 0); GlobalVariableSet(lbl+"R200", lastAlertR200);
         msg = TimeToStr(TimeCurrent(), TIME_SECONDS)+" R200 pivot line touched on "+Symbol();
         if (ShowPopup && Alert200) Alert(msg);
         if (SendEMail && Alert200) SendMail(msg, msg);
         if (SendNotify && Alert200) SendNotification(msg);
       }
     }
   }

   // *****************************************
   //    Return from Start() (Main Routine)
   DeletePivotEnd(); ShowPivotEnd(); //TBD: some optimization !?
   return(0);
  }
//+-------------------------------------------------------------------------------------------------------+
//  END Custom indicator iteration function
//+-------------------------------------------------------------------------------------------------------+


// Delete objects
// a) used during deinit()
// b) needed for proper update of existing objects!
void DeletePivotEnd() {
   ObjectDelete("P_endline");ObjectDelete("P_label");
   ObjectDelete("R38_endline");ObjectDelete("R38_label");
   ObjectDelete("S38_endline");ObjectDelete("S38_label");
   ObjectDelete("R61_endline");ObjectDelete("R61_label");
   ObjectDelete("S61_endline");ObjectDelete("S61_label");
   ObjectDelete("R78_endline");ObjectDelete("R78_label");
   ObjectDelete("S78_endline");ObjectDelete("S78_label");
   ObjectDelete("R100_endline");ObjectDelete("R100_label");
   ObjectDelete("S100_endline");ObjectDelete("S100_label");
   ObjectDelete("R138_endline");ObjectDelete("R138_label");
   ObjectDelete("S138_endline");ObjectDelete("S138_label");
   ObjectDelete("R161_endline");ObjectDelete("R161_label");
   ObjectDelete("S161_endline");ObjectDelete("S161_label");
   ObjectDelete("R200_endline");ObjectDelete("R200_label");
   ObjectDelete("S200_endline");ObjectDelete("S200_label");
   ObjectDelete("PivotTF");
}

// Display static part:
// simple continuation of pivot lines after the calculated indicator's values
void ShowPivotEnd() {
      datetime WeekDate    =  Time[0];
      int CurrentPivotTF = getCurrentPivotTF();
      int    WeeklyBar     =  iBarShift(NULL, CurrentPivotTF, WeekDate, false)+1; 
      double PreviousHigh  =  iHigh(NULL, CurrentPivotTF, WeeklyBar);
      double PreviousLow   =  iLow(NULL, CurrentPivotTF, WeeklyBar);
      double PreviousClose =  iClose(NULL, CurrentPivotTF, WeeklyBar);
      double P  =  (PreviousHigh+PreviousLow+PreviousClose)/3;
      double R38 = P + ((PreviousHigh-PreviousLow) * 0.382);
      double S38 = P - ((PreviousHigh-PreviousLow) * 0.382);
      double R61 = P + ((PreviousHigh-PreviousLow) * 0.618);
      double S61 = P - ((PreviousHigh-PreviousLow) * 0.618);
      double R100 = P + ((PreviousHigh-PreviousLow) * 1.000);
      double S100 = P - ((PreviousHigh-PreviousLow) * 1.000);
      double R78 = P + ((PreviousHigh-PreviousLow) * 0.786);
      double S78 = P - ((PreviousHigh-PreviousLow) * 0.786);
      double R138 = P + ((PreviousHigh-PreviousLow) * 1.382);
      double S138 = P - ((PreviousHigh-PreviousLow) * 1.382);
      double R161 = P + ((PreviousHigh-PreviousLow) * 1.618);
      double S161 = P - ((PreviousHigh-PreviousLow) * 1.618);
      double R200 = P + ((PreviousHigh-PreviousLow) * 2.000);
      double S200 = P - ((PreviousHigh-PreviousLow) * 2.000);
      //PrintFormat("Showing pivot endlines, WP=%0.5f", P);
      //Set pivot lines labels
      string LabelTextP;
      string LabelTextR38;
      string LabelTextS38;
      string LabelTextR61;
      string LabelTextS61;
      string LabelTextR78;
      string LabelTextS78;     
      string LabelTextR100;
      string LabelTextS100;
      string LabelTextR138;
      string LabelTextS138;
      string LabelTextR161;
      string LabelTextS161;
      string LabelTextR200;
      string LabelTextS200;
      //
      if (ShowLabelPivotTF) {
         string ShortPivotTF = StringSubstr(getPivotTextTF(), 0,1);
         LabelTextP += ShortPivotTF;
         LabelTextR38 += ShortPivotTF;
         LabelTextS38 += ShortPivotTF;
         LabelTextR61 += ShortPivotTF;
         LabelTextS61 += ShortPivotTF;
         LabelTextR78 += ShortPivotTF;
         LabelTextS78 += ShortPivotTF;      
         LabelTextR100 += ShortPivotTF;
         LabelTextS100 += ShortPivotTF;
         LabelTextR138 += ShortPivotTF;
         LabelTextS138 += ShortPivotTF;
         LabelTextR161 += ShortPivotTF;
         LabelTextS161 += ShortPivotTF;
         LabelTextR200 += ShortPivotTF;
         LabelTextS200 += ShortPivotTF;
      }
      LabelTextP += "PP";
      LabelTextR38 += "R38";
      LabelTextS38 += "S38";
      LabelTextR61 += "R61";
      LabelTextS61 += "S61";
      LabelTextR78 += "R78";
      LabelTextS78 += "S78";      
      LabelTextR100 += "R100";
      LabelTextS100 += "S100";
      LabelTextR138 += "R138";
      LabelTextS138 += "S138";
      LabelTextR161 += "R161";
      LabelTextS161 += "S161";
      LabelTextR200 += "R200";
      LabelTextS200 += "S200";
      //
      if (ShowLegendPivotTF) {
         ObjectCreate("PivotTF",OBJ_LABEL,0,0,0);
         ObjectSet("PivotTF",OBJPROP_CORNER,1);
         ObjectSet("PivotTF",OBJPROP_XDISTANCE,5);
         ObjectSet("PivotTF",OBJPROP_YDISTANCE,30);
         ObjectSetText("PivotTF", "Pivot TF: " + getPivotTextTF() , 8, NULL, ColorLegendPivotTF);
      }
      if (!HiddenHistory()) {
         LabelTextP += "  " + DoubleToStr(P,Digits);
         LabelTextR38 += "  " + DoubleToStr(R38,Digits);
         LabelTextS38 += "  " + DoubleToStr(S38,Digits);
         LabelTextR61 += "  " + DoubleToStr(R61,Digits);
         LabelTextS61 += "  " + DoubleToStr(S61,Digits);
         LabelTextR78 += "  " + DoubleToStr(R78,Digits);
         LabelTextS78 += "  " + DoubleToStr(S78,Digits);
         LabelTextR100 += "  " + DoubleToStr(R100,Digits);
         LabelTextS100 += "  " + DoubleToStr(S100,Digits);
         LabelTextR138 += "  " + DoubleToStr(R138,Digits);
         LabelTextS138 += "  " + DoubleToStr(S138,Digits);
         LabelTextR161 += "  " + DoubleToStr(R161,Digits);
         LabelTextS161 += "  " + DoubleToStr(S161,Digits);
         LabelTextR200 += "  " + DoubleToStr(R200,Digits);
         LabelTextS200 += "  " + DoubleToStr(S200,Digits);
      }
      int StyleEndline;
      if ( HiddenHistory() )
         StyleEndline = OBJ_HLINE;
      else
         StyleEndline = OBJ_TREND;
      int offsetHighTF = 0; 
      if (Period() < 1440) offsetHighTF =1 ; // =1 to fill tiny 1pixel hole on low TF
      ObjectCreate("P_endline", StyleEndline, 0, Time[0] + Period() * 2200, P, Time[0] - offsetHighTF, P); //2200 - end of screen
      ObjectSet("P_endline", OBJPROP_RAY, false);
      ObjectSet("P_endline", OBJPROP_COLOR, ColorP);
      ObjectSet("P_endline", OBJPROP_STYLE, LineStylePP);
      ObjectCreate("P_label", OBJ_TEXT, 0, Time[0] + Period() * 700, P);
      ObjectSetText("P_label", LabelTextP, 10, "Arial", ColorP);      
      
      ObjectCreate("R38_endline", StyleEndline, 0, Time[0] + Period() * 2200, R38, Time[0] - offsetHighTF, R38); 
      ObjectSet("R38_endline", OBJPROP_RAY, false);
      ObjectSet("R38_endline", OBJPROP_COLOR, ColorR38);
      ObjectSet("R38_endline", OBJPROP_STYLE, LineStyle);
      ObjectCreate("R38_label", OBJ_TEXT, 0, Time[0] + Period() * 700, R38);
      ObjectSetText("R38_label", LabelTextR38, 10, "Arial", ColorR38);
      
      ObjectCreate("S38_endline", StyleEndline, 0, Time[0] + Period() * 2200, S38, Time[0] - offsetHighTF, S38); 
      ObjectSet("S38_endline", OBJPROP_RAY, false);
      ObjectSet("S38_endline", OBJPROP_COLOR, ColorS38);
      ObjectSet("S38_endline", OBJPROP_STYLE, LineStyle);
      ObjectCreate("S38_label", OBJ_TEXT, 0, Time[0] + Period() * 700, S38);
      ObjectSetText("S38_label", LabelTextS38, 10, "Arial", ColorS38);

      ObjectCreate("R61_endline", StyleEndline, 0, Time[0] + Period() * 2200, R61, Time[0] - offsetHighTF, R61); 
      ObjectSet("R61_endline", OBJPROP_RAY, false);
      ObjectSet("R61_endline", OBJPROP_COLOR, ColorR61);
      ObjectSet("R61_endline", OBJPROP_STYLE, LineStyle);
      ObjectCreate("R61_label", OBJ_TEXT, 0, Time[0] + Period() * 700, R61);
      ObjectSetText("R61_label", LabelTextR61, 10, "Arial", ColorR61);

      ObjectCreate("S61_endline", StyleEndline, 0, Time[0] + Period() * 2200, S61, Time[0] - offsetHighTF, S61); 
      ObjectSet("S61_endline", OBJPROP_RAY, false);
      ObjectSet("S61_endline", OBJPROP_COLOR, ColorS61);
      ObjectSet("S61_endline", OBJPROP_STYLE, LineStyle);
      ObjectCreate("S61_label", OBJ_TEXT, 0, Time[0] + Period() * 700, S61);
      ObjectSetText("S61_label", LabelTextS61, 10, "Arial", ColorS61);

      ObjectCreate("R78_endline", StyleEndline, 0, Time[0] + Period() * 2200, R78, Time[0] - offsetHighTF, R78); 
      ObjectSet("R78_endline", OBJPROP_RAY, false);
      ObjectSet("R78_endline", OBJPROP_COLOR, ColorR78);
      ObjectSet("R78_endline", OBJPROP_STYLE, LineStyle);
      ObjectCreate("R78_label", OBJ_TEXT, 0, Time[0] + Period() * 700, R78);
      ObjectSetText("R78_label", LabelTextR78, 10, "Arial", ColorR78);

      ObjectCreate("S78_endline", StyleEndline, 0, Time[0] + Period() * 2200, S78, Time[0] - offsetHighTF, S78); 
      ObjectSet("S78_endline", OBJPROP_RAY, false);
      ObjectSet("S78_endline", OBJPROP_COLOR, ColorS78);
      ObjectSet("S78_endline", OBJPROP_STYLE, LineStyle);
      ObjectCreate("S78_label", OBJ_TEXT, 0, Time[0] + Period() * 700, S78);
      ObjectSetText("S78_label", LabelTextS78, 10, "Arial", ColorS78);

      ObjectCreate("R100_endline", StyleEndline, 0, Time[0] + Period() * 2200, R100, Time[0] - offsetHighTF, R100); 
      ObjectSet("R100_endline", OBJPROP_RAY, false);
      ObjectSet("R100_endline", OBJPROP_COLOR, ColorR100);
      ObjectSet("R100_endline", OBJPROP_STYLE, LineStyle);
      ObjectCreate("R100_label", OBJ_TEXT, 0, Time[0] + Period() * 700, R100);
      ObjectSetText("R100_label", LabelTextR100, 10, "Arial", ColorR100);

      ObjectCreate("S100_endline", StyleEndline, 0, Time[0] + Period() * 2200, S100, Time[0] - offsetHighTF, S100); 
      ObjectSet("S100_endline", OBJPROP_RAY, false);
      ObjectSet("S100_endline", OBJPROP_COLOR, ColorS100);
      ObjectSet("S100_endline", OBJPROP_STYLE, LineStyle);
      ObjectCreate("S100_label", OBJ_TEXT, 0, Time[0] + Period() * 700, S100);
      ObjectSetText("S100_label", LabelTextS100, 10, "Arial", ColorS100);

      ObjectCreate("R138_endline", StyleEndline, 0, Time[0] + Period() * 2200, R138, Time[0] - offsetHighTF, R138); 
      ObjectSet("R138_endline", OBJPROP_RAY, false);
      ObjectSet("R138_endline", OBJPROP_COLOR, ColorR138);
      ObjectSet("R138_endline", OBJPROP_STYLE, LineStyle);
      ObjectCreate("R138_label", OBJ_TEXT, 0, Time[0] + Period() * 700, R138);
      ObjectSetText("R138_label", LabelTextR138, 10, "Arial", ColorR138);

      ObjectCreate("S138_endline", StyleEndline, 0, Time[0] + Period() * 2200, S138, Time[0] - offsetHighTF, S138); 
      ObjectSet("S138_endline", OBJPROP_RAY, false);
      ObjectSet("S138_endline", OBJPROP_COLOR, ColorS138);
      ObjectSet("S138_endline", OBJPROP_STYLE, LineStyle);
      ObjectCreate("S138_label", OBJ_TEXT, 0, Time[0] + Period() * 700, S138);
      ObjectSetText("S138_label", LabelTextS138, 10, "Arial", ColorS138);

      ObjectCreate("R161_endline", StyleEndline, 0, Time[0] + Period() * 2200, R161, Time[0] - offsetHighTF, R161); 
      ObjectSet("R161_endline", OBJPROP_RAY, false);
      ObjectSet("R161_endline", OBJPROP_COLOR, ColorR161);
      ObjectSet("R161_endline", OBJPROP_STYLE, LineStyle);
      ObjectCreate("R161_label", OBJ_TEXT, 0, Time[0] + Period() * 700, R161);
      ObjectSetText("R161_label", LabelTextR161, 10, "Arial", ColorR161);

      ObjectCreate("S161_endline", StyleEndline, 0, Time[0] + Period() * 2200, S161, Time[0] - offsetHighTF, S161); 
      ObjectSet("S161_endline", OBJPROP_RAY, false);
      ObjectSet("S161_endline", OBJPROP_COLOR, ColorS161);
      ObjectSet("S161_endline", OBJPROP_STYLE, LineStyle);
      ObjectCreate("S161_label", OBJ_TEXT, 0, Time[0] + Period() * 700, S161);
      ObjectSetText("S161_label", LabelTextS161, 10, "Arial", ColorS161);

      ObjectCreate("R200_endline", StyleEndline, 0, Time[0] + Period() * 2200, R200, Time[0] - offsetHighTF, R200); 
      ObjectSet("R200_endline", OBJPROP_RAY, false);
      ObjectSet("R200_endline", OBJPROP_COLOR, ColorR200);
      ObjectSet("R200_endline", OBJPROP_STYLE, LineStyle);
      ObjectCreate("R200_label", OBJ_TEXT, 0, Time[0] + Period() * 700, R200);
      ObjectSetText("R200_label", LabelTextR200, 10, "Arial", ColorR200);

      ObjectCreate("S200_endline", StyleEndline, 0, Time[0] + Period() * 2200, S200, Time[0] - offsetHighTF, S200); 
      ObjectSet("S200_endline", OBJPROP_RAY, false);
      ObjectSet("S200_endline", OBJPROP_COLOR, ColorS200);
      ObjectSet("S200_endline", OBJPROP_STYLE, LineStyle);
      ObjectCreate("S200_label", OBJ_TEXT, 0, Time[0] + Period() * 700, S200);
      ObjectSetText("S200_label", LabelTextS200, 10, "Arial", ColorS200);
   }

// do not show history - useful for high TF
// (but still does send popup/e-mails)
bool HiddenHistory() {
   //InvisibleIndicatorD1, InvisibleIndicatorW1, InvisibleIndicatorMN1;
   //1440, 10080, 43200
   //if (ShowHistory == false) return false;   
   if ( 
        (ChartM1ShowHistory && Period() == 1) ||
        (ChartM5ShowHistory && Period() == 5) ||
        (ChartM15ShowHistory && Period() == 15) ||
        (ChartM30ShowHistory && Period() == 30) ||
        (ChartH1ShowHistory && Period() == 60) ||
        (ChartH4ShowHistory && Period() == 240) ||
        (ChartD1ShowHistory && Period() == 1440) ||
        (ChartW1ShowHistory && Period() == 10080) ||
        (ChartMN1ShowHistory && Period() == 43200))
      return 
         false;
      else 
         return true;
}

// depends on combination of PivotTFChoice
int getCurrentPivotTF() {
   int PivotTF = DefaultPivotTF;
   //43200, 10080, 1440, 240, 60, 30, 15, 5, 1
   switch (Period()) {
      case 43200: if (ChartMNPivotTF > 0) PivotTF = ChartMNPivotTF; break;
      case 10080: if (ChartW1PivotTF > 0) PivotTF = ChartW1PivotTF; break;
      case 1440: if (ChartD1PivotTF > 0) PivotTF = ChartD1PivotTF; break;
      case 240: if (ChartH4PivotTF > 0) PivotTF = ChartH4PivotTF; break;
      case 60: if (ChartH1PivotTF > 0) PivotTF = ChartH1PivotTF; break;
      case 30: if (ChartM30PivotTF > 0) PivotTF = ChartM30PivotTF; break;
      case 15: if (ChartM15PivotTF > 0) PivotTF = ChartM15PivotTF; break;
      case 5: if (ChartM5PivotTF > 0) PivotTF = ChartM5PivotTF; break;
      case 1: if (ChartM1PivotTF > 0) PivotTF = ChartM1PivotTF; break;
   }
   if (PivotTF ==0) PivotTF=10080; // default
   return PivotTF;
}

// return currently used pivot TF - used only for label
string getPivotTextTF() {
   string PivottextTF;
   switch (getCurrentPivotTF()) {
      case 43200: PivottextTF = "Monthly"; break;
      case 10080: PivottextTF = "Weekly"; break;
      case 1440: PivottextTF = "Daily"; break;
   }   
   return PivottextTF;
   
}

void InitializeIndicators() {
   if (!HiddenHistory()) {
   SetIndexStyle(0, DRAW_LINE, HistoryLineStyle, EMPTY, ColorR100);
   SetIndexStyle(1, DRAW_LINE, HistoryLineStyle, EMPTY, ColorR61);
   SetIndexStyle(2, DRAW_LINE, HistoryLineStyle, EMPTY, ColorR38);
   SetIndexStyle(3, DRAW_LINE, HistoryLineStylePP, EMPTY, ColorP);
   SetIndexStyle(4, DRAW_LINE, HistoryLineStyle, EMPTY, ColorS38);
   SetIndexStyle(5, DRAW_LINE, HistoryLineStyle, EMPTY, ColorS61);
   SetIndexStyle(6, DRAW_LINE, HistoryLineStyle, EMPTY, ColorS100);
   SetIndexStyle(7, DRAW_LINE, STYLE_SOLID); // voty - what is this line ??
   SetIndexStyle(8, DRAW_LINE, HistoryLineStyle, EMPTY, ColorR78);
   SetIndexStyle(9, DRAW_LINE, HistoryLineStyle, EMPTY, ColorS78);
   SetIndexStyle(10, DRAW_LINE, HistoryLineStyle, EMPTY, ColorR138);
   SetIndexStyle(11, DRAW_LINE, HistoryLineStyle, EMPTY, ColorS138);
   SetIndexStyle(12, DRAW_LINE, HistoryLineStyle, EMPTY, ColorR161);
   SetIndexStyle(13, DRAW_LINE, HistoryLineStyle, EMPTY, ColorS161);
   SetIndexStyle(14, DRAW_LINE, HistoryLineStyle, EMPTY, ColorR200);
   SetIndexStyle(15, DRAW_LINE, HistoryLineStyle, EMPTY, ColorS200);
   SetIndexBuffer(0,Res100); SetIndexLabel(0,"R100");
   SetIndexBuffer(1,Res61); SetIndexLabel(1,"R61");
   SetIndexBuffer(2,Res38); SetIndexLabel(2,"R38");
   SetIndexBuffer(3,Pivot); SetIndexLabel(3,"Pivot");
   SetIndexBuffer(4,Supp38); SetIndexLabel(4,"S38");
   SetIndexBuffer(5,Supp61); SetIndexLabel(5,"S61");
   SetIndexBuffer(6,Supp100); SetIndexLabel(6,"S100");
   SetIndexBuffer(7,Extra1);   
   SetIndexBuffer(8,Res78); SetIndexLabel(8,"R78");
   SetIndexBuffer(9,Supp78); SetIndexLabel(9,"S78");
   SetIndexBuffer(10,Res138); SetIndexLabel(10,"R138");
   SetIndexBuffer(11,Supp138); SetIndexLabel(11,"S138");
   SetIndexBuffer(12,Res161); SetIndexLabel(12,"R161");
   SetIndexBuffer(13,Supp161); SetIndexLabel(13,"S161");
   SetIndexBuffer(14,Res200); SetIndexLabel(14,"R200");
   SetIndexBuffer(15,Supp200); SetIndexLabel(15,"S200");      
   }
}
// *****************************************************************************************
// *****************************************************************************************
// -----------------------------------------------------------------------------------------
//    The following routine will use "StartingBar"'s time and use it to find the 
//    general area that SHOULD contain the bar that matches "TimeToLookFor"
// -----------------------------------------------------------------------------------------