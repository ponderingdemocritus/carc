use carc::constants::{TileConstants::{Edges::{CITY, FARM, ROAD}}};
use debug::PrintTrait;
use traits::{Into, TryInto};
use option::OptionTrait;
use box::BoxTrait;
use core::result::ResultTrait;

#[derive(Clone, Copy, Drop)]
struct Tiles {
    tile_type: TileType,
    north_facing_edge: Orientation,
    x: i32,
    y: i32
}

#[derive(Copy, Drop, Serde, PartialEq)]
enum Orientation {
    north,
    east,
    south,
    west
}

impl IntoFelt252Orientation of Into<Orientation, u32> {
    fn into(self: Orientation) -> u32 {
        match self {
            Orientation::north => 0,
            Orientation::east => 1,
            Orientation::south => 2,
            Orientation::west => 3,
        }
    }
}

impl TryIntoOrientationFelt252 of TryInto<felt252, Orientation> {
    fn try_into(self: felt252) -> Option<Orientation> {
        if self == 0 {
            Option::Some(Orientation::north)
        } else if self == 1 {
            Option::Some(Orientation::east)
        } else if self == 2 {
            Option::Some(Orientation::south)
        } else if self == 3 {
            Option::Some(Orientation::west)
        } else {
            Option::None
        }
    }
}

impl OrientationStorageSize of dojo::StorageSize<Orientation> {
    #[inline(always)]
    fn unpacked_size() -> usize {
        1
    }

    #[inline(always)]
    fn packed_size() -> usize {
        252
    }
}

impl OrientationPrint of PrintTrait<Orientation> {
    fn print(self: Orientation) {
        let felt: u32 = self.into();
        felt.print();
    }
}


#[derive(Copy, Drop, Serde)]
enum TileType {
    a,
    b,
    c,
    d,
    e
}

impl IntoFelt252TileType of Into<TileType, felt252> {
    fn into(self: TileType) -> felt252 {
        match self {
            TileType::a => 'a',
            TileType::b => 'b',
            TileType::c => 'c',
            TileType::d => 'd',
            TileType::e => 'e',
        }
    }
}

impl TryIntoTileTypeFelt252 of TryInto<felt252, TileType> {
    fn try_into(self: felt252) -> Option<TileType> {
        if self == 'a' {
            Option::Some(TileType::a)
        } else if self == 'b' {
            Option::Some(TileType::b)
        } else if self == 'c' {
            Option::Some(TileType::c)
        } else if self == 'd' {
            Option::Some(TileType::d)
        } else if self == 'e' {
            Option::Some(TileType::e)
        } else {
            Option::None
        }
    }
}

impl TileTypeStorageSize of dojo::StorageSize<TileType> {
    #[inline(always)]
    fn unpacked_size() -> usize {
        1
    }

    #[inline(always)]
    fn packed_size() -> usize {
        252
    }
}

impl TileTypePrint of PrintTrait<TileType> {
    fn print(self: TileType) {
        let felt: felt252 = self.into();
        felt.print();
    }
}

#[derive(Copy, Drop, Serde)]
struct Tile {
    north: Edge,
    south: Edge,
    east: Edge,
    west: Edge
}

#[derive(Copy, Drop, Serde)]
struct Edge {
    a: u32,
    b: u32,
    c: u32
}

#[generate_trait]
impl TilesImpl of TilesTrait {
    fn get_tile_type(self: Tiles) -> Tile {
        // just for testing
        let test_tile = Tile {
            north: Edge { a: CITY, b: FARM, c: ROAD },
            south: Edge { a: CITY, b: FARM, c: ROAD },
            east: Edge { a: CITY, b: FARM, c: ROAD },
            west: Edge { a: CITY, b: FARM, c: ROAD }
        };
        match self.tile_type {
            TileType::a => Tile {
                north: Edge { a: CITY, b: FARM, c: ROAD },
                south: Edge { a: CITY, b: FARM, c: ROAD },
                east: Edge { a: CITY, b: FARM, c: ROAD },
                west: Edge { a: CITY, b: FARM, c: ROAD }
            },
            TileType::b => Tile {
                north: Edge { a: FARM, b: FARM, c: FARM },
                south: Edge { a: FARM, b: FARM, c: FARM },
                east: Edge { a: CITY, b: FARM, c: ROAD },
                west: Edge { a: CITY, b: FARM, c: ROAD }
            },
            TileType::c => Tile {
                north: Edge { a: CITY, b: ROAD, c: FARM },
                south: Edge { a: CITY, b: FARM, c: ROAD },
                east: Edge { a: FARM, b: ROAD, c: ROAD },
                west: Edge { a: CITY, b: FARM, c: FARM }
            },
            TileType::d => test_tile,
            TileType::e => test_tile
        }
    }
    fn eq(current_edge: Edge, placing_edge: Edge) -> bool {
        current_edge.a == placing_edge.a
            && current_edge.b == placing_edge.b
            && current_edge.c == placing_edge.c
    }
    fn check_matching_edge(self: Tile, orientation: Orientation, edge: Edge) -> bool {
        TilesImpl::eq(edge, self.get_edge(orientation))
    }
    fn turn_to_north(self: Tiles) -> Tile {
        let difference: felt252 = self.orientation_difference(Orientation::north).into();

        let tile = self.get_tile_type();
        let north = tile.north;
        let east = tile.east;
        let south = tile.south;
        let west = tile.west;

        let orientation: Orientation = difference.try_into().unwrap();
        match orientation {
            Orientation::north => Tile { north, east, south, west },
            Orientation::east => Tile { north: west, east: north, south: east, west: south },
            Orientation::south => Tile { north: south, east: west, south: north, west: east },
            Orientation::west => Tile { north: east, east: south, south: west, west: north },
        }
    }
    // TODO:
    fn get_edge(self: Tile, orientation: Orientation) -> Edge {
        match orientation {
            Orientation::north => self.north,
            Orientation::east => self.east,
            Orientation::south => self.south,
            Orientation::west => self.west,
        }
    }
    fn orientation_difference(self: Tiles, orientation: Orientation) -> u32 {
        let north_facing_index: u32 = self.north_facing_edge.into();
        let orientation_index: u32 = orientation.into();

        if orientation_index >= north_facing_index {
            (orientation_index - north_facing_index + 4) % 4
        } else {
            (4 + orientation_index - north_facing_index) % 4
        }
    }
    fn check_neighbor(self: Tiles, tile: Tiles) -> bool {
        let x = self.x;
        let y = self.y;
        let tile_x = tile.x;
        let tile_y = tile.y;
        (x == tile_x && y == tile_y + 1)
            || (x == tile_x && y == tile_y - 1)
            || (x == tile_x + 1 && y == tile_y)
            || (x == tile_x - 1 && y == tile_y)
    }
    fn can_place(ref self: Tiles, ref neighbor_tiles: Array<Tiles>) -> bool {
        loop {
            match neighbor_tiles.pop_front() {
                Option::Some(neighbor) => {
                    // check actual neighbor
                    assert(self.check_neighbor(neighbor), 'not neighbor');

                    // check matching edges
                    match self.determine_direction(neighbor) {
                        Option::Some(direction) => {
                            let tile_north = self.turn_to_north();
                            let neighbor = neighbor.turn_to_north();
                            match direction {
                                Orientation::north => {
                                    assert(
                                        tile_north
                                            .check_matching_edge(
                                                Orientation::north,
                                                neighbor.get_edge(Orientation::south)
                                            ),
                                        'North edge'
                                    );
                                },
                                Orientation::east => {
                                    assert(
                                        tile_north
                                            .check_matching_edge(
                                                Orientation::east,
                                                neighbor.get_edge(Orientation::west)
                                            ),
                                        'East edge'
                                    );
                                },
                                Orientation::south => {
                                    assert(
                                        tile_north
                                            .check_matching_edge(
                                                Orientation::south,
                                                neighbor.get_edge(Orientation::north)
                                            ),
                                        'South edge'
                                    );
                                },
                                Orientation::west => {
                                    assert(
                                        tile_north
                                            .check_matching_edge(
                                                Orientation::west,
                                                neighbor.get_edge(Orientation::east)
                                            ),
                                        'West edge'
                                    );
                                },
                            }
                        },
                        Option::None => {},
                    }
                },
                Option::None => {
                    break true;
                },
            };
        }
    }
    fn determine_direction(self: Tiles, neighbor: Tiles) -> Option<Orientation> {
        if neighbor.x == self.x {
            if neighbor.y == self.y + 1 {
                return Option::Some(Orientation::north);
            } else if neighbor.y == self.y - 1 {
                return Option::Some(Orientation::south);
            }
        } else if neighbor.y == self.y {
            if neighbor.x == self.x + 1 {
                return Option::Some(Orientation::east);
            } else if neighbor.x == self.x - 1 {
                return Option::Some(Orientation::west);
            }
        }
        Option::None
    }
}

// #[test]
// #[available_gas(600000000)]
// fn test_matching_edges() {
//     // Setting up a tile with all city edges
//     let tile_with_city_edges = Tiles {
//         tile_type: TileType::a, north_facing_edge: Orientation::north, x: 0, y: 0
//     };

//     // Setting up another tile with all farm edges
//     let tile_with_farm_edges = Tiles {
//         tile_type: TileType::b, north_facing_edge: Orientation::north, x: 1, y: 1
//     };

//     // city,farm,road
//     let south_edge_city = tile_with_city_edges.get_tile_type().get_edge(Orientation::south);
//     // farm,farm,farm
//     assert(
//         !tile_with_farm_edges.check_matching_edge(Orientation::north, south_edge_city),
//         'City should not match with Farm'
//     );

//     // mixed
//     let tile_mixed = Tiles {
//         tile_type: TileType::c, north_facing_edge: Orientation::north, x: 2, y: 2
//     };
//     // city,farm,road 
//     let north_edge_mixed = tile_mixed.get_tile_type().get_edge(Orientation::north);
//     // city,farm,road
//     assert(
//         tile_with_city_edges.check_matching_edge(Orientation::south, north_edge_mixed),
//         'City should match with City'
//     );

//     // city,farm,road 
//     let south_edge_mixed = tile_mixed.get_tile_type().get_edge(Orientation::south);
//     // farm,farm,farm
//     assert(
//         !tile_with_farm_edges.check_matching_edge(Orientation::north, south_edge_mixed),
//         'Farm should match with Farm'
//     );
// }

#[test]
#[available_gas(600000000)]
fn test_tile_rotation() {
    // Setting up a tile
    let tile = Tiles { tile_type: TileType::a, north_facing_edge: Orientation::north, x: 0, y: 0 };

    let west_edge = tile.get_tile_type().get_edge(Orientation::west);
    let east_edge = tile.get_tile_type().get_edge(Orientation::east);

    // Checking that west and east edges are different
    assert(TilesImpl::eq(west_edge, east_edge), 'West and East edges');
}

#[test]
#[available_gas(600000000)]
fn test_tile_neighbor() {
    // Setting up a tile
    let tile = Tiles { tile_type: TileType::c, north_facing_edge: Orientation::north, x: 0, y: 0 };

    // Setting up another tile
    let tile2 = Tiles { tile_type: TileType::c, north_facing_edge: Orientation::north, x: 0, y: 1 };

    // Checking that tile and tile2 are neighbors
    assert(tile.check_neighbor(tile2), 'Tiles are not neighbors');

    // Setting up another tile
    let tile3 = Tiles { tile_type: TileType::c, north_facing_edge: Orientation::north, x: 0, y: 2 };

    // Checking that tile and tile3 are not neighbors
    assert(!tile.check_neighbor(tile3), 'Tiles are neighbors');
}

#[test]
#[available_gas(60000000000)]
fn test_tile_placement() {
    // Setting up a tile

    // north: Edge { a: CITY, b: FARM, c: ROAD },
    // south: Edge { a: CITY, b: FARM, c: ROAD },
    // east: Edge { a: CITY, b: FARM, c: ROAD },
    // west: Edge { a: CITY, b: FARM, c: ROAD }
    let mut tile = Tiles {
        tile_type: TileType::a, north_facing_edge: Orientation::east, x: 0, y: 0
    };

    // to the north of tile
    // south facing edge = city, farm, road
    let mut tile_to_the_east = Tiles {
        tile_type: TileType::a, north_facing_edge: Orientation::north, x: 0, y: 1
    };

    // east of tile
    // north: Edge { a: FARM, b: FARM, c: FARM },
    // south: Edge { a: FARM, b: FARM, c: FARM },
    // east: Edge { a: CITY, b: FARM, c: ROAD },
    // west: Edge { a: CITY, b: FARM, c: ROAD }

    // so its the west edge = city, farm, road
    let mut tile_to_the_north = Tiles {
        tile_type: TileType::b, north_facing_edge: Orientation::north, x: 1, y: 0
    };

    // so north face of this tile is farm, farm, farm
    let mut tile_to_the_south = Tiles {
        tile_type: TileType::b, north_facing_edge: Orientation::east, x: 0, y: -1
    };

    let mut tile_to_the_west = Tiles {
        tile_type: TileType::b, north_facing_edge: Orientation::north, x: -1, y: 0
    };

    let mut array = array![
        tile_to_the_east, tile_to_the_north, tile_to_the_south, tile_to_the_west
    ];

    assert(tile.can_place(ref array), 'Tile can not be placed');
}

#[test]
#[should_panic(expected: ('North edge',))]
#[available_gas(60000000000)]
fn test_tile_placement_fail() {
    // Setting up a tile

    //    north: Edge { a: CITY, b: ROAD, c: FARM },
    //     south: Edge { a: CITY, b: FARM, c: ROAD },
    //     east: Edge { a: FARM, b: ROAD, c: ROAD },
    //     west: Edge { a: CITY, b: FARM, c: FARM }
    let mut tile = Tiles {
        tile_type: TileType::c, north_facing_edge: Orientation::south, x: 0, y: 0
    };

    //    north: Edge { a: CITY, b: ROAD, c: FARM },
    //     south: Edge { a: CITY, b: FARM, c: ROAD },
    //     east: Edge { a: FARM, b: ROAD, c: ROAD },
    //     west: Edge { a: CITY, b: FARM, c: FARM }
    let mut tile_to_the_south = Tiles {
        tile_type: TileType::c, north_facing_edge: Orientation::south, x: 0, y: 1
    };

    let mut array = array![tile_to_the_south];

    assert(tile.can_place(ref array), 'Tile can not be placed');
}
