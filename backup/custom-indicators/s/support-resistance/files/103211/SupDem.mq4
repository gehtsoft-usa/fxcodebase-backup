//+------------------------------------------------------------------+
//|                                                       SupDem.mq4 |
//|                      Copyright © 2008, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2008, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"

#property indicator_chart_window
#property indicator_buffers 2
extern int forcedtf = 0;
extern bool usenarrowbands = false;
extern bool killretouch = true;
extern color TopColor = C'0,81,81';
extern color BotColor = C'0,54,89';
extern int Price_Width = 1;
extern int Colored = 0;
extern int Width = 3;

double BuferUp[];
double BuferDn[];
double iPeriod=13;
int Dev=8;
int Step=5;
datetime t1,t2;
double p1,p2;
string pair;
double point;
int digits;
int tf;
string TAG;

double upcur,dncur;

int init()
{
   SetIndexBuffer(1,BuferUp);
   SetIndexEmptyValue(1,0.0);
   SetIndexStyle(1,DRAW_NONE);
   SetIndexBuffer(0,BuferDn);
   SetIndexEmptyValue(0,0.0);
   SetIndexStyle(0,DRAW_NONE);
   if(forcedtf != 0) tf = forcedtf;
      else tf = Period();
   point = Point;
   digits = Digits;
   if(digits == 3 || digits == 5) point*=10;
   TAG = "II_SupDem"+tf;
   return(0);
}

int deinit()
{
   ObDeleteObjectsByPrefix(TAG);
   Comment("");
   return(0);
}

int start()
{
   if(NewBar()==true)
   {
      CountZZ(BuferUp,BuferDn,iPeriod,Dev,Step);
      GetValid();
      Draw();
   }
   return(0);
}

void Draw()
{
   int i;
   string s;
   ObDeleteObjectsByPrefix(TAG);
   for(i=0;i<iBars(pair,tf);i++)
   {
      if(BuferDn[i] > 0.0)
      {
         t1 = iTime(pair,tf,i);
         t2 = Time[0];
         if(usenarrowbands) p2 = MathMax(iClose(pair,tf,i),iOpen(pair,tf,i));
            else p2 = MathMin(iClose(pair,tf,i),iOpen(pair,tf,i));
         p2 = MathMax(p2,MathMax(iLow(pair,tf,i-1),iLow(pair,tf,i+1)));


         s = TAG+"UPAR"+tf+i;
         ObjectCreate(s,OBJ_HLINE,0,0,0);
         ObjectSet(s,OBJPROP_ARROWCODE,SYMBOL_RIGHTPRICE);
         ObjectSet(s, OBJPROP_TIME1, t2);
         ObjectSet(s, OBJPROP_PRICE1, p2);
         ObjectSet(s,OBJPROP_COLOR,TopColor);
         ObjectSet(s,OBJPROP_WIDTH,Price_Width);     
     
         s = TAG+"UPFILL"+tf+i;
         ObjectCreate(s,OBJ_RECTANGLE,0,0,0,0,0);
         ObjectSet(s,OBJPROP_TIME1,t1);
         ObjectSet(s,OBJPROP_PRICE1,BuferDn[i]);
         ObjectSet(s,OBJPROP_TIME2,t2);
         ObjectSet(s,OBJPROP_PRICE2,p2);
         ObjectSet(s,OBJPROP_COLOR,TopColor);
         ObjectSet(s,OBJPROP_BACK,Colored);
         ObjectSet(s,OBJPROP_WIDTH,Width);
      }

      if(BuferUp[i] > 0.0)
      {
         t1 = iTime(pair,tf,i);
         t2 = Time[0];
         if(usenarrowbands) p2 = MathMin(iClose(pair,tf,i),iOpen(pair,tf,i));
            else p2 = MathMax(iClose(pair,tf,i),iOpen(pair,tf,i));
         if(i>0) p2 = MathMin(p2,MathMin(iHigh(pair,tf,i+1),iHigh(pair,tf,i-1)));
         s = TAG+"DNAR"+tf+i;
         ObjectCreate(s,OBJ_HLINE,0,0,0);
         ObjectSet(s,OBJPROP_ARROWCODE,SYMBOL_RIGHTPRICE);
         ObjectSet(s, OBJPROP_TIME1, t2);
         ObjectSet(s, OBJPROP_PRICE1, p2);
         ObjectSet(s,OBJPROP_COLOR,BotColor);
         ObjectSet(s,OBJPROP_WIDTH,Price_Width); 

         s = TAG+"DNFILL"+tf+i;
         ObjectCreate(s,OBJ_RECTANGLE,0,0,0,0,0);
         ObjectSet(s,OBJPROP_TIME1,t1);
         ObjectSet(s,OBJPROP_PRICE1,p2);
         ObjectSet(s,OBJPROP_TIME2,t2);
         ObjectSet(s,OBJPROP_PRICE2,BuferUp[i]);
         ObjectSet(s,OBJPROP_COLOR,BotColor);
         ObjectSet(s,OBJPROP_BACK,Colored);
         ObjectSet(s,OBJPROP_WIDTH,Width);
      }
   }
}

bool NewBar() {

   static datetime LastTime = 0;

   if (iTime(pair,tf,0) != LastTime) {
      LastTime = iTime(pair,tf,0);      
      return (true);
   } else
      return (false);
}

void ObDeleteObjectsByPrefix(string Prefix)
{
   int L = StringLen(Prefix);
   int i = 0;
   while(i < ObjectsTotal())
   {
      string ObjName = ObjectName(i);
      if(StringSubstr(ObjName, 0, L) != Prefix)
      {
         i++;
         continue;
      }
      ObjectDelete(ObjName);
   }
}

void CountZZ( double& ExtMapBuffer[], double& ExtMapBuffer2[], int ExtDepth, int ExtDeviation, int ExtBackstep )
{
   int    shift, back,lasthighpos,lastlowpos;
   double val,res;
   double curlow,curhigh,lasthigh,lastlow;
   int count = iBars(pair,tf)-ExtDepth;

   for(shift=count; shift>=0; shift--)
     {
      val = iLow(pair,tf,iLowest(pair,tf,MODE_LOW,ExtDepth,shift));
      if(val==lastlow) val=0.0;
      else
        {
         lastlow=val;
         if((iLow(pair,tf,shift)-val)>(ExtDeviation*Point)) val=0.0;
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
      val=iHigh(pair,tf,iHighest(pair,tf,MODE_HIGH,ExtDepth,shift));
     
      if(val==lasthigh) val=0.0;
      else
        {
         lasthigh=val;
         if((val-iHigh(pair,tf,shift))>(ExtDeviation*Point)) val=0.0;
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

   for(shift=count; shift>=0; shift--)
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
 
   for(shift=iBars(pair,tf)-1; shift>=0; shift--)
   {
      if(shift>=count) ExtMapBuffer[shift]=0.0;
         else
         {
            res=ExtMapBuffer2[shift];
            if(res!=0.0) ExtMapBuffer2[shift]=res;
         }
   }
}

void GetValid()
{
   upcur = 0;
   int upbar = 0;
   dncur = 0;
   int dnbar = 0;
   double curhi = 0;
   double curlo = 0;
   double lastup = 0;
   double lastdn = 0;
   double lowdn = 0;
   double hiup = 0;
   int i;
   for(i=0;i<iBars(pair,tf);i++)
   {
      if(BuferUp[i] > 0)
      {
         upcur = BuferUp[i];
         curlo = BuferUp[i];
         lastup = curlo;
         break;
      }
   }
   for(i=0;i<iBars(pair,tf);i++)
   {
      if(BuferDn[i] > 0)
      {
         dncur = BuferDn[i];
         curhi = BuferDn[i];
         lastdn = curhi;
         break;
      }
   }

   for(i=0;i<iBars(pair,tf);i++) // remove higher lows and lower highs
   {
      if(BuferDn[i] >= lastdn)
      {
         lastdn = BuferDn[i];
         dnbar = i;
      }
         else BuferDn[i] = 0.0;
     
      if(BuferDn[i] <= dncur && BuferUp[i] > 0.0) BuferDn[i] = 0.0;

      if(BuferUp[i] <= lastup && BuferUp[i] > 0)
      {
         lastup = BuferUp[i];
         upbar = i;
      }
         else BuferUp[i] = 0.0;
     
      if(BuferUp[i] > upcur) BuferUp[i] = 0.0;

   }

   if(killretouch)
   {
      if(usenarrowbands)
      {
         lowdn = MathMax(iOpen(pair,tf,dnbar),iClose(pair,tf,dnbar));
         hiup = MathMin(iOpen(pair,tf,upbar),iClose(pair,tf,upbar));
      }
         else
         {
            lowdn = MathMin(iOpen(pair,tf,dnbar),iClose(pair,tf,dnbar));
            hiup = MathMax(iOpen(pair,tf,upbar),iClose(pair,tf,upbar));         
         }

      for(i=MathMax(upbar,dnbar);i>=0;i--) // work back to zero and remove reentries into s/d
      {
         if(BuferDn[i] > lowdn && BuferDn[i] != lastdn) BuferDn[i] = 0.0;
            else if(usenarrowbands && BuferDn[i] > 0)
            {
               lowdn = MathMax(iOpen(pair,tf,i),iClose(pair,tf,i));
               lastdn = BuferDn[i];
            }
               else if(BuferDn[i] > 0)
               {
                  lowdn = MathMin(iOpen(pair,tf,i),iClose(pair,tf,i));
                  lastdn = BuferDn[i];
               }

         if(BuferUp[i] <= hiup && BuferUp[i] > 0 && BuferUp[i] != lastup) BuferUp[i] = 0.0;
            else if(usenarrowbands && BuferUp[i] > 0)
            {
               hiup = MathMin(iOpen(pair,tf,i),iClose(pair,tf,i));
               lastup = BuferUp[i];
            }
               else if(BuferUp[i] > 0)
               {
                  hiup = MathMax(iOpen(pair,tf,i),iClose(pair,tf,i));
                  lastup = BuferUp[i];
               }
      }
   }
}  