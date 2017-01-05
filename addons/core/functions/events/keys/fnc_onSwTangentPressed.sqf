#include "script_component.hpp"

/*
    Name: TFAR_fnc_onSwTangentPressed

    Author(s):
        NKey

    Description:
        Fired when the keybinding for SW is pressed.

    Parameters:

    Returns:
        BOOLEAN

    Example:
        call TFAR_fnc_onSwTangentPressed;
*/

if (time - TF_last_lr_tangent_press < 0.5) exitWith {true};
if ((TF_tangent_sw_pressed) or {!alive TFAR_currentUnit} or {!call TFAR_fnc_haveSWRadio}) exitWith {true};

if (!call TFAR_fnc_isAbleToUseRadio) exitWith {call TFAR_fnc_unableToUseHint;true};

private _radio = call TFAR_fnc_activeSwRadio;
if (!([_radio] call TFAR_fnc_RadioOn)) exitWith {true};

private _depth = TFAR_currentUnit call TFAR_fnc_eyeDepth;
private _isolatedAndInside = TFAR_currentUnit call TFAR_fnc_vehicleIsIsolatedAndInside;

if !([  TFAR_currentUnit,
        _isolatedAndInside,
        [_isolatedAndInside,_depth] call TFAR_fnc_canSpeak,
        _depth
    ] call TFAR_fnc_canUseSWRadio
    ||
    {([_depth,_isolatedAndInside] call TFAR_fnc_canUseDDRadio)}
    ) exitWith {call TFAR_fnc_inWaterHint;true};

["OnBeforeTangent", [TFAR_currentUnit, _radio, 0, false, true]] call TFAR_fnc_fireEventHandlers;
private _currentFrequency = call TFAR_fnc_currentSWFrequency;

private _hintText = format[
                            localize "STR_transmit",
                            format [
                                    "%1<img size='1.5' image='%2'/>",
                                    getText (configFile >> "CfgWeapons" >> _radio >> "displayName"),
                                    getText(configFile >> "CfgWeapons"  >> _radio >> "picture")
                                    ],
                            (_radio call TFAR_fnc_getSwChannel) + 1,
                            _currentFrequency
                        ];

private _pluginCommand = format[
                                "TANGENT	PRESSED	%1%2	%3	%4	%5",
                                _currentFrequency,
                                _radio call TFAR_fnc_getSwRadioCode,
                                getNumber(configFile >> "CfgWeapons" >> _radio >> "tf_range") * (call TFAR_fnc_getTransmittingDistanceMultiplicator),
                                getText(configFile >> "CfgWeapons" >> _radio >> "tf_subtype"),
                                _radio
                            ];

[_hintText,_pluginCommand,-1] call TFAR_fnc_processTangent;

TF_tangent_sw_pressed = true;
//						unit, radio, radioType, additional, buttonDown
["OnTangent", [TFAR_currentUnit, _radio, 0, false, true]] call TFAR_fnc_fireEventHandlers;
true
