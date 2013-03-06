//
//  MyListener.m
//  StackEM
//
//  Created by YunCholHo on 2/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#include "MyListener.h"
#import "LevelHelperLoader.h"
#import "global.h"

MyListener::MyListener()
{
}

MyListener::~MyListener()
{
}

void MyListener::setLevelLoader(LevelHelperLoader *loader)
{
    m_level = loader;
}

void MyListener::BeginContact(b2Contact* contact)
{
    LHSprite* dataA = (LHSprite*)contact->GetFixtureA()->GetBody()->GetUserData();
	LHSprite* dataB = (LHSprite*)contact->GetFixtureB()->GetBody()->GetUserData();
	
    
	if (dataA == NULL && dataB == NULL) {
		return;
	}
    
    b2Body * bodyA = [dataA body];
    b2Body * bodyB = [dataB body];
    
    b2Vec2 vecA = bodyA->GetLinearVelocity();
    b2Vec2 vecB = bodyB->GetLinearVelocity();
        
    if (vecA.Length() > MIN_CONTACT_FORCE || vecB.Length() > MIN_CONTACT_FORCE) {
        int nType1 = [dataA tag];
        int nType2 = [dataB tag];
        
        if (nType1 == FIRE_EYE_TAG || nType2 == FIRE_EYE_TAG) {
            if (nType1 == WOOD_TAG) {
                //[dataA body]->SetFixedRotation(true);
                [g_ContactObj addObject:dataA];
            }
            else if (nType2 == WOOD_TAG) {
                //[dataB body]->SetFixedRotation(true);
                [g_ContactObj addObject:dataB];
            }
            else if (nType1 == ENEMY1_TAG) {
                [g_ContactEnemy addObject:dataA];
            }
            else if (nType2 == ENEMY1_TAG) {
                [g_ContactEnemy addObject:dataB];
            }
            if (nType1 != DEFAULT_TAG && nType2 != DEFAULT_TAG/* && nType1 != GOLD_TAG && nType2 != GOLD_TAG*/) {
                g_EyeContacted = true;
            }
        }
        else if (nType1 == ACID_EYE_TAG || nType2 == ACID_EYE_TAG) {
            if (nType1 == STEEL_TAG || nType1 == ACID_TAG) {
                //[dataA body]->SetFixedRotation(true);
                [g_ContactObj addObject:dataA];
            }
            else if (nType2 == STEEL_TAG || nType2 == ACID_TAG) {
                //[dataB body]->SetFixedRotation(true);
                [g_ContactObj addObject:dataB];
            }
            else if (nType1 == ENEMY1_TAG) {
                [g_ContactEnemy addObject:dataA];
            }
            else if (nType2 == ENEMY1_TAG) {
                [g_ContactEnemy addObject:dataB];
            }
            if (nType1 != DEFAULT_TAG && nType2 != DEFAULT_TAG/* && nType1 != GOLD_TAG && nType2 != GOLD_TAG*/) {
                g_EyeContacted = true;
            }
        }
        else if (nType1 == METAL_EYE_TAG || nType2 == METAL_EYE_TAG) {
            if (nType1 == ICE_TAG) {
                //[dataA body]->SetFixedRotation(true);
                [g_ContactObj addObject:dataA];
            }
            else if (nType2 == ICE_TAG) {
                //[dataB body]->SetFixedRotation(true);
                [g_ContactObj addObject:dataB];
            }
            else if (nType1 == ENEMY1_TAG) {
                [g_ContactEnemy addObject:dataA];
            }
            else if (nType2 == ENEMY1_TAG) {
                [g_ContactEnemy addObject:dataB];
            }
            if (nType1 != DEFAULT_TAG && nType2 != DEFAULT_TAG/* && nType1 != GOLD_TAG && nType2 != GOLD_TAG*/) {
                g_EyeContacted = true;
            }
        }
        else if (nType1 == ICE_EYE_TAG || nType2 == ICE_EYE_TAG) {
            if (nType1 == FIRE_WOOD_TAG) {
                //[dataA body]->SetFixedRotation(true);
                [g_ContactObj addObject:dataA];
            }
            else if (nType2 == FIRE_WOOD_TAG) {
                //[dataB body]->SetFixedRotation(true);
                [g_ContactObj addObject:dataB];
            }
            else if (nType1 == ENEMY1_TAG) {
                [g_ContactEnemy addObject:dataA];
            }
            else if (nType2 == ENEMY1_TAG) {
                [g_ContactEnemy addObject:dataB];
            }
            if (nType1 != DEFAULT_TAG && nType2 != DEFAULT_TAG/* && nType1 != GOLD_TAG && nType2 != GOLD_TAG*/) {
                g_EyeContacted = true;
            }
        }
        else {
            if (nType1 == ENEMY1_TAG) {
                [g_ContactEnemy addObject:dataA];
            }
            else if (g_SelectedEye == FIRE_EYE_TAG && nType1 == WOOD_TAG) {
                //[dataA body]->SetFixedRotation(true);
                [g_ContactObj addObject:dataA];
            }
            if (nType2 == ENEMY1_TAG) {
                [g_ContactEnemy addObject:dataB];
            }
            else  if (g_SelectedEye == FIRE_EYE_TAG && nType1 == WOOD_TAG) {
                //[dataB body]->SetFixedRotation(true);
                [g_ContactObj addObject:dataB];
            }
        }
    }	
}

void MyListener::EndContact(b2Contact* contact) {
    
}

void MyListener::PreSolve(b2Contact* contact, const b2Manifold* oldManifold)
{

}
////////////////////////////////////////////////////////////////////
/// class DestructionListener
////////////////////////////////////////////////////////////////////

void MyDestructionListener::SayGoodbye(b2Joint* joint)
{
}
