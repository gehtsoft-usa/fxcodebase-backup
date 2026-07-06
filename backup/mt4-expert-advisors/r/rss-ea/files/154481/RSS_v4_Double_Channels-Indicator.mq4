//Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=73296

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2023, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                        https://AppliedMachineLearning.systems  |
//|                                                                       https://mario-jemic.com/ |
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|                                           Our work would not be possible without your support. |
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal: https://goo.gl/9Rj74e    |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |  
//+------------------------------------------------------------------------------------------------+


#property copyright "Copyright © 2023, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
 
#property indicator_chart_window
#property indicator_buffers 8
//------
#property indicator_color1 clrRed
#property indicator_color2 clrLime
#property indicator_color3 clrMagenta  //Red
#property indicator_color4 clrWhite    //Lime
#property indicator_color5 clrRed
#property indicator_color6 clrLime
#property indicator_color7 clrMagenta  //Red
#property indicator_color8 clrWhite    //Lime
//------
#property indicator_width1 2
#property indicator_width2 2
#property indicator_width3 4
#property indicator_width4 4
#property indicator_width5 2
#property indicator_width6 2
#property indicator_width7 3
#property indicator_width8 3
//-------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------
enum calcCH { NoChannels, onlyWEAK, onlyMAIN, DOUBLE };
//-------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------

extern int     PeriodWeak      = 24;
extern int     PeriodMain      = 96;
extern string  soundFile       = "alert2.wav";   //"news.wav";   //
extern int     SIGNALBAR       = 6;
extern bool    alertsMessage   = true;
extern bool    alertsSound     = false;
extern bool    alertsEmail     = false;
extern bool    alertsMobile    = true;
extern calcCH  ShowChannels    = DOUBLE;
extern int     DotsGAP         = 5;

extern string             button_note1          = "------------------------------";
extern int                btn_Subwindow = 0;
extern ENUM_BASE_CORNER   btn_corner            = CORNER_LEFT_UPPER; 
extern string             btn_text              = "Renko channel";
extern string             btn_Font              = "Arial";
extern int                btn_FontSize          = 10;                            
extern color              btn_text_ON_color     = clrLime;
extern color              btn_text_OFF_color    = clrRed;
extern string             btn_pressed           = "channel OFF";            
extern string             btn_unpressed         = "channel ON";
extern color              btn_background_color  = clrDimGray;
extern color              btn_border_color      = clrBlack;
extern int                button_x              = 200;                                 
extern int                button_y              = 0;                                   
extern int                btn_Width             = 85;                                 
extern int                btn_Height            = 20;                                
extern string             soundBT               = "tick.wav";  
extern string             button_note2          = "------------------------------";

bool                      show_data             = true;
string IndicatorName, IndicatorObjPrefix ,buttonId ;
//-------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------
double b1[],b2[],b3[],b4[],b5[],b6[],b7[],b8[];
//int  TimeFrame;
int    shift1=PeriodWeak/2;
int    shift2=PeriodMain/2;
//-------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------

string GenerateIndicatorName(const string target)
{
   string name = target;
   int try = 2;
   while (WindowFind(name) != -1)
   {
      name = target + " #" + IntegerToString(try++);
   }
   return name;
}


int init()
{
   //TimeFrame = MathMax(TimeFrame,_Period);
   IndicatorBuffers(8);
   SetIndexBuffer(0,b1); SetIndexStyle(0,DRAW_ARROW); SetIndexArrow(0,164);
   SetIndexBuffer(1,b2); SetIndexStyle(1,DRAW_ARROW); SetIndexArrow(1,164);
   SetIndexBuffer(2,b3); SetIndexStyle(2,DRAW_ARROW); SetIndexArrow(2,91);  //164);
   SetIndexBuffer(3,b4); SetIndexStyle(3,DRAW_ARROW); SetIndexArrow(3,91);  //164);
   SetIndexBuffer(4,b5); SetIndexStyle(4,DRAW_LINE); SetIndexLabel(4,"Upper WEAK channel");
   SetIndexBuffer(5,b6); SetIndexStyle(5,DRAW_LINE); SetIndexLabel(5,"Lower WEAK channel");
   SetIndexBuffer(6,b7); SetIndexStyle(6,DRAW_LINE); SetIndexLabel(6,"Upper MAIN channel");
   SetIndexBuffer(7,b8); SetIndexStyle(7,DRAW_LINE); SetIndexLabel(7,"Lower MAIN channel");
   IndicatorShortName(timeFrameToString(_Period)+" SuperSignals ["+(string)PeriodWeak+","+(string)PeriodMain+"]");
   
    IndicatorName = GenerateIndicatorName(btn_text);
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(WindowExpertName());
   IndicatorDigits(Digits);
      double val;
   if (GlobalVariableGet(IndicatorName + "_visibility", val))
   show_data = val != 0;

   ChartSetInteger(ChartID(), CHART_EVENT_MOUSE_MOVE, 1);
   buttonId = IndicatorObjPrefix+btn_text;
   createButton(buttonId, btn_text, btn_Width, btn_Height, btn_Font, btn_FontSize, btn_background_color, btn_border_color, btn_text_ON_color);
   ObjectSetInteger(ChartID(), buttonId, OBJPROP_YDISTANCE, button_y);
   ObjectSetInteger(ChartID(), buttonId, OBJPROP_XDISTANCE, button_x);
   
   return(0);
}
void createButton(string buttonID,string buttonText,int width,int height,string font,int fontSize,color bgColor,color borderColor,color txtColor)
{
      ObjectDelete    (ChartID(),buttonID);
      ObjectCreate (ChartID(),buttonID,OBJ_BUTTON,btn_Subwindow,0,0);
      ObjectSetInteger(ChartID(),buttonID,OBJPROP_COLOR,txtColor);
      ObjectSetInteger(ChartID(),buttonID,OBJPROP_BGCOLOR,bgColor);
      ObjectSetInteger(ChartID(),buttonID,OBJPROP_BORDER_COLOR,borderColor);
      ObjectSetInteger(ChartID(),buttonID,OBJPROP_XSIZE,width);
      ObjectSetInteger(ChartID(),buttonID,OBJPROP_YSIZE,height);
      ObjectSetString (ChartID(),buttonID,OBJPROP_FONT,font);
      ObjectSetString (ChartID(),buttonID,OBJPROP_TEXT,buttonText);
      ObjectSetInteger(ChartID(),buttonID,OBJPROP_FONTSIZE,fontSize);
      ObjectSetInteger(ChartID(),buttonID,OBJPROP_SELECTABLE,0);
      ObjectSetInteger(ChartID(),buttonID,OBJPROP_CORNER,btn_corner);
      ObjectSetInteger(ChartID(),buttonID,OBJPROP_HIDDEN,1);
      ObjectSetInteger(ChartID(),buttonID,OBJPROP_XDISTANCE,9999);
      ObjectSetInteger(ChartID(),buttonID,OBJPROP_YDISTANCE,9999);
}

//-------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------
int deinit() 
{ /*ALL_OBJ_DELETE();*/  Comment("");

ObjectsDeleteAll(0,"Renko channel");
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);

  return(0);
  
   }
//-------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------

 bool recalc = true;
 void handleButtonClicks()
{
   if (ObjectGetInteger(ChartID(), buttonId, OBJPROP_STATE))
   {
      ObjectSetInteger(ChartID(), buttonId, OBJPROP_STATE, false);
      show_data = !show_data;
      GlobalVariableSet(IndicatorName + "_visibility", show_data ? 1.0 : 0.0);
      recalc = true;
      start();
   }
}
void OnChartEvent(const int id, 
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
   handleButtonClicks();
   if (id==CHARTEVENT_OBJECT_CLICK && ObjectGet(sparam,OBJPROP_TYPE)==OBJ_BUTTON)
   {
   if (soundBT!="") PlaySound(soundBT);     
   }
}


int start()
{
   handleButtonClicks();
   recalc = false;
   
  start2();
  SetIndexStyle(0,DRAW_ARROW); SetIndexArrow(0,164);
  SetIndexStyle(1,DRAW_ARROW); SetIndexArrow(1,164);
  SetIndexStyle(2,DRAW_ARROW); SetIndexArrow(2,91);  //164);
  SetIndexStyle(3,DRAW_ARROW); SetIndexArrow(3,91);  //164);
  SetIndexStyle(4,DRAW_LINE); SetIndexLabel(4,"Upper WEAK channel");
  SetIndexStyle(5,DRAW_LINE); SetIndexLabel(5,"Lower WEAK channel");
  SetIndexStyle(6,DRAW_LINE); SetIndexLabel(6,"Upper MAIN channel");
   SetIndexStyle(7,DRAW_LINE); SetIndexLabel(7,"Lower MAIN channel");
   
   
   if (show_data)
      {
      ObjectSetInteger(ChartID(),buttonId,OBJPROP_COLOR,btn_text_ON_color);
      ObjectSetString(ChartID(),buttonId,OBJPROP_TEXT,btn_unpressed);
      }
      else
      {
      ObjectSetInteger(ChartID(),buttonId,OBJPROP_COLOR,btn_text_OFF_color);
      ObjectSetString(ChartID(),buttonId,OBJPROP_TEXT,btn_pressed);
      SetIndexStyle(0,DRAW_NONE);
        SetIndexStyle(1,DRAW_NONE);
        SetIndexStyle(2,DRAW_NONE);
        SetIndexStyle(3,DRAW_NONE);
        SetIndexStyle(4,DRAW_NONE);
        SetIndexStyle(5,DRAW_NONE);
        SetIndexStyle(6,DRAW_NONE);
        SetIndexStyle(7,DRAW_NONE);
       
   
      //template code     
      }
       return(0);
      }
      
  int start2()
  {
  
   int i,limit,hhb1,llb1,hhb2,llb2;
   
   int CountedBars=IndicatorCounted();
   if (CountedBars<0) return(-1);
   if (CountedBars>0) CountedBars--;
       limit=Bars-CountedBars;
       limit=MathMax(limit,PeriodMain);

//-------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------

   for (i=limit; i>=0; i--)
    {
     hhb1 = Highest(NULL,0,MODE_HIGH,PeriodWeak,i-shift1);
     llb1 = Lowest(NULL,0,MODE_LOW,PeriodWeak,i-shift1);
     hhb2 = Highest(NULL,0,MODE_HIGH,PeriodMain,i-shift2);
     llb2 = Lowest(NULL,0,MODE_LOW,PeriodMain,i-shift2);

     b1[i] = EMPTY_VALUE;
     b2[i] = EMPTY_VALUE;
     b3[i] = EMPTY_VALUE;
     b4[i] = EMPTY_VALUE;
       
/// enum calcCH { NoChannels, onlyWEAK, onlyMAIN, BOTH_CHANNELS };
     
     if(CountedBars==0 || i==0){
     if (ShowChannels==1 || ShowChannels==3) {
         b5[i] = High[hhb1];
         b6[i] = Low[llb1]; 
      }
         
     if (ShowChannels==2 || ShowChannels==3) {
         b7[i] = High[hhb2];
         b8[i] = Low[llb2]; 
      }
      }
     
     double GapDD=DotsGAP*Point;   if (Digits==3 || Digits==5) GapDD=DotsGAP*Point*10;
     
     if (i==hhb1) b1[i]=High[hhb1] +GapDD;
     if (i==llb1) b2[i]=Low[llb1]  -GapDD;
     if (i==hhb2) b3[i]=High[hhb2] +GapDD;
     if (i==llb2) b4[i]=Low[llb2]  -GapDD;
    }
//-------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------
 
   if (alertsMessage || alertsSound || alertsEmail || alertsMobile)
    {
     if (b1[SIGNALBAR] != EMPTY_VALUE && b3[SIGNALBAR] != EMPTY_VALUE) doAlert("  @  MAIN channel UP");
     if (b2[SIGNALBAR] != EMPTY_VALUE && b4[SIGNALBAR] != EMPTY_VALUE) doAlert("  @  MAIN channel LO");
     if (b1[SIGNALBAR] != EMPTY_VALUE && b3[SIGNALBAR] == EMPTY_VALUE) doAlert("  @  WEAK channel UP");
     if (b2[SIGNALBAR] != EMPTY_VALUE && b4[SIGNALBAR] == EMPTY_VALUE) doAlert("  @  WEAK channel LO");
    }
//------
//------
return(0);
}
//-------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------
void doAlert(string doWhat)
{
   static string   previousAlert="nothing";
   static datetime previousTime;
   string message;
   
      if (previousAlert != doWhat || previousTime != Time[0]) {
          previousAlert  = doWhat;
          previousTime   = Time[0];

          message = "SuperSignals v3  >>  "+_Symbol+", "+timeFrameToString(_Period) +doWhat;
             if (alertsMessage) Alert(message);
             if (alertsEmail)   SendMail(_Symbol,message);
             if (alertsSound)   PlaySound(soundFile);
             if (alertsMobile)  SendNotification(message);
      }
}
//-------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------
string sTfTable[] = {"M1","M2","M3","M5","M10","M15","M30","H1","H4","D1","W1","MN"};
int    iTfTable[] = {1,2,3,5,10,15,30,60,240,1440,10080,43200};

string timeFrameToString(int tf)
{
   for (int i=ArraySize(iTfTable)-1; i>=0; i--) 
         if (tf==iTfTable[i]) return(sTfTable[i]);
                              return("");
}
//-------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------

//+------------------------------------------------------------------------------------------------+
//|                                                                    We appreciate your support. | 
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal: https://goo.gl/9Rj74e    |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |  
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                        https://AppliedMachineLearning.systems  |
//|                                                                       https://mario-jemic.com/ |
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|BitCoin                    : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |  
//|Ethereum                   : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |  
//|SOL Address                : 4tJXw7JfwF3KUPSzrTm1CoVq6Xu4hYd1vLk3VF2mjMYh                       |
//|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
//|Dogecoin Address           : DBGXP1Nc18ZusSRNsj49oMEYFQgAvgBVA8                                 |
//|SHIB Address               : 0x1817D9ebb000025609Bf5D61E269C64DC84DA735                         |              
//|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         | 
//|BitCoin Cash               : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg                                 | 
//|LiteCoin                   : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD                                 |  
//+------------------------------------------------------------------------------------------------+