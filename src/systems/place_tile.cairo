#[system]
mod place_tile {
    use array::ArrayTrait;
    use box::BoxTrait;
    use traits::{Into, TryInto};
    use option::OptionTrait;
    use dojo::world::Context;

    use carc::components::game::{GameTile, Ownership};
    use carc::components::tile::Orientation;

    fn execute(
        ctx: Context, game_id: u64, tile_id: u64, orientation: Orientation, x: u32, y: u32
    ) { //TODO: Check ownership + game open
    // check location has no tile
    // check location can be placed - has adjacent tile, adjacent tile/s edge matches

    // place tile

    // set!(ctx.world, (game_tile));
    }
}
