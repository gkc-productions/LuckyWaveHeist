return {
    -- Wave Configuration
    MAX_WAVES = 3,
    WAVES = {
        { number = 1, duration = 60, enemyCount = 5 },
        { number = 2, duration = 75, enemyCount = 8 },
        { number = 3, duration = 90, enemyCount = 12 },
    },
    
    -- Lobby Settings
    MIN_PLAYERS = 1,
    LOBBY_TIMEOUT = 30,
    
    -- State Durations (seconds)
    WAVE_START_DURATION = 5,
    WAVE_END_DURATION = 3,
    VICTORY_DURATION = 5,
    DEFEAT_DURATION = 3,
    
    -- Teams
    TEAMS = {
        { name = "Heist Team", color = BrickColor.new("Cyan") }
    },
    
    -- Spawn Points
    SPAWN_LOCATION_PREFIX = "Spawn"
}
