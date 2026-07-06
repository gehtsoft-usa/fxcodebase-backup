// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=72005


//+------------------------------------------------------------------------+
//|                                    Copyright © 2021, Gehtsoft USA LLC  |
//|                                                 http://fxcodebase.com  |
//+------------------------------------------------------------------------+
//|                                      Support our efforts by donating   |
//|                                         Paypal: https://goo.gl/9Rj74e  |
//+------------------------------------------------------------------------+
//|                                           Developed by : Mario Jemic   |
//|                                               mario.jemic@gmail.com    |
//|                                https://AppliedMachineLearning.systems  |
//|                                     Patreon :  https://goo.gl/GdXWeN   |
//+------------------------------------------------------------------------+

//+------------------------------------------------------------------------+
//|BitCoin Address            : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF         |
//|Ethereum Address           : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D |
//|Dogecoin Address           : DNDTFfmVa2Gjts5YvSKEYaiih6cums2L6C         |
//|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c |
//|Binance Address (BEP2 only): bnb136ns6lfw4zs5hg4n85vdthaad7hq5m4gtkgf23 |
//|Binance MEMO (BEP2 only)   : 107152697                                  |
//|LiteCoin Address           : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD         |
//+------------------------------------------------------------------------+


#property copyright "Copyright © 2021, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.0"
#property description ""

//--- indicator settings
#property indicator_chart_window
#property indicator_buffers 6
#property indicator_plots 6

#property indicator_type1 DRAW_ARROW
#property indicator_width1 5
#property indicator_color1 0xFFFFFF
#property indicator_label1 "open Buy"

#property indicator_type2 DRAW_ARROW
#property indicator_width2 5
#property indicator_color2 0xFFFFFF
#property indicator_label2 "open Buy"

#property indicator_type3 DRAW_ARROW
#property indicator_width3 5
#property indicator_color3 0xFFFFFF
#property indicator_label3 "open Buy"

#property indicator_type4 DRAW_ARROW
#property indicator_width4 5
#property indicator_color4 0xFFFFFF
#property indicator_label4 "open Sell"

#property indicator_type5 DRAW_ARROW
#property indicator_width5 5
#property indicator_color5 0xFFFFFF
#property indicator_label5 "open Buy"

#property indicator_type6 DRAW_ARROW
#property indicator_width6 5
#property indicator_color6 0xFFFFFF
#property indicator_label6 "open Sell"

//--- indicator buffers
double Buffer1[];
double Buffer2[];
double Buffer3[];
double Buffer4[];
double Buffer5[];
double Buffer6[];

datetime time_alert; //used when sending alert
bool Send_Email = true;
bool Audible_Alerts = true;
bool Push_Notifications = true;
double myPoint; //initialized in OnInit
int SAR_handle;
double SAR[];
double Low[];
int AC_handle;
double AC[];
int CCI_handle;
double CCI[];
int DeMarker_handle;
double DeMarker[];
int RSI_handle;
double RSI[];
int Stochastic_handle;
double Stochastic_Main[];
int WPR_handle;
double WPR[];
int MFI_handle;
double MFI[];
double High[];
int CCI_handle2;
double CCI2[];
int RSI_handle2;
double RSI2[];

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void myAlert(string type, string message)
  {
   int handle;
   if(type == "print")
      Print(message);
   else
      if(type == "error")
        {
         Print(type+" | Tester_making @ "+Symbol()+","+IntegerToString(Period())+" | "+message);
        }
      else
         if(type == "order")
           {
           }
         else
            if(type == "modify")
              {
              }
            else
               if(type == "indicator")
                 {
                  Print(type+" | Tester_making @ "+Symbol()+","+IntegerToString(Period())+" | "+message);
                  if(Audible_Alerts)
                     Alert(type+" | Tester_making @ "+Symbol()+","+IntegerToString(Period())+" | "+message);
                  if(Send_Email)
                     SendMail("Tester_making", type+" | Tester_making @ "+Symbol()+","+IntegerToString(Period())+" | "+message);
                  handle = FileOpen("Tester_making.txt", FILE_TXT|FILE_READ|FILE_WRITE|FILE_SHARE_READ|FILE_SHARE_WRITE, ';');
                  if(handle != INVALID_HANDLE)
                    {
                     FileSeek(handle, 0, SEEK_END);
                     FileWrite(handle, type+" | Tester_making @ "+Symbol()+","+IntegerToString(Period())+" | "+message);
                     FileClose(handle);
                    }
                  if(Push_Notifications)
                     SendNotification(type+" | Tester_making @ "+Symbol()+","+IntegerToString(Period())+" | "+message);
                 }
  }

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+

string PanelLabel="Tester_Making";

int PanelMovX=26;
int PanelMovY=26;
int PanelLabX=120;
int PanelLabY=PanelMovY;
int PanelRecX=(PanelMovX+2)*2+PanelLabX+2;
input int Xoff=20;                                      //Horizontal spacing for the control panel
input int Yoff=20;                                      //Vertical spacing for the control panel

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {





//////////////////////////////////////
   SetIndexBuffer(0, Buffer1);
   PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetInteger(0, PLOT_ARROW, 241);
   SetIndexBuffer(1, Buffer2);
   PlotIndexSetDouble(1, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetInteger(1, PLOT_ARROW, 242);
   SetIndexBuffer(2, Buffer3);
   PlotIndexSetDouble(2, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetInteger(2, PLOT_ARROW, 241);
   SetIndexBuffer(3, Buffer4);
   PlotIndexSetDouble(3, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetInteger(3, PLOT_ARROW, 242);
   SetIndexBuffer(4, Buffer5);
   PlotIndexSetDouble(4, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetInteger(4, PLOT_ARROW, 241);
   SetIndexBuffer(5, Buffer6);
   PlotIndexSetDouble(5, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetInteger(5, PLOT_ARROW, 242);
//initialize myPoint
   myPoint = Point();
   if(Digits() == 5 || Digits() == 3)
     {
      myPoint *= 10;
     }
   SAR_handle = iSAR(NULL, PERIOD_CURRENT, 999999999, 999999999);
   if(SAR_handle < 0)
     {
      Print("The creation of iSAR has failed: SAR_handle=", INVALID_HANDLE);
      Print("Runtime error = ", GetLastError());
      return(INIT_FAILED);
     }

   AC_handle = iAC(NULL, PERIOD_CURRENT);
   if(AC_handle < 0)
     {
      Print("The creation of iAC has failed: AC_handle=", INVALID_HANDLE);
      Print("Runtime error = ", GetLastError());
      return(INIT_FAILED);
     }

   CCI_handle = iCCI(NULL, PERIOD_CURRENT, 63, PRICE_LOW);
   if(CCI_handle < 0)
     {
      Print("The creation of iCCI has failed: CCI_handle=", INVALID_HANDLE);
      Print("Runtime error = ", GetLastError());
      return(INIT_FAILED);
     }

   DeMarker_handle = iDeMarker(NULL, PERIOD_CURRENT, 14);
   if(DeMarker_handle < 0)
     {
      Print("The creation of iDeMarker has failed: DeMarker_handle=", INVALID_HANDLE);
      Print("Runtime error = ", GetLastError());
      return(INIT_FAILED);
     }

   RSI_handle = iRSI(NULL, PERIOD_CURRENT, 9, PRICE_LOW);
   if(RSI_handle < 0)
     {
      Print("The creation of iRSI has failed: RSI_handle=", INVALID_HANDLE);
      Print("Runtime error = ", GetLastError());
      return(INIT_FAILED);
     }

   Stochastic_handle = iStochastic(NULL, PERIOD_CURRENT, 5, 3, 6, MODE_LWMA, STO_LOWHIGH);
   if(Stochastic_handle < 0)
     {
      Print("The creation of iStochastic has failed: Stochastic_handle=", INVALID_HANDLE);
      Print("Runtime error = ", GetLastError());
      return(INIT_FAILED);
     }

   WPR_handle = iWPR(NULL, PERIOD_CURRENT, 99);
   if(WPR_handle < 0)
     {
      Print("The creation of iWPR has failed: WPR_handle=", INVALID_HANDLE);
      Print("Runtime error = ", GetLastError());
      return(INIT_FAILED);
     }

   MFI_handle = iMFI(NULL, PERIOD_CURRENT, 1, VOLUME_TICK);
   if(MFI_handle < 0)
     {
      Print("The creation of iMFI has failed: MFI_handle=", INVALID_HANDLE);
      Print("Runtime error = ", GetLastError());
      return(INIT_FAILED);
     }

   CCI_handle2 = iCCI(NULL, PERIOD_CURRENT, 63, PRICE_HIGH);
   if(CCI_handle2 < 0)
     {
      Print("The creation of iCCI has failed: CCI_handle2=", INVALID_HANDLE);
      Print("Runtime error = ", GetLastError());
      return(INIT_FAILED);
     }

   RSI_handle2 = iRSI(NULL, PERIOD_CURRENT, 9, PRICE_HIGH);
   if(RSI_handle2 < 0)
     {
      Print("The creation of iRSI has failed: RSI_handle2=", INVALID_HANDLE);
      Print("Runtime error = ", GetLastError());
      return(INIT_FAILED);
     }

   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
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
                const int& spread[])
  {
   int limit = rates_total - prev_calculated;
//--- counting from 0 to rates_total
   ArraySetAsSeries(Buffer1, true);
   ArraySetAsSeries(Buffer2, true);
   ArraySetAsSeries(Buffer3, true);
   ArraySetAsSeries(Buffer4, true);
   ArraySetAsSeries(Buffer5, true);
   ArraySetAsSeries(Buffer6, true);
//--- initial zero
   if(prev_calculated < 1)
     {
      ArrayInitialize(Buffer1, EMPTY_VALUE);
      ArrayInitialize(Buffer2, EMPTY_VALUE);
      ArrayInitialize(Buffer3, EMPTY_VALUE);
      ArrayInitialize(Buffer4, EMPTY_VALUE);
      ArrayInitialize(Buffer5, EMPTY_VALUE);
      ArrayInitialize(Buffer6, EMPTY_VALUE);
     }
   else
      limit++;
   datetime Time[];

   if(BarsCalculated(SAR_handle) <= 0)
      return(0);
   if(CopyBuffer(SAR_handle, 0, 0, rates_total, SAR) <= 0)
      return(rates_total);
   ArraySetAsSeries(SAR, true);
   if(CopyLow(Symbol(), PERIOD_CURRENT, 0, rates_total, Low) <= 0)
      return(rates_total);
   ArraySetAsSeries(Low, true);
   if(BarsCalculated(AC_handle) <= 0)
      return(0);
   if(CopyBuffer(AC_handle, 0, 0, rates_total, AC) <= 0)
      return(rates_total);
   ArraySetAsSeries(AC, true);
   if(BarsCalculated(CCI_handle) <= 0)
      return(0);
   if(CopyBuffer(CCI_handle, 0, 0, rates_total, CCI) <= 0)
      return(rates_total);
   ArraySetAsSeries(CCI, true);
   if(BarsCalculated(DeMarker_handle) <= 0)
      return(0);
   if(CopyBuffer(DeMarker_handle, 0, 0, rates_total, DeMarker) <= 0)
      return(rates_total);
   ArraySetAsSeries(DeMarker, true);
   if(BarsCalculated(RSI_handle) <= 0)
      return(0);
   if(CopyBuffer(RSI_handle, 0, 0, rates_total, RSI) <= 0)
      return(rates_total);
   ArraySetAsSeries(RSI, true);
   if(BarsCalculated(Stochastic_handle) <= 0)
      return(0);
   if(CopyBuffer(Stochastic_handle, MAIN_LINE, 0, rates_total, Stochastic_Main) <= 0)
      return(rates_total);
   ArraySetAsSeries(Stochastic_Main, true);
   if(BarsCalculated(WPR_handle) <= 0)
      return(0);
   if(CopyBuffer(WPR_handle, 0, 0, rates_total, WPR) <= 0)
      return(rates_total);
   ArraySetAsSeries(WPR, true);
   if(BarsCalculated(MFI_handle) <= 0)
      return(0);
   if(CopyBuffer(MFI_handle, 0, 0, rates_total, MFI) <= 0)
      return(rates_total);
   ArraySetAsSeries(MFI, true);
   if(CopyHigh(Symbol(), PERIOD_CURRENT, 0, rates_total, High) <= 0)
      return(rates_total);
   ArraySetAsSeries(High, true);
   if(BarsCalculated(CCI_handle2) <= 0)
      return(0);
   if(CopyBuffer(CCI_handle2, 0, 0, rates_total, CCI2) <= 0)
      return(rates_total);
   ArraySetAsSeries(CCI2, true);
   if(BarsCalculated(RSI_handle2) <= 0)
      return(0);
   if(CopyBuffer(RSI_handle2, 0, 0, rates_total, RSI2) <= 0)
      return(rates_total);
   ArraySetAsSeries(RSI2, true);
   if(CopyTime(Symbol(), Period(), 0, rates_total, Time) <= 0)
      return(rates_total);
   ArraySetAsSeries(Time, true);
//--- main loop
   for(int i = limit-1; i >= 0; i--)
     {
      if(i >= MathMin(999999-1, rates_total-1-50))
         continue; //omit some old rates to prevent "Array out of range" or slow calculation

      //Indicator Buffer 1
      if(SAR[i] <= Low[i] //Parabolic SAR <= Candlestick Low
         && AC[i] >= AC[1+i] //Accelerator Oscillator >= Accelerator Oscillator
         && CCI[1+i] <= -100 //Commodity Channel Index <= fixed value
         && DeMarker[1+i] <= 0.3 //DeMarker <= fixed value
         && RSI[1+i] <= 30 //Relative Strength Index <= fixed value
         && Stochastic_Main[1+i] <= 30 //Stochastic Oscillator <= fixed value
         && WPR[1+i] <= -80 //William's Percent Range <= fixed value
         && MFI[1+i] <= 5 //Money Flow Index <= fixed value
        )
        {
         Buffer1[i] = Low[i]; //Set indicator value at Candlestick Low
         //  Buying Concept
         DrawEdit(PanelLabel,Xoff+2,Yoff+2,PanelLabX,PanelLabY,true,12,"PATTERN DETECTOR",ALIGN_CENTER,"Consolas","BUYING",false,clrNavy,clrLime,clrBlack);
         if(i == 0 && Time[0] != time_alert)
           {
            myAlert("indicator", "open Buy");   //Instant alert, only once per bar
            time_alert = Time[0];
           }
        }
      else
        {
         Buffer1[i] = EMPTY_VALUE;
        }
      //Indicator Buffer 2
      if(SAR[i] >= High[i] //Parabolic SAR >= Candlestick High
         && AC[i] <= AC[1+i] //Accelerator Oscillator <= Accelerator Oscillator
         && CCI2[1+i] >= 100 //Commodity Channel Index >= fixed value
         && DeMarker[1+i] >= 0.7 //DeMarker >= fixed value
         && RSI2[1+i] >= 70 //Relative Strength Index >= fixed value
         && Stochastic_Main[1+i] >= 70 //Stochastic Oscillator >= fixed value
         && WPR[1+i] >= -20 //William's Percent Range >= fixed value
         && MFI[1+i] >= 95 //Money Flow Index >= fixed value
        )
        {
         Buffer2[i] = High[i]; //Set indicator value at Candlestick High
         //Selling  Concept
         DrawEdit(PanelLabel,Xoff+2,Yoff+2,PanelLabX,PanelLabY,true,12,"PATTERN DETECTOR",ALIGN_CENTER,"Consolas","SELLING",false,clrNavy,clrLime,clrBlack);
         if(i == 0 && Time[0] != time_alert)
           {
            myAlert("indicator", "open Buy");   //Instant alert, only once per bar
            time_alert = Time[0];
           }
        }
      else
        {
         Buffer2[i] = EMPTY_VALUE;
        }
      //Indicator Buffer 3
      if(SAR[i] <= Low[i] //Parabolic SAR <= Candlestick Low
         && AC[i] >= AC[1+i] //Accelerator Oscillator >= Accelerator Oscillator
         && CCI[2+i] <= -100 //Commodity Channel Index <= fixed value
         && DeMarker[2+i] <= 0.3 //DeMarker <= fixed value
         && RSI[2+i] <= 30 //Relative Strength Index <= fixed value
         && Stochastic_Main[2+i] <= 30 //Stochastic Oscillator <= fixed value
         && WPR[2+i] <= -80 //William's Percent Range <= fixed value
         && MFI[2+i] <= 5 //Money Flow Index <= fixed value
        )
        {
         // Buying Concept
         Buffer3[i] = Low[i]; //Set indicator value at Candlestick Low
         DrawEdit(PanelLabel,Xoff+2,Yoff+2,PanelLabX,PanelLabY,true,12,"PATTERN DETECTOR",ALIGN_CENTER,"Consolas","BUY",false,clrNavy,clrLime,clrBlack);
         if(i == 0 && Time[0] != time_alert)
           {
            myAlert("indicator", "open Buy");   //Instant alert, only once per bar
            time_alert = Time[0];
           }
        }
      else
        {
         Buffer3[i] = EMPTY_VALUE;
        }
      //Indicator Buffer 4
      if(SAR[i] >= High[i] //Parabolic SAR >= Candlestick High
         && AC[i] <= AC[1+i] //Accelerator Oscillator <= Accelerator Oscillator
         && CCI2[2+i] >= 100 //Commodity Channel Index >= fixed value
         && DeMarker[2+i] >= 0.7 //DeMarker >= fixed value
         && RSI2[2+i] >= 70 //Relative Strength Index >= fixed value
         && Stochastic_Main[2+i] >= 70 //Stochastic Oscillator >= fixed value
         && WPR[2+i] >= -20 //William's Percent Range >= fixed value
         && MFI[2+i] >= 95 //Money Flow Index >= fixed value
        )
        {
         // Selling Concept
         Buffer4[i] = High[i]; //Set indicator value at Candlestick High
         DrawEdit(PanelLabel,Xoff+2,Yoff+2,PanelLabX,PanelLabY,true,12,"PATTERN DETECTOR",ALIGN_CENTER,"Consolas","SELLING",false,clrNavy,clrLime,clrBlack);
         if(i == 0 && Time[0] != time_alert)
           {
            myAlert("indicator", "open Sell");   //Instant alert, only once per bar
            time_alert = Time[0];
           }
        }
      else
        {
         Buffer4[i] = EMPTY_VALUE;
        }
      //Indicator Buffer 5
      if(SAR[i] <= Low[i] //Parabolic SAR <= Candlestick Low
         && AC[i] >= AC[1+i] //Accelerator Oscillator >= Accelerator Oscillator
         && CCI[3+i] <= -100 //Commodity Channel Index <= fixed value
         && DeMarker[3+i] <= 0.3 //DeMarker <= fixed value
         && RSI[3+i] <= 30 //Relative Strength Index <= fixed value
         && Stochastic_Main[3+i] <= 30 //Stochastic Oscillator <= fixed value
         && WPR[3+i] <= -80 //William's Percent Range <= fixed value
         && MFI[3+i] <= 5 //Money Flow Index <= fixed value
        )
        {
         //Buying Concept
         Buffer5[i] = Low[i]; //Set indicator value at Candlestick Low
         DrawEdit(PanelLabel,Xoff+2,Yoff+2,PanelLabX,PanelLabY,true,12,"PATTERN DETECTOR",ALIGN_CENTER,"Consolas","BUYING",false,clrNavy,clrLime,clrBlack);
         if(i == 0 && Time[0] != time_alert)
           {
            myAlert("indicator", "open Buy");   //Instant alert, only once per bar
            time_alert = Time[0];
           }
        }
      else
        {
         Buffer5[i] = EMPTY_VALUE;
        }
      //Indicator Buffer 6
      if(SAR[i] >= High[i] //Parabolic SAR >= Candlestick High
         && AC[i] <= AC[1+i] //Accelerator Oscillator <= Accelerator Oscillator
         && CCI2[3+i] >= 100 //Commodity Channel Index >= fixed value
         && DeMarker[3+i] >= 0.7 //DeMarker >= fixed value
         && RSI2[3+i] >= 70 //Relative Strength Index >= fixed value
         && Stochastic_Main[3+i] >= 70 //Stochastic Oscillator >= fixed value
         && WPR[3+i] >= -20 //William's Percent Range >= fixed value
         && MFI[3+i] >= 95 //Money Flow Index >= fixed value
        )
        {
         //Selling Concept
         Buffer6[i] = High[i]; //Set indicator value at Candlestick High
         DrawEdit(PanelLabel,Xoff+2,Yoff+2,PanelLabX,PanelLabY,true,12,"PATTERN DETECTOR",ALIGN_CENTER,"Consolas","SELLING",false,clrNavy,clrLime,clrBlack);
         if(i == 0 && Time[0] != time_alert)
           {
            myAlert("indicator", "open Sell");   //Instant alert, only once per bar
            time_alert = Time[0];
           }
        }
      else
        {
         Buffer6[i] = EMPTY_VALUE;
        }
     }
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int  DrawEdit(string Name,
              int XStart,
              int YStart,
              int Width,
              int Height,
              bool ReadOnly,
              int EditFontSize,
              string Tooltip,
              int Align,
              string EditFont,
              string Text,
              bool Selectable,
              color TextColor=clrBlack,
              color BGColor=clrWhiteSmoke,
              color BDColor=clrBlack
             )
  {
// ObjectsTotal(NULL, 0, OBJ_FIBO);



   fx_delete_previous_concept();
   string name_mapping   =  Name+   iTime(Symbol(),Period(), 1);



   ObjectCreate(0,name_mapping,OBJ_EDIT,0,0,0);
   ObjectSetInteger(0,name_mapping,OBJPROP_XDISTANCE,XStart);
   ObjectSetInteger(0,name_mapping,OBJPROP_YDISTANCE,YStart);
   ObjectSetInteger(0,name_mapping,OBJPROP_XSIZE,Width);
   ObjectSetInteger(0,name_mapping,OBJPROP_YSIZE,Height);
   ObjectSetInteger(0,name_mapping,OBJPROP_BORDER_TYPE,BORDER_FLAT);
   ObjectSetInteger(0,name_mapping,OBJPROP_STATE,false);
   ObjectSetInteger(0,name_mapping,OBJPROP_HIDDEN,false);
   ObjectSetInteger(0,name_mapping,OBJPROP_READONLY,ReadOnly);
   ObjectSetInteger(0,name_mapping,OBJPROP_FONTSIZE,EditFontSize);
   ObjectSetString(0,name_mapping,OBJPROP_TOOLTIP,Tooltip);
   ObjectSetInteger(0,name_mapping,OBJPROP_ALIGN,Align);
   ObjectSetString(0,name_mapping,OBJPROP_FONT,EditFont);
   ObjectSetString(0,name_mapping,OBJPROP_TEXT,Text);
   ObjectSetInteger(0,name_mapping,OBJPROP_SELECTABLE,Selectable);
   ObjectSetInteger(0,name_mapping,OBJPROP_COLOR,TextColor);
   ObjectSetInteger(0,name_mapping,OBJPROP_BGCOLOR,BGColor);
   ObjectSetInteger(0,name_mapping,OBJPROP_BORDER_COLOR,BDColor);
   return  0;
  }


//   void Deinit() {


//   }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {


   for(int i =ObjectsTotal(NULL, 0,OBJ_EDIT) - 1; i >= 0; i--)
     {
      string name;
      string output[];


      name = ObjectName(NULL, i, 0, OBJ_EDIT);
      int k = StringSplit(name, StringGetCharacter("_", 0), output);

      if(ArraySize(output)  > 1)
        {
         ObjectDelete(0,  name);
        }

     }

  }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int   fx_delete_previous_concept()
  {

   string name;
   string output[];
   int i;
   for(int i =ObjectsTotal(NULL, 0,OBJ_EDIT) - 1; i >= 0; i--)
     {
      name = ObjectName(NULL, i, 0, OBJ_EDIT);
      int k = StringSplit(name, StringGetCharacter("_", 0), output);
      if(ArraySize(output)  > 1)
        {
         if(output[0]   ==   "Tester")
           {

            ObjectDelete(0,  name);





           }

        }
     }
   return   0 ;
  }
//+------------------------------------------------------------------+
