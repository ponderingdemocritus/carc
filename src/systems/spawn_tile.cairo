// creates game_tile which can then be placed
#[system]
mod spawn_tiles {
    use array::ArrayTrait;
    use box::BoxTrait;
    use traits::{Into, TryInto};
    use option::OptionTrait;
    use dojo::world::Context;

    use carc::components::game::{GameTile, Ownership};
    use carc::components::tile::{Orientation, TileType};

    fn execute(ctx: Context, game_id: u64) {
        let tile_id: u64 = ctx.world.uuid().into();

        // create game tile
        let game_tile = GameTile {
            game_id, tile_id, tile_type: TileType::a, placed: false, orientation: Orientation::north
        };

        let ownership = Ownership { game_id, tile_id, owner: ctx.origin.into() };
        set!(ctx.world, (game_tile));
    }
}
