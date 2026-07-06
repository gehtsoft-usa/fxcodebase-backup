//Available @  https://fxcodebase.com/ 

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright © 2025, Gehtsoft USA LLC   | 
// |                                                                         http://fxcodebase.com   |
// |                                                               PayPal: https://goo.gl/9Rj74e     |
// +------------------------------------------------------------------------------------------------+
// |                                                                   Developed by: Mario Jemic     |                    
// |                                                                     mario.jemic@gmail.com       |
// |                                                                 https://mario-jemic.com/        | 
// |                                                             Patreon: http://tiny.cc/1ybwxz      |   
// |                                                      Buy Me a Coffee: http://tiny.cc/bj7vxz     |  
// +-----------------+----------------------+---------------------------------------------------------+
// |  Cryptocurrency |  Network             |  Address                                                |
// +-----------------+----------------------+---------------------------------------------------------+
// |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                     | 
// |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2           | 
// |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             |
// |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// +-----------------+----------------------+---------------------------------------------------------+


#property copyright "Copyright © 2025, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
 

#property indicator_chart_window
#property indicator_buffers 9
#property indicator_color1  clrHotPink
#property indicator_color2  clrAqua
#property indicator_color3  clrNONE
#property indicator_width1  2
#property indicator_width2  2
#property indicator_width3  2

input  string            TimeFrame       = "Current time frame";
input  bool              ShowLines       = true;
input  int               Lb              = 13;
input  bool              alertsOn        = false;
input  bool              alertsOnCurrent = true;
input  bool              alertsMessage   = true;
input  bool              alertsSound     = false;
input  bool              alertsEmail     = false;
input  bool              ShowArrows      = true;
input bool               ArrowOnFirst    = true;             // Arrow on first bars
input int                UpArrowSize     = 1;                // Up Arrow size
input int                DnArrowSize     = 1;                // Down Arrow size
input int                UpArrowCode     = 221;              // Up arrow code     
input int                DnArrowCode     = 222;              // Down arrow code        
input double             UpArrowGap      = 0;              // Up Arrow gap        
input double             DnArrowGap      = 0;              // Downn Arrow gap
input color              UpArrowColor    = clrBlue;     // Up Arrow Color
input color              DnArrowColor    = clrRed;        // Down Arrow Color
input  bool              Interpolate     = true;
input int               bars            = 2;                // Bars of max/min for Gann Swing
input color             GannSwing_Color = clrYellow;        // Gann Swing color
input  color            TopColorHH      = clrBlue;
input  color            TopColorLH      = clrGray;
input  color            BotColorHL      = clrGray;
input  color            BotColorLL      = clrRed;
input  double           Labeldistance   = 0;
input  int              ATRPeriod       = 10;
input  int              TxtSize1        = 8;
input  int              TxtSize2        = 8;
input  string           Fonts           = "Arial Black";

double gup[];
double gdna[];
double gdnb[];
double upArr[],dnArr[],trend[];
double GannSwing[],us[],ds[];

int    timeFrame;
string indicatorFileName;
bool   returnBars;
bool   calculateValue;

int init()
{
   IndicatorBuffers(9);
   SetIndexBuffer(0,gup);   SetIndexStyle(0,ShowLines ?DRAW_LINE:DRAW_NONE);
   SetIndexBuffer(1,gdna);  SetIndexStyle(1,ShowLines ?DRAW_LINE:DRAW_NONE);
   SetIndexBuffer(2,gdnb);  SetIndexStyle(2,ShowLines ?DRAW_LINE:DRAW_NONE);
   SetIndexBuffer(3,upArr); SetIndexStyle(3,ShowArrows?DRAW_ARROW:DRAW_NONE,0,UpArrowSize,UpArrowColor); SetIndexArrow(3,UpArrowCode);
   SetIndexBuffer(4,dnArr); SetIndexStyle(4,ShowArrows?DRAW_ARROW:DRAW_NONE,0,DnArrowSize,DnArrowColor); SetIndexArrow(4,DnArrowCode);
   SetIndexBuffer(5,trend);
   SetIndexBuffer(6,GannSwing); SetIndexStyle(6,DRAW_SECTION,STYLE_SOLID,2,GannSwing_Color); SetIndexLabel(6,"Gann Swing");
   SetIndexBuffer(7,us);       SetIndexStyle(7,DRAW_NONE);
   SetIndexBuffer(8,ds);       SetIndexStyle(8,DRAW_NONE);
   
         
         indicatorFileName = WindowExpertName();
         calculateValue    = (TimeFrame=="calculateValue"); if (calculateValue) return(0);
         returnBars        = (TimeFrame=="returnBars");     if (returnBars)     return(0);
         timeFrame         = stringToTimeFrame(TimeFrame);
      
      
   IndicatorShortName(timeFrameToString(timeFrame)+" Gann high/low activator ("+Lb+")");
         
   return(0);
}

int deinit()
{
   del_objF();
   return(0);
}

int start()
{
   int counted_bars=IndicatorCounted();
   int i,limit;

   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
           limit=MathMin(Bars-counted_bars,Bars-1);
           if (returnBars) { gup[0] = limit+1; return(0); }

   if (calculateValue || timeFrame == Period())
   {
      if (!calculateValue && trend[limit]==-1) CleanPoint(limit,gdna,gdnb);
      for(i=limit;i>=0;i--)
      {
         gdna[i]  = gdnb[i]  = EMPTY_VALUE;
         upArr[i] = dnArr[i] = EMPTY_VALUE;
         trend[i] = trend[i+1];
            if(Close[i]>iMA(Symbol(),0,Lb,0,MODE_SMA,PRICE_HIGH,i+1)) trend[i] =  1;
            if(Close[i]<iMA(Symbol(),0,Lb,0,MODE_SMA,PRICE_LOW,i+1))  trend[i] = -1;
      
            if(trend[i] == -1)
                  gup[i] = iMA(Symbol(),0,Lb,0,MODE_SMA,PRICE_HIGH,i+1);
            else  gup[i] = iMA(Symbol(),0,Lb,0,MODE_SMA,PRICE_LOW,i+1);
            if (!calculateValue && trend[i]==-1) PlotPoint(i,gdna,gdnb,gup);
            
            
            if (trend[i]!=trend[i+1])
            {
               if (trend[i] ==  1) upArr[i] = fmin(gup[i],Low[i] )-iATR(_Symbol,_Period,21,i)*UpArrowGap;
               if (trend[i] == -1) dnArr[i] = fmax(gup[i],High[i])+iATR(_Symbol,_Period,15,i)*DnArrowGap;
            } 
      }

      for (i=limit; i>0; i--) { ResetGannBuffers(i); }
      for (i=limit; i>0; i--)
      {
         ds[i] = 1;
         us[i] = 1;
         for (int ii=0; ii<bars; ++ii)
         {
            if (High[i+ii] <= High[i+ii+1]) { us[i] = 0; }
            if (Low[i+ii]  >= Low[i+ii+1])  { ds[i] = 0; }
         }
         if (us[i] == 0 && High[i] > High[i+1] && Low[i] >= Low[i+1]) us[i] = 1;
         if (ds[i] == 0 && High[i] <= High[i+1] && Low[i] <  Low[i+1]) ds[i] = 1;
      }
      int swingDir = 0;
      for (i=limit; i>0; i--)
      {
         if (us[i] == 1)
         {
            if (swingDir == 1)                 GannSwing[i] = High[i];
            else if (swingDir == -1) {         GannSwing[i] = High[i]; swingDir = 1; }
            else                     { swingDir = 1; GannSwing[i] = High[i]; }
         }
         else if (ds[i] == 1)
         {
            if (swingDir == -1)                GannSwing[i] = Low[i];
            else if (swingDir == 1)  {         GannSwing[i] = Low[i];  swingDir = -1; }
            else                     { swingDir = -1; GannSwing[i] = Low[i]; }
         }
         else
         {
            if (High[i+1] > High[i+2] && Low[i+1] < Low[i+3])
            {
               if (High[i] > High[i+1] && Low[i] >= Low[i+1])
               {
                  if (swingDir == -1)                 GannSwing[i] = Low[i];
                  else if (swingDir == 1) {           GannSwing[i] = Low[i]; swingDir = -1; }
               }
               else if (High[i] <= High[i+1] && Low[i] < Low[i+1])
               {
                  if (swingDir == 1)                  GannSwing[i] = High[i];
                  else if (swingDir == -1) {          GannSwing[i] = High[i]; swingDir = 1; }
               }
            }
         }
      }
      int Last=0, LastIndex=0;
      for (i=limit; i>0; i--)
      {
         if (GannSwing[i] == High[i])
         {
            if (Last == 1) GannSwing[LastIndex] = EMPTY_VALUE;
            Last = 1; LastIndex = i;
         }
         if (GannSwing[i] == Low[i])
         {
            if (Last == -1) GannSwing[LastIndex] = EMPTY_VALUE;
            Last = -1; LastIndex = i;
         }
      }
      int maxCheck = MathMin(1000, Bars-1);
      for (int m=maxCheck; m>0; m--)
      {
         if (GannSwing[m] == High[m]) DrawHighLabel(m);
         if (GannSwing[m] == Low[m])  DrawLowLabel(m);
      }
      manageAlerts();
      return(0);
   }      

   limit = MathMax(limit,MathMin(Bars-1,iCustom(NULL,timeFrame,indicatorFileName,"returnBars",0,0)*timeFrame/Period()));
   if (trend[limit]==-1) CleanPoint(limit,gdna,gdnb);
   for(i=limit; i>=0; i--)
   {
      int y = iBarShift(NULL,timeFrame,Time[i]);
      int x = y;
      if (ArrowOnFirst)
            {  if (i<Bars-1) x = iBarShift(_Symbol,timeFrame,Time[i+1]);               }
      else  {  if (i>0)      x = iBarShift(_Symbol,timeFrame,Time[i-1]); else x = -1;  }
         gdna[i]  = EMPTY_VALUE;
         gdnb[i]  = EMPTY_VALUE;
         gup[i]   = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",ShowLines,Lb,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsEmail,ShowArrows,ArrowOnFirst,UpArrowSize,DnArrowSize,UpArrowCode,DnArrowCode,UpArrowGap,DnArrowGap,UpArrowColor,DnArrowColor,Interpolate,bars,GannSwing_Color,TopColorHH,TopColorLH,BotColorHL,BotColorLL,Labeldistance,ATRPeriod,TxtSize1,TxtSize2,Fonts,0,y);
         trend[i] = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",ShowLines,Lb,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsEmail,ShowArrows,ArrowOnFirst,UpArrowSize,DnArrowSize,UpArrowCode,DnArrowCode,UpArrowGap,DnArrowGap,UpArrowColor,DnArrowColor,Interpolate,bars,GannSwing_Color,TopColorHH,TopColorLH,BotColorHL,BotColorLL,Labeldistance,ATRPeriod,TxtSize1,TxtSize2,Fonts,5,y);
         GannSwing[i] = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",ShowLines,Lb,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsEmail,ShowArrows,ArrowOnFirst,UpArrowSize,DnArrowSize,UpArrowCode,DnArrowCode,UpArrowGap,DnArrowGap,UpArrowColor,DnArrowColor,Interpolate,bars,GannSwing_Color,TopColorHH,TopColorLH,BotColorHL,BotColorLL,Labeldistance,ATRPeriod,TxtSize1,TxtSize2,Fonts,6,y);
         if (x!=y)
         {
            upArr[i] = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",ShowLines,Lb,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsEmail,ShowArrows,ArrowOnFirst,UpArrowSize,DnArrowSize,UpArrowCode,DnArrowCode,UpArrowGap,DnArrowGap,UpArrowColor,DnArrowColor,Interpolate,bars,GannSwing_Color,TopColorHH,TopColorLH,BotColorHL,BotColorLL,Labeldistance,ATRPeriod,TxtSize1,TxtSize2,Fonts,3,y);
            dnArr[i] = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",ShowLines,Lb,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsEmail,ShowArrows,ArrowOnFirst,UpArrowSize,DnArrowSize,UpArrowCode,DnArrowCode,UpArrowGap,DnArrowGap,UpArrowColor,DnArrowColor,Interpolate,bars,GannSwing_Color,TopColorHH,TopColorLH,BotColorHL,BotColorLL,Labeldistance,ATRPeriod,TxtSize1,TxtSize2,Fonts,4,y);
         }
                       
         if (timeFrame <= Period() || y==iBarShift(NULL,timeFrame,Time[i-1])) continue;
         if (!Interpolate) continue;

         datetime time = iTime(NULL,timeFrame,y);
            for(int n = 1; i+n < Bars && Time[i+n] >= time; n++) continue;	
            for(int k = 1; k < n; k++)
               gup[i+k] = gup[i] + (gup[i+n]-gup[i])*k/n;
   }
   for (i=limit;i>=0;i--) if (trend[i]==-1) PlotPoint(i,gdna,gdnb,gup);

   manageAlerts();
   return(0);
}

void manageAlerts()
{
   if (!calculateValue && alertsOn)
   {
      if (alertsOnCurrent)
           int whichBar = 0;
      else     whichBar = 1; whichBar = iBarShift(NULL,0,iTime(NULL,timeFrame,whichBar));
      if (trend[whichBar] != trend[whichBar+1])
      {
         if (trend[whichBar] == 1) doAlert(whichBar,"up");
         if (trend[whichBar] ==-1) doAlert(whichBar,"down");
      }         
   }
}   

void doAlert(int forBar, string doWhat)
{
   static string   previousAlert="nothing";
   static datetime previousTime;
   string message;
   
      if (previousAlert != doWhat || previousTime != Time[forBar]) {
          previousAlert  = doWhat;
          previousTime   = Time[forBar];

          message =  StringConcatenate(Symbol()," at ",TimeToStr(TimeLocal(),TIME_SECONDS)," Gann HL activator trend changed to ",doWhat);
             if (alertsMessage) Alert(message);
             if (alertsEmail)   SendMail(StringConcatenate(Symbol(),"Gann HL "),message);
             if (alertsSound)   PlaySound("alert2.wav");
      }
}

string sTfTable[] = {"M1","M5","M15","M30","H1","H4","D1","W1","MN"};
int    iTfTable[] = {1,5,15,30,60,240,1440,10080,43200};

int stringToTimeFrame(string tfs)
{
   tfs = stringUpperCase(tfs);
   for (int i=ArraySize(iTfTable)-1; i>=0; i--)
         if (tfs==sTfTable[i] || tfs==""+iTfTable[i]) return(MathMax(iTfTable[i],Period()));
                                                      return(Period());
}
string timeFrameToString(int tf)
{
   for (int i=ArraySize(iTfTable)-1; i>=0; i--) 
         if (tf==iTfTable[i]) return(sTfTable[i]);
                              return("");
}

string stringUpperCase(string str)
{
   string   s = str;

   for (int length=StringLen(str)-1; length>=0; length--)
   {
      int tchar = StringGetChar(s, length);
         if((tchar > 96 && tchar < 123) || (tchar > 223 && tchar < 256))
                     s = StringSetChar(s, length, tchar - 32);
         else if(tchar > -33 && tchar < 0)
                     s = StringSetChar(s, length, tchar + 224);
   }
   return(s);
}


void CleanPoint(int i,double& first[],double& second[])
{
   if ((second[i]  != EMPTY_VALUE) && (second[i+1] != EMPTY_VALUE))
        second[i+1] = EMPTY_VALUE;
   else
      if ((first[i] != EMPTY_VALUE) && (first[i+1] != EMPTY_VALUE) && (first[i+2] == EMPTY_VALUE))
          first[i+1] = EMPTY_VALUE;
}

void PlotPoint(int i,double& first[],double& second[],double& from[])
{
   if (first[i+1] == EMPTY_VALUE)
      {
         if (first[i+2] == EMPTY_VALUE) {
                first[i]   = from[i];
                first[i+1] = from[i+1];
                second[i]  = EMPTY_VALUE;
            }
         else {
                second[i]   =  from[i];
                second[i+1] =  from[i+1];
                first[i]    = EMPTY_VALUE;
            }
      }
   else
      {
         first[i]  = from[i];
         second[i] = EMPTY_VALUE;
      }
}

void ResetGannBuffers(int shift)
{
   GannSwing[shift] = EMPTY_VALUE;
   us[shift]        = EMPTY_VALUE;
   ds[shift]        = EMPTY_VALUE;
}

void DrawHighLabel(int shift)
{
   string status      = "HH";
   double currentHigh = GannSwing[shift];
   double prev1 = 0;
   double prev2 = 0;
   for (int n=shift+1; n<shift+1000; n++)
   {
      if (GannSwing[n] != 0)
      {
         prev1 = GannSwing[n];
         for (int j=n+1; j<n+1000; j++)
         {
            if (GannSwing[j] != 0) prev2 = GannSwing[j];
            break;
         }
      }
   }
   double offsetPointsTop = MathMax(1.0, Labeldistance) * Point;
   double position = GannSwing[shift] + offsetPointsTop;
   if (currentHigh > prev1 && currentHigh > prev2) status = "HH  ";
   if (currentHigh < prev1 && currentHigh > prev2) status = "LH  ";
   ObjectCreate("statusLabel"+Time[shift], OBJ_TEXT, 0, Time[shift], position);
   color labelColorTop = TopColorHH;
   if (StringFind(status,"LH") != -1) labelColorTop = TopColorLH;
   ObjectSetText("statusLabel"+Time[shift], status, TxtSize1, Fonts, labelColorTop);
}

void DrawLowLabel(int shift)
{
   string status     = "LL";
   double currentLow = GannSwing[shift];
   double prev1 = 0;
   double prev2 = 0;
   for (int n=shift+1; n<shift+1000; n++)
   {
      if (GannSwing[n] != 0)
      {
         prev1 = GannSwing[n];
         for (int j=n+1; j<n+1000; j++)
         {
            if (GannSwing[j] != 0) prev2 = GannSwing[j];
            break;
         }
      }
   }
   double offsetPointsBot = MathMax(1.0, Labeldistance) * Point;
   double position = GannSwing[shift] - offsetPointsBot;
   if (currentLow < prev1 && currentLow < prev2) status = "LL  ";
   if (currentLow > prev1 && currentLow < prev2) status = "HL  ";
   ObjectCreate("statusLabel"+Time[shift], OBJ_TEXT, 0, Time[shift], position);
   color labelColorBot = BotColorLL;
   if (StringFind(status,"HL") != -1) labelColorBot = BotColorHL;
   ObjectSetText("statusLabel"+Time[shift], status, TxtSize1, Fonts, labelColorBot);
}

void del_objF()
{
   int k = 0;
   while (k < ObjectsTotal())
   {
      string ObjName = ObjectName(k);
      if (StringSubstr(ObjName,0,StringLen("statusLabel")) == "statusLabel") ObjectDelete(ObjName);
      else k++;
   }
}
//Available @  https://fxcodebase.com/ 

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright © 2025, Gehtsoft USA LLC   | 
// |                                                                         http://fxcodebase.com   |
// |                                                               PayPal: https://goo.gl/9Rj74e     |
// +------------------------------------------------------------------------------------------------+
// |                                                                   Developed by: Mario Jemic     |                    
// |                                                                     mario.jemic@gmail.com       |
// |                                                                 https://mario-jemic.com/        | 
// |                                                             Patreon: http://tiny.cc/1ybwxz      |   
// |                                                      Buy Me a Coffee: http://tiny.cc/bj7vxz     |  
// +-----------------+----------------------+---------------------------------------------------------+
// |  Cryptocurrency |  Network             |  Address                                                |
// +-----------------+----------------------+---------------------------------------------------------+
// |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                     | 
// |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2           | 
// |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             |
// |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// +-----------------+----------------------+---------------------------------------------------------+