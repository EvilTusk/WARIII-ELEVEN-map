//! zinc

library StatusBar requires TimerUtils {
    struct StatusBarStruct {
        private integer m_hpBar;
        private integer m_mpBar;
        private integer m_hpText;
        private integer m_mpText;
        private integer m_hpRevText;
        private integer m_mpRevText;
        private integer m_heroIcon;
        private unit m_hero;

        public static method create() -> StatusBarStruct {
            StatusBarStruct ret = StatusBarStruct.allocate();
            ret.m_hpBar = 0;
            ret.m_mpBar = 0;
            ret.m_hero = null;

            return ret;
        }

        public method onDestroy() {
            m_hero = null;
        }

        public method show() -> boolean {
            integer ret;
            integer gameUI = DzGetGameUI();
            timer t;

            ret = DzCreateFrameByTagName("BACKDROP", "HpBar", gameUI, "UI\\FrameDef\\Glue\\BattleNetTemplates.fdf", 0);
            if (ret == 0) {
                return false;
            }
            m_hpBar = ret;

            ret = DzCreateFrameByTagName("BACKDROP", "MpBar", gameUI, "UI\\FrameDef\\Glue\\BattleNetTemplates.fdf", 0);
            if (ret == 0) {
                return false;
            }
            m_mpBar = ret;

            ret = DzCreateFrameByTagName("TEXT", "HpText", gameUI, "UI\\FrameDef\\Glue\\BattleNetTemplates.fdf", 0);
            if (ret == 0) {
                return false;
            }
            m_hpText = ret;

            ret = DzCreateFrameByTagName("TEXT", "MpText", gameUI, "UI\\FrameDef\\Glue\\BattleNetTemplates.fdf", 0);
            if (ret == 0) {
                return false;
            }
            m_mpText = ret;

            DzFrameShow(m_mpBar, true);
            DzFrameSetTexture(m_mpBar, "UI\\Feedback\\HpbarConsole\\human-healthbar-fill.blp", 0);
            DzFrameSetPoint(m_mpBar, 6, gameUI, 7, -0.12, 0.0003);
            DzFrameSetSize(m_mpBar, 0.24, 0.015);

            DzFrameShow(m_hpBar, true);
            DzFrameSetTexture(m_hpBar, "UI\\Feedback\\HpbarConsole\\human-healthbar-fill.blp", 0);
            DzFrameSetPoint(m_hpBar, 6, m_mpBar, 0, 0., 0.0003);
            DzFrameSetSize(m_hpBar, 0.24, 0.015);
            
            DzFrameShow(m_mpText, true);
            DzFrameSetTexture(m_mpText, "UI\\Feedback\\HpbarConsole\\human-healthbar-fill.blp", 0);
            DzFrameSetPoint(m_mpText, 4, m_mpBar, 3, 0.12, 0.);
            DzFrameSetText(m_mpText, "0/0");
            
            DzFrameShow(m_hpText, true);
            DzFrameSetTexture(m_hpText, "UI\\Feedback\\HpbarConsole\\human-healthbar-fill.blp", 0);
            DzFrameSetPoint(m_hpText, 4, m_hpBar, 3, 0.12, 0.);
            DzFrameSetText(m_hpText, "0/0");

            
            t = NewTimer();
            SetTimerData(t, this);
            TimerStart(t, 0.2, true, function() {
                timer t = GetExpiredTimer();
                StatusBarStruct this;
                integer i = 0;
                
                while (i < 12) {
                    if (udg_Hero[i] != null) {
                        break;
                    }
                    i = i + 1;
                }
                
                if (i >= 12) {
                    return;
                }
                
                if (Player(i) == GetLocalPlayer()) {
                    this = GetTimerData(t);
                    ReleaseTimer(t);
                    t = null;
                    this.setHero(udg_Hero[i]);
                }
            });


            return true;
        }

        public method setHero(unit o) -> boolean {
            integer ret;
            integer gameUI = DzGetGameUI();
            string heroIconPath;
            timer t;
            integer skillIcon;
            integer i, j;
            
            m_hero = o;

            heroIconPath = YDWEGetObjectPropertyString(YDWE_OBJECT_TYPE_UNIT, GetUnitTypeId(m_hero), "Art");
            ret = DzCreateFrameByTagName("BACKDROP", "HeroIcon", gameUI, "UI\\FrameDef\\Glue\\BattleNetTemplates.fdf", 0);
            if (ret == 0) {
                return false;
            }
            m_heroIcon = ret;
            DzFrameShow(m_heroIcon, true);
            DzFrameSetTexture(m_heroIcon, heroIconPath, 0);
            DzFrameSetPoint(m_heroIcon, 8, m_mpBar, 6, -0.0003, 0.);
            DzFrameSetSize(m_heroIcon, 0.03, 0.04);

            for (0 <= i < 4) {
                skillIcon = DzFrameGetCommandBarButton(2, i);
                DzFrameShow(skillIcon, true);
                DzFrameClearAllPoints(skillIcon);
                DzFrameSetPoint(skillIcon, 6, m_hpBar, 0, 0.03*i, 0.003);
                DzFrameSetSize(skillIcon, 0.027, 0.036);
            }
            for (0 <= i < 4) {
                skillIcon = DzFrameGetCommandBarButton(0, i);
                DzFrameShow(skillIcon, true);
                DzFrameClearAllPoints(skillIcon);
                DzFrameSetPoint(skillIcon, 8, m_mpBar, 6, -(0.03*(3-i) + 0.10), 0.);
                DzFrameSetSize(skillIcon, 0.027, 0.036);
            }
            for (0 <= i < 2) {
                for (0 <= j < 3) {
                    skillIcon = DzFrameGetItemBarButton(i*3 + j);
                    DzFrameShow(skillIcon, true);
                    DzFrameClearAllPoints(skillIcon);
                    DzFrameSetPoint(skillIcon, 6, m_mpBar, 6, 0.026*j + 0.25, 0.034*(1-i));
                    DzFrameSetSize(skillIcon, 0.024, 0.032);
                }
            }
            skillIcon = DzFrameGetCommandBarButton(1, 3);
            DzFrameShow(skillIcon, true);
            DzFrameClearAllPoints(skillIcon);
            DzFrameSetPoint(skillIcon, 6, m_hpBar, 0, 0.03*5, 0.003);
            DzFrameSetSize(skillIcon, 0.027, 0.036);
            
            t = NewTimer();
            SetTimerData(t, this);
            TimerStart(t, 0.01, true, function() {
                timer t = GetExpiredTimer();
                StatusBarStruct this = GetTimerData(t);
                t = null;
                
                this.syncHero();
            });
            
            return true;
        }
        
        public method syncHero() {
            integer heroHp = R2I(GetUnitState(m_hero, UNIT_STATE_LIFE));
            integer heroMaxHp = R2I(GetUnitState(m_hero, UNIT_STATE_MAX_LIFE));
            integer heroMp = R2I(GetUnitState(m_hero, UNIT_STATE_MANA));
            integer heroMaxMp = R2I(GetUnitState(m_hero, UNIT_STATE_MAX_MANA));
            player curPlayer = GetOwningPlayer(m_hero);

            if (curPlayer != GetLocalPlayer()) {
                curPlayer = null;
                return;
            }

            DzFrameSetText(m_hpText, I2S(heroHp) + "/" + I2S(heroMaxHp));
            DzFrameSetText(m_mpText, I2S(heroMp) + "/" + I2S(heroMaxMp));
            DzFrameSetSize(m_hpBar, (I2R(heroHp)/I2R(heroMaxHp)) * 0.24, 0.015);
            DzFrameSetSize(m_mpBar, (I2R(heroMp)/I2R(heroMaxMp)) * 0.24, 0.015);

            curPlayer = null;
        }
    }

    function onInit() {
        StatusBarStruct bar = StatusBarStruct.create();
        bar.show();
    }
}

//! endzinc