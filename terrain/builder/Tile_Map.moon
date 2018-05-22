	/**
	 * The map of "tile" structures corresponding to the level map.
	 */
	class tilemap
	{
	public:
		/**
		 * Constructs a tilemap of dimensions x * y
		 */
		tilemap(int x, int y)
			: tiles_((x + 4) * (y + 4))
			, x_(x)
			, y_(y)
		{
			reset();
		}

		/**
		 * Returns a reference to the tile which is at the position
		 * pointed by loc. The location MUST be on the map!
		 *
		 * @param loc    The location of the tile
		 *
		 * @return		A reference to the tile at this location.
		 *
		 */
		tile& operator[](const map_location& loc);
		/**
		 * a const variant of operator[]
		 */
		const tile& operator[](const map_location& loc) const;

		/**
		 * Tests if a location is on the map.
		 *
		 * @param loc   The location to test
		 *
		 * @return		true if loc is on the map, false otherwise.
		 */
		bool on_map(const map_location& loc) const;

		/**
		 * Resets the whole tile map
		 */
		void reset();

		/**
		 * Rebuilds the map to a new set of dimensions
		 */
		void reload(int x, int y);

	private:
		/** The map */
		std::vector<tile> tiles_;
		/** The x dimension of the map */
		int x_;
		/** The y dimension of the map */
		int y_;
	};


    void terrain_builder::tilemap::reset()
{
	for(std::vector<tile>::iterator it = tiles_.begin(); it != tiles_.end(); ++it)
		it->clear();
}

void terrain_builder::tilemap::reload(int x, int y)
{
	x_ = x;
	y_ = y;
	std::vector<terrain_builder::tile> new_tiles((x + 4) * (y + 4));
	tiles_.swap(new_tiles);
	reset();
}

bool terrain_builder::tilemap::on_map(const map_location& loc) const
{
	if(loc.x < -2 || loc.y < -2 || loc.x > (x_ + 1) || loc.y > (y_ + 1)) {
		return false;
	}

	return true;
}

terrain_builder::tile& terrain_builder::tilemap::operator[](const map_location& loc)
{
	assert(on_map(loc));

	return tiles_[(loc.x + 2) + (loc.y + 2) * (x_ + 4)];
}

const terrain_builder::tile& terrain_builder::tilemap::operator[](const map_location& loc) const
{
	assert(on_map(loc));

	return tiles_[(loc.x + 2) + (loc.y + 2) * (x_ + 4)];
}
