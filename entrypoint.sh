#!/bin/bash
set -e

STEAMCMDDIR=/opt/steamcmd
SERVER_DIR=/opt/conan

# Only install if not already present
if [ ! -f "$SERVER_DIR/ConanSandboxServer.exe" ]; then
  echo "Installing Conan Exiles server..."
fi

# Install Windows Conan Exiles server via SteamCMD
$STEAMCMDDIR/steamcmd.sh \
  +force_install_dir $SERVER_DIR \
  +login anonymous \
  +@sSteamCmdForcePlatformType windows \
  +app_update $STEAMAPPID validate \
  +quit

# Create config folder
CONF_DIR="$SERVER_DIR/ConanSandbox/Saved/Config/WindowsServer"
mkdir -p "$CONF_DIR"

# Generate full ServerSettings.ini from .env
cat > "$CONF_DIR/ServerSettings.ini" <<EOF
[ServerSettings]
ServerName=${SERVER_NAME}
ServerPassword=${SERVER_PASSWORD}
AdminPassword=${ADMIN_PASSWORD}
ServerMessageOfTheDay=${SERVER_MOTD}
ServerRegion=${SERVER_REGION}

MaxPlayers=${MAX_PLAYERS}
MaxNudity=${MAX_NUDITY}

PVPEnabled=${PVP_ENABLED}
RestrictPVPTime=${RESTRICT_PVP_TIME}
PVPTimeRestrictionStart=${PVP_TIME_START}
PVPTimeRestrictionEnd=${PVP_TIME_END}

RestrictPVPBuildingDamageTime=${RESTRICT_PVP_BUILDING}
PVPBuildingDamageTimeRestrictionStart=${PVP_BUILDING_START}
PVPBuildingDamageTimeRestrictionEnd=${PVP_BUILDING_END}

DayCycleSpeedScale=${DAY_CYCLE_SCALE}
DayTimeSpeedScale=${DAY_TIME_SCALE}
NightTimeSpeedScale=${NIGHT_TIME_SCALE}
DawnDuskSpeedScale=${DAWN_DUSK_SPEED_SCALE}

PlayerXPRateMultiplier=${PLAYER_XP_RATE}
PlayerXPKillMultiplier=${PLAYER_XP_KILL}
PlayerXPHarvestMultiplier=${PLAYER_XP_HARVEST}
PlayerXPCraftMultiplier=${PLAYER_XP_CRAFT}

HarvestAmountMultiplier=${HARVEST_AMOUNT}
ResourceRespawnSpeedMultiplier=${RESOURCE_RESPAWN}

CraftingCostMultiplier=${CRAFT_COST}
CraftingTimeMultiplier=${CRAFT_TIME}

PlayerDamageMultiplier=${PLAYER_DAMAGE}
PlayerDamageTakenMultiplier=${PLAYER_DAMAGE_TAKEN}
PlayerHealthMultiplier=${PLAYER_HEALTH}
PlayerStaminaMultiplier=${PLAYER_STAMINA}

StructureDamageMultiplier=${STRUCTURE_DAMAGE}
StructureDamageTakenMultiplier=${STRUCTURE_DAMAGE_TAKEN}
StructureHealthMultiplier=${STRUCTURE_HEALTH}

NPCRespawnMultiplier=${NPC_RESPAWN}
NPCHealthMultiplier=${NPC_HEALTH}

PlayerEncumbranceMultiplier=${PLAYER_ENCUMBRANCE}
PlayerEncumbrancePenaltyMultiplier=${PLAYER_ENCUMBRANCE_PENALTY}

PlayerIdleThirstMultiplier=${PLAYER_IDLE_THIRST}
PlayerActiveThirstMultiplier=${PLAYER_ACTIVE_THIRST}
PlayerOfflineThirstMultiplier=${PLAYER_OFFLINE_THIRST}
PlayerIdleHungerMultiplier=${PLAYER_IDLE_HUNGER}
PlayerActiveHungerMultiplier=${PLAYER_ACTIVE_HUNGER}
PlayerOfflineHungerMultiplier=${PLAYER_OFFLINE_HUNGER}

ItemSpoilRateScale=${ITEM_SPOIL_RATE}

ShieldDurabilityMultiplier=${SHIELD_DURABILITY}

DropLootOnDeath=${DROP_LOOT}
DropEquipmentOnDeath=${DROP_EQUIPMENT}
DropBackpackOnDeath=${DROP_BACKPACK}
EverybodyCanLootCorpse=${EVERYBODY_LOOT}

ChatHasGlobal=${CHAT_GLOBAL}
ChatLocalRadius=${CHAT_LOCAL_RADIUS}

EveryoneCanCheat=${EVERYONE_CAN_CHEAT}
LogoutCharactersRemainInTheWorld=${LOGOUT_REMAINS}

NoOwnership=${NO_OWNERSHIP}
CanDamagePlayerOwnedStructures=${CAN_DAMAGE_OWN_STRUCTURES}

BlueprintConfigVersion=${BLUEPRINT_CONFIG_VERSION}
ConfigVersion=${CONFIG_VERSION}
NPCMindReadingMode=${NPC_MIND_READING}
MinionDamageMultiplier=${MINION_DAMAGE}
MinionDamageTakenMultiplier=${MINION_DAMAGE_TAKEN}
PlayerKnockbackMultiplier=${PLAYER_KNOCKBACK}
NPCKnockbackMultiplier=${NPC_KNOCKBACK}
EOF

# Start server with Wine
xvfb-run --auto-servernum --server-args='-screen 0 640x480x24:32' \
  wine "$SERVER_DIR/ConanSandboxServer.exe" \
  ${MAP}?listen \
  -Port=${GAME_PORT} \
  -QueryPort=${QUERY_PORT} \
  -MaxPlayers=${MAX_PLAYERS} \
  -log
