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

# Engine.ini
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

# Game.ini
cat > "$CONF_DIR/Game.ini" <<EOF
[/Script/Engine.GameSession]
MaxPlayers=${MAX_PLAYERS}

[RconPlugin]
RconEnabled=${RCON_ENABLED}
RconPassword=${RCON_PASSWORD}
RconPort=${RCON_PORT}
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
