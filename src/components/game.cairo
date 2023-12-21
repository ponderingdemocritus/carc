// Game tiles are created within games, and are based off the 
// tile components. You can't place a tile in a game, unless it already exists in the game.

use carc::components::tile::{Orientation, Tiles, TileType};
use starknet::ContractAddress;
use debug::PrintTrait;

#[derive(Component, Copy, Drop, Serde)]
struct Game {
    #[key]
    game_id: u64,
    count: u64,
}

// we hash the game_id and the coords so we can quickly find the tile type
#[derive(Component, Copy, Drop, Serde)]
struct PositionCache {
    #[key]
    game_id: u64,
    #[key]
    x: u64,
    #[key]
    y: u64,
    tile_id: u64,
}

// we also store the raw position data, so we can quickly find the tile type
// TODO: This might be redundant
#[derive(Component, Copy, Drop, Serde)]
struct Position {
    #[key]
    game_id: u64,
    #[key]
    tile_id: u64,
    x: u64,
    y: u64,
}

// when a tile is created in a game it is given a unique id
#[derive(Component, Copy, Drop, Serde)]
struct GameTile {
    #[key]
    game_id: u64,
    #[key]
    tile_id: u64, // uuid of tile within game
    tile_type: TileType,
    placed: bool,
    orientation: Orientation,
}

// #[generate_trait]
// impl GameTileImpl of GameTileTrait {
//     fn into_library(self: GameTile, x: u32, y: u32) -> Tiles {
//         Tiles { tile_type: self.tile_type, north_facing_edge: self.orientation, x, y }
//     }

//     fn check_placement(self: GameTile, neighbor: GameTile) {
//         let tile = self.into_library(0, 0);
//     // let neighbor_tile = neighbor.into_library(0, 0);
//     }
// }

#[derive(Component, Copy, Drop, Serde)]
struct Ownership {
    #[key]
    game_id: u64,
    #[key]
    tile_id: u64,
    owner: ContractAddress,
}


// for the game with orders
#[derive(Component, Copy, Drop, Serde)]
struct Order {
    #[key]
    game_id: u64,
    #[key]
    tile_id: u64,
    order_id: u64
}
