[DEFAULT]
debug = {{.Values.keystone.default.debug | default "false"}}

[database]
connection = {{.Values.keystone.database.connection}}

[token]
provider = {{.Values.keystone.token.provider}}
