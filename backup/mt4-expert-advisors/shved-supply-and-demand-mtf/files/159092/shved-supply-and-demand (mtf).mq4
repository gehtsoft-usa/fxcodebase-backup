//Available @  https://fxcodebase.com/ 

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright ©  2025, Gehtsoft USA LLC  | 
// |                                                                         http://fxcodebase.com  |
// |                                                               Paypal:  https://goo.gl/9Rj74e   |
// +------------------------------------------------------------------------------------------------+
// |                                                                   Developed by : Mario Jemic   |                    
// |                                                                       mario.jemic@gmail.com    |
// |                                                                       https://mario-jemic.com/ | 
// |                                                             Patreon :  http://tiny.cc/1ybwxz   |   
// |                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
// +-----------------+----------------------+-------------------------------------------------------+
// |  Cryptocurrency |  Network             |  Address                                              |
// +-----------------+----------------------+-------------------------------------------------------+
// |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                   | 
// |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2         | 
// |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           |
// |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// +-----------------+----------------------+-------------------------------------------------------+ 


#property copyright "Copyright © 2025, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
#property description "edited by eevviill"
#property description "on-off zones,build 600+,nearest zones in buffers"

#property indicator_chart_window
#property indicator_buffers 8
#property indicator_color1  clrRed
#property indicator_color2  clrRed
#property indicator_color3  clrDodgerBlue
#property indicator_color4  clrDodgerBlue


//
//
//

enum enTimeFrames
{
         tf_cu  = 0,                                                 // Current time frame
         tf_m1  = PERIOD_M1,                                         // 1 minute
         tf_m5  = PERIOD_M5,                                         // 5 minutes
         tf_m15 = PERIOD_M15,                                        // 15 minutes
         tf_m30 = PERIOD_M30,                                        // 30 minutes
         tf_h1  = PERIOD_H1,                                         // 1 hour
         tf_h4  = PERIOD_H4,                                         // 4 hours
         tf_d1  = PERIOD_D1,                                         // Daily
         tf_w1  = PERIOD_W1,                                         // Weekly
         tf_mn1 = PERIOD_MN1,                                        // Monthly
         tf_n1  = -1,                                                // First higher time frame
         tf_n2  = -2,                                                // Second higher time frame
         tf_n3  = -3,                                                // Third higher time frame
         tf_cus = 12345678                                           // Custom time frame
      };
input enTimeFrames inpTimeFrame      = tf_cu;                 // Time frame to use
input int         inpTimeFrameCustom = 0;                     // Custom time frame to use (if custom time frame used)  
extern int    BackLimit              = 1000;
extern bool   zone_show_weak         = true;
extern bool   zone_show_untested     = true;
extern bool   zone_show_turncoat     = false;
extern double zone_fuzzfactor        = 0.75;
extern bool   fractals_show          = false;
extern double fractal_fast_factor    = 3.0;
extern double fractal_slow_factor    = 6.0;
extern bool   SetGlobals             = true;
extern bool   zone_solid             = true;
extern int    zone_linewidth         = 1;
extern int    zone_style             = 0;
extern bool   zone_show_info         = true;
extern int    zone_label_shift       = 4;
extern bool   zone_merge             = true;
extern bool   zone_extend            = true;
extern bool   zone_show_alerts       = false;
extern bool   zone_alert_popups      = true;
extern bool   zone_alert_sounds      = true;
extern int    zone_alert_waitseconds = 300;
extern int    Text_size              = 8;
extern string Text_font              = "Courier New";
extern color  Text_color             = clrWhite;
extern string sup_name               = "Sup";
extern string res_name               = "Res";
extern string test_name              = "Retests";
extern color  color_support_weak     = clrDarkSlateGray;
extern color  color_support_untested = clrSeaGreen;
extern color  color_support_verified = clrGreen;
extern color  color_support_proven   = clrLimeGreen;
extern color  color_support_turncoat = clrOliveDrab;
extern color  color_resist_weak      = clrIndigo;
extern color  color_resist_untested  = clrOrchid;
extern color  color_resist_verified  = clrCrimson;
extern color  color_resist_proven    = clrRed;
extern color  color_resist_turncoat  = clrDarkOrange;

double FastDnPts[],FastUpPts[],SlowDnPts[],SlowUpPts[],count[];
double ner_lo_zone_P1[],ner_lo_zone_P2[],ner_hi_zone_P1[],ner_hi_zone_P2[];

double zone_hi[1000],zone_lo[1000];
int    zone_start[1000],zone_hits[1000],zone_type[1000],zone_strength[1000],zone_count=0;
bool   zone_turn[1000];

#define ZONE_SUPPORT 1
#define ZONE_RESIST  2

#define ZONE_WEAK      0
#define ZONE_TURNCOAT  1
#define ZONE_UNTESTED  2
#define ZONE_VERIFIED  3
#define ZONE_PROVEN    4

#define UP_POINT 1
#define DN_POINT -1

int time_offset=0;
struct sGlobalStruct
{
   string indicatorFileName;
   int    indicatorTimeFrame;
   int    tfcustom;
};
sGlobalStruct global;
#define _mtfCall(_buff,_ind) iCustom(_Symbol,global.indicatorTimeFrame,global.indicatorFileName,tf_cu,0,BackLimit,zone_show_weak,zone_show_untested,zone_show_turncoat,zone_fuzzfactor,fractals_show,fractal_fast_factor,fractal_slow_factor,SetGlobals,zone_solid,zone_linewidth,zone_style,zone_show_info,zone_label_shift,zone_merge,zone_extend,zone_show_alerts,zone_alert_popups,zone_alert_sounds,zone_alert_waitseconds,Text_size,Text_font,Text_color,sup_name,res_name,test_name,color_support_weak,color_support_untested,color_support_verified,color_support_proven,color_support_turncoat,color_resist_weak,color_resist_untested,color_resist_verified,color_resist_proven,color_resist_turncoat,_buff,_ind)


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int init()
{
   IndicatorDigits(_Digits);
   IndicatorBuffers(9);
   SetIndexBuffer(0,SlowDnPts);      SetIndexStyle(0,!fractals_show ? DRAW_NONE : DRAW_ARROW,0,3); SetIndexArrow(0,218);
   SetIndexBuffer(1,SlowUpPts);      SetIndexStyle(1,!fractals_show ? DRAW_NONE : DRAW_ARROW,0,3); SetIndexArrow(1,217);
   SetIndexBuffer(2,FastDnPts);      SetIndexStyle(2,!fractals_show ? DRAW_NONE : DRAW_ARROW,0,1); SetIndexArrow(2,218);
   SetIndexBuffer(3,FastUpPts);      SetIndexStyle(3,!fractals_show ? DRAW_NONE : DRAW_ARROW,0,1); SetIndexArrow(3,217);
   SetIndexBuffer(4,ner_hi_zone_P1); SetIndexStyle(4,DRAW_NONE); SetIndexLabel(4,"ner up zone P1");
   SetIndexBuffer(5,ner_hi_zone_P2); SetIndexStyle(5,DRAW_NONE); SetIndexLabel(5,"ner up zone P2");
   SetIndexBuffer(6,ner_lo_zone_P1); SetIndexStyle(6,DRAW_NONE); SetIndexLabel(6,"ner dn zone P1");
   SetIndexBuffer(7,ner_lo_zone_P2); SetIndexStyle(7,DRAW_NONE); SetIndexLabel(7,"ner dn zone P2");
   SetIndexBuffer(8,count);

   global.indicatorFileName = WindowExpertName();
   if (inpTimeFrameCustom==0) global.tfcustom =(enTimeFrames)timeFrameValue(inpTimeFrameCustom);
   global.indicatorTimeFrame = (inpTimeFrame!=tf_cus) ? (enTimeFrames)timeFrameValue(inpTimeFrame) : (enTimeFrames)inpTimeFrameCustom;

return(0);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int deinit()
  {
   DeleteZones();
   DeleteGlobalVars();
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
{
   int counted_bars=IndicatorCounted();
      if(counted_bars<0) return(-1);
      if(counted_bars>0) counted_bars--;
         int limit = fmin(Bars-counted_bars,Bars-1); count[0] = limit;
         
         //
         //
         //
         
         if (global.indicatorTimeFrame != _Period)
         {
            limit = (int)MathMax(limit,fmin(Bars-1,_mtfCall(8,0)*global.indicatorTimeFrame/_Period));
            for(int i=limit; i>=0 && !_StopFlag; i--)
            {
               int y = iBarShift(NULL,global.indicatorTimeFrame,Time[i]);
                  SlowDnPts[i]      = _mtfCall(0,y);
                  SlowUpPts[i]      = _mtfCall(1,y);
                  FastDnPts[i]      = _mtfCall(2,y);
                  FastUpPts[i]      = _mtfCall(3,y);
                  ner_hi_zone_P1[i] = _mtfCall(4,y);
                  ner_hi_zone_P2[i] = _mtfCall(5,y);
                  ner_lo_zone_P1[i] = _mtfCall(6,y);
                  ner_lo_zone_P2[i] = _mtfCall(7,y);             
            }
   return(0);
   }  
   
   //
   //
   //
   
   if(NewBar()==true)
     {
      int old_zone_count=zone_count;

      FastFractals();
      SlowFractals();
      DeleteZones();
      FindZones();
      DrawZones();
      if(zone_count<old_zone_count)
         DeleteOldGlobalVars(old_zone_count);
     }

   if(zone_show_info==true)
     {
      for(i=0; i<zone_count; i++)
        {
         string lbl;
         if(zone_strength[i]==ZONE_PROVEN)
            lbl=timeFrameToString(global.indicatorTimeFrame)+" Proven";
         else if(zone_strength[i]==ZONE_VERIFIED)
            lbl=timeFrameToString(global.indicatorTimeFrame)+" Verified";
         else if(zone_strength[i]==ZONE_UNTESTED)
            lbl=timeFrameToString(global.indicatorTimeFrame)+" Untested";
         else if(zone_strength[i]==ZONE_TURNCOAT)
            lbl=timeFrameToString(global.indicatorTimeFrame)+" Turncoat";
         else
            lbl=timeFrameToString(global.indicatorTimeFrame)+" Weak";

         if(zone_type[i]==ZONE_SUPPORT)
            lbl=lbl+" "+sup_name;
         else
            lbl=lbl+" "+res_name;

         if(zone_hits[i]>0 && zone_strength[i]>ZONE_UNTESTED)
           {
            if(zone_hits[i]==1)
               lbl=lbl+", "+test_name+"="+zone_hits[i];
            else
               lbl=lbl+", "+test_name+"="+zone_hits[i];
           }

         int adjust_hpos;
         int wbpc=WindowBarsPerChart();
         int k=_Period*60+(20+StringLen(lbl));

         if(wbpc<80)
            adjust_hpos=Time[0]+k*4;
         else if(wbpc<125)
            adjust_hpos=Time[0]+k*8;
         else if(wbpc<250)
            adjust_hpos=Time[0]+k*15;
         else if(wbpc<480)
            adjust_hpos=Time[0]+k*29;
         else if(wbpc<950)
            adjust_hpos=Time[0]+k*58;
         else
            adjust_hpos=Time[0]+k*115;

         //

         int shift=k*zone_label_shift;
         double vpos=zone_hi[i]-(zone_hi[i]-zone_lo[i])/2;

         if(zone_strength[i]==ZONE_WEAK && zone_show_weak==false)
            continue;
         if(zone_strength[i]==ZONE_UNTESTED && zone_show_untested==false)
            continue;
         if(zone_strength[i]==ZONE_TURNCOAT && zone_show_turncoat==false)
            continue;

         string s="SSSR#"+i+"LBL";
         ObjectCreate(s,OBJ_TEXT,0,0,0);
         ObjectSet(s,OBJPROP_TIME1,adjust_hpos+shift);
         ObjectSet(s,OBJPROP_PRICE1,vpos);
         ObjectSetText(s,StringRightPad(lbl,36," "),Text_size,Text_font,Text_color);
        }
     }

   CheckAlerts();

   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CheckAlerts()
  {
   static int lastalert=0;

   if(zone_show_alerts==false)
      return;

   if(Time[0]-lastalert>zone_alert_waitseconds)
      if(CheckEntryAlerts()==true)
         lastalert=Time[0];
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CheckEntryAlerts()
  {
// check for entries
   for(int i=0; i<zone_count; i++)
     {
      if(Close[0]>=zone_lo[i] && Close[0]<zone_hi[i])
        {
         if(zone_show_alerts==true)
           {
            if(zone_alert_popups==true)
              {
               if(zone_type[i]==ZONE_SUPPORT)
                  Alert(_Symbol+timeFrameToString(_Period)+": Support Zone Entered");
               else
                  Alert(_Symbol+timeFrameToString(_Period)+": Resistance Zone Entered");
              }

            if(zone_alert_sounds==true)
               PlaySound("alert_wav");
           }

         return(true);
        }
     }

   return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DeleteGlobalVars()
  {
   if(SetGlobals==false)
      return;

   GlobalVariableDel("SSSR_Count_"+Symbol()+Period());
   GlobalVariableDel("SSSR_Updated_"+Symbol()+Period());

   int old_count=zone_count;
   zone_count=0;
   DeleteOldGlobalVars(old_count);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DeleteOldGlobalVars(int old_count)
  {
   if(SetGlobals==false)
      return;

   for(int i=zone_count; i<old_count; i++)
     {
      GlobalVariableDel("SSSR_HI_"+Symbol()+Period()+i);
      GlobalVariableDel("SSSR_LO_"+Symbol()+Period()+i);
      GlobalVariableDel("SSSR_HITS_"+Symbol()+Period()+i);
      GlobalVariableDel("SSSR_STRENGTH_"+Symbol()+Period()+i);
      GlobalVariableDel("SSSR_AGE_"+Symbol()+Period()+i);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void FindZones()
  {
   int i,j,shift,bustcount=0,testcount=0;
   double hival,loval;
   bool turned=false,hasturned=false;

   double temp_hi[1000],temp_lo[1000];
   int    temp_start[1000],temp_hits[1000],temp_strength[1000],temp_count=0;
   bool   temp_turn[1000],temp_merge[1000];
   int merge1[1000],merge2[1000],merge_count=0;

// iterate through zones from oldest to youngest (ignore recent 5 bars),
// finding those that have survived through to the present___
   for(shift=MathMin(Bars-1,BackLimit); shift>5; shift--)
     {
      double atr= iATR(NULL,0,7,shift);
      double fu = atr/2 * zone_fuzzfactor;
      bool isWeak;
      bool touchOk= false;
      bool isBust = false;

      if(FastUpPts[shift]>0.001)
        {
         // a zigzag high point
         isWeak=true;
         if(SlowUpPts[shift]>0.001)
            isWeak=false;

         hival=High[shift];
         if(zone_extend==true)
            hival+=fu;

         loval=MathMax(MathMin(Close[shift],High[shift]-fu),High[shift]-fu*2);
         turned=false;
         hasturned=false;
         isBust=false;

         bustcount = 0;
         testcount = 0;

         for(i=shift-1; i>=0; i--)
           {
            if((turned==false && FastUpPts[i]>=loval && FastUpPts[i]<=hival) || 
               (turned==true && FastDnPts[i]<=hival && FastDnPts[i]>=loval))
              {
               // Potential touch, just make sure its been 10+candles since the prev one
               touchOk=true;
               for(j=i+1; j<i+11; j++)
                 {
                  if((turned==false && FastUpPts[j]>=loval && FastUpPts[j]<=hival) || 
                     (turned==true && FastDnPts[j]<=hival && FastDnPts[j]>=loval))
                    {
                     touchOk=false;
                     break;
                    }
                 }

               if(touchOk==true)
                 {
                  // we have a touch_  If its been busted once, remove bustcount
                  // as we know this level is still valid & has just switched sides
                  bustcount=0;
                  testcount++;
                 }
              }

            if((turned==false && High[i]>hival) || 
               (turned==true && Low[i]<loval))
              {
               // this level has been busted at least once
               bustcount++;

               if(bustcount>1 || isWeak==true)
                 {
                  // busted twice or more
                  isBust=true;
                  break;
                 }

               if(turned == true)
                  turned = false;
               else if(turned==false)
                  turned=true;

               hasturned=true;

               // forget previous hits
               testcount=0;
              }
           }

         if(isBust==false)
           {
            // level is still valid, add to our list
            temp_hi[temp_count] = hival;
            temp_lo[temp_count] = loval;
            temp_turn[temp_count] = hasturned;
            temp_hits[temp_count] = testcount;
            temp_start[temp_count] = shift;
            temp_merge[temp_count] = false;

            if(testcount>3)
               temp_strength[temp_count]=ZONE_PROVEN;
            else if(testcount>0)
               temp_strength[temp_count]=ZONE_VERIFIED;
            else if(hasturned==true)
               temp_strength[temp_count]=ZONE_TURNCOAT;
            else if(isWeak==false)
               temp_strength[temp_count]=ZONE_UNTESTED;
            else
               temp_strength[temp_count]=ZONE_WEAK;

            temp_count++;
           }
        }
      else if(FastDnPts[shift]>0.001)
        {
         // a zigzag low point
         isWeak=true;
         if(SlowDnPts[shift]>0.001)
            isWeak=false;

         loval=Low[shift];
         if(zone_extend==true)
            loval-=fu;

         hival=MathMin(MathMax(Close[shift],Low[shift]+fu),Low[shift]+fu*2);
         turned=false;
         hasturned=false;

         bustcount = 0;
         testcount = 0;
         isBust=false;

         for(i=shift-1; i>=0; i--)
           {
            if((turned==true && FastUpPts[i]>=loval && FastUpPts[i]<=hival) || 
               (turned==false && FastDnPts[i]<=hival && FastDnPts[i]>=loval))
              {
               // Potential touch, just make sure its been 10+candles since the prev one
               touchOk=true;
               for(j=i+1; j<i+11; j++)
                 {
                  if((turned==true && FastUpPts[j]>=loval && FastUpPts[j]<=hival) || 
                     (turned==false && FastDnPts[j]<=hival && FastDnPts[j]>=loval))
                    {
                     touchOk=false;
                     break;
                    }
                 }

               if(touchOk==true)
                 {
                  // we have a touch_  If its been busted once, remove bustcount
                  // as we know this level is still valid & has just switched sides
                  bustcount=0;
                  testcount++;
                 }
              }

            if((turned==true && High[i]>hival) || 
               (turned==false && Low[i]<loval))
              {
               // this level has been busted at least once
               bustcount++;

               if(bustcount>1 || isWeak==true)
                 {
                  // busted twice or more
                  isBust=true;
                  break;
                 }

               if(turned == true)
                  turned = false;
               else if(turned==false)
                  turned=true;

               hasturned=true;

               // forget previous hits
               testcount=0;
              }
           }

         if(isBust==false)
           {
            // level is still valid, add to our list
            temp_hi[temp_count] = hival;
            temp_lo[temp_count] = loval;
            temp_turn[temp_count] = hasturned;
            temp_hits[temp_count] = testcount;
            temp_start[temp_count] = shift;
            temp_merge[temp_count] = false;

            if(testcount>3)
               temp_strength[temp_count]=ZONE_PROVEN;
            else if(testcount>0)
               temp_strength[temp_count]=ZONE_VERIFIED;
            else if(hasturned==true)
               temp_strength[temp_count]=ZONE_TURNCOAT;
            else if(isWeak==false)
               temp_strength[temp_count]=ZONE_UNTESTED;
            else
               temp_strength[temp_count]=ZONE_WEAK;

            temp_count++;
           }
        }
     }

// look for overlapping zones___
   if(zone_merge==true)
     {
      merge_count=1;
      int iterations=0;
      while(merge_count>0 && iterations<3)
        {
         merge_count=0;
         iterations++;

         for(i=0; i<temp_count; i++)
            temp_merge[i]=false;

         for(i=0; i<temp_count-1; i++)
           {
            if(temp_hits[i]==-1 || temp_merge[j]==true)
               continue;

            for(j=i+1; j<temp_count; j++)
              {
               if(temp_hits[j]==-1 || temp_merge[j]==true)
                  continue;

               if((temp_hi[i]>=temp_lo[j] && temp_hi[i]<=temp_hi[j]) || 
                  (temp_lo[i] <= temp_hi[j] && temp_lo[i] >= temp_lo[j]) ||
                  (temp_hi[j] >= temp_lo[i] && temp_hi[j] <= temp_hi[i]) ||
                  (temp_lo[j] <= temp_hi[i] && temp_lo[j] >= temp_lo[i]))
                 {
                  merge1[merge_count] = i;
                  merge2[merge_count] = j;
                  temp_merge[i] = true;
                  temp_merge[j] = true;
                  merge_count++;
                 }
              }
           }

         // ___ and merge them ___
         for(i=0; i<merge_count; i++)
           {
            int target = merge1[i];
            int source = merge2[i];

            temp_hi[target] = MathMax(temp_hi[target], temp_hi[source]);
            temp_lo[target] = MathMin(temp_lo[target], temp_lo[source]);
            temp_hits[target] += temp_hits[source];
            temp_start[target] = MathMax(temp_start[target], temp_start[source]);
            temp_strength[target]=MathMax(temp_strength[target],temp_strength[source]);
            if(temp_hits[target]>3)
               temp_strength[target]=ZONE_PROVEN;

            if(temp_hits[target]==0 && temp_turn[target]==false)
              {
               temp_hits[target]=1;
               if(temp_strength[target]<ZONE_VERIFIED)
                  temp_strength[target]=ZONE_VERIFIED;
              }

            if(temp_turn[target] == false || temp_turn[source] == false)
               temp_turn[target] = false;
            if(temp_turn[target] == true)
               temp_hits[target] = 0;

            temp_hits[source]=-1;
           }
        }
     }

// copy the remaining list into our official zones arrays
   zone_count=0;
   for(i=0; i<temp_count; i++)
     {
      if(temp_hits[i]>=0 && zone_count<1000)
        {
         zone_hi[zone_count]       = temp_hi[i];
         zone_lo[zone_count]       = temp_lo[i];
         zone_hits[zone_count]     = temp_hits[i];
         zone_turn[zone_count]     = temp_turn[i];
         zone_start[zone_count]    = temp_start[i];
         zone_strength[zone_count] = temp_strength[i];

         if(zone_hi[zone_count]<Close[4])
            zone_type[zone_count]=ZONE_SUPPORT;
         else if(zone_lo[zone_count]>Close[4])
            zone_type[zone_count]=ZONE_RESIST;
         else
           {
            for(j=5; j<1000; j++)
              {
               if(Close[j]<zone_lo[zone_count])
                 {
                  zone_type[zone_count]=ZONE_RESIST;
                  break;
                 }
               else if(Close[j]>zone_hi[zone_count])
                 {
                  zone_type[zone_count]=ZONE_SUPPORT;
                  break;
                 }
              }

            if(j==1000)
               zone_type[zone_count]=ZONE_SUPPORT;
           }

         zone_count++;
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawZones()
  {
   double lower_nerest_zone_P1=0;
   double lower_nerest_zone_P2=0;
   double higher_nerest_zone_P1=EMPTY_VALUE;
   double higher_nerest_zone_P2=EMPTY_VALUE;

   if(SetGlobals==true)
     {
      GlobalVariableSet("SSSR_Count_"+Symbol()+Period(),zone_count);
      GlobalVariableSet("SSSR_Updated_"+Symbol()+Period(),TimeCurrent());
     }

   for(int i=0; i<zone_count; i++)
     {
      if(zone_strength[i]==ZONE_WEAK && zone_show_weak==false)
         continue;

      if(zone_strength[i]==ZONE_UNTESTED && zone_show_untested==false)
         continue;

      if(zone_strength[i]==ZONE_TURNCOAT && zone_show_turncoat==false)
         continue;

      //name sup
      if(zone_type[i]==ZONE_SUPPORT)
         string s="SSSR#S"+i+" Strength=";
      else
      //name res
         s="SSSR#R"+i+" Strength=";

      if(zone_strength[i]==ZONE_PROVEN)
         s=s+"Proven, Test Count="+zone_hits[i];
      else if(zone_strength[i]==ZONE_VERIFIED)
         s=s+"Verified, Test Count="+zone_hits[i];
      else if(zone_strength[i]==ZONE_UNTESTED)
         s=s+"Untested";
      else if(zone_strength[i]==ZONE_TURNCOAT)
         s=s+"Turncoat";
      else
         s=s+"Weak";

      ObjectCreate(s,OBJ_RECTANGLE,0,0,0,0,0);
      ObjectSet(s,OBJPROP_TIME1,Time[zone_start[i]]);
      ObjectSet(s,OBJPROP_TIME2,Time[0]);
      ObjectSet(s,OBJPROP_PRICE1,zone_hi[i]);
      ObjectSet(s,OBJPROP_PRICE2,zone_lo[i]);
      ObjectSet(s,OBJPROP_BACK,zone_solid);
      ObjectSet(s,OBJPROP_WIDTH,zone_linewidth);
      ObjectSet(s,OBJPROP_STYLE,zone_style);

      if(zone_type[i]==ZONE_SUPPORT)
        {
         // support zone
         if(zone_strength[i]==ZONE_TURNCOAT)
            ObjectSet(s,OBJPROP_COLOR,color_support_turncoat);
         else if(zone_strength[i]==ZONE_PROVEN)
            ObjectSet(s,OBJPROP_COLOR,color_support_proven);
         else if(zone_strength[i]==ZONE_VERIFIED)
            ObjectSet(s,OBJPROP_COLOR,color_support_verified);
         else if(zone_strength[i]==ZONE_UNTESTED)
            ObjectSet(s,OBJPROP_COLOR,color_support_untested);
         else
            ObjectSet(s,OBJPROP_COLOR,color_support_weak);
        }
      else
        {
         // resistance zone
         if(zone_strength[i]==ZONE_TURNCOAT)
            ObjectSet(s,OBJPROP_COLOR,color_resist_turncoat);
         else if(zone_strength[i]==ZONE_PROVEN)
            ObjectSet(s,OBJPROP_COLOR,color_resist_proven);
         else if(zone_strength[i]==ZONE_VERIFIED)
            ObjectSet(s,OBJPROP_COLOR,color_resist_verified);
         else if(zone_strength[i]==ZONE_UNTESTED)
            ObjectSet(s,OBJPROP_COLOR,color_resist_untested);
         else
            ObjectSet(s,OBJPROP_COLOR,color_resist_weak);
        }


      if(SetGlobals==true)
        {
         GlobalVariableSet("SSSR_HI_"+Symbol()+Period()+i,zone_hi[i]);
         GlobalVariableSet("SSSR_LO_"+Symbol()+Period()+i,zone_lo[i]);
         GlobalVariableSet("SSSR_HITS_"+Symbol()+Period()+i,zone_hits[i]);
         GlobalVariableSet("SSSR_STRENGTH_"+Symbol()+Period()+i,zone_strength[i]);
         GlobalVariableSet("SSSR_AGE_"+Symbol()+Period()+i,zone_start[i]);
        }

      //nearest zones
      if(zone_lo[i]>lower_nerest_zone_P2 && Bid>zone_lo[i]) {lower_nerest_zone_P1=zone_hi[i];lower_nerest_zone_P2=zone_lo[i];}
      if(zone_hi[i]<higher_nerest_zone_P1 && Bid<zone_hi[i]) {higher_nerest_zone_P1=zone_hi[i];higher_nerest_zone_P2=zone_lo[i];}
     }

   ner_hi_zone_P1[0]=higher_nerest_zone_P1;
   ner_hi_zone_P2[0]=higher_nerest_zone_P2;
   ner_lo_zone_P1[0]=lower_nerest_zone_P1;
   ner_lo_zone_P2[0]=lower_nerest_zone_P2;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Fractal(int M,int P,int shift)
  {
   if(Period()>P)
      P=Period();

   P=P/Period()*2+MathCeil(P/Period()/2);

   if(shift<P)
      return(false);

   if(shift>Bars-P)
      return(false);

   for(int i=1; i<=P; i++)
     {
      if(M==UP_POINT)
        {
         if(High[shift+i]>High[shift])
            return(false);
         if(High[shift-i]>=High[shift])
            return(false);
        }
      if(M==DN_POINT)
        {
         if(Low[shift+i]<Low[shift])
            return(false);
         if(Low[shift-i]<=Low[shift])
            return(false);
        }
     }
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void FastFractals()
  {
   int shift;
   int limit=MathMin(Bars-1,BackLimit);
   int P=Period()*fractal_fast_factor;

   FastUpPts[0] = 0.0; FastUpPts[1] = 0.0;
   FastDnPts[0] = 0.0; FastDnPts[1] = 0.0;

   for(shift=limit; shift>1; shift--)
     {
      if(Fractal(UP_POINT,P,shift)==true)
         FastUpPts[shift]=High[shift];
      else
         FastUpPts[shift]=0.0;

      if(Fractal(DN_POINT,P,shift)==true)
         FastDnPts[shift]=Low[shift];
      else
         FastDnPts[shift]=0.0;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SlowFractals()
  {
   int shift;
   int limit=MathMin(Bars-1,BackLimit);
   int P=Period()*fractal_slow_factor;

   SlowUpPts[0] = 0.0; SlowUpPts[1] = 0.0;
   SlowDnPts[0] = 0.0; SlowDnPts[1] = 0.0;

   for(shift=limit; shift>1; shift--)
     {
      if(Fractal(UP_POINT,P,shift)==true)
         SlowUpPts[shift]=High[shift];
      else
         SlowUpPts[shift]=0.0;

      if(Fractal(DN_POINT,P,shift)==true)
         SlowDnPts[shift]=Low[shift];
      else
         SlowDnPts[shift]=0.0;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool NewBar()
  {
   static datetime LastTime=0;
   if(iTime(Symbol(),Period(),0)+time_offset!=LastTime)
     {
      LastTime=iTime(Symbol(),Period(),0)+time_offset;
      return (true);
     }
   else
      return (false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DeleteZones()
  {
   int len=5;
   int i;

   while(i<ObjectsTotal())
     {
      string objName=ObjectName(i);
      if(StringSubstr(objName,0,len)!="SSSR#")
        {
         i++;
         continue;
        }
      ObjectDelete(objName);
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string StringRepeat(string str,int n=1)
  {
   string outstr="";
   for(int i=0; i<n; i++) outstr=outstr+str;
   return(outstr);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string StringRightPad(string str,int n=1,string str2=" ")
  {
   return(str + StringRepeat(str2,n-StringLen(str)));
  }
//+------------------------------------------------------------------+

//-------------------------------------------------------------------
//
//-------------------------------------------------------------------

string sTfTable[] = {"M1","M5","M15","M30","H1","H4","D1","W1","MN"};
int    iTfTable[] = {1,5,15,30,60,240,1440,10080,43200};

string timeFrameToString(int tf)
{
   for (int i=ArraySize(iTfTable)-1; i>=0; i--) 
         if (tf==iTfTable[i]) return(sTfTable[i]);
                              return("");
}
int timeFrameValue(int _tf)
{
   int add  = (_tf>=0) ? 0 : fabs(_tf);
   if (add != 0) _tf = _Period;
   int size = ArraySize(iTfTable); 
      int i =0; for (;i<size; i++) if (iTfTable[i]==_tf) break;
                                   if (i==size) return(_Period);
                                                return(iTfTable[(int)fmin(i+add,size-1)]);
}
//Available @  https://fxcodebase.com/ 

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright ©  2025, Gehtsoft USA LLC  | 
// |                                                                         http://fxcodebase.com  |
// |                                                               Paypal:  https://goo.gl/9Rj74e   |
// +------------------------------------------------------------------------------------------------+
// |                                                                   Developed by : Mario Jemic   |                    
// |                                                                       mario.jemic@gmail.com    |
// |                                                                       https://mario-jemic.com/ | 
// |                                                             Patreon :  http://tiny.cc/1ybwxz   |   
// |                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
// +-----------------+----------------------+-------------------------------------------------------+
// |  Cryptocurrency |  Network             |  Address                                              |
// +-----------------+----------------------+-------------------------------------------------------+
// |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                   | 
// |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2         | 
// |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           |
// |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// +-----------------+----------------------+-------------------------------------------------------+ 