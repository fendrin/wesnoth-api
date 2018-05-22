# Wesnoth API
This api is the core of the game server.
It is not meant to be used directly by the UMC Designer.

Currently all functions are located in a single table.


## Documentation

The library uses the ldoc tool to allow the autogeneration of the API reference.

On a debian/ubuntu linux system:
```bash
sudo apt-get  install luarocks
sudo luarocks install ldoc
ldoc
```

## Unit Tests

The busted unit test framework can be used to run the test suite on the module.

luarocks can be used to install busted into your lua environment.

On a debian/ubuntu linux system:
```bash
sudo apt-get  install luarocks
sudo luarocks install busted
sudo luarocks install moonscript
busted
```
