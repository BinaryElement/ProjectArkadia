/**
 *  processPlayerData.sqf
 *
 *
 * @mod    	   Project Arkadia
 * @author     Stefan (Stephano) Rasmussen
 *
 */
 
 private["_stats", "_equipment","_weapons","_weaponsData","_lastLoc"];
_stats = [_this,0,[],[[]]] call BIS_fnc_param;
_equipment = [_this,1,[],[[]]] call BIS_fnc_param;
_experience = [_this,2,0,[0]] call BIS_fnc_param;
_lastLoc = [_this,3,[],[[]]] call BIS_fnc_param;
_weapons = [];
_weaponsData = [];

ARK_gbl_experience = 0;
ARK_gbl_lastLoc = [];

diag_log _experience;
diag_log ARK_gbl_experience;

if (count _stats != 2) exitwith {
    [] call ARK_fnc_playerSetupBambiGear;
};

if ((_stats select 0) >= 1) exitWith {
    [] call ARK_fnc_playerSetupBambiGear;
};

if (count _lastLoc > 0) then {
    ARK_gbl_lastLoc = _lastLoc;
};

// only process the player data if they are actually still alive.
player setDamage (_stats select 0);
player setFatigue (_stats select 1);

if (count _equipment > 0) then {
    removeAllAssignedItems player;
    removeAllWeapons player;
    removeUniform player;
    removeVest player;
    removeBackpack player;
    removeGoggles player;
    removeHeadGear player;
    removeAllItems player;

    // Add headgear
    if ((_equipment select 2) != "") then {
        player addHeadgear (_equipment select 2);
    };

    // Add uniform 
    if (((_equipment select 3) select 0) != "") then {
        player addUniform ((_equipment select 3) select 0);
    };

    // Add vest 
    if (((_equipment select 4) select 0) != "") then {
        player addVest ((_equipment select 4) select 0);
    };

    // Add backpack 
    if (((_equipment select 5) select 0) != "") then {
        player addBackpack ((_equipment select 5) select 0);
    };

    // Add glasses 
    if ((_equipment select 7) != "") then {
         player addItem (_equipment select 7);
         player assignItem (_equipment select 7);
    };

    // Add assigned items
    if (count (_equipment select 6) > 0) then {
        {
            if (_x != "") then {
                if (_x == "Rangefinder") then {
                    player addWeapon "Rangefinder";
                } else {
                    player addItem _x;
                    player assignItem _x;
                };
            };
        } foreach (_equipment select 6);
    };

    /*[
        "arifle_MX_ACO_pointer_F",      //weapon
        "muzzle_snds_H",                //suppressor
        "acc_pointer_IR",               //laser
        "optic_Aco",                    //optics
        [                               //loaded magazine
            "30Rnd_65x39_caseless_mag", //mag type
            30                          //mag ammo count
        ],
        "bipod_01_F_blk"                //bipod
    ]*/

    _weapons = (_equipment select 0);
    _weaponsData = (_equipment select 1);

    if (debugMode) then {
        diag_log "Processing Equipment:";
        diag_log _equipment;
    };

    if (count _weaponsData > 0) then {
        {
            // for some reason, if you have a rangefinder and no secondary, the rangefinder takes it place.
            if ((_x select 0) != "" && (_x select 0) != "Rangefinder") then {
                if (count (_x select 4) > 0) then {
                    if (((_x select 4) select 1) > 0) then {
                        player addMagazine [((_x select 4) select 0), ((_x select 4) select 1)];
                    };
                };

                player addWeapon (_x select 0);

                // suppressor
                if ((_x select 1) != "") then {
                    if ((_x select 0) == (_weapons select 0)) then {
                        player addPrimaryWeaponItem (_x select 1);
                    } else {
                        if ((_x select 0) == (_weapons select 1)) then {
                            player addSecondaryWeaponItem (_x select 1);
                        } else {
                            player addHandgunItem (_x select 1);
                        };
                    };
                };

                // laser
                if ((_x select 2) != "") then {
                    if ((_x select 0) == (_weapons select 0)) then {
                        player addPrimaryWeaponItem (_x select 2);
                    } else {
                        if ((_x select 0) == (_weapons select 1)) then {
                            player addSecondaryWeaponItem (_x select 2);
                        } else {
                            player addHandgunItem (_x select 2);
                        };
                    };
                };

                // optics
                if ((_x select 3) != "") then {
                    if ((_x select 0) == (_weapons select 0)) then {
                        player addPrimaryWeaponItem (_x select 3);
                    } else {
                        if ((_x select 0) == (_weapons select 1)) then {
                            player addSecondaryWeaponItem (_x select 3);
                        } else {
                            player addHandgunItem (_x select 3);
                        };
                    };
                };

                // bipod
                if ((_x select 5) != "") then {
                    if ((_x select 0) == (_weapons select 0)) then {
                        player addPrimaryWeaponItem (_x select 5);
                    } else {
                        if ((_x select 0) == (_weapons select 1)) then {
                            player addSecondaryWeaponItem (_x select 5);
                        } else {
                            player addHandgunItem (_x select 5);
                        };
                    };
                };

                // Select primary weapon or pistol if no primary
                if (((_x select 0) == (_weapons select 0)) OR ((_x select 0) == (_weapons select 2) AND (_weapons select 0) == "")) then {
                    player selectWeapon (_x select 0);
                };
            };

        } forEach _weaponsData;
    };

    // add uniform items
    {
        if (_x != "") then {
             player addItemToUniform _x;
        };
    } foreach ((_equipment select 3) select 1);

    // add vest items
    {
        if (_x != "") then {
             player addItemToVest _x;
        };
    } foreach ((_equipment select 4) select 1);

    // add backpack items
    {
        if (_x != "") then {
             player addItemToBackpack _x;
        };
    } foreach ((_equipment select 5) select 1);
};