#!/bin/bash
set -e

STEAMCMDDIR=/opt/steamcmd
SERVER_DIR=/opt/conan

# Only install if not already present
if [ ! -f "$SERVER_DIR/ConanSandboxServer.exe" ]; then
  echo "Installing Conan Exiles server..."
  $STEAMCMDDIR/steamcmd.sh \
    +force_install_dir $SERVER_DIR \
    +login anonymous \
    +@sSteamCmdForcePlatformType windows \
    +app_update $STEAMAPPID validate \
    +quit
else
  echo "Server already installed."
fi

# Install/Update mods
if [ -n "$MOD_IDS" ]; then
  echo "Installing/updating mods..."
  IFS=',' read -ra MODS <<< "$MOD_IDS"
  for mod_id in "${MODS[@]}"; do
    mod_id=$(echo "$mod_id" | xargs)
    if [ -n "$mod_id" ]; then
      echo "Downloading mod: $mod_id"
      $STEAMCMDDIR/steamcmd.sh \
        +force_install_dir $SERVER_DIR \
        +login anonymous \
        +@sSteamCmdForcePlatformType windows \
        +workshop_download_item 440900 $mod_id validate \
        +quit
    fi
  done
  
  # Copy mods to the correct location
  echo "Copying mods to server directory..."
  mkdir -p "$SERVER_DIR/ConanSandbox/Mods"
  for mod_id in "${MODS[@]}"; do
    mod_id=$(echo "$mod_id" | xargs)
    if [ -n "$mod_id" ]; then
      WORKSHOP_DIR="$SERVER_DIR/steamapps/workshop/content/440900/$mod_id"
      if [ -d "$WORKSHOP_DIR" ]; then
        # Find the .pak file in the workshop directory
        PAK_FILE=$(find "$WORKSHOP_DIR" -name "*.pak" -type f | head -1)
        if [ -n "$PAK_FILE" ]; then
          echo "Copying mod $mod_id: $(basename "$PAK_FILE")"
          cp "$PAK_FILE" "$SERVER_DIR/ConanSandbox/Mods/$mod_id.pak"
        else
          echo "Warning: No .pak file found for mod $mod_id"
        fi
      else
        echo "Warning: Workshop directory not found for mod $mod_id"
      fi
    fi
  done
fi

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

# Generate Engine.ini
cat > "$CONF_DIR/Engine.ini" <<EOF
[OnlineSubsystem]
ServerName=${SERVER_NAME}
ServerPassword=${SERVER_PASSWORD}

[/Script/Engine.GameSession]
MaxPlayers=${MAX_PLAYERS}

[/Script/OnlineSubsystemUtils.IpNetDriver]
MaxClientRate=${MAX_CLIENT_RATE}
MaxInternetClientRate=${MAX_INTERNET_CLIENT_RATE}
NetServerMaxTickRate=${TICK_RATE}
LanServerMaxTickRate=${TICK_RATE}
EOF

# Generate Game.ini (empty by default, users can customize)
cat > "$CONF_DIR/Game.ini" <<EOF
[/Script/Engine.GameSession]
MaxPlayers=${MAX_PLAYERS}
EOF

# Generate modlist.txt
MODLIST_FILE="$SERVER_DIR/ConanSandbox/Mods/modlist.txt"
mkdir -p "$(dirname "$MODLIST_FILE")"
> "$MODLIST_FILE"
if [ -n "$MOD_IDS" ]; then
  IFS=',' read -ra MODS <<< "$MOD_IDS"
  for mod_id in "${MODS[@]}"; do
    mod_id=$(echo "$mod_id" | xargs)
    if [ -n "$mod_id" ]; then
      echo "*$mod_id.pak" >> "$MODLIST_FILE"
    fi
  done
  echo "Modlist created with $(wc -l < "$MODLIST_FILE") mods"
fi

# Start server with Wine
xvfb-run --auto-servernum --server-args='-screen 0 640x480x24:32' \
  wine "$SERVER_DIR/ConanSandboxServer.exe" \
  ${MAP}?listen \
  -Port=${GAME_PORT} \
  -QueryPort=${QUERY_PORT} \
  -MaxPlayers=${MAX_PLAYERS} \
  -log
