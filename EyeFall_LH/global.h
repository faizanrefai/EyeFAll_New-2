#ifndef     _GLOBAL_H_
#define     _GLOBAL_H_

#define LEVEL_COUNT     12
#define WORLD_COUNT     5
#define MIN_CONTACT_FORCE       2.0f

#ifdef DEBUG
    #define MAX_LEVEL_TIME          60//181
#else
    #define MAX_LEVEL_TIME          120
#endif

#define     _TOP_Z          100
#define     MAX_LIVES_COUNT 10
#define     EYE_ANI_TIME    1.0f
#define     MAXVEL	80
#define     MINVEL	20
#define     SCORE_LABEL_INDEX   1000
#define     _TAG_EYE_TAIL_PARTICLE      2000
#define     NOT_COMBINE_ADMOBE       300

typedef enum _WND_ID
{
	WND_NONE = 0,
	WND_TITLE,
    WND_MODE,
	WND_LEVEL,
	WND_SCORE,
	WND_SETTING,
	WND_GAME,
    
	WND_COUNT
} WND_ID;

typedef enum _PLAY_MODE
{
    MODE_TIME = 100,
    MODE_DESTRUCTION,
} PLAY_MODE;

extern NSMutableArray*      g_ContactObj;
extern NSMutableArray*      g_ContactEnemy;
extern bool                 g_EyeContacted;
extern int                  g_SelectedEye;

extern NSString*		g_strFontName;
extern NSString*		g_strFontName1;

//Random floating point number in range[lo, hi]
float RandomFloat(float lo, float hi);
int RandomInt(int lo, int hi);

extern bool        g_bTestMode;
#endif