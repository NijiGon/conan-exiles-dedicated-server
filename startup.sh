#!/bin/bash

PUID=${PUID:-911}
PGID=${PGID:-911}

groupmod -o -g "$PGID" steam
usermod -o -u "$PUID" steam

echo "
-------------------------------------
GID/UID
-------------------------------------
User uid:    $(id -u steam)
User gid:    $(id -g steam)
-------------------------------------
"
chown steam:steam -R /home/steam
echo "
-------------------------------------
Generating ServerSettings.ini
-------------------------------------
"
mkdir -p ${STEAMAPPDIR}/ConanSandbox/Saved/Config/WindowsServer

cat > ${STEAMAPPDIR}/ConanSandbox/Saved/Config/WindowsServer/ServerSettings.ini << EOF
[ServerSettings]
PVPEnabled=${PVP_ENABLED:-False}
AdminPassword=${ADMIN_PASSWORD:-ChangeMe}
NPCMindReadingMode=${NPC_MIND_READING_MODE:-0}
MaxNudity=${MAX_NUDITY:-2}
ServerCommunity=${SERVER_COMMUNITY:-0}
ConfigVersion=${CONFIG_VERSION:-3}
BlueprintConfigVersion=${BLUEPRINT_CONFIG_VERSION:-14}
PlayerKnockbackMultiplier=${PLAYER_KNOCKBACK_MULTIPLIER:-1.000000}
NPCKnockbackMultiplier=${NPC_KNOCKBACK_MULTIPLIER:-1.000000}
StructureDamageMultiplier=${STRUCTURE_DAMAGE_MULTIPLIER:-1.000000}
StructureDamageTakenMultiplier=${STRUCTURE_DAMAGE_TAKEN_MULTIPLIER:-1.000000}
StructureHealthMultiplier=${STRUCTURE_HEALTH_MULTIPLIER:-1.000000}
NPCRespawnMultiplier=${NPC_RESPAWN_MULTIPLIER:-1.000000}
NPCHealthMultiplier=${NPC_HEALTH_MULTIPLIER:-1.000000}
CraftingCostMultiplier=${CRAFTING_COST_MULTIPLIER:-1.000000}
PlayerDamageMultiplier=${PLAYER_DAMAGE_MULTIPLIER:-1.000000}
PlayerDamageTakenMultiplier=${PLAYER_DAMAGE_TAKEN_MULTIPLIER:-1.000000}
MinionDamageMultiplier=${MINION_DAMAGE_MULTIPLIER:-1.000000}
MinionDamageTakenMultiplier=${MINION_DAMAGE_TAKEN_MULTIPLIER:-1.000000}
NPCDamageMultiplier=${NPC_DAMAGE_MULTIPLIER:-1.000000}
NPCDamageTakenMultiplier=${NPC_DAMAGE_TAKEN_MULTIPLIER:-1.000000}
PlayerEncumbranceMultiplier=${PLAYER_ENCUMBRANCE_MULTIPLIER:-1.000000}
PlayerEncumbrancePenaltyMultiplier=${PLAYER_ENCUMBRANCE_PENALTY_MULTIPLIER:-1.000000}
PlayerMovementSpeedScale=${PLAYER_MOVEMENT_SPEED_SCALE:-1.000000}
PlayerStaminaCostSprintMultiplier=${PLAYER_STAMINA_COST_SPRINT_MULTIPLIER:-1.000000}
PlayerSprintSpeedScale=${PLAYER_SPRINT_SPEED_SCALE:-1.000000}
PlayerStaminaCostMultiplier=${PLAYER_STAMINA_COST_MULTIPLIER:-1.000000}
PlayerHealthRegenSpeedScale=${PLAYER_HEALTH_REGEN_SPEED_SCALE:-1.000000}
PlayerStaminaRegenSpeedScale=${PLAYER_STAMINA_REGEN_SPEED_SCALE:-1.000000}
PlayerXPRateMultiplier=${PLAYER_XP_RATE_MULTIPLIER:-1.000000}
PlayerXPKillMultiplier=${PLAYER_XP_KILL_MULTIPLIER:-1.000000}
PlayerXPHarvestMultiplier=${PLAYER_XP_HARVEST_MULTIPLIER:-1.000000}
PlayerXPCraftMultiplier=${PLAYER_XP_CRAFT_MULTIPLIER:-1.000000}
PlayerXPTimeMultiplier=${PLAYER_XP_TIME_MULTIPLIER:-1.000000}
DogsOfTheDesertSpawnWithDogs=${DOGS_OF_THE_DESERT_SPAWN_WITH_DOGS:-False}
CrossDesertOnce=${CROSS_DESERT_ONCE:-True}
WeaponEffectBoundsShorteningFraction=${WEAPON_EFFECT_BOUNDS_SHORTENING_FRACTION:-0.200000}
EnforceRotationRateWhenRoaming_2=${ENFORCE_ROTATION_RATE_WHEN_ROAMING_2:-True}
EnforceRotationRateInCombat_2=${ENFORCE_ROTATION_RATE_IN_COMBAT_2:-True}
ClipVelocityOnNavmeshBoundary=${CLIP_VELOCITY_ON_NAVMESH_BOUNDARY:-True}
UnarmedNPCStepBackDistance=${UNARMED_NPC_STEP_BACK_DISTANCE:-400.000000}
PathFollowingAvoidanceMode=${PATH_FOLLOWING_AVOIDANCE_MODE:-257}
RotateToTargetSendsAngularVelocity=${ROTATE_TO_TARGET_SENDS_ANGULAR_VELOCITY:-True}
TargetPredictionMaxSeconds=${TARGET_PREDICTION_MAX_SECONDS:-1.000000}
TargetPredictionAllowSecondsForAttack=${TARGET_PREDICTION_ALLOW_SECONDS_FOR_ATTACK:-0.400000}
MaxAggroRange=${MAX_AGGRO_RANGE:-9000.000000}
serverRegion=${SERVER_REGION:-256}
LandClaimRadiusMultiplier=${LAND_CLAIM_RADIUS_MULTIPLIER:-1.000000}
ItemConvertionMultiplier=${ITEM_CONVERTION_MULTIPLIER:-1.000000}
PathFollowingSendsAngularVelocity=${PATH_FOLLOWING_SENDS_ANGULAR_VELOCITY:-False}
UnconsciousTimeSeconds=${UNCONSCIOUS_TIME_SECONDS:-600.000000}
ConciousnessDamageMultiplier=${CONCIOUSNESS_DAMAGE_MULTIPLIER:-1.000000}
ValidatePhysNavWalkWithRaycast=${VALIDATE_PHYS_NAV_WALK_WITH_RAYCAST:-True}
LocalNavMeshVisualizationFrequency=${LOCAL_NAV_MESH_VISUALIZATION_FREQUENCY:--1.000000}
UseLocalQuadraticAngularVelocityPrediction=${USE_LOCAL_QUADRATIC_ANGULAR_VELOCITY_PREDICTION:-True}
AvatarsDisabled=${AVATARS_DISABLED:-False}
AvatarLifetime=${AVATAR_LIFETIME:-60.000000}
AvatarSummonTime=${AVATAR_SUMMON_TIME:-20.000000}
IsBattlEyeEnabled=${IS_BATTLEYE_ENABLED:-False}
RegionAllowAfrica=${REGION_ALLOW_AFRICA:-True}
RegionAllowAsia=${REGION_ALLOW_ASIA:-True}
RegionAllowCentralEurope=${REGION_ALLOW_CENTRAL_EUROPE:-True}
RegionAllowEasternEurope=${REGION_ALLOW_EASTERN_EUROPE:-True}
RegionAllowWesternEurope=${REGION_ALLOW_WESTERN_EUROPE:-True}
RegionAllowNorthAmerica=${REGION_ALLOW_NORTH_AMERICA:-True}
RegionAllowOceania=${REGION_ALLOW_OCEANIA:-True}
RegionAllowSouthAmerica=${REGION_ALLOW_SOUTH_AMERICA:-True}
RegionBlockList=${REGION_BLOCK_LIST:-}
bCanBeDamaged=${B_CAN_BE_DAMAGED:-True}
CanDamagePlayerOwnedStructures=${CAN_DAMAGE_PLAYER_OWNED_STRUCTURES:-False}
EnableSandStorm=${ENABLE_SAND_STORM:-True}
ClanMaxSize=${CLAN_MAX_SIZE:-22}
HarvestAmountMultiplier=${HARVEST_AMOUNT_MULTIPLIER:-1}
ResourceRespawnSpeedMultiplier=${RESOURCE_RESPAWN_SPEED_MULTIPLIER:-1}
EverybodyCanLootCorpse=${EVERYBODY_CAN_LOOT_CORPSE:-False}
NetServerMaxTickRate=30
ServerName=${SERVER_NAME:-Conan Exiles Server}
ServerPassword=${SERVER_PASSWORD:-}
ServerRegion=${SERVER_REGION:-256}
ServerIsInLobby=${SERVER_IS_IN_LOBBY:-True}
ServerVACEnabled=${SERVER_VAC_ENABLED:-False}
ServerBattlEyeRequired=${SERVER_BATTLEYE_REQUIRED:-False}
EOF

echo "
-------------------------------------
Updating application
-------------------------------------
"
set -x
su steam -c "${STEAMCMDDIR}/steamcmd.sh +@sSteamCmdForcePlatformType windows +force_install_dir ${STEAMAPPDIR} +login anonymous +app_update ${STEAMAPPID} validate +quit"

echo "
------------------------------------
Updating mods
------------------------------------
"
STEAMSERVERID=440900
GAMEMODDIR=${STEAMAPPDIR}/ConanSandbox/Mods
GAMEMODLIST=${GAMEMODDIR}/modlist.txt

# Generate modlist from environment variable or use existing file
if [ ! -z "$CONAN_MODS" ]; then
    echo "Using mods from CONAN_MODS environment variable"
    echo "$CONAN_MODS" | tr ',' '\n' > ${STEAMAPPDIR}/modlist.txt
else
    echo "No CONAN_MODS set, creating empty modlist"
    echo "" > ${STEAMAPPDIR}/modlist.txt
fi

# Clear server modlist so we don't end up with duplicates
echo "" > ${GAMEMODLIST}
MODS=$(awk '{print $1}' ${STEAMAPPDIR}/modlist.txt)

MODCMD="${STEAMCMDDIR}/steamcmd.sh +@sSteamCmdForcePlatformType windows +login anonymous"
for MODID in ${MODS}
do
    echo "Adding $MODID to update list..."
    MODCMD="${MODCMD}  +workshop_download_item ${STEAMSERVERID} ${MODID}"
done
MODCMD="${MODCMD} +quit"
su steam -c "${MODCMD}"

echo "Linking mods..."
mkdir -p ${GAMEMODDIR}
for MODID in ${MODS}
do
    echo "Linking $MODID..."
    MODDIR=/home/steam/Steam/steamapps/workshop/content/${STEAMSERVERID}/${MODID}/
    find "${MODDIR}" -iname '*.pak' >> ${GAMEMODLIST}
done

echo "
-------------------------------------
Starting server
-------------------------------------
"
su steam -c  "xvfb-run --auto-servernum wine ${STEAMAPPDIR}/ConanSandboxServer.exe ${CONAN_ARGS:--log}"
