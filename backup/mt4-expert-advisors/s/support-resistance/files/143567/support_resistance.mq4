// More information about this indicator can be found at:
//https://fxcodebase.com/code/viewtopic.php?f=38&t=71498

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2021, Gehtsoft USA LLC  |
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                              Support our efforts by donating   |
//|                                                                 Paypal: https://goo.gl/9Rj74e  |
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |
//|                                                                       mario.jemic@gmail.com    |
//|                                                        https://AppliedMachineLearning.systems  |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|BitCoin Address            : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |
//|Ethereum Address           : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |
//|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |
//|Dogecoin Address           : DNDTFfmVa2Gjts5YvSKEYaiih6cums2L6C                                 |
//|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         |
//+------------------------------------------------------------------------------------------------+

#property copyright "Copyright © 2021, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.0"
#define MaxObject    1000
#property indicator_chart_window
//---- indicator parameters
input ENUM_TIMEFRAMES TimeFrame=PERIOD_CURRENT;
input int BarsMax=11;
input int ExtDepth=13;
input int ExtDeviation=1;
input int ExtBackstep=5;
input bool DeleteObjectsOnExit=true;
input color LineColorM1_Resistance=RosyBrown;
input color LineColorM1_Support=Orchid;
input color LineColorM5_Resistance=DarkTurquoise;
input color LineColorM5_Support=DarkOrchid;
input color LineColorM15_Resistance=DarkOrange;
input color LineColorM15_Support=DeepPink;
input color LineColorM30_Resistance=PaleVioletRed;
input color LineColorM30_Support=Coral;
input color LineColorH1_Resistance=Red;
input color LineColorH1_Support=Blue;
input color LineColorH4_Resistance=Magenta;
input color LineColorH4_Support=Yellow;
input color LineColorD1_Resistance=DarkViolet;
input color LineColorD1_Support=SteelBlue;
input color LineColorW1_Resistance=Teal;
input color LineColorW1_Support=MediumSpringGreen;
input color LineColorMN1_Resistance=Teal;
input color LineColorMN1_Support=MediumSpringGreen;
//-----------------------
double ExtMapBuffer[];
double ExtMapBuffer2[];
int SUPRESCount=0;
int linewidth;
string NamePattern;
color LineColor;
color LineColorSupport;
color LineColorResistance;

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
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
   IndicatorBuffers(2);
   SetIndexBuffer(0,ExtMapBuffer);
   SetIndexBuffer(1,ExtMapBuffer2);
   SetIndexEmptyValue(0,0.0);
   ArraySetAsSeries(ExtMapBuffer,true);
   ArraySetAsSeries(ExtMapBuffer2,true);
   
   int tf=0;
   
   if(TimeFrame == PERIOD_CURRENT)
      tf = Period();
   else
      tf = TimeFrame;
           
   switch (tf)
     {
        case PERIOD_M1: linewidth=2; LineColorSupport=LineColorM1_Support; LineColorResistance=LineColorM1_Resistance;break;   
        case PERIOD_M5: linewidth=2; LineColorSupport=LineColorM5_Support; LineColorResistance=LineColorM5_Resistance;break;
        case PERIOD_M15: linewidth=2; LineColorSupport=LineColorM15_Support; LineColorResistance=LineColorM15_Resistance;break;
        case PERIOD_M30: linewidth=2; LineColorSupport=LineColorM30_Support; LineColorResistance=LineColorM30_Resistance;break;
        case PERIOD_H1: Print("H1 Here");linewidth=2; LineColorSupport=LineColorH1_Support; LineColorResistance=LineColorH1_Resistance;break;
        case PERIOD_H4: linewidth=2; LineColorSupport=LineColorH4_Support;LineColorResistance=LineColorH4_Resistance; break;
        case PERIOD_D1: linewidth=2; LineColorSupport=LineColorD1_Support;LineColorResistance=LineColorD1_Resistance; break;
        case PERIOD_W1: linewidth=2; LineColorSupport=LineColorW1_Support;LineColorResistance=LineColorW1_Resistance; break;
        case PERIOD_MN1: linewidth=2; LineColorSupport=LineColorMN1_Support;LineColorResistance=LineColorMN1_Resistance; break;
        default: linewidth=2;break;
     }
   NamePattern=DoubleToStr(TimeFrame,0)+" SUPRES ";
   
   ObjectsDeleteAll(0,OBJ_TREND);
	visibility.Init("show_hide_sr", "SR", "Show/Hide", button_x, button_y);
   return(0);
}
  
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
{
   if (DeleteObjectsOnExit==true) 
      ObjectsDeleteAll(0,OBJ_TREND);
   visibility.DeInit();
   return(0);
}   
  
  
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
   if (visibility.HandleButtonClicks())
   {
      start();
   }
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
{
   visibility.HandleButtonClicks();
   int    shift, back,lasthighpos,lastlowpos;
   double val,res;
   double curlow,curhigh,lasthigh,lastlow;
   string objectname;

   if (visibility.IsRecalcNeeded())
   {
      if (!visibility.IsVisible())
      {
         if (DeleteObjectsOnExit==true) 
            ObjectsDeleteAll(0,OBJ_TREND);
            
         ArrayInitialize(ExtMapBuffer, EMPTY_VALUE);
         ArrayInitialize(ExtMapBuffer2, EMPTY_VALUE);

         visibility.ResetRecalc();
         return 0;
      }
      visibility.ResetRecalc();
   }
   if (!visibility.IsVisible())
   {
      return 0;
   }
   for (shift = iBars(NULL,TimeFrame)-ExtDepth; shift>=0; shift--)
   {
      val = iLow(NULL,TimeFrame,Lowest(NULL,TimeFrame,MODE_LOW,ExtDepth,shift));
      if (val == lastlow) 
         val = 0.0;
      else 
      { 
         lastlow = val; 
         if ((iLow(NULL, TimeFrame, shift) - val) > (ExtDeviation * Point)) 
            val = 0.0;
         else
         {
            for (back = 1; back <= ExtBackstep; back++)
            {
               res=ExtMapBuffer[shift+back];
               if((res!=0)&&(res>val)) ExtMapBuffer[shift+back]=0.0; 
            }
         }
      } 
      
      ExtMapBuffer[shift]= val;
     
      //--- high
      val=iHigh(NULL,TimeFrame,Highest(NULL,TimeFrame,MODE_HIGH,ExtDepth,shift));
      if(val==lasthigh)
         val=0.0;
      else 
      {
         lasthigh=val;
         if((val-iHigh(NULL,TimeFrame,shift))>(ExtDeviation*Point)) 
            val=0.0;
         else
         {
            for(back=1; back<=ExtBackstep; back++)
            {
               res=ExtMapBuffer2[shift+back];
               if((res!=0)&&(res<val)) 
                  ExtMapBuffer2[shift+back]=0.0; 
            } 
         }
      }
      ExtMapBuffer2[shift]=val;
   }

   // final cutting 
   lasthigh=-1; lasthighpos=-1;
   lastlow=-1;  lastlowpos=-1;

   for(shift=iBars(NULL,TimeFrame)-ExtDepth; shift>=0; shift--)
   {
      curlow=ExtMapBuffer[shift];
      curhigh=ExtMapBuffer2[shift];
      if((curlow==0)&&(curhigh==0)) 
         continue;
      //---
      if(curhigh!=0)
      {
         if(lasthigh>0) 
         {
            if(lasthigh<curhigh)
               ExtMapBuffer2[lasthighpos]=0;
            else 
               ExtMapBuffer2[shift]=0;
         }
         //---
         if(lasthigh<curhigh || lasthigh<0)
         {
            lasthigh=curhigh;
            lasthighpos=shift;
         }
         lastlow=-1;
      }
      //----
      if(curlow!=0)
      {
         if(lastlow>0)
         {
            if(lastlow>curlow) ExtMapBuffer[lastlowpos]=0;
            else ExtMapBuffer[shift]=0;
         }
         //---
         if((curlow<lastlow)||(lastlow<0))
         {
            lastlow=curlow;
            lastlowpos=shift;
         } 
         lasthigh=-1;
      }
   }
  
   for(shift=iBars(NULL,TimeFrame)-1; shift>=0; shift--)
   {
      if(shift>=iBars(NULL,TimeFrame)-ExtDepth) 
         ExtMapBuffer[shift]=0.0;
      else
      {
         res=ExtMapBuffer2[shift];
         if(res!=0.0) 
            ExtMapBuffer[shift]= -res;
      }
   }
 ///////////////////////// Lines creation /////////////////   
   int count=0;
   double TempBufferPrice[MaxObject];   
   int TempBufferBar[MaxObject];
   string ObjectNames[MaxObject];
 //////////////////////// lists of lines //////////////////  
   for(shift=BarsMax; shift>0; shift--)
      if (ExtMapBuffer[shift]!=0)
      {
         count++;
         TempBufferPrice[count-1]=ExtMapBuffer[shift];
         TempBufferBar[count-1]=shift;
      }   
   for(int i=0; i<count; i++)   
      ObjectNames[i]=TimeFrame+"m S/R("+i+") @ "+DoubleToStr(TempBufferPrice[i],Digits)+" "+
                     TimeToStr(iTime(NULL,TimeFrame,TempBufferBar[i]),TIME_DATE|TIME_MINUTES);

 /////// deleting pending objects ///////////////     
   int ObjectForDeleteCount=0;
   string ObjectsForDelete[MaxObject];
   for(i=0; i<ObjectsTotal(); i++)   
   {
      objectname=ObjectName(i);
      if (StringSubstr(objectname,0,StringLen(NamePattern))==NamePattern)
      {
         ObjectForDeleteCount++;
         ObjectsForDelete[ObjectForDeleteCount-1]=objectname;
      }   
   }
   for(i=0; i<count-2; i++)
   {
      objectname=ObjectNames[i];
      for(int j=0; j<ObjectForDeleteCount; j++)
         if(ObjectsForDelete[j]==objectname)
         {
            ObjectsForDelete[j]="";    
            break;
         }     
   }
   for(j=0; j<ObjectForDeleteCount; j++)
      if (ObjectsForDelete[j]!="")
      { 
         ObjectDelete(ObjectsForDelete[j]);
      }
 ////////////// objects plotting /////////////////  
   for(i=0; i<count; i++)   
   {
      if (ObjectFind(ObjectNames[i])==-1)
      {
         if(TempBufferPrice[i] < 0 )
         {
            ObjectCreate(ObjectNames[i],OBJ_TREND,0,iTime(NULL,TimeFrame,TempBufferBar[i]),-TempBufferPrice[i],
                           iTime(NULL,TimeFrame,TempBufferBar[i])+10080*60,-TempBufferPrice[i]);
            ObjectSet(ObjectNames[i],OBJPROP_WIDTH,linewidth); 
            ObjectSet(ObjectNames[i],OBJPROP_COLOR,LineColorResistance);
            ObjectSet(ObjectNames[i],OBJPROP_RAY,true);
         }
         else if(TempBufferPrice[i] > 0 )
         {
            ObjectCreate(ObjectNames[i],OBJ_TREND,0,iTime(NULL,TimeFrame,TempBufferBar[i]),TempBufferPrice[i],
                           iTime(NULL,TimeFrame,TempBufferBar[i])+10080*60,TempBufferPrice[i]);
            ObjectSet(ObjectNames[i],OBJPROP_WIDTH,linewidth); 
            ObjectSet(ObjectNames[i],OBJPROP_COLOR,LineColorSupport);
            ObjectSet(ObjectNames[i],OBJPROP_RAY,true);
         }
      } 
   }        
   return(0);
}