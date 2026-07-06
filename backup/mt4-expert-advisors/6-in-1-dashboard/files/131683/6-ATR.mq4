#property copyright "ABS 20"
#define MAX_OBJECT_NUM 20

#property indicator_chart_window
#property indicator_buffers 6
#property indicator_color1 CLR_NONE
#property indicator_width1 1
#property indicator_color3  Aqua
#property indicator_width3 1
#property indicator_color4  Magenta
#property indicator_width4 1
#property indicator_color5 Aqua
#property indicator_width5 1
#property indicator_color6  Magenta
#property indicator_width6 1
//---- input parameters
extern int       Mode = 0;
extern double    DeltaPrice = 0.003;
extern double    Multiplier = 2;
extern int    ATRLength = 10;
extern bool    AlertMe = true;
extern bool    ShowRisk = true;
extern bool ShowArrow = true;
//---- buffers
double TrStop[];
double ATR[];
double aup[];
double ado[];
double state[];
double upStop[];
double dnStop[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- 
   IndicatorDigits(Digits);
   DeleteAllArrowObjects();
   SetIndexStyle(0, DRAW_NONE);
   SetIndexArrow(0,159);
   SetIndexBuffer(0, TrStop);
   SetIndexStyle(1, DRAW_NONE);
   SetIndexBuffer(1, ATR);
   if (ShowArrow)
   {
      SetIndexBuffer(2,aup); SetIndexStyle(2,DRAW_ARROW); SetIndexArrow(2,233);
      SetIndexBuffer(3,ado); SetIndexStyle(3,DRAW_ARROW); SetIndexArrow(3,234);
   }
   else
   {
      SetIndexBuffer(2,aup); SetIndexStyle(2,DRAW_NONE); SetIndexArrow(2,233);
      SetIndexBuffer(3,ado); SetIndexStyle(3,DRAW_NONE); SetIndexArrow(3,234);
   }
   SetIndexStyle(4, DRAW_ARROW);
   SetIndexArrow(4,159);
   SetIndexBuffer(4, upStop);
   SetIndexStyle(5, DRAW_ARROW);
   SetIndexArrow(5,159);
   SetIndexBuffer(5, dnStop);
   
   string short_name = "ATR Stop Loss";
   IndicatorShortName(short_name);
   SetIndexLabel(0, short_name);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//---- 
   DeleteAllArrowObjects();
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int    counted_bars = IndicatorCounted();
   int limit;
   int i;
   bool savedDn = false;
   bool savedUp = false;
   
   double DeltaStop;
   
   limit = Bars;

   for(i = 0; i < limit; i ++) {
      ATR[i] = iATR(NULL, 0, ATRLength, i);
   }

   for(i = limit - 1; i >= 0; i --) 
   {
      if (Mode == 0) 
      {
         DeltaStop = iMAOnArray(ATR, 0, (ATRLength * 2) - 1, 0, MODE_EMA, i) * Multiplier;
      } 
      else 
      {
         DeltaStop = DeltaPrice;
      }

      if (Close[i] == TrStop[i + 1]) 
      {
         TrStop[i] = TrStop[i + 1];
      } 
      else 
      {
         if (Close[i + 1] < TrStop[i + 1] && Close[i] < TrStop[i + 1]) 
         {
            TrStop[i] = MathMin(TrStop[i + 1], Close[i] + DeltaStop);
         } 
         else 
         {
            if (Close[i + 1] > TrStop[i + 1] && Close[i] > TrStop[i + 1]) 
            {
               TrStop[i] = MathMax(TrStop[i + 1], Close[i] - DeltaStop);         
            } 
            else 
            {
               if (Close[i] > TrStop[i + 1]) 
                  TrStop[i] = Close[i] - DeltaStop; 
               else 
                  TrStop[i] = Close[i] + DeltaStop;
            }
         }
      }
      
      bool Up = false;
      bool Dn = false;         
      string  ObjName;
      if ( Close[i] > TrStop[i])
      {
         upStop[i] = TrStop[i];
         dnStop[i]= EMPTY_VALUE;
      }
      else if ( Close[i] < TrStop[i])
      {
         dnStop[i] = TrStop[i];
         upStop[i]= EMPTY_VALUE;
      }         
      else
      {
         upStop[i] = EMPTY_VALUE;
         dnStop[i] = EMPTY_VALUE;
      }
      if ( Close[i] > TrStop[i] && Close[i + 1] <= TrStop[i + 1] )
      {
         aup[i] = TrStop[i] - iATR(NULL,0,10,i);
         ado[i] = EMPTY_VALUE;
         Up = true;
         /*if (ShowRisk && i==1)
         {
            ObjName = "HPT - Risk " + TimeToStr(Time[i],TIME_DATE);
            if (ObjectFind(ObjName)==-1)
               ObjectCreate( ObjName, OBJ_TEXT, 0, Time[i], aup[i] - iATR(NULL,0,10,i));
            ObjectSetText(ObjName, DoubleToStr(MathAbs(TrStop[i]-Close[i])/Point, 0), 10, "Arial Black", SlateBlue);
         }*/
      }
      else if ( Close[i] < TrStop[i] && Close[i + 1] >= TrStop[i + 1] ) 
      {
         ado[i] = TrStop[i] + iATR(NULL,0,10,i);
         aup[i] = EMPTY_VALUE;
         Dn = true;
         /* if (ShowRisk && i==1)
         {
            ObjName = "HPT - Risk " + TimeToStr(Time[i],TIME_DATE);
            if (ObjectFind(ObjName)==-1)
               ObjectCreate( ObjName, OBJ_TEXT, 0, Time[i], ado[i] + iATR(NULL,0,10,i));
            ObjectSetText(ObjName, DoubleToStr(MathAbs(TrStop[i]-Close[i])/Point, 0), 10, "Arial Black", SlateBlue);
         }*/
      }
      else
      {
         aup[i] = EMPTY_VALUE;
         ado[i] = EMPTY_VALUE;
      }
   }
   if ( Up ) 
   {
      if (i==1) savedUp=Up;
   }
   else if ( Dn )
   {
      if (i==1) savedDn=Dn;
   }


   if ( i > 0 ) 
   {
      if (AlertMe)
      {
         if (savedDn) doAlert("down signal");
         if (savedUp) doAlert("up signal");
      }  
   }
   
   if (ShowRisk)
   {
      ObjName = "HPT - Risk Pips";
      if (ObjectFind(ObjName)==-1)
         ObjectCreate(ObjName, OBJ_LABEL, 0, EMPTY_VALUE,EMPTY_VALUE);
      ObjectSetText(ObjName, "ATR Risk = " + DoubleToStr(MathAbs(TrStop[1]-Close[1])/Point, 0), 10, "Arial Black", White);
      ObjectSet(ObjName, OBJPROP_CORNER, 1);
      ObjectSet(ObjName, OBJPROP_XDISTANCE, 2);
      ObjectSet(ObjName, OBJPROP_YDISTANCE, 2);

      ObjName = "HPT - Risk Price";
      if (ObjectFind(ObjName)==-1)
         ObjectCreate(ObjName, OBJ_LABEL, 0, EMPTY_VALUE,EMPTY_VALUE);
      ObjectSetText(ObjName, "ATR Price = " + DoubleToStr(TrStop[1], Digits), 10, "Arial Black", White);
      ObjectSet(ObjName, OBJPROP_CORNER, 1);
      ObjectSet(ObjName, OBJPROP_XDISTANCE, 2);
      ObjectSet(ObjName, OBJPROP_YDISTANCE, 15);
   }
   
//----
   return(0);
}
//+------------------------------------------------------------------+

string TimeFrameToString(int tf)
{
   string tfs="";
   switch(tf) {
      case PERIOD_M1:  tfs="M1"  ; break;
      case PERIOD_M5:  tfs="M5"  ; break;
      case PERIOD_M15: tfs="M15" ; break;
      case PERIOD_M30: tfs="M30" ; break;
      case PERIOD_H1:  tfs="H1"  ; break;
      case PERIOD_H4:  tfs="H4"  ; break;
      case PERIOD_D1:  tfs="D1"  ; break;
      case PERIOD_W1:  tfs="W1"  ; break;
      case PERIOD_MN1: tfs="MN1";
   }
   return(tfs);
}

void doAlert(string doWhat)
{
   static string   previousAlert="nothing";
   static datetime previousTime;
   string message;
   
      if (previousAlert != doWhat || previousTime != Time[0]) 
      {
          previousAlert  = doWhat;
          previousTime   = Time[0];

          message =  StringConcatenate(Symbol()+" - "+TimeFrameToString(Period())," at ",TimeToStr(TimeLocal(),TIME_SECONDS)," Level stop reverse ",doWhat);
          Alert(message);
      }
}

void DeleteAllArrowObjects() {
   for(int i=ObjectsTotal(); i>=0; i--)
   {
      string name = ObjectName(i);
         if (StringFind(name,"HPT - Risk",0) !=-1)
             ObjectDelete(name);  
   }    
   return;
}