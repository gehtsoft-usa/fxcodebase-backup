//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&p=160164#p160164

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
#property description "Supply & Demand Zones (build 600+)"
#property indicator_chart_window
#property indicator_buffers 2

//--- indicator buffers
double BuferUp1[];
double BuferDn1[];

input int     forced_tf            = 0;
input bool    draw_zones           = true;
input bool    solid_zones          = true;
input bool    solid_retouch        = true;
input bool    recolor_retouch      = true;
input bool    recolor_weak_retouch = false;
input bool    zone_strength        = true;
input bool    no_weak_zones        = true;
input bool    draw_edge_price      = true;
input color   edge_price_color     = White;
input int     zone_width           = 1;
input bool    zone_fibs            = false;
input int     fib_style            = 0;
input bool    HUD_on               = false;
input bool    timer_on             = false;
input int     layer_zone           = 0;
input int     layer_HUD            = 20;
input int     corner_HUD           = 2;
input int     pos_x                = 100;
input int     pos_y                = 20;
input bool    alert_on             = true;
input bool    alert_popup          = false;
input string  alert_sound          = "alert.wav";
input color   color_sup_strong     = IndianRed;
input color   color_sup_weak       = Olive;
input color   color_sup_retouch    = Aqua;
input color   color_dem_strong     = SteelBlue;
input color   color_dem_weak       = LightSteelBlue;
input color   color_dem_retouch    = Lime;
input color   color_fib            = DodgerBlue;
input color   color_HUD_tf         = White;
input color   color_arrow_up       = SeaGreen;
input color   color_arrow_dn       = Crimson;
input color   color_timer_back     = DarkGray;
input color   color_timer_bar      = Red;
input color   color_shadow         = DarkSlateGray;
input bool    limit_zone_vis       = false;
input bool    same_tf_vis          = true;
input bool    show_on_m1           = false;
input bool    show_on_m5           = true;
input bool    show_on_m15          = false;
input bool    show_on_m30          = false;
input bool    show_on_h1           = false;
input bool    show_on_h4           = false;
input bool    show_on_d1           = false;
input bool    show_on_w1           = false;
input bool    show_on_mn           = false;
input int     Price_Width          = 1;
input int     time_offset          = 0;
input bool    globals              = false;

double sup_RR[4];
double dem_RR[4];
double sup_width,dem_width;
string  l_hud,l_zone;
int     HUD_x;
string  font_HUD = "Comic Sans MS";
int     font_HUD_size = 20;
string  font_HUD_price = "Arial Bold";
int     font_HUD_price_size = 8;
int     arrow_UP = 0x70;
int     arrow_DN = 0x71;
string  font_arrow = "WingDings 3";
int     font_arrow_size = 40;
int     font_pair_size = 8;

string  arrow_glance;
color   color_arrow;
int     visible;
int     rotation=270;
int     lenbase;
string  s_base="|||||||||||||||||||||||";
string  timer_font="Arial Bold";
int     size_timer_font=8;

double  min,max;
double  iPeriod[4] = {3,8,13,34}; 
int     Dev[4]     = {2,5,8,13};
int     Step[4]    = {2,3,5,8};
datetime t1,t2;
double  p1,p2;
string  pair;
double  point;
int     digits;
int     tf;
string  TAG;

double fib_sup,fib_dem;
int    SupCount,DemCount;
int    SupAlert,DemAlert;
double up_cur,dn_cur;
double fib_level_array[13]={0,0.236,0.386,0.5,0.618,0.786,1,1.276,1.618,2.058,2.618,3.33,4.236};
string fib_level_desc[13] = {"0","23.6%","38.6%","50%","61.8%","78.6%","100%","127.6%","161.8%","205.8%","261.80%","333%","423.6%"};

int hud_timer_x,hud_timer_y,hud_arrow_x,hud_arrow_y,hud_tf_x,hud_tf_y;
int hud_sup_x,hud_sup_y,hud_dem_x,hud_dem_y;
int hud_timers_x,hud_timers_y,hud_arrows_x,hud_arrows_y,hud_tfs_x,hud_tfs_y;
int hud_sups_x,hud_sups_y,hud_dems_x,hud_dems_y;

int OnInit()
{
   SetIndexBuffer(1,BuferUp1,INDICATOR_DATA);
   PlotIndexSetInteger(1,PLOT_DRAW_TYPE,DRAW_NONE);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0.0);

   SetIndexBuffer(0,BuferDn1,INDICATOR_DATA);
   PlotIndexSetInteger(0,PLOT_DRAW_TYPE,DRAW_NONE);
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);

   int layer_HUD_eff  = MathMin(layer_HUD,25);
   l_hud  = (string)CharToString(0x61+layer_HUD_eff);
   int layer_zone_eff = MathMin(layer_zone,25);
   l_zone = (string)CharToString(0x61+layer_zone_eff);

   pair   = Symbol();   
   tf     = (forced_tf!=0 ? forced_tf : (int)Period());
   point  = _Point;
   digits = _Digits;
   if(digits==3 || digits==5) point*=10;

   TAG = HUD_on && !draw_zones ? "II_HUD"+string(tf) : "II_SupDem"+string(tf);
   lenbase = StringLen(s_base);

   if(HUD_on) setHUD();
   if(limit_zone_vis) setVisibility();
   ObDeleteObjectsByPrefix(l_hud+TAG);
   ObDeleteObjectsByPrefix(l_zone+TAG);

   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{
   ObDeleteObjectsByPrefix(l_hud+TAG);
   ObDeleteObjectsByPrefix(l_zone+TAG);
   Comment("");
}

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   Calculate();
   return(rates_total);
}

void Calculate()
{
   if(NewBar())
   {
      SupAlert = 1;
      DemAlert = 1;
      ObDeleteObjectsByPrefix(l_zone+TAG);
      CountZZ(BuferUp1,BuferDn1,(int)iPeriod[0],Dev[0],Step[0]);
      GetValid(BuferUp1,BuferDn1);
      Draw();
      if(HUD_on) HUD();
   }
   if(HUD_on && timer_on) BarTimer();
   if(alert_on)           CheckAlert();
}

//--------------------------------------------------------------------------------------
bool NewBar(){
   static datetime LastTime = 0;
   if(iTime(pair,(ENUM_TIMEFRAMES)tf,0)+time_offset != LastTime){
      LastTime = iTime(pair,(ENUM_TIMEFRAMES)tf,0)+time_offset;
      return true;
   }
   return false;
}
//--------------------------------------------------------------------------------------
void ObDeleteObjectsByPrefix(string Prefix){
   int L = StringLen(Prefix);
   long cid = ChartID();
   int total = (int)ObjectsTotal(cid,0,-1);
   for(int i=total-1;i>=0;i--){
      string ObjName = ObjectName(cid,i,0);
      if(StringSubstr(ObjName,0,L) == Prefix)
         ObjectDelete(cid,ObjName);
   }
}
//--------------------------------------------------------------------------------------
int CountZZ(double &ExtMapBuffer[], double &ExtMapBuffer2[], int ExtDepth, int ExtDeviation, int ExtBackstep){
   int shift,back,lasthighpos,lastlowpos;
   double val,res;
   double curlow,curhigh,lasthigh,lastlow; lasthigh=0.0; lastlow=0.0;
   int count = iBars(pair,(ENUM_TIMEFRAMES)tf)-ExtDepth;
   for(shift=count;shift>=0;shift--){
      val = iLow(pair,(ENUM_TIMEFRAMES)tf,iLowest(pair,(ENUM_TIMEFRAMES)tf,MODE_LOW,ExtDepth,shift));
      if(val==lastlow) val=0.0;
      else{
         lastlow=val;
         if((iLow(pair,(ENUM_TIMEFRAMES)tf,shift)-val)>(ExtDeviation*_Point)) val=0.0;
         else{
            for(back=1;back<=ExtBackstep;back++){
               res=ExtMapBuffer[shift+back];
               if((res!=0)&&(res>val)) ExtMapBuffer[shift+back]=0.0;
            }
         }
      }
      ExtMapBuffer[shift]=val;
      // high
      val = iHigh(pair,(ENUM_TIMEFRAMES)tf,iHighest(pair,(ENUM_TIMEFRAMES)tf,MODE_HIGH,ExtDepth,shift));
      if(val==lasthigh) val=0.0;
      else{
         lasthigh=val;
         if((val-iHigh(pair,(ENUM_TIMEFRAMES)tf,shift))>(ExtDeviation*_Point)) val=0.0;
         else{
            for(back=1;back<=ExtBackstep;back++){
               res=ExtMapBuffer2[shift+back];
               if((res!=0)&&(res<val)) ExtMapBuffer2[shift+back]=0.0;
            }
         }
      }
      ExtMapBuffer2[shift]=val;
   }
   lasthigh=-1; lasthighpos=-1;
   lastlow=-1;  lastlowpos=-1;
   for(shift=count;shift>=0;shift--){
      curlow=ExtMapBuffer[shift];
      curhigh=ExtMapBuffer2[shift];
      if((curlow==0)&&(curhigh==0)) continue;
      if(curhigh!=0){
         if(lasthigh>0){
            if(lasthigh<curhigh) ExtMapBuffer2[lasthighpos]=0;
            else ExtMapBuffer2[shift]=0;
         }
         if(lasthigh<curhigh || lasthigh<0){
            lasthigh=curhigh;
            lasthighpos=shift;
         }
         lastlow=-1;
      }
      if(curlow!=0){
         if(lastlow>0){
            if(lastlow>curlow) ExtMapBuffer[lastlowpos]=0;
            else ExtMapBuffer[shift]=0;
         }
         if((curlow<lastlow)||(lastlow<0)){
            lastlow=curlow;
            lastlowpos=shift;
         }
         lasthigh=-1;
      }
   }
   for(shift=iBars(pair,(ENUM_TIMEFRAMES)tf)-1;shift>=0;shift--){
      if(shift>=count) ExtMapBuffer[shift]=0.0;
      else{
         res=ExtMapBuffer2[shift];
         if(res!=0.0) ExtMapBuffer2[shift]=res;
      }
   }
   return 0;
}
//--------------------------------------------------------------------------------------
void CheckAlert(){
   string n1 = l_zone+TAG+"UPAR"+string(SupAlert);
   double price = GetObjectPrice1(n1);
   double close0 = iClose(pair,(ENUM_TIMEFRAMES)tf,0);
   if(close0 > price && price > point){
      if(alert_popup){
         string msg1 = pair+" "+TimeFrameToString(tf)+" Supply Zone Entered at "+DoubleToString(price,digits);
         Alert(msg1);
      }
      PlaySound(alert_sound);
      SupAlert++;
   }
   string n2 = l_zone+TAG+"DNAR"+string(DemAlert);
   price = GetObjectPrice1(n2);
   close0 = iClose(pair,(ENUM_TIMEFRAMES)tf,0);
   if(close0 < price){
      if(alert_popup){
         string msg2 = pair+" "+TimeFrameToString(tf)+" Demand Zone Entered at "+DoubleToString(price,digits);
         Alert(msg2);
      }
      PlaySound(alert_sound);
      DemAlert++;
   }
}
//--------------------------------------------------------------------------------------
void Draw(){
   int fib_sup_hit=0;
   int fib_dem_hit=0;
   int sc=0,dc=0; 
   int i=0,j=0,countstrong=0,countweak=0;
   color c;
   string s;
   bool exit,draw,fle,fhe,retouch;
   bool valid;
   double val;
   // vars for fib/HUD decisions
   int dr=0,sr=0,d1=0,s1=0;
   double a=0.0,b=0.0;
   fhe=false;
   fle=false;
   SupCount=0;
   DemCount=0;
   fib_sup=0;
   fib_dem=0;
   for(i=0;i<iBars(pair,(ENUM_TIMEFRAMES)tf);i++){
      if(BuferDn1[i] > point){
         retouch = false;
         valid = false;
         t1 = iTime(pair,(ENUM_TIMEFRAMES)tf,i);
         t2 = iTime(_Symbol,PERIOD_CURRENT,0);
         p2 = MathMin(iClose(pair,(ENUM_TIMEFRAMES)tf,i),iOpen(pair,(ENUM_TIMEFRAMES)tf,i));
         if(i>0) p2 = MathMax(p2,MathMax(iLow(pair,(ENUM_TIMEFRAMES)tf,i-1),iLow(pair,(ENUM_TIMEFRAMES)tf,i+1)));
         if(i>0) p2 = MathMax(p2,MathMin(iOpen(pair,(ENUM_TIMEFRAMES)tf,i-1),iClose(pair,(ENUM_TIMEFRAMES)tf,i-1)));
         p2 = MathMax(p2,MathMin(iOpen(pair,(ENUM_TIMEFRAMES)tf,i+1),iClose(pair,(ENUM_TIMEFRAMES)tf,i+1)));
         draw=true;
         if(recolor_retouch || !solid_retouch){
            exit = false;
            for(j=i;j>=0;j--){
               if(j==0 && !exit) {draw=false;break;}
               if(!exit && iHigh(pair,(ENUM_TIMEFRAMES)tf,j)<p2) {exit=true;continue;}
               if(exit && iHigh(pair,(ENUM_TIMEFRAMES)tf,j)>p2) {
                  retouch = true;
                  if(zone_fibs && fib_sup_hit==0){ fib_sup = p2; fib_sup_hit = j;}
                  break;
               }
            }
         }
         if(SupCount != 0) val = GetRectPrice2(TAG+"UPZONE"+string(SupCount)); else val=0;
         if(draw_zones && draw && BuferDn1[i]!=val) {
            valid=true;
            c = color_sup_strong;
            if(zone_strength && (retouch || !recolor_retouch)){
               countstrong=0;
               countweak=0;
               for(j=i;j<1000000;j++){
                  if(iHigh(pair,(ENUM_TIMEFRAMES)tf,j+1)<p2) countstrong++;
                  if(iHigh(pair,(ENUM_TIMEFRAMES)tf,j+1)>BuferDn1[i]) countweak++;
                  if(countstrong > 1) break;
                     else if(countweak > 1){
                        c=color_sup_weak;
                        if(no_weak_zones) draw = false;
                        break;
                     }                 
               }
            }
            if(draw){
               if(recolor_retouch && retouch && countweak<2) c = color_sup_retouch;
               else if(recolor_weak_retouch && retouch && countweak>1) c = color_sup_retouch;
               SupCount++;
               if(draw_edge_price){
                  s = l_zone+TAG+"UPAR"+string(SupCount);
                  long cid = ChartID();
                  ObjectCreate(cid,s,OBJ_ARROW_RIGHT_PRICE,0,0,0);
                  ObjectSetDouble (cid,s,OBJPROP_PRICE,0,p2);
                  ObjectSetInteger(cid,s,OBJPROP_COLOR,edge_price_color);
                  ObjectSetInteger(cid,s,OBJPROP_WIDTH,Price_Width);
                  if(limit_zone_vis) ObjectSetInteger(cid,s,OBJPROP_TIMEFRAMES,visible);
                  string sP = l_zone+TAG+"UPPRC"+string(SupCount);
                  if(ObjectFind(cid,sP)!=-1) ObjectDelete(cid,sP);
                  ObjectCreate(cid,sP,OBJ_TEXT,0,t2,p2);
                  ObjectSetString (cid,sP,OBJPROP_TEXT,DoubleToString(p2,digits));
                  ObjectSetInteger(cid,sP,OBJPROP_COLOR,edge_price_color);
                  ObjectSetInteger(cid,sP,OBJPROP_FONTSIZE,font_HUD_price_size);
                  ObjectSetString (cid,sP,OBJPROP_FONT,font_HUD_price);
                  ObjectSetInteger(cid,sP,OBJPROP_ANCHOR,ANCHOR_LEFT);
                  if(limit_zone_vis) ObjectSetInteger(cid,sP,OBJPROP_TIMEFRAMES,visible);
               }
               s = l_zone+TAG+"UPZONE"+string(SupCount);
               long cid2=ChartID();
               ObjectCreate(cid2,s,OBJ_RECTANGLE,0,t1,BuferDn1[i],t2,p2);
               ObjectSetInteger(cid2,s,OBJPROP_COLOR,c);
               ObjectSetInteger(cid2,s,OBJPROP_BACK,true);
               ObjectSetInteger(cid2,s,OBJPROP_FILL,true);
               if(limit_zone_vis) ObjectSetInteger(cid2,s,OBJPROP_TIMEFRAMES,visible);
               if(!solid_zones) {ObjectSetInteger(cid2,s,OBJPROP_BACK,false);ObjectSetInteger(cid2,s,OBJPROP_WIDTH,zone_width);}            
               if(!solid_retouch && retouch) {ObjectSetInteger(cid2,s,OBJPROP_BACK,false);ObjectSetInteger(cid2,s,OBJPROP_WIDTH,zone_width);}            
               if(globals){
                  GlobalVariableSet(TAG+"S_PH"+string(SupCount),BuferDn1[i]);
                  GlobalVariableSet(TAG+"S_PL"+string(SupCount),p2);
                  GlobalVariableSet(TAG+"S_T"+string(SupCount),iTime(pair,(ENUM_TIMEFRAMES)tf,i));
               }
               if(!fhe && c!=color_dem_retouch){fhe=true;GlobalVariableSet(TAG+"GOSHORT",p2);}            
            }
         }
         if(draw && sc<4 && HUD_on && valid){
            if(sc==0) sup_width = BuferDn1[i] - p2;
            sup_RR[sc] = p2;
            sc++;
         }
      }

      if(BuferUp1[i] > point){
         retouch = false;
         valid=false;
         t1 = iTime(pair,(ENUM_TIMEFRAMES)tf,i);
         t2 = iTime(_Symbol,PERIOD_CURRENT,0);
         p2 = MathMax(iClose(pair,(ENUM_TIMEFRAMES)tf,i),iOpen(pair,(ENUM_TIMEFRAMES)tf,i));
         if(i>0) p2 = MathMin(p2,MathMin(iHigh(pair,(ENUM_TIMEFRAMES)tf,i+1),iHigh(pair,(ENUM_TIMEFRAMES)tf,i-1)));
         if(i>0) p2 = MathMin(p2,MathMax(iOpen(pair,(ENUM_TIMEFRAMES)tf,i-1),iClose(pair,(ENUM_TIMEFRAMES)tf,i-1)));
         p2 = MathMin(p2,MathMax(iOpen(pair,(ENUM_TIMEFRAMES)tf,i+1),iClose(pair,(ENUM_TIMEFRAMES)tf,i+1)));
         c = color_dem_strong;
         draw=true;
         if(recolor_retouch || !solid_retouch){
            exit = false;
            for(j=i;j>=0;j--) {
               if(j==0 && !exit) {draw=false;break;}
               if(!exit && iLow(pair,(ENUM_TIMEFRAMES)tf,j)>p2) {exit=true;continue;}
               if(exit && iLow(pair,(ENUM_TIMEFRAMES)tf,j)<p2) {
                  retouch = true;
                  if(zone_fibs && fib_dem_hit==0){fib_dem = p2; fib_dem_hit = j; }
                  break;
               }
            }
         }
         if(DemCount != 0) val = GetRectPrice2(TAG+"DNZONE"+string(DemCount)); else val=0;
         if(draw_zones && draw && BuferUp1[i]!=val){
            valid = true;
            if(zone_strength && (retouch || !recolor_retouch)){
               countstrong=0;
               countweak=0;
               for(j=i;j<100000;j++){
                  if(iLow(pair,(ENUM_TIMEFRAMES)tf,j+1)>p2) countstrong++;
                  if(iLow(pair,(ENUM_TIMEFRAMES)tf,j+1)<BuferUp1[i]) countweak++;
                  if(countstrong > 1) break;
                     else if(countweak > 1){
                        if(no_weak_zones) draw = false;
                        c=color_dem_weak;
                        break;
                     }                 
               }
            }
            if(draw){
               if(recolor_retouch && retouch && countweak<2) c = color_dem_retouch;
               else if(recolor_weak_retouch && retouch && countweak>1) c = color_dem_retouch;
               DemCount++;
               if(draw_edge_price){
                  s = l_zone+TAG+"DNAR"+string(DemCount);
                  long cid3=ChartID();
                  ObjectCreate(cid3,s,OBJ_ARROW_RIGHT_PRICE,0,0,0);
                  ObjectSetDouble (cid3,s,OBJPROP_PRICE,0,p2);
                  ObjectSetInteger(cid3,s,OBJPROP_COLOR,edge_price_color);
                  ObjectSetInteger(cid3,s,OBJPROP_WIDTH,Price_Width);  
                  if(limit_zone_vis) ObjectSetInteger(cid3,s,OBJPROP_TIMEFRAMES,visible);
                  string dP = l_zone+TAG+"DNPRC"+string(DemCount);
                  if(ObjectFind(cid3,dP)!=-1) ObjectDelete(cid3,dP);
                  ObjectCreate(cid3,dP,OBJ_TEXT,0,t2,p2);
                  ObjectSetString (cid3,dP,OBJPROP_TEXT,DoubleToString(p2,digits));
                  ObjectSetInteger(cid3,dP,OBJPROP_COLOR,edge_price_color);
                  ObjectSetInteger(cid3,dP,OBJPROP_FONTSIZE,font_HUD_price_size);
                  ObjectSetString (cid3,dP,OBJPROP_FONT,font_HUD_price);
                  ObjectSetInteger(cid3,dP,OBJPROP_ANCHOR,ANCHOR_LEFT);
                  if(limit_zone_vis) ObjectSetInteger(cid3,dP,OBJPROP_TIMEFRAMES,visible);
               }
               s = l_zone+TAG+"DNZONE"+string(DemCount);
               long cid4=ChartID();
               ObjectCreate(cid4,s,OBJ_RECTANGLE,0,t1,p2,t2,BuferUp1[i]);
               ObjectSetInteger(cid4,s,OBJPROP_COLOR,c);
               ObjectSetInteger(cid4,s,OBJPROP_BACK,true);
               ObjectSetInteger(cid4,s,OBJPROP_FILL,true);
               if(limit_zone_vis) ObjectSetInteger(cid4,s,OBJPROP_TIMEFRAMES,visible);
               if(!solid_zones) {ObjectSetInteger(cid4,s,OBJPROP_BACK,false);ObjectSetInteger(cid4,s,OBJPROP_WIDTH,zone_width);}            
               if(!solid_retouch && retouch) {ObjectSetInteger(cid4,s,OBJPROP_BACK,false);ObjectSetInteger(cid4,s,OBJPROP_WIDTH,zone_width);}            
               if(globals){
                  GlobalVariableSet(TAG+"D_PL"+string(DemCount),BuferUp1[i]);
                  GlobalVariableSet(TAG+"D_PH"+string(DemCount),p2);
                  GlobalVariableSet(TAG+"D_T"+string(DemCount),iTime(pair,(ENUM_TIMEFRAMES)tf,i));
               }
               if(!fle && c!=color_dem_retouch){fle=true;GlobalVariableSet(TAG+"GOLONG",p2);}               
            }
         }
         if(draw && dc<4 && HUD_on && valid){
            if(dc==0) dem_width = p2-BuferUp1[i];
            dem_RR[dc] = p2;
            dc++;
         }
      }
   }

   if(zone_fibs || HUD_on){
      for(i=0;i<100000;i++){
         if(iHigh(pair,(ENUM_TIMEFRAMES)tf,i)>fib_sup && sr==0) sr = i;
         if(iHigh(pair,(ENUM_TIMEFRAMES)tf,i)>sup_RR[0] && s1==0) s1 = i;
         if(iLow(pair,(ENUM_TIMEFRAMES)tf,i)<fib_dem && dr==0) dr = i;
         if(iLow(pair,(ENUM_TIMEFRAMES)tf,i)<dem_RR[0] && d1==0) d1 = i;
         if(sr!=0&&s1!=0&&dr!=0&&d1!=0) break;
      }
   }
   if(zone_fibs){
      if(dr<sr) {b = fib_dem; a = sup_RR[0];}
      else      {b = fib_sup; a = dem_RR[0];}
      s = l_zone+TAG+"FIBO";
      long cid5=ChartID();
      ObjectCreate(cid5,s,OBJ_FIBO,0,iTime(_Symbol,PERIOD_CURRENT,0),a,iTime(_Symbol,PERIOD_CURRENT,0),b);
      ObjectSetInteger(cid5,s,OBJPROP_COLOR,CLR_NONE);
      ObjectSetInteger(cid5,s,OBJPROP_STYLE,fib_style);
      ObjectSetInteger(cid5,s,OBJPROP_RAY,true);
      ObjectSetInteger(cid5,s,OBJPROP_BACK,true);
      if(limit_zone_vis) ObjectSetInteger(cid5,s,OBJPROP_TIMEFRAMES,visible);
      int level_count=ArraySize(fib_level_array);
      ObjectSetInteger(cid5,s,OBJPROP_LEVELS,level_count);
      for(j=0;j<level_count;j++){
         ObjectSetDouble(cid5,s,OBJPROP_LEVELVALUE,j,fib_level_array[j]);
         ObjectSetString(cid5,s,OBJPROP_LEVELTEXT ,j,fib_level_desc[j]);
      }
   }
   if(HUD_on) {
      if(d1<s1) {b = dem_RR[0]; a = sup_RR[0]; arrow_glance = (string)CharToString(arrow_UP); color_arrow = color_arrow_up;}
      else      {b = sup_RR[0]; a = dem_RR[0]; arrow_glance = (string)CharToString(arrow_DN); color_arrow = color_arrow_dn;}
      min = MathMin(a,b);
      max = MathMax(a,b);
   }
}
//--------------------------------------------------------------------------------------
void GetValid(double &ExtMapBuffer[], double &ExtMapBuffer2[]){
   up_cur = 0; int upbar = 0;
   dn_cur = 0; int dnbar = 0;
   double cur_hi = 0,cur_lo = 0;
   double last_up = 0,last_dn = 0;
   double low_dn = 0,hi_up = 0;
   int i;
   for(i=0;i<iBars(pair,(ENUM_TIMEFRAMES)tf);i++) if(ExtMapBuffer[i] > 0){
      up_cur = ExtMapBuffer[i];
      cur_lo = ExtMapBuffer[i];
      last_up = cur_lo;
      break;
   }
   for(i=0;i<iBars(pair,(ENUM_TIMEFRAMES)tf);i++) if(ExtMapBuffer2[i] > 0){
      dn_cur = ExtMapBuffer2[i];
      cur_hi = ExtMapBuffer2[i];
      last_dn = cur_hi;
      break;
   }
   for(i=0;i<iBars(pair,(ENUM_TIMEFRAMES)tf);i++){
      if(ExtMapBuffer2[i] >= last_dn){
         last_dn = ExtMapBuffer2[i];
         dnbar = i;
      } else ExtMapBuffer2[i] = 0.0;
      if(ExtMapBuffer2[i] <= dn_cur && ExtMapBuffer[i] > 0.0) ExtMapBuffer2[i] = 0.0;
      if(ExtMapBuffer[i] <= last_up && ExtMapBuffer[i] > 0){
         last_up = ExtMapBuffer[i];
         upbar = i;
      } else ExtMapBuffer[i] = 0.0;
      if(ExtMapBuffer[i] > up_cur) ExtMapBuffer[i] = 0.0;
   }
   low_dn = MathMin(iOpen(pair,(ENUM_TIMEFRAMES)tf,dnbar),iClose(pair,(ENUM_TIMEFRAMES)tf,dnbar));
   hi_up = MathMax(iOpen(pair,(ENUM_TIMEFRAMES)tf,upbar),iClose(pair,(ENUM_TIMEFRAMES)tf,upbar));
   for(i=MathMax(upbar,dnbar);i>=0;i--){
      if(ExtMapBuffer2[i] > low_dn && ExtMapBuffer2[i] != last_dn) ExtMapBuffer2[i] = 0.0;
      else if(ExtMapBuffer2[i] > 0){
         last_dn = ExtMapBuffer2[i];
         low_dn = MathMin(iClose(pair,(ENUM_TIMEFRAMES)tf,i),iOpen(pair,(ENUM_TIMEFRAMES)tf,i));
         if(i>0) low_dn = MathMax(low_dn,MathMax(iLow(pair,(ENUM_TIMEFRAMES)tf,i-1),iLow(pair,(ENUM_TIMEFRAMES)tf,i+1)));
         if(i>0) low_dn = MathMax(low_dn,MathMin(iOpen(pair,(ENUM_TIMEFRAMES)tf,i-1),iClose(pair,(ENUM_TIMEFRAMES)tf,i-1)));
         low_dn = MathMax(low_dn,MathMin(iOpen(pair,(ENUM_TIMEFRAMES)tf,i+1),iClose(pair,(ENUM_TIMEFRAMES)tf,i+1)));
      }
      if(ExtMapBuffer[i] <= hi_up && ExtMapBuffer[i] > 0 && ExtMapBuffer[i] != last_up) ExtMapBuffer[i] = 0.0;
      else if(ExtMapBuffer[i] > 0){
         last_up = ExtMapBuffer[i];
         hi_up = MathMax(iClose(pair,(ENUM_TIMEFRAMES)tf,i),iOpen(pair,(ENUM_TIMEFRAMES)tf,i));
         if(i>0) hi_up = MathMin(hi_up,MathMin(iHigh(pair,(ENUM_TIMEFRAMES)tf,i+1),iHigh(pair,(ENUM_TIMEFRAMES)tf,i-1)));
         if(i>0) hi_up = MathMin(hi_up,MathMax(iOpen(pair,(ENUM_TIMEFRAMES)tf,i-1),iClose(pair,(ENUM_TIMEFRAMES)tf,i-1)));
         hi_up = MathMin(hi_up,MathMax(iOpen(pair,(ENUM_TIMEFRAMES)tf,i+1),iClose(pair,(ENUM_TIMEFRAMES)tf,i+1)));
      }
   }
}
//--------------------------------------------------------------------------------------
void BarTimer(){
   int i=0,sec=0; string time="",s_end="",s;
   long cid=ChartID();
   s = l_hud+TAG+"btimerback";
   if (ObjectFind(cid,s)==-1) {
      ObjectCreate(cid,s,OBJ_LABEL,0,0,0);
      ObjectSetInteger(cid,s,OBJPROP_XDISTANCE,hud_timer_x);
      ObjectSetInteger(cid,s,OBJPROP_YDISTANCE,hud_timer_y);
      ObjectSetInteger(cid,s,OBJPROP_CORNER,corner_HUD);
      ObjectSetDouble (cid,s,OBJPROP_ANGLE,(double)rotation);
      ObjectSetString (cid,s,OBJPROP_TEXT,s_base);
      ObjectSetInteger(cid,s,OBJPROP_COLOR,color_timer_back);
      ObjectSetInteger(cid,s,OBJPROP_FONTSIZE,size_timer_font);
      ObjectSetString (cid,s,OBJPROP_FONT,timer_font);
   }
   sec=(int)(TimeCurrent()-iTime(pair,(ENUM_TIMEFRAMES)tf,0));
   i=(lenbase-1)*sec/(tf*60);
   if(i>lenbase-1) i=lenbase-1;
   if(i<lenbase-1) s_end=StringSubstr(s_base,i+1,lenbase-i-1);
   time="|"+s_end;
   s = l_hud+TAG+"timerfront";
   if (ObjectFind(cid,s)==-1) {
     ObjectCreate(cid,s,OBJ_LABEL,0,0,0);
     ObjectSetInteger(cid,s,OBJPROP_XDISTANCE,hud_timer_x);
     ObjectSetInteger(cid,s,OBJPROP_YDISTANCE,hud_timer_y);
     ObjectSetInteger(cid,s,OBJPROP_CORNER,corner_HUD);
     ObjectSetDouble (cid,s,OBJPROP_ANGLE,(double)rotation);
   }
   ObjectSetString (cid,s,OBJPROP_TEXT,time);
   ObjectSetInteger(cid,s,OBJPROP_COLOR,color_timer_bar);
   ObjectSetInteger(cid,s,OBJPROP_FONTSIZE,size_timer_font);
   ObjectSetString (cid,s,OBJPROP_FONT,timer_font);
}
//--------------------------------------------------------------------------------------
void DrawText(string l,string t,int x,int y,color c,string f,int s,int k=0,int a=0,bool b=false){
   long cid=ChartID();
   string tag = l_hud+TAG+l+string(x)+string(y);
   if(ObjectFind(cid,tag)!=-1) ObjectDelete(cid,tag);
   ObjectCreate(cid,tag,OBJ_LABEL,0,0,0);
   ObjectSetString (cid,tag,OBJPROP_TEXT,t);
   ObjectSetInteger(cid,tag,OBJPROP_FONTSIZE,s);
   ObjectSetString (cid,tag,OBJPROP_FONT,f);
   ObjectSetInteger(cid,tag,OBJPROP_COLOR,c);
   ObjectSetInteger(cid,tag,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(cid,tag,OBJPROP_YDISTANCE,y);
   ObjectSetInteger(cid,tag,OBJPROP_CORNER,k);
   ObjectSetDouble (cid,tag,OBJPROP_ANGLE,(double)a);
   if(b) ObjectSetInteger(cid,tag,OBJPROP_BACK,true);
}
//--------------------------------------------------------------------------------------
string TimeFrameToString(int timeframe){
   switch(timeframe){
      case PERIOD_M1:  return "M1";
      case PERIOD_M5:  return "M5";
      case PERIOD_M15: return "M15";
      case PERIOD_M30: return "M30";
      case PERIOD_H1:  return "H1";
      case PERIOD_H4:  return "H4";
      case PERIOD_D1:  return "D1";
      case PERIOD_W1:  return "W1";
      case PERIOD_MN1: return "MN";
   }
   return "";
}
//--------------------------------------------------------------------------------------
void setHUD(){
   switch(tf){
      case PERIOD_M1:  HUD_x=7 ; break;
      case PERIOD_M5:  HUD_x=7 ; break;
      case PERIOD_M15: HUD_x=3 ; break;
      case PERIOD_M30: HUD_x=2 ; break;
      case PERIOD_H1:  HUD_x=12; break;
      case PERIOD_H4:  HUD_x=8 ; break;
      case PERIOD_D1:  HUD_x=12; break;
      case PERIOD_W1:  HUD_x=8 ; break;
      case PERIOD_MN1: HUD_x=7 ; break;
   }
   int corner_eff = corner_HUD;
   if(corner_eff>3) corner_eff=0;
   if(corner_eff==0||corner_eff==2) rotation=90;
   switch(corner_eff){
      case 0:
         hud_tf_x = pos_x-HUD_x+10;
         hud_tf_y = pos_y+18;
         hud_arrow_x = pos_x-2;
         hud_arrow_y = pos_y+7;
         hud_sup_x = pos_x;
         hud_sup_y = pos_y;
         hud_dem_x = pos_x;
         hud_dem_y = pos_y+56;
         hud_timer_x = pos_x+50;
         hud_timer_y = pos_y+72;
         hud_tfs_x = hud_tf_x+1;
         hud_tfs_y = hud_tf_y+1;
         hud_arrows_x = hud_arrow_x+1;
         hud_arrows_y = hud_arrow_y+1;
         hud_sups_x = hud_sup_x+1;
         hud_sups_y = hud_sup_y+1;
         hud_dems_x = hud_dem_x+1;
         hud_dems_y = hud_dem_y+1;
         break;
      case 1:
         hud_tf_x = pos_x+HUD_x;
         hud_tf_y = pos_y+18;
         hud_arrow_x = pos_x+2;
         hud_arrow_y = pos_y+7;
         hud_sup_x = pos_x;
         hud_sup_y = pos_y;
         hud_dem_x = pos_x;
         hud_dem_y = pos_y+56;
         hud_timer_x = pos_x-15;
         hud_timer_y = pos_y+71;
         hud_tfs_x = hud_tf_x-1;
         hud_tfs_y = hud_tf_y+1;
         hud_arrows_x = hud_arrow_x-1;
         hud_arrows_y = hud_arrow_y+1;
         hud_sups_x = hud_sup_x-1;
         hud_sups_y = hud_sup_y+1;
         hud_dems_x = hud_dem_x-1;
         hud_dems_y = hud_dem_y+1;
         break;
      case 2:
         hud_tf_x = pos_x-HUD_x;
         hud_tf_y = pos_y+20;
         hud_arrow_x = pos_x-2;
         hud_arrow_y = pos_y+7;
         hud_sup_x = pos_x;
         hud_sup_y = pos_y+56;
         hud_dem_x = pos_x;
         hud_dem_y = pos_y;
         hud_timer_x = pos_x+62;
         hud_timer_y = pos_y+3;
         hud_tfs_x = hud_tf_x+1;
         hud_tfs_y = hud_tf_y-1;
         hud_arrows_x = hud_arrow_x+1;
         hud_arrows_y = hud_arrow_y-1;
         hud_sups_x = hud_sup_x+1;
         hud_sups_y = hud_sup_y-1;
         hud_dems_x = hud_dem_x+1;
         hud_dems_y = hud_dem_y-1;
         break;
      case 3:
         hud_tf_x = pos_x+HUD_x;
         hud_tf_y = pos_y+20;
         hud_arrow_x = pos_x+2;
         hud_arrow_y = pos_y+7;
         hud_sup_x = pos_x;
         hud_sup_y = pos_y+56;
         hud_dem_x = pos_x;
         hud_dem_y = pos_y;
         hud_timer_x = pos_x-2;
         hud_timer_y = pos_y+3;
         hud_tfs_x = hud_tf_x-1;
         hud_tfs_y = hud_tf_y-1;
         hud_arrows_x = hud_arrow_x-1;
         hud_arrows_y = hud_arrow_y-1;
         hud_sups_x = hud_sup_x-1;
         hud_sups_y = hud_sup_y-1;
         hud_dems_x = hud_dem_x-1;
         hud_dems_y = hud_dem_y-1;
         break;
   }
}
//--------------------------------------------------------------------------------------
void setVisibility(){
   int per = (int)Period();
   visible = 0;
   if(same_tf_vis){
      if(forced_tf==per || forced_tf==0){
         switch(per){
            case PERIOD_M1:  visible=0x0001; break;
            case PERIOD_M5:  visible=0x0002; break;
            case PERIOD_M15: visible=0x0004; break;
            case PERIOD_M30: visible=0x0008; break;
            case PERIOD_H1:  visible=0x0010; break;
            case PERIOD_H4:  visible=0x0020; break;
            case PERIOD_D1:  visible=0x0040; break;
            case PERIOD_W1:  visible=0x0080; break;
            case PERIOD_MN1: visible=0x0100; break;
         }
      }
   }else{
      if(show_on_m1)  visible+=0x0001;
      if(show_on_m5)  visible+=0x0002;
      if(show_on_m15) visible+=0x0004;
      if(show_on_m30) visible+=0x0008;
      if(show_on_h1)  visible+=0x0010;
      if(show_on_h4)  visible+=0x0020;
      if(show_on_d1)  visible+=0x0040;
      if(show_on_w1)  visible+=0x0080;
      if(show_on_mn)  visible+=0x0100;
   }
}
//--------------------------------------------------------------------------------------
void HUD(){
   long cid=ChartID();
   string sTF = TimeFrameToString(tf);
   string u = DoubleToString(GetObjectPrice1(l_zone+TAG+"UPAR1"),digits);
   string d = DoubleToString(GetObjectPrice1(l_zone+TAG+"DNAR1"),digits);
   string l = "b";
   DrawText(l,sTF,hud_tf_x,hud_tf_y,color_HUD_tf,font_HUD,font_HUD_size,corner_HUD);
   DrawText(l,arrow_glance,hud_arrow_x,hud_arrow_y,color_arrow,font_arrow,font_arrow_size,corner_HUD,0,true);
   DrawText(l,u,hud_sup_x,hud_sup_y,color_sup_strong,font_HUD_price,font_HUD_price_size,corner_HUD);
   DrawText(l,d,hud_dem_x,hud_dem_y,color_dem_strong,font_HUD_price,font_HUD_price_size,corner_HUD);
   l = "a";
   DrawText(l,sTF,hud_tfs_x,hud_tfs_y,color_shadow,font_HUD,font_HUD_size,corner_HUD,0,true);
   DrawText(l,arrow_glance,hud_arrows_x,hud_arrows_y,color_shadow,font_arrow,font_arrow_size,corner_HUD,0,true);
   DrawText(l,u,hud_sups_x,hud_sups_y,color_shadow,font_HUD_price,font_HUD_price_size,corner_HUD,0,true);
   DrawText(l,d,hud_dems_x,hud_dems_y,color_shadow,font_HUD_price,font_HUD_price_size,corner_HUD,0,true);
}
//--------------------------------------------------------------------------------------

double GetObjectPrice1(const string name){
   long chart_id = ChartID();
   if(ObjectFind(chart_id,name)==-1) return 0.0;
   return ObjectGetDouble(chart_id,name,OBJPROP_PRICE,0);
}

double GetRectPrice2(const string name){
   long cid=ChartID();
   if(ObjectFind(cid,name)==-1) return 0.0;
   return ObjectGetDouble(cid,name,OBJPROP_PRICE,1);
}
//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&p=160164#p160164

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