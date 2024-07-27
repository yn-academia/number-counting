# Ruby Server Implementation

The ruby server is implemented using the [EventMachine](https://github.com/eventmachine/eventmachine) ruby gem.

## Implementation Details

We provided a `BootsCats::Server` class based on the `EventMachine` examples, that is capable of creating multiple connections and handling the data received from the clients.

The `BootsCats::Server::Connection` class represents a single connection, and maintains a pointer to both the player associated with this connection, and the game instance itself.
