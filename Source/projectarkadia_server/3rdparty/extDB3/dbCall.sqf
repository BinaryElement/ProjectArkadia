/**
 * dbCalls.sqf
 *
 * This script was made with parts of Bryan "Tonic" Boardwine, asyncCall functions.
 *
 * @mod    	   Project Arkadia
 * @author     Stefan (Stephano) Rasmussen
 *
 */

private ["_call","_params","_key","_queryResult","_loop","_pipe"];
_call = [_this,0,"",[""]] call BIS_fnc_param;
_params = [_this,1,[],[[]]] call BIS_fnc_param;
_return = false;

if (debugMode) then {
    diag_log "--------- SQL CALL ---------";
    diag_log format["NAME: %1", _call];
    diag_log format["PARAMS: %1", _params];
    diag_log "------------------------------";
};

// Prepare the parameters for the query.
if (count _params > 0) then {
    {
        switch (typeName _x) do {
            case "ARRAY": {
                _x = str _x;
            };
            case "SCALAR": {
                _x = [_x] call ARK_fnc_numberToText;
            };
            case "BOOL": {
                _x = parseNumber(_x);
            };
        };

        _params set [_forEachIndex, _x];

    } foreach _params;
};

_key = switch (toLower(_call)) do {
    case "newplayer": {
        call compile ("extDB3" callExtension format["1:%1:newPlayer:%2:%3:%4:%5:%6:%7", (call extDB_SQL_CUSTOM_ID), (_params select 0), (_params select 1),[],[],0,[]]);
    };
    case "loadplayer": {
        _return = true;
        call compile ("extDB3" callExtension format["2:%1:loadPlayer:%2", (call extDB_SQL_CUSTOM_ID), (_params select 0)]);
    };
    case "savelocation": {
        call compile ("extDB3" callExtension format["1:%1:saveLocation:%2:%3", (call extDB_SQL_CUSTOM_ID), (_params select 0), (_params select 1)]);
    };
    case "updateplayername": {
        call compile ("extDB3" callExtension format["1:%1:updatePlayerName:%2:%3", (call extDB_SQL_CUSTOM_ID), (_params select 0), (_params select 1)]);
    };
    case "saveplayerstats": {
        call compile ("extDB3" callExtension format["1:%1:savePlayerStats:%2:%3", (call extDB_SQL_CUSTOM_ID), (_params select 0), (_params select 1)]);
    };
    case "saveplayerequipment": {
        call compile ("extDB3" callExtension format["1:%1:savePlayerEquipment:%2:%3", (call extDB_SQL_CUSTOM_ID), (_params select 0), (_params select 1)]);
    };
    case "saveplayerfull": {
		diag_log "dbCall saveplayerfull";
		diag_log format ["1:%1:savePlayerFull:%2:%3:%4:%5:%6:%7", (call extDB_SQL_CUSTOM_ID), (_params select 0), (_params select 1), (_params select 2), (_params select 3), (_params select 4), (_params select 5)]
        call compile ("extDB3" callExtension format["1:%1:savePlayerFull:%2:%3:%4:%5:%6:%7", (call extDB_SQL_CUSTOM_ID), (_params select 0), (_params select 1), (_params select 2), (_params select 3), (_params select 4), (_params select 5)]);
    };

    default {
        if (debugMode) then {
            diag_log "--------- SQL ERROR ---------";
            diag_log format["Undefined call %1", toLower(_call)];
            diag_log "-----------------------------";
        };
    };
};

if (!_return) exitWith {};

if (debugMode) then {
    diag_log "--------- SQL RESULT KEY ---------";
    diag_log str _key;
    diag_log "----------------------------------";
};

if (count (_key select 1) > 0) then {
    _key = call compile format["%1",_key];
    _key = _key select 1;

    _queryResult = "";
    _loop = true;

    while {_loop} do {
        _queryResult = "extDB3" callExtension format["4:%1", _key];

        // Multi-Part Message
        if (_queryResult isEqualTo "[5]") then {
            _queryResult = "";

            while {true} do {
                _pipe = "extDB3" callExtension format["5:%1", _key];

                if (_pipe isEqualTo "") exitWith {
                    _loop = false
                };

                _queryResult = _queryResult + _pipe;
            };
        } else {
            // result not ready yet
            if (_queryResult isEqualTo "[3]") then {
                uisleep 0.1;
            } else {
                _loop = false;
            };
        };
    };


    _queryResult = call compile _queryResult;
    _queryResult = (_queryResult select 1);
} else {
    _queryResult = [];
};

if (typeName _queryResult == "ARRAY" && typeName (_queryResult select 0) == "ARRAY") then {
    _queryResult = (_queryResult select 0);
};

if (debugMode) then {
    diag_log "--------- SQL RESULTS COMPLETE ---------";
    diag_log str _queryResult;
    diag_log "----------------------------------------";
};

_queryResult