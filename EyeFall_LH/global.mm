#import "global.h"
#import "LevelHelperLoader.h"

NSMutableArray*     g_ContactObj = nil;
NSMutableArray*     g_ContactEnemy = nil;
bool                g_EyeContacted = false;
int                  g_SelectedEye = FIRE_EYE_TAG;

NSString*		g_strFontName = @"ARIALNB.TTF";
NSString*		g_strFontName1 = @"Bungnipper.ttf";

#define RAND_LIMIT  32767

bool        g_bTestMode = false;
//Random floating point number in range[lo, hi]
float RandomFloat(float lo, float hi) {
    float r = (float)(rand() & (RAND_LIMIT));
    r /= RAND_LIMIT;
    r = (hi - lo) * r + lo;
    return r;
}

int RandomInt(int lo, int hi) {
    int r = (rand() % (hi - lo + 1));
    return r + lo;
}