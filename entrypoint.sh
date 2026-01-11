#!/bin/bash
set -e

STEAMCMDDIR=/opt/steamcmd
SERVER_DIR=/opt/conan
CONF_DIR="$SERVER_DIR/ConanSandbox/Saved/Config/WindowsServer"
MOD_DIR="$SERVER_DIR/ConanSandbox/Mods"

# Helper to run SteamCMD commands
run_steamcmd() {
    $STEAMCMDDIR/steamcmd.sh +force_install_dir "$SERVER_DIR" +login anonymous "$@" +quit
}

# Always install/update server
echo "Installing/updating Conan Exiles server..."
run_steamcmd "+@sSteamCmdForcePlatformType windows" "+app_update $STEAMAPPID validate"

# Prepare mod list from MOD_IDS
IFS=',' read -ra MODS <<< "$MOD_IDS"
for i in "${!MODS[@]}"; do
    MODS[$i]="${MODS[$i]// /}"  # trim spaces
done

mkdir -p "$MOD_DIR"

# Remove unlisted mods in Mods folder
for existing_mod in "$MOD_DIR"/*.pak; do
    [ ! -f "$existing_mod" ] && continue
    mod_file=$(basename "$existing_mod")
    mod_id="${mod_file%.pak}"
    if [[ ! " ${MODS[*]} " =~ " $mod_id " ]]; then
        echo "Removing unlisted mod: $mod_id"
        rm -f "$existing_mod"
    fi
done

# Download mods in parallel with caching
if [ ${#MODS[@]} -gt 0 ]; then
    echo "Installing/updating mods..."
    for mod_id in "${MODS[@]}"; do
        [ -z "$mod_id" ] && continue

        WORKSHOP_DIR="$SERVER_DIR/steamapps/workshop/content/440900/$mod_id"
        WORKSHOP_PAK=$(find "$WORKSHOP_DIR" -name "*.pak" -type f | head -1)
        MOD_PAK="$MOD_DIR/$mod_id.pak"

        # Skip download if .pak exists in MOD_DIR (cached)
        if [ -f "$MOD_PAK" ]; then
            echo "Mod $mod_id already exists, skipping download"
            continue
        fi

        # Download in background if not cached
        (
            echo "Downloading mod: $mod_id"
            run_steamcmd "+@sSteamCmdForcePlatformType windows" \
                         "+workshop_download_item 440900 $mod_id validate"
        ) &
    done
    wait
    echo "All mods downloaded."
fi

# Convert existing duplicates to symlinks
for mod_id in "${MODS[@]}"; do
    [ -z "$mod_id" ] && continue

    WORKSHOP_DIR="$SERVER_DIR/steamapps/workshop/content/440900/$mod_id"
    WORKSHOP_PAK=$(find "$WORKSHOP_DIR" -name "*.pak" -type f | head -1)
    MOD_PAK="$MOD_DIR/$mod_id.pak"

    if [ -f "$WORKSHOP_PAK" ]; then
        if [ -f "$MOD_PAK" ]; then
            # Remove copy and create symlink
            rm -f "$MOD_PAK"
        fi
        ln -sf "$WORKSHOP_PAK" "$MOD_PAK"
        echo "Linked $mod_id.pak -> Workshop folder"
    fi
done

# Config folders
mkdir -p "$CONF_DIR"

# Generate ServerSettings.ini
cat > "$CONF_DIR/ServerSettings.ini" <<EOF
[ServerSettings]
ServerName=${SERVER_NAME:-ConanServer}
ServerPassword=${SERVER_PASSWORD:-}
AdminPassword=${ADMIN_PASSWORD:-admin}
ServerMessageOfTheDay=${SERVER_MOTD:-Welcome to the server}
ServerRegion=${SERVER_REGION:-1}

MaxPlayers=${MAX_PLAYERS:-40}
MaxNudity=${MAX_NUDITY:-2}

PVPEnabled=${PVP_ENABLED:-False}
RestrictPVPTime=${RESTRICT_PVP_TIME:-False}
PVPTimeRestrictionStart=${PVP_TIME_START:-0}
PVPTimeRestrictionEnd=${PVP_TIME_END:-2359}

RestrictPVPBuildingDamageTime=${RESTRICT_PVP_BUILDING:-False}
PVPBuildingDamageTimeRestrictionStart=${PVP_BUILDING_START:-0}
PVPBuildingDamageTimeRestrictionEnd=${PVP_BUILDING_END:-2359}

DayCycleSpeedScale=${DAY_CYCLE_SCALE:-1.0}
DayTimeSpeedScale=${DAY_TIME_SCALE:-1.0}
NightTimeSpeedScale=${NIGHT_TIME_SCALE:-1.0}
DawnDuskSpeedScale=${DAWN_DUSK_SPEED_SCALE:-1.0}

PlayerXPRateMultiplier=${PLAYER_XP_RATE:-1.0}
PlayerXPKillMultiplier=${PLAYER_XP_KILL:-1.0}
PlayerXPHarvestMultiplier=${PLAYER_XP_HARVEST:-1.0}
PlayerXPCraftMultiplier=${PLAYER_XP_CRAFT:-1.0}

HarvestAmountMultiplier=${HARVEST_AMOUNT:-1.0}
ResourceRespawnSpeedMultiplier=${RESOURCE_RESPAWN:-1.0}

CraftingCostMultiplier=${CRAFT_COST:-1.0}
CraftingTimeMultiplier=${CRAFT_TIME:-1.0}

PlayerDamageMultiplier=${PLAYER_DAMAGE:-1.0}
PlayerDamageTakenMultiplier=${PLAYER_DAMAGE_TAKEN:-1.0}
PlayerHealthMultiplier=${PLAYER_HEALTH:-1.0}
PlayerStaminaMultiplier=${PLAYER_STAMINA:-1.0}

StructureDamageMultiplier=${STRUCTURE_DAMAGE:-1.0}
StructureDamageTakenMultiplier=${STRUCTURE_DAMAGE_TAKEN:-1.0}
StructureHealthMultiplier=${STRUCTURE_HEALTH:-1.0}

NPCRespawnMultiplier=${NPC_RESPAWN:-1.0}
NPCHealthMultiplier=${NPC_HEALTH:-1.0}

PlayerEncumbranceMultiplier=${PLAYER_ENCUMBRANCE:-1.0}
PlayerEncumbrancePenaltyMultiplier=${PLAYER_ENCUMBRANCE_PENALTY:-1.0}

PlayerIdleThirstMultiplier=${PLAYER_IDLE_THIRST:-1.0}
PlayerActiveThirstMultiplier=${PLAYER_ACTIVE_THIRST:-1.0}
PlayerOfflineThirstMultiplier=${PLAYER_OFFLINE_THIRST:-1.0}

PlayerIdleHungerMultiplier=${PLAYER_IDLE_HUNGER:-1.0}
PlayerActiveHungerMultiplier=${PLAYER_ACTIVE_HUNGER:-1.0}
PlayerOfflineHungerMultiplier=${PLAYER_OFFLINE_HUNGER:-1.0}

ItemSpoilRateScale=${ITEM_SPOIL_RATE:-1.0}
ShieldDurabilityMultiplier=${SHIELD_DURABILITY:-1.0}

DropLootOnDeath=${DROP_LOOT:-0}
DropEquipmentOnDeath=${DROP_EQUIPMENT:-0}
DropBackpackOnDeath=${DROP_BACKPACK:-0}
EverybodyCanLootCorpse=${EVERYBODY_LOOT:-False}

ChatHasGlobal=${CHAT_GLOBAL:-True}
ChatLocalRadius=${CHAT_LOCAL_RADIUS:-1000}

EveryoneCanCheat=${EVERYONE_CAN_CHEAT:-False}
LogoutCharactersRemainInTheWorld=${LOGOUT_REMAINS:-True}

NoOwnership=${NO_OWNERSHIP:-False}
CanDamagePlayerOwnedStructures=${CAN_DAMAGE_OWN_STRUCTURES:-False}

BlueprintConfigVersion=${BLUEPRINT_CONFIG_VERSION:-1}
ConfigVersion=${CONFIG_VERSION:-1}
NPCMindReadingMode=${NPC_MIND_READING:-False}

MinionDamageMultiplier=${MINION_DAMAGE:-1.0}
MinionDamageTakenMultiplier=${MINION_DAMAGE_TAKEN:-1.0}
PlayerKnockbackMultiplier=${PLAYER_KNOCKBACK:-1.0}
NPCKnockbackMultiplier=${NPC_KNOCKBACK:-1.0}
EOF

# Engine.ini
cat > "$CONF_DIR/Engine.ini" <<EOF
[OnlineSubsystem]
ServerName=${SERVER_NAME:-ConanServer}
ServerPassword=${SERVER_PASSWORD:-}

[/Script/Engine.GameSession]
MaxPlayers=${MAX_PLAYERS:-40}

[/Script/OnlineSubsystemUtils.IpNetDriver]
MaxClientRate=${MAX_CLIENT_RATE:-150000}
MaxInternetClientRate=${MAX_INTERNET_CLIENT_RATE:-150000}
NetServerMaxTickRate=${TICK_RATE:-30}
LanServerMaxTickRate=${TICK_RATE:-30}
EOF

# Game.ini
cat > "$CONF_DIR/Game.ini" <<EOF
[/Script/Engine.GameSession]
MaxPlayers=${MAX_PLAYERS:-40}

[RconPlugin]
RconEnabled=${RCON_ENABLED:-0}
RconPassword=${RCON_PASSWORD:-}
RconPort=${RCON_PORT:-27020}
EOF

# Generate modlist.txt
> "$MOD_DIR/modlist.txt"
for mod_id in "${MODS[@]}"; do
    [ -z "$mod_id" ] && continue
    echo "*$mod_id.pak" >> "$MOD_DIR/modlist.txt"
done
echo "Modlist created with $(wc -l < "$MOD_DIR/modlist.txt") mods"

# Start server
xvfb-run --auto-servernum --server-args='-screen 0 640x480x24:32' \
    wine "$SERVER_DIR/ConanSandboxServer.exe" \
    ${MAP}?listen \
    -Port=${GAME_PORT} \
    -QueryPort=${QUERY_PORT} \
    -MaxPlayers=${MAX_PLAYERS} \
    -log
