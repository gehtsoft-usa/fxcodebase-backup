//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=74642

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2024, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                                    Developed by : Mario Jemic  |                                                                                      
//|                                                                         mario.jemic@gmail.com  |                                                                         
//|                                                        https://AppliedMachineLearning.systems  |                                                                      
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|                                           Our work would not be possible without your support. |
//+------------------------------------------------------------------------------------------------+
//|                                                              Paypal: https://goo.gl/9Rj74e     |
//|                                                            Patreon : https://goo.gl/GdXWeN     |  
//|                                                     Buy Me a Coffee: http://tiny.cc/pjh9vz     |
//+------------------------------------------------------------------------------------------------+

#property copyright "Copyright © 2024, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
#property indicator_separate_window
#property indicator_buffers 5
#property indicator_color1  DodgerBlue
#property indicator_color2  Gold
#property indicator_color3  DodgerBlue
#property indicator_color4  SeaGreen
#property indicator_color5  Red
#property indicator_width2  2
#property indicator_width4  2
#property indicator_levelcolor C'80,90,100'

extern string TimeFrame                 = "Current time frame";
extern int    ShowHowManyBars           = 1000;

extern int    RsxPeriod                 = 20;
extern int    RsxPrice                  = PRICE_TYPICAL;
extern double RsxPriceLinePeriod        = 2;
extern double RsxPriceLinePhase         = 0;
extern bool   RsxPriceLineDouble        = false;
extern double RsxSignalLinePeriod       = 7;
extern double RsxSignalLinePhase        = 0;
extern bool   RsxSignalLineDouble       = false;
extern int    VolatilityBandPeriod      = 34;
extern int    VolatilityBandMAMode      = MODE_SMA;
extern double VolatilityBandMultiplier  = 1.6185;

extern bool   divergenceVisible         = true;
extern bool   divergenceOnValuesVisible = true;
extern bool   divergenceOnChartVisible  = true;
extern color  divergenceBullishColor    = Turquoise;
extern color  divergenceBearishColor    = OrangeRed;
extern int    divergenceLineWidth       = 2;
extern string divergenceUniqueID        = "TDI_Div";

extern bool   Interpolate               = true;

extern bool   ShowArrows                = false;
extern color  arrowsUpColor             = DeepSkyBlue;
extern color  arrowsDnColor             = Red;
extern string arrowsIdentifier          = "TDI_Arrow";
extern double arrowDistance             = 2.0;

extern bool   verticalLinesVisible      = true;
extern color  verticalLinesUpColor      = DeepSkyBlue;
extern color  verticalLinesDownColor    = PaleVioletRed;
extern int    verticalLinesStyle        = STYLE_DOT;
extern int    verticalLinesWidth        = 0;
extern string verticalLinesID           = "TDI_Line";

extern string WhenToDrawLinesOrArrows   = "set when to draw lines or arrows";
extern string _1___________________     = "draw on OB & OS levels";
extern string _2___________________     = "draw on break Band levels";
extern string _3___________________     = "draw at every turn";
extern string _4___________________     = "draw at every crossing";
extern string _5___________________     = "draw at base line crossing";

extern int    whenToDrawSignals         = 5;
extern int    OS_Level                  = 20;
extern int    OB_Level                  = 80;

extern bool   alertsOn                  = false;
extern bool   alertsOnCurrent           = true;
extern bool   alertsMessage             = true;
extern bool   alertsSound               = false;
extern bool   alertsEmail               = false;


double rsx[];
double rsxPriceLine[];
double rsxSignalLine[];
double bandUp[];
double bandMiddle[];
double bandDown[];
double trend[];

string indicatorFileName;
bool   calculateValue;
bool   returnBars;
int    timeFrame;
string shortName;

int nextArrow=0;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

int init() {
   IndicatorBuffers(7);
   SetIndexBuffer(0,bandUp);
   SetIndexBuffer(1,bandMiddle);
   SetIndexBuffer(2,bandDown);
   SetIndexBuffer(3,rsxPriceLine);
   SetIndexBuffer(4,rsxSignalLine);
   SetIndexBuffer(5,rsx);
   SetIndexBuffer(6,trend);

   // HIDE LIVE BUFFER DATA FROM SHOWING
   SetIndexLabel(0, "upperband");
   SetIndexLabel(1, "baseline");
   SetIndexLabel(2, "lowerband");
   SetIndexLabel(3, "rsxPriceLine");
   SetIndexLabel(4, "rsxSignalLine");
   SetIndexLabel(5, NULL);
   SetIndexLabel(6, NULL);
   
   indicatorFileName = WindowExpertName();
   returnBars        = (TimeFrame=="returnBars");     if (returnBars)     return(0);
   calculateValue    = (TimeFrame=="calculateValue");
   if (calculateValue)
   {
      int s = StringFind(divergenceUniqueID,":",0);
         shortName = divergenceUniqueID;
         divergenceUniqueID = StringSubstr(divergenceUniqueID,0,s);
         return(0);
   }            
   timeFrame = stringToTimeFrame(TimeFrame);
   
   SetLevelValue(0,OS_Level);
   SetLevelValue(1,OB_Level);

   shortName = divergenceUniqueID+": "+timeFrameToString(timeFrame)+" - TDI RSX ("+RsxPeriod+")";
   
   IndicatorShortName(shortName);
   deinit();
   return (0);
}

 
int deinit() {
   string lookFor        = verticalLinesID+":";
   int    lookForLength1 = StringLen(lookFor);
   int    lookForLength2 = StringLen(divergenceUniqueID);
   for (int i=ObjectsTotal()-1; i>=0; i--) {
      string objectName = ObjectName(i);
         if (StringSubstr(objectName,0,lookForLength1) == lookFor)            ObjectDelete(objectName);
         if (StringSubstr(objectName,0,lookForLength2) == divergenceUniqueID) ObjectDelete(objectName);
   }
   if (!calculateValue && ShowArrows) deleteArrows();
   return(0);
}
  
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double wrkBuffer[][13];

int start() {
   int i,k,n,r,limit,counted_bars=IndicatorCounted();

   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
         limit = MathMin(Bars-counted_bars,Bars-1);
         if (returnBars) { bandUp[0] = limit+1; return(0); }

   if (calculateValue || timeFrame == Period())
   {
      if (ArrayRange(wrkBuffer,0) != Bars) ArrayResize(wrkBuffer,Bars);
      
      double Kg = (3.0)/(2.0+RsxPeriod); 
      double Hg = 1.0-Kg;
      for(i=limit, r=Bars-i-1; i>=0; i--, r++)
      {
         wrkBuffer[r][12] = iMA(NULL,0,1,0,MODE_SMA,RsxPrice,i);

            if (i==(Bars-1)) { for (int c=0; c<12; c++) wrkBuffer[r][c] = 0; continue; }  
   
         double mom = wrkBuffer[r][12]-wrkBuffer[r-1][12];
         double moa = MathAbs(mom);
         for (k=0; k<3; k++)
         {
            int kk = k*2;
               wrkBuffer[r][kk+0] = Kg*mom                + Hg*wrkBuffer[r-1][kk+0];
               wrkBuffer[r][kk+1] = Kg*wrkBuffer[r][kk+0] + Hg*wrkBuffer[r-1][kk+1]; mom = 1.5*wrkBuffer[r][kk+0] - 0.5 * wrkBuffer[r][kk+1];
               wrkBuffer[r][kk+6] = Kg*moa                + Hg*wrkBuffer[r-1][kk+6];
               wrkBuffer[r][kk+7] = Kg*wrkBuffer[r][kk+6] + Hg*wrkBuffer[r-1][kk+7]; moa = 1.5*wrkBuffer[r][kk+6] - 0.5 * wrkBuffer[r][kk+7];
         }
         if (moa != 0)
              rsx[i] = MathMax(MathMin((mom/moa+1.0)*50.0,100.00),0.00); 
         else rsx[i] = 50.0;
      }
      for(i=ShowHowManyBars; i>=0; i--)
      {
         rsxPriceLine[i]  = iDSmooth(rsx[i],RsxPriceLinePeriod ,RsxPriceLinePhase ,RsxPriceLineDouble ,i, 0);
         rsxSignalLine[i] = iDSmooth(rsx[i],RsxSignalLinePeriod,RsxSignalLinePhase,RsxSignalLineDouble,i,20);
         double deviation = iStdDevOnArray(rsx,0,VolatilityBandPeriod,0,VolatilityBandMAMode,i);
         double average   = iMAOnArray(rsx,0,VolatilityBandPeriod,0,VolatilityBandMAMode,i);
            bandUp[i]     = average+VolatilityBandMultiplier*deviation;
            bandDown[i]   = average-VolatilityBandMultiplier*deviation;
            bandMiddle[i] = average;
                 trend[i] = trend[i+1];
            
            if (rsxPriceLine[i] > rsxSignalLine[i]) trend[i] =  1;
            if (rsxPriceLine[i] < rsxSignalLine[i]) trend[i] = -1;
            
            //if (rsxPriceLine[i]>bandUp[i])   trend[i] =  1;
            //if (rsxPriceLine[i]<bandDown[i]) trend[i] = -1;
            
            if (!calculateValue) manageLines(i);
            if (!calculateValue) manageArrow(i);
            
            if (divergenceVisible) {
               CatchBullishDivergence(rsx,i);
               CatchBearishDivergence(rsx,i);
            }           
      }
      manageAlerts();
      return (0);
   }      

   limit = MathMax(limit,MathMin(Bars,iCustom(NULL,timeFrame,indicatorFileName,"returnBars",0,0)*timeFrame/Period()));
   for (i=limit;i>=0;i--)
   {
      int y = iBarShift(NULL,timeFrame,Time[i]);
         bandUp[i]        = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",ShowHowManyBars,RsxPeriod,RsxPrice,RsxPriceLinePeriod,RsxPriceLinePhase,RsxPriceLineDouble,RsxSignalLinePeriod,RsxSignalLinePhase,RsxSignalLineDouble,VolatilityBandPeriod,VolatilityBandMAMode,VolatilityBandMultiplier,divergenceVisible,divergenceOnValuesVisible,divergenceOnChartVisible,divergenceBullishColor,divergenceBearishColor,divergenceLineWidth,divergenceUniqueID,Interpolate,0,y);
         bandMiddle[i]    = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",ShowHowManyBars,RsxPeriod,RsxPrice,RsxPriceLinePeriod,RsxPriceLinePhase,RsxPriceLineDouble,RsxSignalLinePeriod,RsxSignalLinePhase,RsxSignalLineDouble,VolatilityBandPeriod,VolatilityBandMAMode,VolatilityBandMultiplier,divergenceVisible,divergenceOnValuesVisible,divergenceOnChartVisible,divergenceBullishColor,divergenceBearishColor,divergenceLineWidth,divergenceUniqueID,Interpolate,0,y);
         bandDown[i]      = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",ShowHowManyBars,RsxPeriod,RsxPrice,RsxPriceLinePeriod,RsxPriceLinePhase,RsxPriceLineDouble,RsxSignalLinePeriod,RsxSignalLinePhase,RsxSignalLineDouble,VolatilityBandPeriod,VolatilityBandMAMode,VolatilityBandMultiplier,divergenceVisible,divergenceOnValuesVisible,divergenceOnChartVisible,divergenceBullishColor,divergenceBearishColor,divergenceLineWidth,divergenceUniqueID,Interpolate,0,y);
         rsxPriceLine[i]  = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",ShowHowManyBars,RsxPeriod,RsxPrice,RsxPriceLinePeriod,RsxPriceLinePhase,RsxPriceLineDouble,RsxSignalLinePeriod,RsxSignalLinePhase,RsxSignalLineDouble,VolatilityBandPeriod,VolatilityBandMAMode,VolatilityBandMultiplier,divergenceVisible,divergenceOnValuesVisible,divergenceOnChartVisible,divergenceBullishColor,divergenceBearishColor,divergenceLineWidth,divergenceUniqueID,Interpolate,0,y);
         rsxSignalLine[i] = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",ShowHowManyBars,RsxPeriod,RsxPrice,RsxPriceLinePeriod,RsxPriceLinePhase,RsxPriceLineDouble,RsxSignalLinePeriod,RsxSignalLinePhase,RsxSignalLineDouble,VolatilityBandPeriod,VolatilityBandMAMode,VolatilityBandMultiplier,divergenceVisible,divergenceOnValuesVisible,divergenceOnChartVisible,divergenceBullishColor,divergenceBearishColor,divergenceLineWidth,divergenceUniqueID,Interpolate,0,y);
         trend[i]         = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",ShowHowManyBars,RsxPeriod,RsxPrice,RsxPriceLinePeriod,RsxPriceLinePhase,RsxPriceLineDouble,RsxSignalLinePeriod,RsxSignalLinePhase,RsxSignalLineDouble,VolatilityBandPeriod,VolatilityBandMAMode,VolatilityBandMultiplier,divergenceVisible,divergenceOnValuesVisible,divergenceOnChartVisible,divergenceBullishColor,divergenceBearishColor,divergenceLineWidth,divergenceUniqueID,Interpolate,0,y);
            
         manageArrow(i);
         manageLines(i);

         if (!Interpolate || y==iBarShift(NULL,timeFrame,Time[i-1])) continue;

         datetime time = iTime(NULL,timeFrame,y);
            for(n = 1; i+n < Bars && Time[i+n] >= time; n++) continue;	
            for(k = 1; k < n; k++)
            {
               bandUp[i+k]        = bandUp[i]        + (bandUp[i+n]        - bandUp[i]       )*k/n;
               bandMiddle[i+k]    = bandMiddle[i]    + (bandMiddle[i+n]    - bandMiddle[i]   )*k/n;
               bandDown[i+k]      = bandDown[i]      + (bandDown[i+n]      - bandDown[i]     )*k/n;
               rsxPriceLine[i+k]  = rsxPriceLine[i]  + (rsxPriceLine[i+n]  - rsxPriceLine[i] )*k/n;
               rsxSignalLine[i+k] = rsxSignalLine[i] + (rsxSignalLine[i+n] - rsxSignalLine[i])*k/n;
            }               
   }
   manageAlerts();
   return(0);
}

//+-------------------------------------------------------------------
//|                                                                  
//+-------------------------------------------------------------------

void manageAlerts() {
   if (!calculateValue && alertsOn) {
      if (alertsOnCurrent)
           int whichBar = 0;
      else     whichBar = 1; whichBar = iBarShift(NULL,0,iTime(NULL,timeFrame,whichBar));
      if (trend[whichBar] != trend[whichBar+1]) {
         if (trend[whichBar] ==  1) doAlert(whichBar,"up");
         if (trend[whichBar] == -1) doAlert(whichBar,"down");
      }
   }
}

void doAlert(int forBar, string doWhat) {
   static string   previousAlert="nothing";
   static datetime previousTime;
   string message;
   
   if (previousAlert != doWhat || previousTime != Time[forBar]) {
       previousAlert  = doWhat;
       previousTime   = Time[forBar];

       message =  StringConcatenate(Symbol()," ",timeFrameToString(timeFrame)," at ",TimeToStr(TimeLocal(),TIME_SECONDS)," TDI trend changed to ",doWhat);
          if (alertsMessage) Alert(message);
          if (alertsEmail)   SendMail(StringConcatenate(Symbol(),"TDI"),message);
          if (alertsSound)   PlaySound("alert2.wav");
   }
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void manageArrow(int i) {
   if (ShowArrows) {
      deleteArrow(Time[i]);
      
      if(whenToDrawSignals == 1) {
         if (rsxPriceLine[i+2] > rsxPriceLine[i+1] && rsxPriceLine[i+1] < rsxPriceLine[i] && rsxPriceLine[i] < OS_Level || (rsx[i+1] < bandDown[i+1] && rsxPriceLine[i+1] < rsxPriceLine[i]))  drawArrow(i,arrowsUpColor,233,false);
         if (rsxPriceLine[i+2] < rsxPriceLine[i+1] && rsxPriceLine[i+1] > rsxPriceLine[i] && rsxPriceLine[i] > OB_Level || (rsx[i+1] > bandUp[i+1]   && rsxPriceLine[i+1] > rsxPriceLine[i]))  drawArrow(i,arrowsDnColor,234,true);
      } else
      if(whenToDrawSignals == 2) {
         if (rsx[i+1] < bandDown[i+1] && rsx[i] > bandDown[i] && bandMiddle[i] < 50) drawArrow(i,arrowsUpColor,233,false);
         if (rsx[i+1] > bandUp[i+1]   && rsx[i] < bandUp[i]   && bandMiddle[i] > 50) drawArrow(i,arrowsDnColor,234,true);
      } else 
      if(whenToDrawSignals == 3) {
         if (rsxPriceLine[i+2] > rsxPriceLine[i+1] && rsxPriceLine[i+1] < rsxPriceLine[i] && rsxPriceLine[i] < 50 && bandMiddle[i] > 50 )  drawArrow(i,arrowsUpColor,233,false);
         if (rsxPriceLine[i+2] < rsxPriceLine[i+1] && rsxPriceLine[i+1] > rsxPriceLine[i] && rsxPriceLine[i] > 50 && bandMiddle[i] < 50 )  drawArrow(i,arrowsDnColor,234,true);
      } else 
      if(whenToDrawSignals == 4) {
         if ((rsxPriceLine[i+2] < rsxSignalLine[i+2] && rsxPriceLine[i+1] < rsxSignalLine[i+1]) && rsxPriceLine[i] > rsxSignalLine[i] && rsxPriceLine[i] < OB_Level)  drawArrow(i,arrowsUpColor,233,false);
         if ((rsxPriceLine[i+2] > rsxSignalLine[i+2] && rsxPriceLine[i+1] > rsxSignalLine[i+1]) && rsxPriceLine[i] < rsxSignalLine[i] && rsxPriceLine[i] > OS_Level)  drawArrow(i,arrowsDnColor,234,true);
      } else 
      if(whenToDrawSignals == 5) {
         if ((rsxPriceLine[i+1] < bandMiddle[i+1]) && rsxPriceLine[i] > bandMiddle[i])  drawArrow(i,arrowsUpColor,233,false);
         if ((rsxPriceLine[i+1] > bandMiddle[i+1]) && rsxPriceLine[i] < bandMiddle[i])  drawArrow(i,arrowsDnColor,234,true);
      } else 
      return;     
   }
}              

void drawArrow(int i,color theColor,int theCode,bool up) {
   
   
   if(up && nextArrow==-1) return;
   if(!up && nextArrow==1) return;

   
   string name = arrowsIdentifier+":"+Time[i];
   //double gap  = arrowDistance*iATR(NULL,0,20,i)/4.0;   
   double gapup  = arrowDistance*iATR(NULL,0,20,i)/3.0;   
   double gapdn  = arrowDistance*iATR(NULL,0,20,i)/12.0;   
   
      ObjectCreate(name,OBJ_ARROW,0,Time[i],0);
         ObjectSet(name,OBJPROP_ARROWCODE,theCode);
         ObjectSet(name,OBJPROP_COLOR,theColor);
         if (up)
               ObjectSet(name,OBJPROP_PRICE1,High[i]+gapup);
         else  ObjectSet(name,OBJPROP_PRICE1,Low[i] -gapdn);
   
      if(up){ nextArrow=-1; } else { nextArrow=1; }
}

void deleteArrows() {
   string lookFor       = arrowsIdentifier+":";
   int    lookForLength = StringLen(lookFor);
   for (int i=ObjectsTotal()-1; i>=0; i--) {
      string objectName = ObjectName(i);
         if (StringSubstr(objectName,0,lookForLength) == lookFor) ObjectDelete(objectName);
   }
}

void deleteArrow(datetime time) {
   string lookFor = arrowsIdentifier+":"+time; ObjectDelete(lookFor);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void manageLines(int i) {
   if (!calculateValue && verticalLinesVisible) {
      deleteLine(Time[i]);

      if(whenToDrawSignals == 1) {
         if (rsxPriceLine[i+2] > rsxPriceLine[i+1] && rsxPriceLine[i+1] < rsxPriceLine[i] && rsxPriceLine[i] < OS_Level)  drawLine(i,verticalLinesUpColor);
         if (rsxPriceLine[i+2] < rsxPriceLine[i+1] && rsxPriceLine[i+1] > rsxPriceLine[i] && rsxPriceLine[i] > OB_Level)  drawLine(i,verticalLinesDownColor);
      } else
      if(whenToDrawSignals == 2) {
         if (rsx[i+1] < bandDown[i+1] && rsx[i] > bandDown[i] && bandMiddle[i] < 50) drawLine(i,verticalLinesUpColor);
         if (rsx[i+1] > bandUp[i+1]   && rsx[i] < bandUp[i]   && bandMiddle[i] > 50) drawLine(i,verticalLinesDownColor);
      } else   
      if(whenToDrawSignals == 3) {
         if (rsxPriceLine[i+2] > rsxPriceLine[i+1] && rsxPriceLine[i+1] < rsxPriceLine[i] && rsxPriceLine[i] < 50 /* && rsxPriceLine[i] > rsxSignalLine[i] */ ) drawLine(i,verticalLinesUpColor);
         if (rsxPriceLine[i+2] < rsxPriceLine[i+1] && rsxPriceLine[i+1] > rsxPriceLine[i] && rsxPriceLine[i] > 50 /* && rsxPriceLine[i] < rsxSignalLine[i] */ ) drawLine(i,verticalLinesDownColor);
      } else 
      if(whenToDrawSignals == 4) {
         if ((rsxPriceLine[i+2] < rsxSignalLine[i+2] && rsxPriceLine[i+1] < rsxSignalLine[i+1]) && rsxPriceLine[i] > rsxSignalLine[i] && rsxPriceLine[i] < OB_Level) drawLine(i,verticalLinesUpColor);
         if ((rsxPriceLine[i+2] > rsxSignalLine[i+2] && rsxPriceLine[i+1] > rsxSignalLine[i+1]) && rsxPriceLine[i] < rsxSignalLine[i] && rsxPriceLine[i] > OS_Level) drawLine(i,verticalLinesDownColor);
      } else
      if(whenToDrawSignals == 5) {
         if ((rsxPriceLine[i+1] < bandMiddle[i+1]) && rsxPriceLine[i] > bandMiddle[i]) drawLine(i,verticalLinesUpColor);
         if ((rsxPriceLine[i+1] > bandMiddle[i+1]) && rsxPriceLine[i] < bandMiddle[i]) drawLine(i,verticalLinesDownColor);
      } else 
      return;     
   }
}               

void drawLine(int i,color theColor) {
   string name = verticalLinesID+":"+Time[i];
   
      ObjectCreate(name,OBJ_VLINE,0,Time[i],0);
         ObjectSet(name,OBJPROP_COLOR,theColor);
         ObjectSet(name,OBJPROP_STYLE,verticalLinesStyle);
         ObjectSet(name,OBJPROP_WIDTH,verticalLinesWidth);
         ObjectSet(name,OBJPROP_BACK,true);
}

void deleteLine(datetime time) {
   string lookFor = verticalLinesID+":"+time; ObjectDelete(lookFor);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void CatchBullishDivergence(double& values[], int i) {
   i++;
            ObjectDelete(divergenceUniqueID+"l"+DoubleToStr(Time[i],0));
            ObjectDelete(divergenceUniqueID+"l"+"os" + DoubleToStr(Time[i],0));            
   if (!IsIndicatorLow(values,i)) return;  

   int currentLow = i;
   int lastLow    = GetIndicatorLastLow(values,i+1);
      if (values[currentLow] > values[lastLow] && Low[currentLow] < Low[lastLow])
      {
         if(divergenceOnChartVisible)  DrawPriceTrendLine("l",Time[currentLow],Time[lastLow],Low[currentLow],Low[lastLow],divergenceBullishColor,STYLE_SOLID,divergenceLineWidth);
         if(divergenceOnValuesVisible) DrawIndicatorTrendLine("l",Time[currentLow],Time[lastLow],values[currentLow],values[lastLow],divergenceBullishColor,STYLE_SOLID,divergenceLineWidth);
      }
      if (values[currentLow] < values[lastLow] && Low[currentLow] > Low[lastLow])
      {
         if(divergenceOnChartVisible)  DrawPriceTrendLine("l",Time[currentLow],Time[lastLow],Low[currentLow],Low[lastLow], divergenceBullishColor, STYLE_DOT,0);
         if(divergenceOnValuesVisible) DrawIndicatorTrendLine("l",Time[currentLow],Time[lastLow],values[currentLow],values[lastLow], divergenceBullishColor, STYLE_DOT,0);
      }
}

void CatchBearishDivergence(double& values[], int i) {
   i++; 
            ObjectDelete(divergenceUniqueID+"h"+DoubleToStr(Time[i],0));
            ObjectDelete(divergenceUniqueID+"h"+"os" + DoubleToStr(Time[i],0));            
   if (IsIndicatorPeak(values,i) == false) return;

   int currentPeak = i;
   int lastPeak = GetIndicatorLastPeak(values,i+1);
      if (values[currentPeak] < values[lastPeak] && High[currentPeak]>High[lastPeak])
      {
         if (divergenceOnChartVisible)  DrawPriceTrendLine("h",Time[currentPeak],Time[lastPeak],High[currentPeak],High[lastPeak],divergenceBearishColor,STYLE_SOLID,divergenceLineWidth);
         if (divergenceOnValuesVisible) DrawIndicatorTrendLine("h",Time[currentPeak],Time[lastPeak],values[currentPeak],values[lastPeak],divergenceBearishColor,STYLE_SOLID,divergenceLineWidth);
      }
      if(values[currentPeak] > values[lastPeak] && High[currentPeak] < High[lastPeak])
      {
         if (divergenceOnChartVisible)  DrawPriceTrendLine("h",Time[currentPeak],Time[lastPeak],High[currentPeak],High[lastPeak], divergenceBearishColor, STYLE_DOT,0);
         if (divergenceOnValuesVisible) DrawIndicatorTrendLine("h",Time[currentPeak],Time[lastPeak],values[currentPeak],values[lastPeak], divergenceBearishColor, STYLE_DOT,0);
      }
}

bool IsIndicatorPeak(double& values[], int i) { return(values[i] >= values[i+1] && values[i] > values[i+2] && values[i] > values[i-1]); }
bool IsIndicatorLow( double& values[], int i) { return(values[i] <= values[i+1] && values[i] < values[i+2] && values[i] < values[i-1]); }

int GetIndicatorLastPeak(double& values[], int shift) {
   for(int i = shift+5; i<Bars; i++)
         if (values[i] >= values[i+1] && values[i] > values[i+2] && values[i] >= values[i-1] && values[i] > values[i-2]) return(i);
   return(-1);
}

int GetIndicatorLastLow(double& values[], int shift) {
   for(int i = shift+5; i<Bars; i++)
         if (values[i] <= values[i+1] && values[i] < values[i+2] && values[i] <= values[i-1] && values[i] < values[i-2]) return(i);
   return(-1);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void DrawPriceTrendLine(string first,datetime t1, datetime t2, double p1, double p2, color lineColor, double style, double width) {
   string   label = divergenceUniqueID+first+"os"+DoubleToStr(t1,0);
   if (Interpolate) t2 += Period()*60-1;
    
   ObjectDelete(label);
      ObjectCreate(label, OBJ_TREND, 0, t1+Period()*60-1, p1, t2, p2, 0, 0);
         ObjectSet(label, OBJPROP_RAY, false);
         ObjectSet(label, OBJPROP_COLOR, lineColor);
         ObjectSet(label, OBJPROP_STYLE, style);
         ObjectSet(label, OBJPROP_WIDTH, width);         
}
void DrawIndicatorTrendLine(string first,datetime t1, datetime t2, double p1, double p2, color lineColor, double style, double width)
{
   int indicatorWindow = WindowFind(shortName);
   if (indicatorWindow < 0) return;
   if (Interpolate) t2 += Period()*60-1;
   
   string label = divergenceUniqueID+first+DoubleToStr(t1,0);
   ObjectDelete(label);
      ObjectCreate(label, OBJ_TREND, indicatorWindow, t1+Period()*60-1, p1, t2, p2, 0, 0);
         ObjectSet(label, OBJPROP_RAY, false);
         ObjectSet(label, OBJPROP_COLOR, lineColor);
         ObjectSet(label, OBJPROP_STYLE, style);
         ObjectSet(label, OBJPROP_WIDTH, width);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

string sTfTable[] = {"M1","M5","M15","M30","H1","H4","D1","W1","MN"};
int    iTfTable[] = {1,5,15,30,60,240,1440,10080,43200};

int stringToTimeFrame(string tfs) {
   tfs = stringUpperCase(tfs);
   for (int i=ArraySize(iTfTable)-1; i>=0; i--)
         if (tfs==sTfTable[i] || tfs==""+iTfTable[i]) return(MathMax(iTfTable[i],Period()));
                                                      return(Period());
}
string timeFrameToString(int tf) {
   for (int i=ArraySize(iTfTable)-1; i>=0; i--) 
         if (tf==iTfTable[i]) return(sTfTable[i]);
                              return("");
}

string stringUpperCase(string str) {
   string   s = str;

   for (int length=StringLen(str)-1; length>=0; length--) {
      int pos = StringGetChar(s, length);
         if((pos > 96 && pos < 123) || (pos > 223 && pos < 256))
                     s = StringSetChar(s, length, pos - 32);
         else if(pos > -33 && pos < 0)
                     s = StringSetChar(s, length, pos + 224);
   }
   return(s);
}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double wrk[][40];

#define bsmax  5
#define bsmin  6
#define volty  7
#define vsum   8
#define avolty 9

double iDSmooth(double price, double length, double phase, bool isDouble, int i, int s=0) {
   if (isDouble)
         return (iSmooth(iSmooth(price,MathSqrt(length),phase,i,s),MathSqrt(length),phase,i,s+10));
   else  return (iSmooth(price,length,phase,i,s));
}

double iSmooth(double price, double length, double phase, int i, int s=0) {
   if (length <=1) return(price);
   if (ArrayRange(wrk,0) != Bars) ArrayResize(wrk,Bars);
   
   int r = Bars-i-1; 
      if (r==0) { for(int k=0; k<7; k++) wrk[r][k+s]=price; for(; k<10; k++) wrk[r][k+s]=0; return(price); }

      double len1   = MathMax(MathLog(MathSqrt(0.5*(length-1)))/MathLog(2.0)+2.0,0);
      double pow1   = MathMax(len1-2.0,0.5);
      double del1   = price - wrk[r-1][bsmax+s];
      double del2   = price - wrk[r-1][bsmin+s];
      double div    = 1.0/(10.0+10.0*(MathMin(MathMax(length-10,0),100))/100);
      int    forBar = MathMin(r,10);
	
         wrk[r][volty+s] = 0;
               if(MathAbs(del1) > MathAbs(del2)) wrk[r][volty+s] = MathAbs(del1); 
               if(MathAbs(del1) < MathAbs(del2)) wrk[r][volty+s] = MathAbs(del2); 
         wrk[r][vsum+s] =	wrk[r-1][vsum+s] + (wrk[r][volty+s]-wrk[r-forBar][volty+s])*div;
         
         wrk[r][avolty+s] = wrk[r-1][avolty+s]+(2.0/(MathMax(4.0*length,30)+1.0))*(wrk[r][vsum+s]-wrk[r-1][avolty+s]);
            if (wrk[r][avolty+s] > 0)
               double dVolty = wrk[r][volty+s]/wrk[r][avolty+s]; else dVolty = 0;   
	               if (dVolty > MathPow(len1,1.0/pow1)) dVolty = MathPow(len1,1.0/pow1);
                  if (dVolty < 1)                      dVolty = 1.0;

   	double pow2 = MathPow(dVolty, pow1);
      double len2 = MathSqrt(0.5*(length-1))*len1;
      double Kv   = MathPow(len2/(len2+1), MathSqrt(pow2));

         if (del1 > 0) wrk[r][bsmax+s] = price; else wrk[r][bsmax+s] = price - Kv*del1;
         if (del2 < 0) wrk[r][bsmin+s] = price; else wrk[r][bsmin+s] = price - Kv*del2;
	
      double R     = MathMax(MathMin(phase,100),-100)/100.0 + 1.5;
      double beta  = 0.45*(length-1)/(0.45*(length-1)+2);
      double alpha = MathPow(beta,pow2);

         wrk[r][0+s] = price + alpha*(wrk[r-1][0+s]-price);
         wrk[r][1+s] = (price - wrk[r][0+s])*(1-beta) + beta*wrk[r-1][1+s];
         wrk[r][2+s] = (wrk[r][0+s] + R*wrk[r][1+s]);
         wrk[r][3+s] = (wrk[r][2+s] - wrk[r-1][4+s])*MathPow((1-alpha),2) + MathPow(alpha,2)*wrk[r-1][3+s];
         wrk[r][4+s] = (wrk[r-1][4+s] + wrk[r][3+s]); 

   return(wrk[r][4+s]);
}


//+------------------------------------------------------------------------------------------------+
//|                                                                    We appreciate your support. | 
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal: https://goo.gl/9Rj74e    |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |  
//|                                                     Buy Me a Coffee: http://tiny.cc/pjh9vz     |
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