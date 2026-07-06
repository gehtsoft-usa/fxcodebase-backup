// Id: 7482
//+------------------------------------------------------------------+
//|                                               ZigZag_Counter.mq4 |
//|                               Copyright � 2012, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright � 2012, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 Red
//---- indicator parameters
extern int ExtDepth=12;
extern int ExtDeviation=5;
extern int ExtBackstep=3;
extern int FontSize=10;
extern color TextColor=Yellow;
//---- indicator buffers
double ExtMapBuffer[];
double ExtMapBuffer2[];

string IndicatorName;
string IndicatorObjPrefix;

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

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   IndicatorBuffers(2);
//---- drawing settings
   SetIndexStyle(0,DRAW_SECTION);
//---- indicator buffers mapping
   SetIndexBuffer(0,ExtMapBuffer);
   SetIndexBuffer(1,ExtMapBuffer2);
   SetIndexEmptyValue(0,0.0);
//---- indicator short name
IndicatorName = GenerateIndicatorName("ZigZag("+ExtDepth+","+ExtDeviation+","+ExtBackstep+")");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
//---- initialization done
   return(0);
  }
  
int deinit()
  {
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return(0);
  }
  
void DeleteLabels(double startBar, double endBar)
{
 int i;
 int obj_total=ObjectsTotal();
 string obj_name;
 datetime obj_time;
 for (i=obj_total-1;i>=0;i--)
 {
  obj_name=ObjectName(i);
  if (ObjectType(obj_name)!=OBJ_TEXT) continue;
  obj_time=ObjectGet(obj_name, OBJPROP_TIME1);
  if (obj_time>=startBar && obj_time<=endBar)
  {
   ObjectDelete(obj_name);
  }
 }
 return;
}  

string TextFormat(int bars, double pips)
{
 return (""+(DoubleToStr(MathAbs(bars)+1,0))+" bars, "+DoubleToStr(MathFloor(MathAbs(pips)/Point+0.5),0)+" pips");
}

void DrawLabel(int bar1, int bar2, double price1, double price2)
{
 int Nbar1=iBarShift(NULL, 0, bar1);
 int Nbar2=iBarShift(NULL, 0, bar2);
 string Str=TextFormat(Nbar1-Nbar2, price1-price2);
 string obj_name=IndicatorObjPrefix + ""+bar2;
 ObjectCreate(obj_name, OBJ_TEXT, 0, bar2, price2);
 ObjectSetText(obj_name, Str, FontSize, "Arial", TextColor);
 ObjectSet(obj_name, OBJPROP_PRICE1, price2);
 return;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {
   int    shift, back,lasthighpos,lastlowpos;
   double val,res;
   double curlow,curhigh,lasthigh,lastlow;

   for(shift=Bars-ExtDepth; shift>=0; shift--)
     {
      val=Low[Lowest(NULL,0,MODE_LOW,ExtDepth,shift)];
      if(val==lastlow) val=0.0;
      else 
        { 
         lastlow=val; 
         if((Low[shift]-val)>(ExtDeviation*Point)) val=0.0;
         else
           {
            for(back=1; back<=ExtBackstep; back++)
              {
               res=ExtMapBuffer[shift+back];
               if((res!=0)&&(res>val)) ExtMapBuffer[shift+back]=0.0; 
              }
           }
        } 
      ExtMapBuffer[shift]=val;
      //--- high
      val=High[Highest(NULL,0,MODE_HIGH,ExtDepth,shift)];
      if(val==lasthigh) val=0.0;
      else 
        {
         lasthigh=val;
         if((val-High[shift])>(ExtDeviation*Point)) val=0.0;
         else
           {
            for(back=1; back<=ExtBackstep; back++)
              {
               res=ExtMapBuffer2[shift+back];
               if((res!=0)&&(res<val)) ExtMapBuffer2[shift+back]=0.0; 
              } 
           }
        }
      ExtMapBuffer2[shift]=val;
     }

   // final cutting 
   lasthigh=-1; lasthighpos=-1;
   lastlow=-1;  lastlowpos=-1;

   for(shift=Bars-ExtDepth; shift>=0; shift--)
     {
      curlow=ExtMapBuffer[shift];
      curhigh=ExtMapBuffer2[shift];
      if((curlow==0)&&(curhigh==0)) continue;
      //---
      if(curhigh!=0)
        {
         if(lasthigh>0) 
           {
            if(lasthigh<curhigh) ExtMapBuffer2[lasthighpos]=0;
            else ExtMapBuffer2[shift]=0;
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
  
   DeleteLabels(Time[Bars-1], Time[0]);
   double LastPrice=EMPTY_VALUE;
   int LastBar=EMPTY_VALUE;
   for(shift=Bars-1; shift>=0; shift--)
     {
      if(shift>=Bars-ExtDepth) ExtMapBuffer[shift]=0.0;
      else
        {
         res=ExtMapBuffer2[shift];
         if(res!=0.0) 
         {
          ExtMapBuffer[shift]=res;
         }
         else
         {
          res=ExtMapBuffer[shift];
         }

         if (res!=0)
         {
          if (LastPrice!=EMPTY_VALUE)
          {
           DrawLabel(Time[LastBar], Time[shift], LastPrice, res);
          } 
          LastPrice=res;
          LastBar=shift;
         } 
        }
     }
  }