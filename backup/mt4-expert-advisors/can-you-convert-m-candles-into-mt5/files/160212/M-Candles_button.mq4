//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&p=160107#p160107

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

//------- Âíåøíèå ïàðàìåòðû ------------------------------------------
extern int   CandleTimeFrame      = 60;           // Ïåðèîä ñòàðøèõ ñâå÷åê
extern bool  FillCandleWithColors = false;           // objFillCandleWithColors

extern int   NumberOfBar          = 100;           // Êîëè÷åñòâî ñòàðøèõ ñâå÷åê
extern color ColorUp              = clrLime;//0x003300;      // Öâåò âîñõîäÿùåé ñâå÷è
extern color ColorDown            = clrRed;//0x000033;      // Öâåò íèñõîäÿùåé ñâå÷è
extern int   CandleWidth          = 2;
extern color LinkHH2LLColor       = clrGold;
extern int   LinkHH2LLWidth       = 1;
extern color LinkLL2HHColor       = clrGold;
extern int   LinkLL2HHWidth       = 1;

extern string             button_note1          = "------------------------------";
extern ENUM_BASE_CORNER   btn_corner            = CORNER_LEFT_UPPER; // chart btn_corner for anchoring
extern string             btn_text              = "H1 Candle";
extern string             btn_Font              = "Arial";
extern int                btn_FontSize          = 8;                             //btn__font size
extern color              btn_text_color        = clrWhite;
extern color              btn_background_color  = clrDimGray;
extern color              btn_border_color      = clrBlack;
extern int                button_x              = 20;                                     //btn__x
extern int                button_y              = 13;                                     //btn__y
extern int                btn_Width             = 60;                                 //btn__width
extern int                btn_Height            = 20;                                //btn__height
extern string             button_note2          = "------------------------------";

bool                      show_data             = true;
string IndicatorName, IndicatorObjPrefix;
//template code end1

//+------------------------------------------------------------------+
string GenerateIndicatorName(const string target) //don't change anything here
{
   string name = target;
   int try = 2;
   while (WindowFind(name) != -1)
   {
      name = target + " #" + IntegerToString(try++);
   }
   return name;
}
//+------------------------------------------------------------------+
string buttonId;

int init()
{
   IndicatorName = GenerateIndicatorName(btn_text);
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   IndicatorDigits(Digits);
   
   double val;
   if (GlobalVariableGet(IndicatorName + "_visibility", val))
      show_data = val != 0;

// put init() here
  int i;

  for (i=0; i<NumberOfBar; i++) {
    ObjectDelete("BodyTF"   +CandleTimeFrame+"Bar" + i);
    ObjectDelete("ShadowTFh"+CandleTimeFrame+"Bar" + i);
    ObjectDelete("ShadowTFl"+CandleTimeFrame+"Bar" + i);
    ObjectDelete("HHLLTF"  +CandleTimeFrame+"Bar" + i);
    ObjectDelete("LLHHTF"  +CandleTimeFrame+"Bar" + i);

  }
  for (i=0; i<NumberOfBar; i++) {
    ObjectCreate("BodyTF"   +CandleTimeFrame+"Bar"+i, OBJ_RECTANGLE, 0, 0,0, 0,0);
    ObjectCreate("ShadowTFh"+CandleTimeFrame+"Bar"+i, OBJ_TREND,     0, 0,0, 0,0);
    ObjectCreate("ShadowTFl"+CandleTimeFrame+"Bar"+i, OBJ_TREND,     0, 0,0, 0,0);
    if (i < NumberOfBar-1)
       ObjectCreate("HHLLTF"+CandleTimeFrame+"Bar"+i, OBJ_TREND,     0, 0,0, 0,0);
    if (i < NumberOfBar-1)
       ObjectCreate("LLHHTF"+CandleTimeFrame+"Bar"+i, OBJ_TREND,     0, 0,0, 0,0);

  }
  Comment("");

   ChartSetInteger(0, CHART_EVENT_MOUSE_MOVE, 1);
   buttonId = IndicatorObjPrefix + "MCandleH1";
   createButton(buttonId, btn_text, btn_Width, btn_Height, btn_Font, btn_FontSize, btn_background_color, btn_border_color, btn_text_color);
   ObjectSetInteger(0, buttonId, OBJPROP_YDISTANCE, button_y);
   ObjectSetInteger(0, buttonId, OBJPROP_XDISTANCE, button_x);
   
   return 0;
}
//+------------------------------------------------------------------+
//don't change anything here
void createButton(string buttonID,string buttonText,int width,int height,string font,int fontSize,color bgColor,color borderColor,color txtColor)
{
      ObjectDelete    (0,buttonID);
      ObjectCreate    (0,buttonID,OBJ_BUTTON,0,0,0);
      ObjectSetInteger(0,buttonID,OBJPROP_COLOR,txtColor);
      ObjectSetInteger(0,buttonID,OBJPROP_BGCOLOR,bgColor);
      ObjectSetInteger(0,buttonID,OBJPROP_BORDER_COLOR,borderColor);
      ObjectSetInteger(0,buttonID,OBJPROP_BORDER_TYPE,BORDER_RAISED);
      ObjectSetInteger(0,buttonID,OBJPROP_XSIZE,width);
      ObjectSetInteger(0,buttonID,OBJPROP_YSIZE,height);
      ObjectSetString (0,buttonID,OBJPROP_FONT,font);
      ObjectSetString (0,buttonID,OBJPROP_TEXT,buttonText);
      ObjectSetInteger(0,buttonID,OBJPROP_FONTSIZE,fontSize);
      ObjectSetInteger(0,buttonID,OBJPROP_SELECTABLE,0);
      ObjectSetInteger(0,buttonID,OBJPROP_CORNER,btn_corner);
      ObjectSetInteger(0,buttonID,OBJPROP_HIDDEN,1);
      ObjectSetInteger(0,buttonID,OBJPROP_XDISTANCE,9999);
      ObjectSetInteger(0,buttonID,OBJPROP_YDISTANCE,9999);
}
//+------------------------------------------------------------------+
int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);

//put deinit() here
  // Óäàëåíèå îáúåêòîâ
  for (int i=0; i<NumberOfBar; i++) {
    ObjectDelete("BodyTF"   +CandleTimeFrame+"Bar" + i);
    ObjectDelete("ShadowTFh"+CandleTimeFrame+"Bar" + i);
    ObjectDelete("ShadowTFl"+CandleTimeFrame+"Bar" + i);
    ObjectDelete("HHLLTF"  +CandleTimeFrame+"Bar" + i);
    ObjectDelete("LLHHTF"  +CandleTimeFrame+"Bar" + i);

  }
  Comment("");

   return 0;
}
//+------------------------------------------------------------------+
//don't change anything here
bool recalc = true;

void handleButtonClicks()
{
   if (ObjectGetInteger(0, buttonId, OBJPROP_STATE))
   {
      ObjectSetInteger(0, buttonId, OBJPROP_STATE, false);
      show_data = !show_data;
      GlobalVariableSet(IndicatorName + "_visibility", show_data ? 1.0 : 0.0);
      recalc = true;
      start();
   }
}
//+------------------------------------------------------------------+
void OnChartEvent(const int id, //don't change anything here
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
   handleButtonClicks();
}
//+------------------------------------------------------------------+
int start2() {
  int shb=0, sh1=1;
  double   po, pc;       // Öåíû îòêðûòèÿ è çàêðûòèÿ ñòàðøèõ ñâå÷åê
  double   ph=0, pl=500; // Öåíû õàé è ëîó ñòàðøèõ ñâå÷åê
  datetime to, tc, ts;   // Âðåìÿ îòêðûòèÿ, çàêðûòèÿ è òåíåé ñòàðøèõ ñâå÷åê

  
  bool OK_Period=false;   
  switch (CandleTimeFrame)
  {    
    case 1:OK_Period=true;break;
    case 5:OK_Period=true;break;
    case 15:OK_Period=true;break;
    case 30:OK_Period=true;break;
    case 60:OK_Period=true;break;
    case 240:OK_Period=true;break;
    case 1440:OK_Period=true;break;
    case 10080:OK_Period=true;break;
    case 43200:OK_Period=true;break;
  }
  if (OK_Period==false)
     {
        Comment("CandleTimeFrame != 1,5,15,30,60,240(H4), 1440(D1),10080(W1), 43200(MN) !");   
//      Comment("Âû ââåëè íåñòàíäàðòíóþ öèôðó òàéìôðåéìà CandleTimeFrame! Íåîáõîäèìî ââåñòè îäíó èç ñëåäóþùèõ: 1,5,15,30,60,240,1440 è ò.ä.");   
       return(0);
     }
  if (Period()>CandleTimeFrame) 
  {
    Comment("mCandles: CandleTimeFrame<"+Period());//Çàäàâàåìûé ñòàíäàðòíûé ïåðèîä äîëæåí áûòü áîëüøå òåêóùåãî! (Òåêóùèé ðàâåí " + Period() + ")");
//  Comment("Çàäàâàåìûé ñòàíäàðòíûé ïåðèîä äîëæåí áûòü áîëüøå òåêóùåãî! (Òåêóùèé ðàâåí " + Period() + ")");
    return(0);
  }
    
    shb=0;
    // Áåæèì ïî ñòàðøèì ñâå÷êàì  
    while (shb<NumberOfBar) 
    {
      to = iTime(Symbol(), CandleTimeFrame, shb);
      tc = iTime(Symbol(), CandleTimeFrame, shb) + CandleTimeFrame*60;
      po = iOpen(Symbol(), CandleTimeFrame, shb);
      pc = iClose(Symbol(), CandleTimeFrame, shb);
      ph = iHigh(Symbol(), CandleTimeFrame, shb); 
      pl = iLow(Symbol(), CandleTimeFrame, shb); 
      //óñòàíàâëèâàåì  ðåêòàíãåëû
      ObjectSet("BodyTF"+CandleTimeFrame+"Bar"+shb, OBJPROP_TIME1, to);  //âðåìÿ îòêðûòèÿ
      ObjectSet("BodyTF"+CandleTimeFrame+"Bar"+shb, OBJPROP_PRICE1, po); //öåíà îòêðûòèÿ
      ObjectSet("BodyTF"+CandleTimeFrame+"Bar"+shb, OBJPROP_TIME2, tc);  //âðåìÿ çàêðûòèÿ
      ObjectSet("BodyTF"+CandleTimeFrame+"Bar"+shb, OBJPROP_PRICE2, pc); //öåíà çàêðûòèÿ
      ObjectSet("BodyTF"+CandleTimeFrame+"Bar"+shb, OBJPROP_STYLE, STYLE_SOLID);
      ObjectSet("BodyTF"+CandleTimeFrame+"Bar"+shb, OBJPROP_WIDTH, CandleWidth);
      ObjectSet("BodyTF"+CandleTimeFrame+"Bar"+shb, OBJPROP_BACK, FillCandleWithColors);
      //óñòàíàâëèâàåì òåíè hl
      ts = to + MathRound((CandleTimeFrame*60)/2);
      ObjectSet("ShadowTFh"+CandleTimeFrame+"Bar"+shb, OBJPROP_TIME1, ts);
      ObjectSet("ShadowTFh"+CandleTimeFrame+"Bar"+shb, OBJPROP_PRICE1, ph);
      ObjectSet("ShadowTFh"+CandleTimeFrame+"Bar"+shb, OBJPROP_TIME2, ts);
      ObjectSet("ShadowTFh"+CandleTimeFrame+"Bar"+shb, OBJPROP_PRICE2, MathMax(po,pc));
      ObjectSet("ShadowTFh"+CandleTimeFrame+"Bar"+shb, OBJPROP_STYLE, STYLE_SOLID);
      ObjectSet("ShadowTFh"+CandleTimeFrame+"Bar"+shb, OBJPROP_WIDTH, CandleWidth);
      ObjectSet("ShadowTFh"+CandleTimeFrame+"Bar"+shb, OBJPROP_BACK, FillCandleWithColors);
      ObjectSet("ShadowTFh"+CandleTimeFrame+"Bar"+shb, OBJPROP_RAY, False);            
 
      ObjectSet("ShadowTFl"+CandleTimeFrame+"Bar"+shb, OBJPROP_TIME1, ts);
      ObjectSet("ShadowTFl"+CandleTimeFrame+"Bar"+shb, OBJPROP_PRICE1, MathMin(po,pc));
      ObjectSet("ShadowTFl"+CandleTimeFrame+"Bar"+shb, OBJPROP_TIME2, ts);
      ObjectSet("ShadowTFl"+CandleTimeFrame+"Bar"+shb, OBJPROP_PRICE2, pl);
      ObjectSet("ShadowTFl"+CandleTimeFrame+"Bar"+shb, OBJPROP_STYLE, STYLE_SOLID);
      ObjectSet("ShadowTFl"+CandleTimeFrame+"Bar"+shb, OBJPROP_WIDTH, CandleWidth);
      ObjectSet("ShadowTFl"+CandleTimeFrame+"Bar"+shb, OBJPROP_BACK, FillCandleWithColors);
      ObjectSet("ShadowTFl"+CandleTimeFrame+"Bar"+shb, OBJPROP_RAY, False);            
 
 
 
      //óñòàíàâëèâàåì öâåòà äëÿ âñåõ îáúåêòîâ
      if (po<pc) {
          ObjectSet("BodyTF"+CandleTimeFrame+"Bar"+shb, OBJPROP_COLOR, ColorUp);
          ObjectSet("ShadowTFh"+CandleTimeFrame+"Bar"+shb, OBJPROP_COLOR, ColorUp);
          ObjectSet("ShadowTFl"+CandleTimeFrame+"Bar"+shb, OBJPROP_COLOR, ColorUp);
 
        } else {
          ObjectSet("BodyTF"+CandleTimeFrame+"Bar"+shb, OBJPROP_COLOR, ColorDown);
          ObjectSet("ShadowTFh"+CandleTimeFrame+"Bar"+shb, OBJPROP_COLOR, ColorDown);
          ObjectSet("ShadowTFl"+CandleTimeFrame+"Bar"+shb, OBJPROP_COLOR, ColorDown);

        }
      // HH->LL
      if (shb < NumberOfBar-1)
      {
         datetime to_next_2 = iTime(Symbol(), CandleTimeFrame, shb+1);
         datetime ts_next_2 = to_next_2 + MathRound((CandleTimeFrame*60)/2);
         double   pl_next_2 = iLow(Symbol(), CandleTimeFrame, shb+1);
         string   linkName_2 = "HHLLTF"+IntegerToString(CandleTimeFrame)+"Bar"+IntegerToString(shb);
         ObjectSet(linkName_2, OBJPROP_TIME1, ts);
         ObjectSet(linkName_2, OBJPROP_PRICE1, ph);
         ObjectSet(linkName_2, OBJPROP_TIME2, ts_next_2);
         ObjectSet(linkName_2, OBJPROP_PRICE2, pl_next_2);
         ObjectSet(linkName_2, OBJPROP_STYLE, STYLE_SOLID);
         ObjectSet(linkName_2, OBJPROP_WIDTH, LinkHH2LLWidth);
         ObjectSet(linkName_2, OBJPROP_COLOR, LinkHH2LLColor);
         ObjectSet(linkName_2, OBJPROP_BACK, FillCandleWithColors);
         ObjectSet(linkName_2, OBJPROP_RAY, False);
      }
      // LL -> HH
      if (shb < NumberOfBar-1)
      {
         datetime to_next_3 = iTime(Symbol(), CandleTimeFrame, shb+1);
         datetime ts_next_3 = to_next_3 + MathRound((CandleTimeFrame*60)/2);
         double   ph_next_3   = iHigh(Symbol(), CandleTimeFrame, shb+1);
         string   linkName_3 = "LLHHTF"+IntegerToString(CandleTimeFrame)+"Bar"+IntegerToString(shb);
         ObjectSet(linkName_3, OBJPROP_TIME1, ts);
         ObjectSet(linkName_3, OBJPROP_PRICE1, pl);
         ObjectSet(linkName_3, OBJPROP_TIME2, ts_next_3);
         ObjectSet(linkName_3, OBJPROP_PRICE2, ph_next_3);
         ObjectSet(linkName_3, OBJPROP_STYLE, STYLE_SOLID);
         ObjectSet(linkName_3, OBJPROP_WIDTH, LinkLL2HHWidth);
         ObjectSet(linkName_3, OBJPROP_COLOR, LinkLL2HHColor);
         ObjectSet(linkName_3, OBJPROP_BACK, FillCandleWithColors);
         ObjectSet(linkName_3, OBJPROP_RAY, False);
      }
      shb++;
     }       
  return(0);
}
//+------------------------------------------------------------------+
int start()
{
   handleButtonClicks();
   recalc = false;
   start2();
      if (show_data)
      {
        for (int i=0; i<NumberOfBar; i++) {
             ObjectCreate("BodyTF"   +CandleTimeFrame+"Bar"+i, OBJ_RECTANGLE, 0, 0,0, 0,0);
             ObjectCreate("ShadowTFh"+CandleTimeFrame+"Bar"+i, OBJ_TREND,     0, 0,0, 0,0);
             ObjectCreate("ShadowTFl"+CandleTimeFrame+"Bar"+i, OBJ_TREND,     0, 0,0, 0,0);
            if (i < NumberOfBar-1)
               ObjectCreate("HHLLTF"+CandleTimeFrame+"Bar"+i, OBJ_TREND,     0, 0,0, 0,0);
               ObjectCreate("LLHHTF"+CandleTimeFrame+"Bar"+i, OBJ_TREND,     0, 0,0, 0,0);
        }
        Comment("");
        start2();
      }
      else
      {
        for (i=0; i<NumberOfBar; i++) {
             ObjectDelete("BodyTF"   +CandleTimeFrame+"Bar" + i);
             ObjectDelete("ShadowTFh"+CandleTimeFrame+"Bar" + i);
             ObjectDelete("ShadowTFl"+CandleTimeFrame+"Bar" + i);
             ObjectDelete("HHLLTF"  +CandleTimeFrame+"Bar" + i);
             ObjectDelete("LLHHTF"  +CandleTimeFrame+"Bar" + i);
        }
        Comment("");
      }
   return 0;
}
//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&p=160107#p160107

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
