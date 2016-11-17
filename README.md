# Hc

Hc fuses together a REPL an http client and a profile to let you navigate APIs more simply.

Starts `hc` by providing a configuration file.

Here's a simple configuration file:

    name: "omise"

    default_env: "api"

    environments:

      api:
        url: https://api.omise.co/
        user: skey_test_xxxxxxxxxxxxxxxxxxx

      vault:
        url: https://vault.omise.co/
        user: pkey_test_xxxxxxxxxxxxxxxxxxx
  
    store:

      :card: >-
        card[name]=Robin Clart
        card[number]=4242424242424242
        card[expiration_year]=2017
        card[expiration_month]=12
        card[security_code]=123

    plays:

      post_token:
        - 'use vault'
        - 'post /tokens %{card}'
        - 'store token_id id'

      post_charge:
        - 'play create_token'
        - 'use api'
        - 'post /charges amount=100000 currency=thb card=%{token_id}'
        - 'store charge_id id'

# Options

`name` defines the name shown in the prompt.

`default_env` select the default environment with which hc starts.

`environments` list the different urls, as well as the username and password
that will be used in the Authorization header when making requests.

`store` provide a way to store data that will be interpolated with the command
you pass.

`plays` are list of commands that you can run sequentially. You can even nest plays into other plays.

# Commands

`use ENV_NAME` will switch from one env to another one.

`get PATH` make a GET request.

`post PATH [PARAMS...]` make a POST request with the provided params.

`patch PATH [PARAMS...]` make a PATCH request with the provided params.

`delete PATH` make a DELETE request.

`plays` list all plays.

`play PLAY_NAME` run a play.

`store NAME ATTRIBUTE` store into NAME the value from the ATTRIBUTE found in the latest response.

`fetch NAME` fetch value from NAME.
